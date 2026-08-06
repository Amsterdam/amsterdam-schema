import importlib
import json
import sys
from pathlib import Path

from click.testing import CliRunner

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

create_cli = importlib.import_module("amsterdam_schema.create_cli")
create = create_cli.create


def test_create_writes_minimal_valid_dataset_json() -> None:
    runner = CliRunner()
    user_input = "\n".join(
        [
            "bag",
            "gebruik.basisinformatie@amsterdam.nl",
            "Gemeente Amsterdam",
            "BENK",
            "",
            "y",
            "y",
            "adressen",
            "n",
            "n",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["dataset"], input=f"{user_input}\n")

        assert result.exit_code == 0, result.output
        with open("datasets/bag/dataset.json") as dataset_file:
            document = json.load(dataset_file)
        with open("datasets/bag/adressen/v1.json") as table_file:
            table_document = json.load(table_file)

    assert document == {
        "type": "dataset",
        "id": "bag",
        "defaultVersion": "v1",
        "versions": {
            "v1": {
                "status": "stable",
                "version": "1.0.0",
                "enableAPI": True,
                "tables": [{"id": "adressen", "$ref": "adressen/v1"}],
            }
        },
        "creator": "Datateam Basis- en Kernregistraties",
        "authorizationGrantor": "gebruik.basisinformatie@amsterdam.nl",
        "owner": "Gemeente Amsterdam",
        "publisher": {"$ref": "publishers/BENK"},
        "auth": ["OPENBAAR"],
    }
    assert table_document == {
        "id": "adressen",
        "type": "table",
        "version": "1.0.0",
        "status": "stable",
        "schema": {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "required": ["schema", "identifier"],
            "display": "identifier",
            "identifier": "identifier",
            "properties": {
                "schema": {
                    "$ref": "https://schemas.data.amsterdam.nl/schema@v4.2.0#/definitions/schema"
                },
                "identifier": {"type": "string"},
            },
        },
    }


def test_create_writes_under_development_dataset_json() -> None:
    runner = CliRunner()
    user_input = "\n".join(
        [
            "bag",
            "gebruik.basisinformatie@amsterdam.nl",
            "Gemeente Amsterdam",
            "BENK",
            "",
            "n",
            "y",
            "adressen",
            "n",
            "n",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["dataset"], input=f"{user_input}\n")

        assert result.exit_code == 0, result.output
        with open("datasets/bag/dataset.json") as dataset_file:
            document = json.load(dataset_file)
        with open("datasets/bag/adressen/v0.json") as table_file:
            table_document = json.load(table_file)

    assert document == {
        "type": "dataset",
        "id": "bag",
        "defaultVersion": "v0",
        "versions": {
            "v0": {
                "status": "under_development",
                "version": "0.0.1",
                "enableAPI": True,
                "tables": [{"id": "adressen", "$ref": "adressen/v0"}],
            }
        },
        "creator": "Datateam Basis- en Kernregistraties",
        "authorizationGrantor": "gebruik.basisinformatie@amsterdam.nl",
        "owner": "Gemeente Amsterdam",
        "publisher": {"$ref": "publishers/BENK"},
        "auth": ["OPENBAAR"],
    }
    assert table_document == {
        "id": "adressen",
        "type": "table",
        "version": "0.0.1",
        "status": "under_development",
        "schema": {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "required": ["schema", "identifier"],
            "display": "identifier",
            "identifier": "identifier",
            "properties": {
                "schema": {
                    "$ref": "https://schemas.data.amsterdam.nl/schema@v4.2.0#/definitions/schema"
                },
                "identifier": {"type": "string"},
            },
        },
    }


def test_create_writes_table_provenance_for_unity_catalog_sync() -> None:
    runner = CliRunner()
    user_input = "\n".join(
        [
            "bag",
            "gebruik.basisinformatie@amsterdam.nl",
            "Gemeente Amsterdam",
            "BENK",
            "",
            "y",
            "y",
            "adressen",
            "y",
            "catalog.schema.table",
            "n",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["dataset"], input=f"{user_input}\n")

        assert result.exit_code == 0, result.output
        with open("datasets/bag/dataset.json") as dataset_file:
            document = json.load(dataset_file)

    assert document["versions"]["v1"]["tables"] == [
        {
            "id": "adressen",
            "$ref": "adressen/v1",
            "provenance": "uc:catalog.schema.table",
        }
    ]


def test_create_writes_minimal_valid_publisher_json() -> None:
    runner = CliRunner()
    user_input = "\n".join(
        [
            "Amsterdam Data",
            "AD",
            "12345",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["publisher"], input=f"{user_input}\n")

        assert result.exit_code == 0, result.output
        with open("publishers/AD.json") as publisher_file:
            document = json.load(publisher_file)
        with open("publishers/publishers.json") as publishers_file:
            publishers_document = json.load(publishers_file)

    assert document == {
        "type": "publisher",
        "id": "AD",
        "name": "Amsterdam Data",
        "shortname": "ad",
        "tags": {
            "costcenter": "12345",
            "team": "ad",
        },
    }
    assert publishers_document == {"AD": document}


def test_create_writes_minimal_valid_scope_json() -> None:
    runner = CliRunner()
    user_input = "\n".join(
        [
            "HR/R",
            "BENK",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["scope"], input=f"{user_input}\n")

        assert result.exit_code == 0, result.output
        with open("scopes/BENK/hr_r.json") as scope_file:
            document = json.load(scope_file)

    assert document == {
        "type": "scope",
        "id": "HR/R",
        "name": "HR/R",
        "accessPackages": {
            "nonProduction": "EM4W-DATA-schemascope-ot-scope_hr_r",
            "production": "EM4W-DATA-schemascope-p-scope_hr_r",
        },
        "owner": {"$ref": "publishers/BENK"},
    }


def test_create_dataset_rejects_unknown_publisher_choice() -> None:
    runner = CliRunner()
    user_input = "\n".join(
        [
            "bag",
            "gebruik.basisinformatie@amsterdam.nl",
            "Gemeente Amsterdam",
            "NOT_A_PUBLISHER",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["dataset"], input=f"{user_input}\n")

    assert result.exit_code != 0
    assert "Error: 'NOT_A_PUBLISHER' is not one of" in result.output
    assert "Aborted!" in result.output


def test_create_scope_rejects_unknown_owner_choice() -> None:
    runner = CliRunner()
    user_input = "\n".join(
        [
            "HR/R",
            "NOT_A_PUBLISHER",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["scope"], input=f"{user_input}\n")

    assert result.exit_code != 0
    assert "Error: 'NOT_A_PUBLISHER' is not one of" in result.output
    assert "Aborted!" in result.output
