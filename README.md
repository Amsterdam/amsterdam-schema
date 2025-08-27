<div align="center">
  <img alt="Amsterdam logo" width="100px" src="amsterdam-schema.svg" />
</div>

# Amsterdam Schema

Amsterdam Schema aims to describe and validate
[open data published by the City of Amsterdam](https://api.data.amsterdam.nl/api/),
in order to make the storing and publishing
of different datasets more structured,
simpler and better documented.

This repository contains:

1. JSON documents that describe the structure and metadata of datasets (i.e.: `dataset schemas` not to be confused with `JSON-schemas`);
2. JSON documents that describe the structure and metadata of tables (i.e.: `table schemas` not to be confused with `JSON-schemas`);
3. A JSON-Schema _metaschema_ to validate the documents mentioned under 1) and 2).

More specifically, _metaschemas_ are [JSON-Schemas](https://json-schema.org/)
that can make sure every dataset published by the City of Amsterdam
always contains the right metadata and is of the right form.

This is done by running [structural](https://json-schema.org/understanding-json-schema/about.html#what-is-a-schema:~:text=the%20schema%20(or-,structural,-)%20level%2C%20and%20one) and `semantic` validation.
The structural part is handled by the _metaschema_ defined in this repository. The logic for semantic validation is defined in the [schematools](https://github.com/Amsterdam/schema-tools/blob/master/src/schematools/validation.py) repository.

## Amsterdam Schema Specification

Apart from the technical description
an in-depth textual specification of the Amsterdam Schema can be found at
https://schemas.data.amsterdam.nl/docs/ams-schema-spec.html.

The Amsterdam Schema is chosen to be delimited in such a way
that it can interoperate with as many systems as possible.
The results of this analysis can be found at the
[Grootst Gemene Deler](https://github.com/Amsterdam/amsterdam-schema/wiki/Grootst-Gemene-Deler) page.

## Amsterdam Schema Registry

Each instance of Amsterdam Schema exists of:

1. Metadata about a single dataset;
2. Metadata about each table in this single dataset;
3. For each table, a table-schema to describe and validate the data in these tables.

An overview of the current schemas can be found at
https://github.com/Amsterdam/amsterdam-schema/tree/master/datasets.

## Concepts

In Amsterdam Schema, we're using the following concepts:

| Type    | Description                                                                                                       |
| :------ | :---------------------------------------------------------------------------------------------------------------- |
| Dataset | A single dataset, with contents and metadata                                                                      |
| Table   | A single table with objects of a single class/type                                                                |
| Row     | A row in such a table (a single object, a row in a source CSV file or feature in a source Shapefile, for example) |
| Field   | A property of a single object                                                                                     |

For example:

- The dataset `bag` contains data for each building and address in the city;
- This dataset contains two tables: `buildings` and `addresses`;
- To describe this dataset according to Amsterdam Schema,
  we first describe the metadata of the dataset
  (such as its identifier, title, description and
  [DCAT](https://www.w3.org/TR/vocab-dcat-2/) fields) in a dataset.json file;
- For each table in this dataset,
  we describe the table metadata in a separate JSON file.
  We can also choose to combine the dataset and table JSON data in a single JSON file;
- For each table,
  we create a table-schema to describe its contents.
  This JSON Schema describes all the fields in a single table row, and the types of these fields;
- Amsterdam Schema is used to validate the dataset and table JSON data
- Amsterdam Schema is used to validate the table row JSON Schema,
  with a _meta-schema_ (a JSON Schema to verify a JSON Schema).

## Versioning

You can find all historical versions of the Amsterdam Schema definition in this repository.
Version numbers are shown as '@1.0.0'
where we follow SchemaVer for versioning.
This will allow for a gradual evolution of capabilities.

## See also

For more information, see (some of these pages are in Dutch):

- [Amsterdam Schema Wiki](https://github.com/Amsterdam/amsterdam-schema/wiki)
- [Amsterdam Schema Validator 👩🏼‍🏫](https://observablehq.com/@bertspaan/amsterdam-schema-validator)
- [Werkbestand Team Dataservices](https://observablehq.com/@bertspaan/werkbestand-team-dataservices)
- [Amsterdam Schema Playground 🎠](https://observablehq.com/@bertspaan/amsterdam-schema-playground)

# Manuals

- [Developing a metaschema](src/devdocs/Developing-a-metaschema.md)
- [Publishing](src/devdocs/Publishing.md)
