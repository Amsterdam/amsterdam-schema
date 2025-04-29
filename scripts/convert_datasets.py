#!/usr/bin/env python3

# Convert datasets to v3 of the metaschema.
# Usage: in the top dir of this repo,
#   python3 scripts/convert_datasets.py

import json
import os
import re

VERSION_REGEX = r"v?(?P<major>\d+)(?:\.(?P<minor>\d+)(?:\.(?P<patch>\d+))?)?"

# Use this array to select specific datasets, an empty list will convert all datasets
DATASETS = []

for dirpath, dirs, filenames in os.walk("datasets/"):
    dirs.sort()
    for filename in sorted(filenames):
        if not filename.endswith(".json"):
            continue

        filename = os.path.join(dirpath, filename)
        with open(filename) as f:
            d = json.load(f)

        if d.get("type") != "dataset":
            continue

        if DATASETS and d.get("id") not in DATASETS:
            continue

        if not d.get("tables"):
            print(f"{d.get('id')}: SCHEMA IS PROBABLY ALREADY V3")
            continue

        print(f"CONVERTING DATASET: {d.get('id')}")

        cleaned_tables = []
        for table in d["tables"]:
            major_versions = {}

            if "$ref" in table:
                table_filename = table["$ref"]
                table_version = re.search(VERSION_REGEX, table_filename)
                with open(os.path.join(dirpath, table_filename + ".json")) as f:
                    table_schema = json.load(f)

                    # Replace the schema version to v3.1.0 in the table file
                    table_schema["schema"]["properties"]["schema"]["$ref"] = re.sub(
                        VERSION_REGEX,
                        "v3.1.0",
                        table_schema["schema"]["properties"]["schema"]["$ref"],
                    )
                    # Add lifecycleStatus to table
                    table_schema["lifecycleStatus"] = "stable"

                    # For convience add the lifecycle status just below version in the table file
                    table_order = list(table_schema.keys())
                    version_index = table_order.index("version")
                    table_order.insert(version_index + 1, "lifecycleStatus")
                    new_table_schema = {k: table_schema.get(k) for k in table_order}

                    major_versions[table_version.group("major")] = table_filename
                    new_table_filename = re.sub(
                        VERSION_REGEX, f"v{table_version.group('major')}", table_filename
                    )
                    with open(
                        os.path.join(dirpath, new_table_filename + ".json"), "w", encoding="utf8"
                    ) as new_file:
                        new_file.write(json.dumps(new_table_schema, indent=2, ensure_ascii=False))
                    table["$ref"] = new_table_filename
            else:
                # Inline tables will be changed to refs
                table_version = table.get("version", "1.0.0")
                version = re.search(VERSION_REGEX, table_version)
                table_filename = f"{table['id']}/v{version.group('major')}"
                # Replace the schema version to v3 in the table file
                table["schema"]["properties"]["schema"]["$ref"] = re.sub(
                    VERSION_REGEX, "v3.1.0", table["schema"]["properties"]["schema"]["$ref"]
                )
                # Add lifecycleStatus to table
                table["lifecycleStatus"] = "stable"

                # For convience add the lifecycle status just below version in the table file
                table_order = list(table_schema.keys())
                version_index = table_order.index("version")
                table_order.insert(version_index + 1, "lifecycleStatus")
                new_table_schema = {k: table.get(k) for k in table_order}

                os.makedirs(os.path.join(dirpath, table["id"]), exist_ok=True)
                with open(
                    os.path.join(dirpath, f"{table_filename}.json"), "w+", encoding="utf8"
                ) as new_file:
                    new_file.write(json.dumps(table, indent=2, ensure_ascii=False))

                # Remove all inline fields and return id and ref
                table = {
                    "id": table["id"],
                    "$ref": table_filename,
                }

            table.pop("activeVersions", None)
            cleaned_tables.append(table)

        # Add tables to the new v1 version
        d["defaultVersion"] = "v1"
        d["versions"] = {}
        d["versions"]["v1"] = {
            "status": d.get("status", "niet_beschikbaar"),
            "lifecycleStatus": "stable",
            "version": d.get("version", "1.0.0"),
            "tables": cleaned_tables,
        }
        # Remove tables and status, since this moved to versions
        for key in ["tables", "status", "version"]:
            d.pop(key, None)

        # Write changed dataset to file
        with open(filename, "w") as f:
            f.write(json.dumps(d, indent=2))
