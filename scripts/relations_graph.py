#!/usr/bin/env python3

# Show the relations between datasets in Graphviz dot(1) format.
# Usage: in the top dir of this repo,
#   python3 scripts/relations_graph.py | dot -Tsvg > relations.svg

import json
import os


print("digraph {")
print("rankdir=LR")

seen = set()

for dirpath, _, filenames in os.walk("datasets/"):
    for filename in filenames:
        if not filename.endswith(".json"):
            continue

        filename = os.path.join(dirpath, filename)
        with open(filename) as f:
            d = json.load(f)

        if d.get("type") != "dataset":
            continue

        print(d["id"])
        for version in d["versions"]:
            for table in d["versions"][version]["tables"]:
                if "$ref" in table:
                    with open(os.path.join(dirpath, table["$ref"] + ".json")) as f:
                        table = json.load(f)

                for _, prop in table["schema"]["properties"].items():
                    rel = prop.get("relation")
                    if not rel:
                        continue

                    to_ds, to_table = rel.split(":")
                    rel = f"{d['id']} -> {to_ds}"
                    if False:  # TODO Prettify output and enable.
                        rel += f' [label="{table["id"]} -> {to_table}"];'

                    if rel in seen:
                        continue
                    seen.add(rel)

                    print(rel)

print("}")
