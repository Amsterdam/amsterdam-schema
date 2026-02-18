import argparse
import json
import os
import re

import requests

MARKETPLACE_URL = "https://dmpfunc002.amsterdam.nl/marketplace"
DATASETS_FOLDER_PATH = "src/amsterdam_schema/datasets/"
VERSION_PATTERN = re.compile(r"v(\d+)\.json")


def fetch_marketplace_data() -> dict[str, dict]:
    all_products = requests.get(MARKETPLACE_URL, timeout=10).json()["documents"]
    marketplace_map = {}
    for product_summary in all_products:
        product = requests.get(f"{MARKETPLACE_URL}/{product_summary['id']}", timeout=10).json()
        for table in product["schema"]["tables"]:
            try:
                table_id = table["as_id"]
            except KeyError:
                print(f"Table {table["name"]} does not have an id.")
                continue

            if table_id:
                marketplace_map[table_id] = {}
                for attribute in table["attributes"]:
                    for field_name, value in attribute.items():
                        term = value["term"]
                        description = value["description"]
                        if term and description:
                            marketplace_map[table_id][field_name] = {
                                "term": term,
                                "description": description,
                            }
                        elif term and not description:
                            marketplace_map[table_id][field_name] = {
                                "term": term,
                            }
                        elif description and not term:
                            marketplace_map[table_id][field_name] = {
                                "description": description,
                            }

    return marketplace_map


def update_files(marketplace_map: dict, revert: bool = False):
    """
    Loop through schema files.
    """
    for dataset in os.listdir(DATASETS_FOLDER_PATH):
        dataset_path = os.path.join(DATASETS_FOLDER_PATH, dataset)

        if not os.path.isdir(dataset_path):
            continue

        for subdir in os.listdir(dataset_path):
            # Filter out dataset.json files
            if not subdir.endswith(".json"):
                tabledir = os.path.join(dataset_path, subdir)

                if not os.path.isdir(tabledir):
                    continue

                # Loop through all JSON files in table directory
                for file in os.listdir(tabledir):
                    if file.endswith(".json"):
                        json_file_path = os.path.join(tabledir, file)

                        if not json_file_path:
                            continue

                        if revert:
                            remove_business_fields(json_file_path)
                            continue
                        else:

                            # Update schema files
                            updated = update_schema_files(
                                json_file_path,
                                dataset,
                                marketplace_map,
                            )

                            if updated:
                                print(f"Updated {json_file_path}")


def update_schema_files(
    json_file_path: str,
    dataset: str,
    marketplace_map: dict,
) -> bool:
    """
    Compare schema property title/description with marketplace term/description
    for matching table fields and add businessTerm/Description if necessary.
    """

    with open(json_file_path, "r", encoding="utf-8") as f:
        schema_file = json.load(f)

    table_id = schema_file.get("id")

    # Check if table is also present in marketplace data
    if table_id not in marketplace_map:
        return False

    # Get table properties from marketplace and schema
    market_properties = marketplace_map.get(table_id)
    schema_properties = schema_file.get("schema", {}).get("properties", {})

    updated = False

    for field, data in schema_properties.items():
        market_field = market_properties.get(field)
        if not market_field:
            continue

        market_term = market_field.get("term")
        market_description = market_field.get("description")

        schema_title = data.get("title", "")
        schema_description = data.get("description", "")

        if not schema_title or (market_term and schema_title.strip() != market_term.strip()):
            print(f"Adding businessTerm to {dataset}.{table_id}")
            schema_file["schema"]["properties"][field]["businessTerm"] = market_term
            updated = True

        if not schema_description or (
            market_description and schema_description.strip() != market_description.strip()
        ):
            print(f"Adding businessDescription to {dataset}.{table_id}")
            schema_file["schema"]["properties"][field]["businessDescription"] = market_description
            updated = True

    if updated:
        with open(json_file_path, "w", encoding="utf-8") as f:
            json.dump(schema_file, f, ensure_ascii=False, indent=2)

    return updated


def remove_business_fields(
    json_file_path: str,
):
    """
    Removes businessTerm and businessDescription fields from schema files.
    """
    with open(json_file_path, "r", encoding="utf-8") as f:
        try:
            schema_file = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Skipping invalid JSON in {json_file_path}: {e}")
            return

    schema_properties = schema_file.get("schema", {}).get("properties", {})

    for field, data in schema_properties.items():
        if "businessTerm" in data:
            del schema_file["schema"]["properties"][field]["businessTerm"]
            print(f"Business term removed from {json_file_path}")
        if "businessDescription" in data:
            del schema_file["schema"]["properties"][field]["businessDescription"]
            print(f"Business description removed from {json_file_path}")

    with open(json_file_path, "w", encoding="utf-8") as f:
        json.dump(schema_file, f, ensure_ascii=False, indent=2)
        f.write("\n")


parser = argparse.ArgumentParser(
    prog="ImportMarketplace",
    description="Import marketplace products or remove businessTerm and businessDescription",
)
parser.add_argument(
    "-r",
    "--revert",
    action="store_true",
    help="Remove 'businessTerm' and 'businessDecsription' from JSON files",
)


def main():
    args = parser.parse_args()
    marketplace_map = fetch_marketplace_data()
    update_files(marketplace_map, revert=args.revert)


if __name__ == "__main__":
    main()
