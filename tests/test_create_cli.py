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
            "Basisinformatie",
            "gebruik.basisinformatie@amsterdam.nl",
            "Gemeente Amsterdam",
            "publishers/BENK",
            "OPENBAAR",
            "1.0.0",
            "stable",
            "y",
            "adressen",
            "adressen/v1",
            "n",
        ]
    )

    with runner.isolated_filesystem():
        result = runner.invoke(create, ["dataset"], input=f"{user_input}\n")

        assert result.exit_code == 0, result.output
        with open("datasets/bag/dataset.json") as dataset_file:
            document = json.load(dataset_file)

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
        "creator": "Basisinformatie",
        "authorizationGrantor": "gebruik.basisinformatie@amsterdam.nl",
        "owner": "Gemeente Amsterdam",
        "publisher": {"$ref": "publishers/BENK"},
        "auth": "OPENBAAR",
    }
