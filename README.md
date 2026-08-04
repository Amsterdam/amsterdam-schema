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

## Contributing to this repo
This section describes how to set up your local environment to develop your own schema's and contribute to this repository. (Your GH account needs to be a member of the Amsterdam org to create PRs)

### 1. Clone this repository
```
git clone git@github.com:Amsterdam/amsterdam-schema.git
```

Or use the [Github CLI](https://cli.github.com/):
```
gh repo clone Amsterdam/amsterdam-schema
```

Then cd into the folder:
```
cd amsterdam-schema/
```

### 2. Install the pre-commit hooks
Pull requests on the repository are validated with a number of tests and formatting rules these are enforced using [pre-commit](https://pre-commit.com/). To run these tests locally you need to install the [pre-commit hooks](/.pre-commit-config.yaml).

Check that pre-commit is installed with:
```
pre-commit --version
```
If it is not installed yet, install it with:
```
pip install pre-commit
```

After installation of pre-commit, the pre-commit hooks can be installed with:
```
pre-commit install
```

The validations will now be run on all staged files when you create a new commit.
Some problems, like formatting mistakes will be fixed automatically. In this case you will see new unstaged changes in your directory. Just add them and retry the commit. Other problems can not be fixed automatically and will show as an error in the console.

You can also validate a specific file or folder directly with:
```
pre-commit run --files datasets/my_dataset/dataset.json
```

For more on pre-commit see the pre-commit documentation at [pre-commit.com](https://pre-commit.com/)

### 3. Create a new feature branch
Feature branches are namespaced by contributor with the following naming convention: `<github username>/<feature_description>`

So create a new feature branch with something like:
```
git checkout -b <my_gh_usename>/create__mydataset
```

### 4. Commit and push your changes
Please write clear and informative commit messages in imperative voice.
It is important a future contibutor can look back and understand what was changed and why.

DO: `git commit -m "Add table xyz to dataset A"`</br>
DO: `git commit -m "Improve descriptions in table xyz"` </br>
DONT: `git commit -m "table xyz added in dataset A"` (Not imperative) </br>
DONT: `git commit -m "Update dataset x"` (Not informative)

Optionally add a description to you commit message with motivation for change or more context:

DO: `git commit -m "Clarify field descriptions in table xyz" -m "We recieved multiple questions from users about the difference between field x and z. This change clarifies why x is not z."`

`git push --set-upstream origin <your_branch>`

### 5. Create a pull request.
Create a Pull Request and request a review on Slack.
After your changes are merged, It may take about 10 minutes for your changes to go live.

# Manuals

- [Developing a metaschema](src/devdocs/Developing-a-metaschema.md)
- [Publishing](src/devdocs/Publishing.md)
