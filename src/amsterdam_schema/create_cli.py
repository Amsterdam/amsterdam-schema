import json
from pathlib import Path
from typing import Any, cast
from urllib.parse import urldefrag, urljoin

import click
from jsonschema import Draft7Validator, FormatChecker

SCHEMA_VERSION = "v4.2.0"
SCHEMA_DIR = Path(__file__).resolve().parent / f"schema@{SCHEMA_VERSION}"
DATASET_SCHEMA_PATH = SCHEMA_DIR / "dataset.json"
DATASET_VERSION_SCHEMA_PATH = SCHEMA_DIR / "dataset-version.json"
SCHEMA_PATHS = (
    SCHEMA_DIR / "schema.json",
    DATASET_SCHEMA_PATH,
    DATASET_VERSION_SCHEMA_PATH,
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


def _validate_scalar(value: Any, schema: dict[str, Any]) -> str | None:
    validator = Draft7Validator(schema, format_checker=FormatChecker())
    errors = sorted(validator.iter_errors(value), key=lambda error: list(error.absolute_path))
    if not errors:
        return None
    return cast(str, errors[0].message)


def _prompt_value(
    label: str, schema: dict[str, Any], store: dict[str, Any], default: str | None = None
) -> str:
    prompt_schema = _promptable_schema(schema, store)
    prompt_type: Any = (
        click.Choice(prompt_schema["enum"], case_sensitive=True)
        if "enum" in prompt_schema
        else str
    )

    while True:
        value = click.prompt(
            label, type=prompt_type, default=default, show_default=default is not None
        )
        error = _validate_scalar(value, prompt_schema)
        if error is None:
            return str(value)
        click.echo(f"Invalid value for {label}: {error}", err=True)


def _prompt_table_refs(store: dict[str, Any], id_schema: dict[str, Any]) -> list[dict[str, str]]:
    tables = []
    table_ref_schema = {"type": "string", "format": "uri-reference"}
    while True:
        table_id = _prompt_value("Table id", id_schema, store)
        table_ref = _prompt_value("Table ref", table_ref_schema, store)
        tables.append({"id": table_id, "$ref": table_ref})
        if not click.confirm("Add another table?", default=False):
            return tables


def _default_output_path(dataset_id: str) -> Path:
    return Path("datasets") / dataset_id / "dataset.json"


@click.group()  # type: ignore[misc]
def create() -> None:
    """Command line utilities for creating schema artifacts."""


@create.command("dataset")  # type: ignore[misc]
@click.option("--output", type=click.Path(path_type=Path, dir_okay=False))  # type: ignore[misc]
def create_dataset(output: Path | None) -> None:
    """Create a minimal single-version dataset.json from schema-backed prompts."""
    store = _schema_store()
    dataset_schema = _load_json(DATASET_SCHEMA_PATH)
    version_schema = _load_json(DATASET_VERSION_SCHEMA_PATH)
    dataset_fields = _required_fields(dataset_schema, store)
    version_fields = _required_fields(version_schema, store)

    dataset_id = _prompt_value("Dataset id", dataset_fields["id"], store)
    creator = _prompt_value("Creator", dataset_fields["creator"], store)
    authorization_grantor = _prompt_value(
        "Authorization grantor",
        dataset_fields["authorizationGrantor"],
        store,
    )
    owner = _prompt_value("Owner", dataset_fields["owner"], store, default="Gemeente Amsterdam")
    publisher_ref = _prompt_value(
        "Publisher ref", dataset_fields["publisher"]["properties"]["$ref"], store
    )
    auth = _prompt_value("Auth", dataset_fields["auth"], store)

    version = _prompt_value("Dataset version", version_fields["version"], store)
    status = _prompt_value("Version status", version_fields["status"], store)
    enable_api = click.confirm("Enable API?", default=True)
    tables = _prompt_table_refs(store, dataset_fields["id"])

    default_version = f"v{version.split('.', maxsplit=1)[0]}"
    default_version_schema = _promptable_schema(dataset_fields["defaultVersion"], store)
    default_version_error = _validate_scalar(default_version, default_version_schema)
    if default_version_error is not None:
        raise click.ClickException(
            "Dataset version "
            f"{version!r} cannot be mapped to a valid defaultVersion: "
            f"{default_version_error}"
        )

    document = {
        "type": "dataset",
        "id": dataset_id,
        "defaultVersion": default_version,
        "creator": creator,
        "authorizationGrantor": authorization_grantor,
        "owner": owner,
        "publisher": {"$ref": publisher_ref},
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
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w") as output_file:
        json.dump(document, output_file, indent=2)
        output_file.write("\n")

    click.echo(f"Wrote {output_path}")


def main() -> None:
    create()


if __name__ == "__main__":
    main()
