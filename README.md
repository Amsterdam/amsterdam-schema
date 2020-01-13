<div align="center">
  <img width="100px" src="amsterdam-schema.svg" />
</div>

# Amsterdam Schema

Amsterdam Schema aims to describe and validate [open data published by the City of Amsterdam](https://api.data.amsterdam.nl/api/), in order to make the storing and publishing of different datasets more structured, simpler and better documented.

This repository contains [JSON Schemas](https://json-schema.org/) and meta-schemas that can make sure every dataset published by the City of Amsterdam always contains the right metadata and is of the right form.

An instance of Amsterdam Schema exists of:

1. Metadata about a single dataset;
2. Metadata about each table in this single dataset;
3. For each table, a JSON Schema to describe and validate the data in these tables.

This repository contains:

1. A JSON Schema to validate dataset metadata;
2. A JSON Schema to validate table metadata;
3. A JSON Schema _metaschema_ to validate the JSON Schema that describes table data.

__Amsterdam Schema is developed by the City of Amsterdam, but the tools and concepts created in this project can be used in any city.__

## Concepts

In Amsterdam Schema, we're using the following concepts:

| Type       | Description                                        |
|:-----------|:---------------------------------------------------|
| Dataset    | A single dataset, with contents and metadata       |
| Table      | A single table with objects of a single class/type |
| Row        | A row in such a table (a single object, a row in a source CSV file or feature in a source Shapefile, for example) |
| Field      | A property of a single object                      |

For example:

- The dataset `bag` contains data for each building and address in the city;
- This dataset contains two tables: `buildings` and `addresses`;
- To describe this dataset according to Amsterdam Schema, we first describe the metadata of the dataset in a JSON file (such as its identifier, title, description and [DCAT](https://www.w3.org/TR/vocab-dcat-2/) fields);
- For each table in this dataset, we describe the table metadata in a separate JSON file. We can also choose to combine the dataset and table JSON data in a single JSON file;
- For each table, we create a JSON Schema to describe its contents. This JSON Schema describes all the fields in a single table row, and the types of these fields;
- Amsterdam Schema is used to validate the dataset and table JSON data
- Amsterdam Schema is used to validate the table row JSON Schema, with a _meta-schema_ (a JSON Schema to verify a JSON Schema).

## Editor

You can use the [Amsterdam Schema Editor](https://amsterdam.github.io/schema-editor/) to create or edit Amsterdam Schema instances using a web interface.

## Validation

You can use any JSON Schema validator to validate data against a JSON Schema.

To validate data from your browser, you can use the [Amsterdam Schema Validator 👩🏼‍🏫](https://observablehq.com/@bertspaan/amsterdam-schema-validator). With the `data=data:text/x-url,` and `schema=data:text/x-url,` URL parameters, you can load data and schema JSON files from URLs. For example, to verify the schema https://schemas.data.amsterdam.nl/datasets/afvalwegingen/afvalwegingen with https://schemas.data.amsterdam.nl/schema@v1.1.0, open the following link:

https://observablehq.com/@bertspaan/amsterdam-schema-validator?data=data:text/x-url,https%3A%2F%2Fschemas.data.amsterdam.nl%2Fdatasets%2Fafvalwegingen%2Fafvalwegingen&schema=data:text/x-url,https%3A%2F%2Fschemas.data.amsterdam.nl%2Fschema%40v1.1.0

## Versioning

We're currently using [GitHub releases](https://github.com/Amsterdam/amsterdam-schema/releases) to publish different versions of Amsterdam Schema.

## Dataset Schemas

For examples of dataset schemas conforming to Amsterdam Schema, see https://github.com/Amsterdam/schemas.

## See also

For more information, see (some of these pages are in Dutch):

- [Amsterdam Schema Editor](https://amsterdam.github.io/schema-editor/)
- [Amsterdam Schema Wiki](https://github.com/Amsterdam/amsterdam-schema/wiki)
- [Amsterdam Schema Validator 👩🏼‍🏫](https://observablehq.com/@bertspaan/amsterdam-schema-validator)
- [Werkbestand Team Dataservices](https://observablehq.com/@bertspaan/werkbestand-team-dataservices)
- [Amsterdam Schema Playground 🎠](https://observablehq.com/@bertspaan/amsterdam-schema-playground)
