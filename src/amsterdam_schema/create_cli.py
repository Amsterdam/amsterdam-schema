import json
from pathlib import Path
from typing import Any, cast

import click

SCHEMA_VERSION = "v4.2.0"
PUBLISHERS_DIR = Path(__file__).resolve().parents[2] / "publishers"


def _load_json(path: Path) -> dict[str, Any]:
    with path.open() as json_file:
        return cast(dict[str, Any], json.load(json_file))


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
    default: Any = None,
    choices: list[str] | None = None,
) -> Any:
    prompt_type: Any = click.Choice(choices, case_sensitive=True) if choices is not None else str

    value = click.prompt(
        label,
        type=prompt_type,
        default=_prompt_default(default),
        show_default=default is not None,
    )
    return _normalized_prompt_value(str(value), default)


def _prompt_table_refs(default_version: str) -> list[dict[str, str]]:
    tables = []
    while True:
        table_id = _prompt_value("Table id")
        table_ref = f"{table_id}/{default_version}"
        table: dict[str, str] = {"id": table_id, "$ref": table_ref}
        if click.confirm("Do you want to sync this table from Unity Catalog?", default=False):
            provenance = _prompt_value(
                "Provide the location of the table in the shape <catalog>.<schema>.<table>",
            )
            table["provenance"] = f"uc:{provenance}"
        tables.append(table)
        if not click.confirm("Add another table?", default=False):
            return tables


def _default_output_path(dataset_id: str) -> Path:
    return Path("datasets") / dataset_id / "dataset.json"


def _default_publisher_output_path(publisher_id: str) -> Path:
    return Path("publishers") / f"{publisher_id}.json"


def _scope_file_stem(scope_id: str) -> str:
    return scope_id.lower().replace("/", "_")


def _default_scope_output_path(owner: str, scope_id: str) -> Path:
    return Path("scopes") / owner / f"{_scope_file_stem(scope_id)}.json"


def _publishers_index_path(publisher_path: Path) -> Path:
    return publisher_path.parent / "publishers.json"


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


def _ensure_output_paths_do_not_exist(paths: list[Path]) -> None:
    for path in paths:
        if path.exists():
            raise click.ClickException(f"Cannot write, file exists: {path}")


def _write_publisher_index(
    publisher_path: Path, publisher_id: str, document: dict[str, Any]
) -> None:
    index_path = _publishers_index_path(publisher_path)
    publishers_index: dict[str, Any] = {}
    if index_path.exists():
        publishers_index = _load_json(index_path)
    publishers_index[publisher_id] = document
    _write_json_document(index_path, publishers_index)


def _write_table_documents(
    dataset_path: Path, tables: list[dict[str, str]], version: str, status: str
) -> None:
    for table in tables:
        table_path = dataset_path.parent / f"{table['$ref']}.json"
        _write_json_document(table_path, _minimal_table_document(table["id"], version, status))


def _dataset_output_paths(
    output_path: Path, tables: list[dict[str, str]], default_version: str
) -> list[Path]:
    return [
        output_path,
        *(output_path.parent / f"{table['id']}/{default_version}.json" for table in tables),
    ]


@click.group()  # type: ignore[misc]
def create() -> None:
    """Command line utilities for creating schema artifacts."""


@create.command("dataset")  # type: ignore[misc]
@click.option("--output", type=click.Path(path_type=Path, dir_okay=False))  # type: ignore[misc]
def create_dataset(output: Path | None) -> None:
    """Create a minimal single-version dataset.json from interactive prompts."""
    dataset_id = _prompt_value("Dataset id")
    authorization_grantor = _prompt_value("Authorization grantor")
    owner = _prompt_value("Owner", default="Gemeente Amsterdam")
    publisher = _prompt_value("Publisher", choices=_publisher_choices())
    auth = _prompt_value("Auth", default=["OPENBAAR"])
    is_ready_for_production = click.confirm("Is the dataset ready for production?", default=False)
    status, version, default_version = _production_defaults(is_ready_for_production)
    enable_api = click.confirm("Enable API?", default=True)
    tables = _prompt_table_refs(default_version)

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
    _ensure_output_paths_do_not_exist(_dataset_output_paths(output_path, tables, default_version))
    _write_json_document(output_path, document)
    _write_table_documents(output_path, tables, version, status)

    click.echo(f"Wrote {output_path}")


@create.command("publisher")  # type: ignore[misc]
@click.option("--output", type=click.Path(path_type=Path, dir_okay=False))  # type: ignore[misc]
def create_publisher(output: Path | None) -> None:
    """Create a minimal publisher schema from user prompts."""
    name = _prompt_value("Publisher name")

    publisher_id = _prompt_value("Publisher id (e.g. BENK, only uppercase letters)")
    if not publisher_id.isalpha() or not publisher_id.isupper():
        raise click.ClickException("Publisher id must contain only uppercase letters.")

    costcenter = _prompt_value("Publisher costcenter")

    document = {
        "type": "publisher",
        "id": publisher_id,
        "name": name,
        "shortname": publisher_id.lower(),
        "tags": {
            "costcenter": costcenter,
            "team": publisher_id.lower(),
        },
    }

    output_path = output or _default_publisher_output_path(publisher_id)
    _ensure_output_paths_do_not_exist([output_path])
    _write_json_document(output_path, document)
    _write_publisher_index(output_path, publisher_id, document)

    click.echo(f"Wrote {output_path}")


@create.command("scope")  # type: ignore[misc]
@click.option("--output", type=click.Path(path_type=Path, dir_okay=False))  # type: ignore[misc]
def create_scope(output: Path | None) -> None:
    """Create a minimal scope schema from user prompts."""
    scope_id = _prompt_value("Scope id")
    owner = _prompt_value("Owner", choices=_publisher_choices())
    scope_name = scope_id
    scope_slug = _scope_file_stem(scope_id)

    document = {
        "type": "scope",
        "id": scope_id,
        "name": scope_name,
        "accessPackages": {
            "nonProduction": f"EM4W-DATA-schemascope-ot-scope_{scope_slug}",
            "production": f"EM4W-DATA-schemascope-p-scope_{scope_slug}",
        },
        "owner": {"$ref": f"publishers/{owner}"},
    }

    output_path = output or _default_scope_output_path(owner, scope_id)
    _ensure_output_paths_do_not_exist([output_path])
    _write_json_document(output_path, document)

    click.echo(f"Wrote {output_path}")


def main() -> None:
    create()


if __name__ == "__main__":
    main()
