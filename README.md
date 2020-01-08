<div align="center">
  <img width="100px" src="amsterdam-schema.svg" />
</div>

# Amsterdam Schema

This repository contains a work-in-progress version of the Amsterdam Schema. Currently, Amsterdam Schema is a set of [JSON Schemas](https://json-schema.org/) and meta-schemas. The goal of this project is to describe and validate [open data published by the City of Amsterdam](https://api.data.amsterdam.nl/api/). Amsterdam Schema will be used to make the import, storage and publishing layers of our APIs more generic, easier to maintain, and better documented.

This repository contains JSON Schemas to make sure every dataset published by the City of Amsterdam always contains the right metadata and is of the right form.

An instance of Amsterdam Schema exists of:

1. Metadata about a single dataset;
2. Metadata about each table in this dataset;
3. For each table, a JSON Schema to describe and validate the data in these tables.

This repository contains:

1. A JSON Schema to validate dataset metadata;
2. A JSON Schema to validate table metadata;
3. A JSON Schema _metaschema_ to validate the JSON Schema that describes table data.

__Amsterdam Schema is developed by the City of Amsterdam, but the tools and concepts created in this project can be used in any city.__

For more information, see (some of these pages are in Dutch):

- [Werkbestand Team Dataservices](https://observablehq.com/@bertspaan/werkbestand-team-dataservices)
- [Amsterdam Schema Playground 🎠](https://observablehq.com/@bertspaan/amsterdam-schema-playground)
- [Amsterdam Schema Importwizard 🧙‍♀️](https://amsterdam-schema-importwizard.glitch.me/)
- [Amsterdam Schema Validator 👩🏼‍🏫](https://observablehq.com/@bertspaan/amsterdam-schema-validator)
- [Amsterdam Schema Tools](https://github.com/Amsterdam/amsterdam-schema-tools)

## Schemas

Amsterdam Schema aims to restrict the structure and format of data accepted by Amsterdam's open data systems, in order to make the storing and publishing of different datasets more structured, simpler and better documented.

Amsterdam Schema consists of a standard library of available data types, in the form of JSON Schema meta-schemas. These meta-schemas are used to validate JSON Schemas that describe different datasets.

## Concepts

| Type       | Description                              |
|:-----------|:-----------------------------------------|
| Dataset    |                                          |
| Table      | a table, class, etc.                     |
| Row        | een row in table, een regel in CSV, etc. |
| Field      | in JSON schema: property                  |

For example:

- The dataset `bag` contains data for each building and address in the city;
- A JSON Schema describes this dataset, a schema exists for each _class_ in the dataset (e.g. buildings and addresses);
- Amsterdam Schema is used to validate these dataset schemas: Amsterdam Schema requires each object of each type to have an `id` field, defines a way to specify relationships, expects all `geometry` fields to be a GeoJSON geometry, et cetera.

## Geometry

GeoJSON

## Validation

You can use any JSON Schema validator to validate data against a JSON Schema.

To validate data from your browser, you can use the [Amsterdam Schema Validator 👩🏼‍🏫](https://observablehq.com/@bertspaan/amsterdam-schema-validator). With the `data=data:text/x-url,` and `schema=data:text/x-url,` URL parameters, you can load data and schema JSON files from URLs. For example, to verify the schema https://schemas.data.amsterdam.nl/dataset/bag/pand with meta-schema https://schemas.data.amsterdam.nl/core/meta/object@v0.0.1, open the following link:

https://observablehq.com/@bertspaan/amsterdam-schema-validator?data=data:text/x-url,https%3A%2F%2Fams-schema.glitch.me%2Fdataset%2Fbag%2Fpand&schema=data:text/x-url,https%3A%2F%2Fams-schema.glitch.me%2Fcore%2Fmeta%2Fobject%40v0.0.1

## Versioning

We're currently using [GitHub releases](https://github.com/Amsterdam/amsterdam-schema/releases) to publish different versions of Amsterdam Schema.

The [Glitch app](https://glitch.com/~ams-schema) mentioned above acts as a proxy, and reads the JSON Schemas from this repository from all available releases:

- https://schemas.data.amsterdam.nl/core/schema ⟶ https://raw.githubusercontent.com/Amsterdam/amsterdam-schema/master/schema.json
- https://schemas.data.amsterdam.nl/core/schema@v0.0.1 ⟶ https://raw.githubusercontent.com/Amsterdam/amsterdam-schema/v0.0.1/schema.json
- https://schemas.data.amsterdam.nl/core/meta/object ⟶ https://raw.githubusercontent.com/Amsterdam/amsterdam-schema/master/meta/object.json

## Examples

For examples of dataset schemas conforming to Amsterdam Schema, see https://github.com/Amsterdam/schemas.
