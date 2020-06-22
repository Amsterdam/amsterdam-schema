<div align="center">
  <img width="100px" src="amsterdam-schema.svg" />
</div>

# Amsterdam Schema

Amsterdam Schema aims to describe and validate [open data published by the City of Amsterdam](https://api.data.amsterdam.nl/api/), in order to make the storing and publishing of different datasets more structured, simpler and better documented.

This repository contains [JSON Schemas](https://json-schema.org/) and meta-schemas that can make sure every dataset published by the City of Amsterdam always contains the right metadata and is of the right form.

This repository contains:

1. A JSON Schema to validate dataset metadata;
2. A JSON Schema to validate table metadata;
3. A JSON Schema _metaschema_ to validate the JSON Schema that describes table data.

## Amsterdam Schema Specification

Apart from the technical description an in-depth textual specification of the Amsterdam Schema can be found at https://github.com/Amsterdam/amsterdam-schema/wiki/Amsterdam-Schema-Specification

The Amsterdam Schema is chosen to be delimited in such a way that it can interoperate with as many systems as possible. The results of this analysis can be found at the [Grootst Gemene Deler](https://github.com/Amsterdam/amsterdam-schema/wiki/Grootst-Gemene-Deler) page.

## Amsterdam Schema Registry

Each instance of Amsterdam Schema exists of:

1. Metadata about a single dataset;
2. Metadata about each table in this single dataset;
3. For each table, a JSON Schema to describe and validate the data in these tables.

An overview of the existing Amsterdam Schemas can be found in the the Amsterdam Schema Registry at https://github.com/Amsterdam/schemas.

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

You can experiment with aprototype version of [Amsterdam Schema Editor](https://amsterdam.github.io/schema-editor/) to create or edit Amsterdam Schema instances using a web interface. 
Due to the rapid pace of development this tool lags behind the specification and should be considered as an inspiration of how easy it could become for everyone to define their own.

## Versioning

You can find all historical versions of the Amsterdam Schema definition in this repository. Version numbers are shown as '@1.0.0' where we follow SchemaVer for versioning. This will allow for a gradual evolution of capabilities.


## See also

For more information, see (some of these pages are in Dutch):

- [Amsterdam Schema Editor](https://amsterdam.github.io/schema-editor/)
- [Amsterdam Schema Wiki](https://github.com/Amsterdam/amsterdam-schema/wiki)
- [Amsterdam Schema Validator 👩🏼‍🏫](https://observablehq.com/@bertspaan/amsterdam-schema-validator)
- [Werkbestand Team Dataservices](https://observablehq.com/@bertspaan/werkbestand-team-dataservices)
- [Amsterdam Schema Playground 🎠](https://observablehq.com/@bertspaan/amsterdam-schema-playground)
