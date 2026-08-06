import json
from pathlib import Path
from typing import Any, cast
from urllib.parse import urldefrag, urljoin

import click

SCHEMA_VERSION = "v4.2.0"
SCHEMA_DIR = Path(__file__).resolve().parent / f"schema@{SCHEMA_VERSION}"
PUBLISHERS_DIR = Path(__file__).resolve().parents[2] / "publishers"
DATASET_SCHEMA_PATH = SCHEMA_DIR / "dataset.json"
SCHEMA_PATHS = (
    SCHEMA_DIR / "schema.json",
    DATASET_SCHEMA_PATH,
    SCHEMA_DIR / "table.json",
)


def _load_json(path: Path) -> dict[str, Any]:
    with path.open() as json_file:
        return cast(dict[str, Any], json.load(json_file))


def _schema_store() -> dict[str, Any]:
    store: dict[str, Any] = {}
    for schema_path in SCHEMA_PATHS:
        schema = _load_json(schema_path)
        schema_id = urldefrag(schema["$id"])[0]
        schema["__root_id__"] = schema_id
        store[schema_id] = schema
    return store


def _schema_root_id(schema: dict[str, Any]) -> str:
    root_id = schema.get("__root_id__")
    if root_id is not None:
        return cast(str, root_id)
    return urldefrag(cast(str, schema["$id"]))[0]


def _resolve_schema_ref(schema: dict[str, Any], ref: str, store: dict[str, Any]) -> dict[str, Any]:
    if ref.startswith("#"):
        target = store[_schema_root_id(schema)]
        fragment = ref.removeprefix("#")
    else:
        base_id = _schema_root_id(schema)
        target_uri = urljoin(base_id, ref)
        document_uri, fragment = urldefrag(target_uri)
        target = store[document_uri]

    if not fragment:
        return cast(dict[str, Any], target)

    resolved: Any = target
    for part in fragment.removeprefix("/").split("/"):
        resolved = resolved[part]
    if isinstance(resolved, dict):
        resolved = {**resolved, "__root_id__": _schema_root_id(target)}
        return cast(dict[str, Any], resolved)
    raise TypeError(f"Schema ref {ref!r} did not resolve to an object")


def _required_fields(schema: dict[str, Any], store: dict[str, Any]) -> dict[str, dict[str, Any]]:
    properties = {}
    for field_name, field_schema in schema.get("properties", {}).items():
        if isinstance(field_schema, dict):
            properties[field_name] = {**field_schema, "__root_id__": _schema_root_id(schema)}
        else:
            properties[field_name] = field_schema
    required = list(schema.get("required", []))

    for sub_schema in schema.get("allOf", []):
        if "$ref" not in sub_schema:
            continue
        resolved = _resolve_schema_ref(schema, sub_schema["$ref"], store)
        for field_name, field_schema in resolved.get("properties", {}).items():
            if isinstance(field_schema, dict):
                properties[field_name] = {
                    **field_schema,
                    "__root_id__": resolved.get("__root_id__", schema.get("__root_id__")),
                }
            else:
                properties[field_name] = field_schema
        for field_name in resolved.get("required", []):
            if field_name not in required:
                required.append(field_name)

    return {field_name: properties[field_name] for field_name in required}


def _promptable_schema(schema: dict[str, Any], store: dict[str, Any]) -> dict[str, Any]:
    if "$ref" in schema:
        return _promptable_schema(_resolve_schema_ref(schema, schema["$ref"], store), store)
    if "oneOf" in schema:
        first_option: dict[str, Any] | None = None
        for option in schema["oneOf"]:
            if (
                isinstance(option, dict)
                and "__root_id__" not in option
                and "__root_id__" in schema
            ):
                option = {**option, "__root_id__": schema["__root_id__"]}
            resolved_option = _promptable_schema(option, store)
            if first_option is None:
                first_option = resolved_option
            if resolved_option.get("type") == "string":
                return resolved_option
        if first_option is not None:
            return first_option
    return schema


def _publisher_choices() -> list[str]:
    return sorted(
        path.stem for path in PUBLISHERS_DIR.glob("*.json") if path.name != "publishers.json"
    )


def _publisher_name(publisher: str) -> str:
    publisher_document = _load_json(PUBLISHERS_DIR / f"{publisher}.json")
    return cast(str, publisher_document["name"])


def _prompt_default(default: Any) -> Any:
    if isinstance(default, list):
        return ",".join(str(item) for item in default)
    return default


def _normalized_prompt_value(value: str, default: Any) -> Any:
    if isinstance(default, list) and value == _prompt_default(default):
        return default
    return value


def _production_defaults(is_ready_for_production: bool) -> tuple[str, str, str]:
    if is_ready_for_production:
        return "stable", "1.0.0", "v1"
    return "under_development", "0.0.1", "v0"


def _prompt_value(
    label: str,
    schema: dict[str, Any],
    store: dict[str, Any],
    default: Any = None,
    choices: list[str] | None = None,
) -> Any:
    prompt_schema = _promptable_schema(schema, store)
    prompt_type: Any = (
        click.Choice(choices, case_sensitive=True)
        if choices is not None
        else (
            click.Choice(prompt_schema["enum"], case_sensitive=True)
            if "enum" in prompt_schema
            else str
        )
    )

    value = click.prompt(
        label,
        type=prompt_type,
        default=_prompt_default(default),
        show_default=default is not None,
    )
    return _normalized_prompt_value(str(value), default)


def _prompt_table_refs(
    store: dict[str, Any], id_schema: dict[str, Any], default_version: str
) -> list[dict[str, str]]:
    tables = []
    while True:
        table_id = _prompt_value("Table id", id_schema, store)
        table_ref = f"{table_id}/{default_version}"
        table: dict[str, str] = {"id": table_id, "$ref": table_ref}
        if click.confirm("Do you want to sync this table from Unity Catalog?", default=False):
            provenance = _prompt_value(
                "Provide the location of the table in the shape <catalog>.<schema>.<table>",
                {"type": "string"},
                store,
            )
            table["provenance"] = f"uc:{provenance}"
        tables.append(table)
        if not click.confirm("Add another table?", default=False):
            return tables


def _default_output_path(dataset_id: str) -> Path:
    return Path("datasets") / dataset_id / "dataset.json"


def _minimal_table_document(table_id: str, version: str, status: str) -> dict[str, Any]:
    return {
        "id": table_id,
        "type": "table",
        "version": version,
        "status": status,
        "schema": {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "required": ["schema", "identifier"],
            "display": "identifier",
            "identifier": "identifier",
            "properties": {
                "schema": {
                    "$ref": f"https://schemas.data.amsterdam.nl/schema@{SCHEMA_VERSION}#/"
                    "definitions/schema"
                },
                "identifier": {"type": "string"},
            },
        },
    }


def _write_json_document(path: Path, document: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as output_file:
        json.dump(document, output_file, indent=2)
        output_file.write("\n")


def _write_table_documents(
    dataset_path: Path, tables: list[dict[str, str]], version: str, status: str
) -> None:
    for table in tables:
        table_path = dataset_path.parent / f"{table['$ref']}.json"
        _write_json_document(table_path, _minimal_table_document(table["id"], version, status))


@click.group()  # type: ignore[misc]
def create() -> None:
    """Command line utilities for creating schema artifacts."""


@create.command("dataset")  # type: ignore[misc]
@click.option("--output", type=click.Path(path_type=Path, dir_okay=False))  # type: ignore[misc]
def create_dataset(output: Path | None) -> None:
    """Create a minimal single-version dataset.json from schema-backed prompts."""
    store = _schema_store()
    dataset_schema = _load_json(DATASET_SCHEMA_PATH)
    dataset_fields = _required_fields(dataset_schema, store)

    dataset_id = _prompt_value("Dataset id", dataset_fields["id"], store)
    authorization_grantor = _prompt_value(
        "Authorization grantor",
        dataset_fields["authorizationGrantor"],
        store,
    )
    owner = _prompt_value("Owner", dataset_fields["owner"], store, default="Gemeente Amsterdam")
    publisher = _prompt_value(
        "Publisher",
        dataset_fields["publisher"]["properties"]["$ref"],
        store,
        choices=_publisher_choices(),
    )
    auth = _prompt_value("Auth", dataset_fields["auth"], store, default=["OPENBAAR"])
    is_ready_for_production = click.confirm("Is the dataset ready for production?", default=False)
    status, version, default_version = _production_defaults(is_ready_for_production)
    enable_api = click.confirm("Enable API?", default=True)
    tables = _prompt_table_refs(store, dataset_fields["id"], default_version)

    document = {
        "type": "dataset",
        "id": dataset_id,
        "defaultVersion": default_version,
        "creator": _publisher_name(publisher),
        "authorizationGrantor": authorization_grantor,
        "owner": owner,
        "publisher": {"$ref": f"publishers/{publisher}"},
        "auth": auth,
        "versions": {
            default_version: {
                "status": status,
                "version": version,
                "enableAPI": enable_api,
                "tables": tables,
            }
        },
    }

    output_path = output or _default_output_path(dataset_id)
    _write_json_document(output_path, document)
    _write_table_documents(output_path, tables, version, status)

    click.echo(f"Wrote {output_path}")


def main() -> None:
    create()


if __name__ == "__main__":
    main()
