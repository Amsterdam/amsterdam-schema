# Create CLI Commands

This document covers the `create_cli` command surface exposed through the `create` CLI. It is intended as a quick reference for creating minimal schema artifacts.

For the schema format itself, field semantics, and the meaning of Amsterdam Schema concepts such as datasets, tables, versions, publishers, and scopes, see the Amsterdam Schema specification:

https://schemas.data.amsterdam.nl/docs/ams-schema-spec.html

## Availability

After installing the package, the `create` command is available:

```bash
pip install .
```

## `create`

The `create` command is a grouped CLI for generating minimal schema artifacts interactively.

### `create dataset`

Creates a minimal `dataset.json` and matching table files from prompts.

```bash
create dataset
```

What it prompts for:

- Dataset id
- Authorization grantor
- Owner
- Publisher
- Auth
- Whether the dataset is ready for production
- Whether the API should be enabled
- One or more table definitions

Behavior:

- Writes a dataset document.
- Writes one table schema file per prompted table.
- Refuses to overwrite existing output files.

Output location:

```text
datasets/<dataset_id>/dataset.json
```

The generated table files are created next to that dataset file, using the selected default version.

Example:

```bash
create dataset
```

### `create publisher`

Creates a minimal publisher definition and updates the publisher index.

```bash
create publisher
```

What it prompts for:

- Publisher name
- Publisher id
- Publisher costcenter

Behavior:

- Requires the publisher id to contain uppercase letters only.
- Writes a publisher file.
- Updates `publishers/publishers.json` with the newly created publisher.
- Refuses to overwrite an existing publisher file.

Default output location:

```text
publishers/<PUBLISHER_ID>.json
```

Example:

```bash
create publisher
```

### `create scope`

Creates a minimal scope definition.

```bash
create scope
```

What it prompts for:

- Scope id
- Owner

Behavior:

- Writes a scope file with generated non-production and production access package names.
- Refuses to overwrite an existing scope file.

Default output location:

```text
scopes/<OWNER>/<scope_id_lowercased>.json
```

If the scope id contains `/`, the filename uses `_` instead.

Example:

```bash
create scope
```

## Notes

- `create dataset`, `create publisher`, and `create scope` are interactive by design.
- The schema specification remains the authoritative source for the structure and meaning of the generated JSON documents:

  https://schemas.data.amsterdam.nl/docs/ams-schema-spec.html
