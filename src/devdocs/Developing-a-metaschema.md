
# Developing a metaschema

In order to develop a new metaschema version locally and run structural and semantic validation
against it, we take the following steps. The `metaschema` cli command has been implemented to
automate many of the shell commands we used. All version arguments should include the `v` prefix,
i.e. `v3.1.0`, not `3.1.0`.

The validation commands expect the structure of the metaschema files to be
exactly as it is on the live environments, which is different than how it is stored
on disk. Therefore, we need to spin up either a devserver or the DSO-API. For the
latter, you need some extra setup, which you can put in a docker-compose.override.yml
file:

```yaml
services:
  web:
    ports:
      - "5678:5678"
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

## Step 0: Installation

Install the package in your virtual environment, to ensure you can run the necessary
cli commands.

```pip install -e .[dev]```

If you are validating against a local devserver, you also need to install schema tools:

```pip install [-e] <path to schema-tools folder>```

The -e flag will be useful if you are simultaneously altering schema-tools to work
with the new metaschema.

## Step 1: Create a new metaschema (optional)

```metaschema create <latest-version> <your-version>```

At this point, you can start altering the schema to incorporate new functionality.

When you alter an existing metaschema, for example when you remove a restriction,
or add one that is already adhered to by all existing schemas, this step can be skipped.

## Step 2: Update the references to point to the local instance

The refs in the metaschema should be updated so that schema tools can resolve them.
This can be done with the following command.

```metaschema refs local <your-version> [<dataset>] [--docker] [--port 8001]```

This changes the refs in the metaschema to either the locally running devserver
(without --docker), or to a locally running DSO-API (with --docker and --port).

The default port is 8000

_Note: This command is not idempotent, meaning that if you accidentally change to
the incorrect local instance, you need to first revert as in step 6 below._

## Step 3: Generate the index(es) expected by schematools

```generate-index > datasets/index.json```

This creates the index.json of the datasets folder.

Note: If you need the index of any of the other folders, in case you want
to check the metaschema against profiles, publishers, or scopes, you need
to manually create one (as of August 2025). Preferably copy the file from
the deployed application at https://schemas.data.amsterdam.nl/ and remove
unnecessary entries to speed up testing.

## Step 4: Start the server if you haven't already

Either run ```docker compose up devserver -d``` or run the DSO containers locally.

## Step 5: Run the validation

### Validating Datasets

To validate a dataset against the local devserver running on port 8000:

```schema validate --schema-url='http://localhost:8000/datasets' <some-dataset> 'http://localhost:8000/schema@<your-version>'```

To validate a dataset against the locally running DSO:

```docker compose exec web schema validate --schema-url='/tmp/datasets/' <dataset> 'http://host.docker.internal:8000/schema@<your-version>'```

### Validating Scopes and Publishers

Note: make sure you have created the `scopes/index.json` and/or `publishers/index.json`
file.

To validate all scopes against the local devserver running on port 8000:

```schema validate-scopes --schema-url='http://localhost:8000/datasets' 'http://localhost:8000/schema@<your-version>'```

To validate against the locally running DSO:

```docker compose exec web schema validate-scopes --schema-url='/tmp/datasets/' 'http://host.docker.internal:8000/schema@<your-version>```

To validate publishers, exchange the `validate-scopes` command for
`validate-publishers`.

## Step 6: Set the refs back to the remote URL

And of course; when the metaschema is validated to do what it should do, the
references in the new metaschema and the dataset used for development need to be
reset to the online URL:

```metaschema refs remote <your-version> [dataset]```

## Extras

To inspect the diff between two schema versions, use:

```metaschema diff <version1> <version2>```
