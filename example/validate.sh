#!/usr/bin/env bash

for schema in *.json; do
  jq -c -r -M '.' < $schema | node ../../amsterdam-schema-tools/cli.js \
    -s ../meta/core.json \
    -s ../meta/type.json \
    -s ../meta/collection.json \
    -s ../meta/dataset.json \
    -s ../meta/class.json \
    -s ../meta/object.json \
    -s ../schema.json \
    -i https://ams-schema.glitch.me/schema@v0.1# \
    2>&1 1>/dev/null
done
