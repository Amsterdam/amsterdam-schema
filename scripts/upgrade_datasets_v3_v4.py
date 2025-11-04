#!/usr/bin/env python3

# Convert datasets to v3 of the metaschema.
# Usage: in the top dir of this repo,
#   python3 scripts/convert_datasets.py

import json
import os

VERSION_REGEX = r"v?(?P<major>\d+)(?:\.(?P<minor>\d+)(?:\.(?P<patch>\d+))?)?"

# Use this array to select specific datasets, an empty list will convert all datasets
DATASETS: list = []

for dirpath, dirs, filenames in os.walk("datasets/"):
    dirs.sort()
    for filename in sorted(filenames):
        if not filename.endswith(".json"):
            continue

        filename = os.path.join(dirpath, filename)
        with open(filename) as f:
            d = json.load(f)

        if d.get("type") == "dataset":
            if DATASETS and d.get("id") not in DATASETS:
                continue

            for version_number, version in d["versions"].items():
                # Rename lifecycleStatus to status and replace status with enableAPI on
                # the same position in the dataset
                key_order = list(version.keys())

                status = version.get("status")

                status_index = key_order.index("status")
                key_order.insert(status_index + 1, "enableAPI")
                new_version_schema = {k: version.get(k) for k in key_order}

                # Rename lifecycleStatus to status
                new_version_schema["status"] = version["lifecycleStatus"]
                new_version_schema.pop("lifecycleStatus", None)
                new_version_schema["enableAPI"] = True if status == "beschikbaar" else False

                d["versions"][version_number] = new_version_schema

            # Write changed dataset to file
            with open(filename, "w") as f:
                f.write(json.dumps(d, indent=2))
        elif d.get("type") == "table":
            key_order = list(d.keys())
            status_index = key_order.index("lifecycleStatus")
            key_order.insert(status_index + 1, "status")
            d["status"] = d["lifecycleStatus"]
            new_table_schema = {k: d.get(k) for k in key_order}
            new_table_schema.pop("lifecycleStatus", None)

            # Write changed table to file
            with open(filename, "w") as f:
                f.write(json.dumps(new_table_schema, indent=2))
