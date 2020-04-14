from __future__ import annotations

import json
from typing import Dict

import requests

from . import types


def schema_defs_from_url(schemas_url) -> Dict[str, types.DatasetSchema]:
    """Fetch all schema definitions from a remote file.
    The URL could be ``https://schemas.data.amsterdam.nl/datasets/``
    """
    schema_lookup = {}
    if not schemas_url.endswith("/"):
        schemas_url = f"{schemas_url}/"

    with requests.Session() as connection:

        # Fetch complete lookup
        response = connection.get(schemas_url)
        response.raise_for_status()
        response_data = response.json()
        if not isinstance(response_data, list):
            raise ValueError(
                f"Unexpected response at {schemas_url}, not a directory listing"
            )

        for schema_dir_info in response_data:

            # Fetch folder data of datasets
            schema_dir_name = schema_dir_info["name"]
            response = connection.get(f"{schemas_url}{schema_dir_name}/")
            response.raise_for_status()
            response_data = response.json()
            if not isinstance(response_data, list):
                raise ValueError(
                    f"Unexpected response at {schemas_url}, not a directory listing"
                )

            for schema_file_info in response_data:
                # Fetch each schema from the folder
                schema_name = schema_file_info["name"]
                response = connection.get(
                    f"{schemas_url}{schema_dir_name}/{schema_name}"
                )
                response.raise_for_status()

                schema_lookup[schema_name] = types.DatasetSchema.from_dict(
                    response.json()
                )

    return schema_lookup


def schema_def_from_url(schemas_url, schema_name):
    schemas = schema_defs_from_url(schemas_url)
    try:
        return schemas[schema_name]
    except KeyError:
        avail = ", ".join(sorted(schemas.keys()))
        raise ValueError(
            f"Schema f{schema_name} does not exist at {schemas_url}. Available are: {avail}"
        )


def schema_def_from_file(filename) -> Dict[str, types.DatasetSchema]:
    """Read schema definitions from a file on local drive."""
    with open(filename, "r") as file_handler:
        schema_info = json.load(file_handler)
        return {schema_info["id"]: types.DatasetSchema.from_dict(schema_info)}
