import json
from io import BufferedReader
from pathlib import Path

import click


@click.command()  # type: ignore[misc]
@click.argument("dataset_in_file", type=click.File("rb"))  # type: ignore[misc]
@click.argument("dataset_out_dir", type=click.Path(path_type=Path))  # type: ignore[misc]
def main(dataset_in_file: BufferedReader, dataset_out_dir: Path) -> None:
    """Split up a single dataset json schema file into separate files.

    DATASET_IN_PATH: Path to dataset.json that needs to be split up in tables.
    DATASET_OUT_DIR: Path where output files need to be placed.
    """
    dataset = json.load(dataset_in_file)

    new_tables = []
    for table in dataset["tables"]:
        version = table["version"]
        table_id = table["id"]
        ref = f"{table_id}/v{version}"
        table_dir = dataset_out_dir / table_id
        table_dir.mkdir(parents=True, exist_ok=True)
        table_file = table_dir / f"v{version}.json"
        with table_file.open("w") as tf:
            json.dump(table, tf, indent=2)
        new_tables.append(
            {
                "id": table_id,
                "$ref": ref,
                "activeVersions": {f"v{version}": ref},
            }
        )

    dataset["tables"] = new_tables
    dataset_file = dataset_out_dir / "dataset.json"
    with open(dataset_file, "w") as dsf:
        json.dump(dataset, dsf, indent=2)
