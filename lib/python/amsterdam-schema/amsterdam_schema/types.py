"""Python types for the Amsterdam Schema JSON file contents."""
from __future__ import annotations

import json
import typing
from collections import UserDict

import jsonschema

SUPPORTED_REFS = {
    "https://geojson.org/schema/Geometry.json",
    "https://geojson.org/schema/Point.json",
    "https://geojson.org/schema/Polygon.json",
    "https://schemas.data.amsterdam.nl/schema@v1.1.0#/definitions/id",
    "https://schemas.data.amsterdam.nl/schema@v1.1.0#/definitions/class",
    "https://schemas.data.amsterdam.nl/schema@v1.1.0#/definitions/dataset",
    "https://schemas.data.amsterdam.nl/schema@v1.1.0#/definitions/year",
    "https://schemas.data.amsterdam.nl/schema@v1.1.0#/definitions/uri",
    "https://schemas.data.amsterdam.nl/schema@v1.1.0#/definitions/schema",
}


class SchemaType(UserDict):
    def __repr__(self):
        return f"{self.__class__.__name__}({self.data!r})"

    def __missing__(self, key):
        raise KeyError(f"No field named '{key}' exists in {self!r}")

    @property
    def id(self) -> str:
        return self["id"]

    @property
    def type(self) -> str:
        return self["type"]

    def json(self) -> str:
        return json.dumps(self.data)

    def json_data(self) -> dict:
        return self.data


class DatasetType(UserDict):
    def __repr__(self):
        return f"{self.__class__.__name__}({self.data!r})"

    def __missing__(self, key):
        raise KeyError(f"No field named '{key}' exists in {self!r}")


class DatasetSchema(SchemaType):
    """The schema of a dataset.
    This is a collection of JSON Schema's within a single file.
    """

    @classmethod
    def from_file(cls, filename: str):
        """Open an Amsterdam schema from a file."""
        with open(filename) as fh:
            return cls.from_dict(json.load(fh))

    @classmethod
    def from_dict(cls, obj: dict):
        """ Parses given dict and validates the given schema """
        if obj.get("type") != "dataset" or not isinstance(obj.get("tables"), list):
            raise ValueError("Invalid Amsterdam Schema file")

        return cls(obj)

    @property
    def tables(self) -> typing.List[DatasetTableSchema]:
        """Access the tables within the file"""
        return [DatasetTableSchema(i, _parent_schema=self) for i in self["tables"]]

    def get_table_by_id(self, table_id: str) -> DatasetTableSchema:
        for table in self.tables:
            if table.id == table_id:
                return table
        raise ValueError(f"Schema of table '{table_id}' does not exist in {self}")


class DatasetTableSchema(SchemaType):
    """The table within a dataset.
    This table definition follows the JSON Schema spec.
    """

    def __init__(self, *args, _parent_schema=None, **kwargs):
        super().__init__(*args, **kwargs)
        self._parent_schema = _parent_schema

        if self.get("type") != "table":
            raise ValueError("Invalid Amsterdam schema table data")

        if not self["schema"].get("$schema", "").startswith("http://json-schema.org/"):
            raise ValueError("Invalid JSON-schema contents of table")

    @property
    def fields(self):
        required = set(self["schema"]["required"])
        for name, spec in self["schema"]["properties"].items():
            yield DatasetFieldSchema(
                _name=name, _parent_table=self, _required=(name in required), **spec
            )

    def validate(self, row: dict):
        """Validate a record against the schema."""
        jsonschema.validate(row, self.data["schema"])

    def _resolve(self, ref):
        """Resolve the actual data type of a remote URI reference."""
        return jsonschema.RefResolver(ref, referrer=self)


class DatasetFieldSchema(DatasetType):
    """ A single field (column) in a table """

    def __init__(self, *args, _name=None, _parent_table=None, _required=None, **kwargs):
        super().__init__(*args, **kwargs)
        self._name = _name
        self._parent_table = _parent_table
        self._required = _required

    @property
    def name(self) -> str:
        return self._name

    @property
    def required(self) -> bool:
        return self._required

    @property
    def type(self) -> str:
        value = self.get("type")
        if not value:
            value = self.get("$ref")
            if not value:
                raise RuntimeError(f"No 'type' or '$ref' found in {self!r}")
        return value

    @property
    def is_primary(self) -> bool:
        return self.name == "id" and self.type.endswith("/definitions/id")

    @property
    def relation(self) -> typing.Optional[str]:
        return self.get("relation")

    @property
    def format(self) -> typing.Optional[str]:
        return self.get("format")


class DatasetRow(DatasetType):
    """ An actual instance of data """

    def validate(self, schema: DatasetSchema):
        table = schema.get_table_by_id(self["table"])
        table.validate(self.data)
