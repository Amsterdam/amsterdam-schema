import click
from schematools.datasetcollection import DatasetCollection

REQUIRED_DATASET_ATTS = [
    "id",
    "type",
    "status",
    "authorizationGrantor",
    "owner",
    "publisher",
    "auth",
    "creator",
    "tables",
]

REQUIRED_TABLE_ATTS = ["id", "type", "version", "schema"]


@click.command()  # type: ignore[misc]
def main() -> None:
    """Generate list of missing/empty attributes for all amsterdam schema datasets."""
    dataset_collection = DatasetCollection()
    for dataset_id, dataset in dataset_collection.get_all_datasets().items():
        for att_name in REQUIRED_DATASET_ATTS:
            if (
                not dataset.get(att_name)
                or att_name == "creator"
                and dataset.get(att_name) == "bronhouder onbekend"
            ):
                click.echo(".".join((dataset_id, att_name)) + " ontbreekt")
        for table in dataset.tables:
            for att_name in REQUIRED_TABLE_ATTS:
                if not table.get(att_name):
                    click.echo(".".join((dataset_id, table.id, att_name)) + " ontbreekt")
            for field in table.fields:
                # should have either `type` or `$ref`
                if not bool(field.get("type")) ^ bool(field.get("$ref")):
                    click.echo(".".join((dataset_id, table.id, field.id)) + " ontbreekt")
