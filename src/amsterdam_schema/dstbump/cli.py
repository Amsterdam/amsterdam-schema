import json
from io import BufferedReader
from pathlib import Path

import click
import semver


# Remove this when migrating to python3.9,
# that has str.removeprefix
def remove_prefix(text: str, prefix: str) -> str:
    if text.startswith(prefix):
        return text[len(prefix) :]
    return text


@click.command()  # type: ignore[misc]
@click.argument("dataset_in_file", type=click.File("rb"))  # type: ignore[misc]
@click.argument("table_id", required=False)  # type: ignore[misc]
@click.option(  # type: ignore[misc]
    "-b", "bump_type", default="minor", type=click.Choice(("major", "minor", "patch"))
)
def main(dataset_in_file: BufferedReader, table_id: str, bump_type: str) -> None:
    """Bump the version of table.

    DATASET_IN_FILE: Path to dataset.json that contains the table to be bumped.
    TABLE_ID: Name of table that needs to be bumped.
    BUMP: Type of bump. 'minor' (default) or 'major'.

    NB. When TABLE_ID is not given, the list of possible tables will we presented.
    """
    dataset = json.load(dataset_in_file)
    dataset_dir = Path(dataset_in_file.name).parent

    table_lookup = {table["id"]: table for table in dataset["tables"]}
    if table_id is None or table_id not in table_lookup:
        click.echo(f"Missing table_id, available are: {' '.join(table_lookup.keys())}")
        exit(1)

    table_slot = table_lookup[table_id]
    if "$ref" not in table_slot:
        click.echo("Bump is only possible for tables in separate json files.")

    # The semver.VersionInfo.bump_major / .bump_minor methods are used to bump the version.
    current_version_str = table_slot["$ref"].split("/")[-1]
    current_version = semver.VersionInfo.parse(remove_prefix(current_version_str, "v"))
    bumped_version = getattr(current_version, f"bump_{bump_type}")()
    bumped_version_str = f"v{bumped_version}"

    table_dir = dataset_dir / table_id.lower()

    with (table_dir / f"{current_version_str}.json").open() as ptf:
        previous_table = json.load(ptf)

    # Update table_slot in the dataset
    ref = f"{table_id.lower()}/{bumped_version_str}"
    table_slot["$ref"] = ref
    table_slot["activeVersions"] = {str(bumped_version): ref}

    dataset_file = dataset_dir / "dataset.json"
    with open(dataset_file, "w") as dsf:
        json.dump(dataset, dsf, indent=2)
        dsf.write("\n")

    # Write the bumped table file to the filesystem.
    table_file = table_dir / f"{bumped_version_str}.json"
    previous_table["version"] = str(bumped_version)
    with table_file.open("w") as tf:
        json.dump(previous_table, tf, indent=2)
        tf.write("\n")
