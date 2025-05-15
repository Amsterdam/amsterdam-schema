__doc__ = """

Script that publishes verified schemas to the objectstore.

Course of action is as follows:

* The relevant schema files (metaschema + datasets) are pushed to the objectstore
* An json file with an index of the datasets is pushed to the the objectstore

"""

import json
import logging
import os
import shutil
import sys
from importlib import resources
from io import BytesIO
from os.path import splitext
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Callable, Dict, Iterator, List, Tuple

import click
import in_place
from azure.storage.blob import BlobServiceClient, ContentSettings
from more_itertools import chunked

logger = logging.getLogger("__name__")

DEFAULT_BASE_URL = "https://schemas.data.amsterdam.nl"
DEFAULT_STORAGE_CONTAINER = "schemas"
PUBLISHERS_DIR = "publishers"
SCHEMAS_SA_NAME = os.getenv("SCHEMAS_SA_NAME", "devschemassa")
SCOPES_DIR = "scopes"
SCOPES_IGNORED_FILES = ["index", "packages", "scopes"]
SCOPES_UNAVAILABLE_DATASETS = ["brp_r"]
PUBLISHABLE_PREFIXES = ("datasets", "schema@", PUBLISHERS_DIR, SCOPES_DIR)


def fetch_local_as_publishable(
    root_pkg_name: str,
    temp_dir_path: Path,
    publishable_prefixes: Tuple[str, ...] = PUBLISHABLE_PREFIXES,
    glob: str = "**/*.json",
) -> List[List[str]]:
    """Fetch publishable artifacts from package as path components.

    Not sure how to describe this function best. I've kept the API, or at least that what it
    returns, identical to its predecessor. It copies the publishable artifacts from the package
    to the ``temp_dir_path`` and returns all relative paths from ``temp_dir_path`` down as a
    list of strings where each string represents a path component.

    Args:
        root_pkg_name: Name of the root package (eg "amsterdam_schema"
        temp_dir_path: Path of the temporary directory to copy publishable artifacts to
        publishable_prefixes: prefixes of directories to publish parts of
        glob: Which files to fetch

    Returns:
        A list of publishable artifacts in the ``temp_dir_path``. Each publishable
        artifacts is identified by a list of its path components from `temp_dir_path`` down
        (eg it does not include the path component of ``temp_dir_path``)

    """
    dst_path = temp_dir_path / root_pkg_name

    # Use importlib to extract resources from the package. This works for regularly installed
    # packages as well as editable installed packages.
    resource_names: Iterator[str] = filter(
        lambda res: any(res.startswith(prefix) for prefix in publishable_prefixes),
        resources.contents(root_pkg_name),
    )

    resource_root = resources.files(root_pkg_name)
    resource_paths = (resource_root.joinpath(name) for name in resource_names)

    for dir_path in resource_paths:
        shutil.copytree(str(dir_path), (dst_path / dir_path.name).as_posix(), dirs_exist_ok=True)

    publishable_paths: List[List[str]] = []

    for schema_path in dst_path.glob(glob):
        sub_path = schema_path.relative_to(dst_path.parent)
        publishable_paths.append(list(sub_path.parts))

    return publishable_paths


def get_index_file_obj(publishable_paths: List[List[str]], files_root: Path) -> BytesIO:
    """Create index file of all the datasets in JSON format.

    For every dataset.json file it will add an entry of the form:
    `dataset_id:'path/to/dataset/'`.
    """
    index: Dict[str, str] = {}
    for path_parts in sorted(publishable_paths, key=len):
        if path_parts[1] != "datasets":
            continue
        file_name = path_parts[-1]
        if file_name != "dataset.json":
            continue

        # Grab id from dataset file
        with open(files_root / Path(*path_parts)) as f:
            key = json.load(f)["id"]

        folder = "/".join(path_parts[2:-1])

        # Check for duplicate ids
        if key in index:
            raise Exception(f"Datasets with duplicate id:{key!r} in {folder} and {index[key]}.")

        index[key] = folder
    return BytesIO(json.dumps(index).encode())


def create_object_name(path_parts: List[str]) -> str:
    """Mangle path names.

    We need some path mangling and move objects from version directories
    to the root with an @vx.y.z postfix, e.g.:
        schema@v1.1.1/row-meta-schema -> row-meta-schema@v1.1.1
        schema@v1.1.1/meta/auth -> meta/auth@v1.1.1
    """
    parts = path_parts[:]
    # Always remove json extension
    parts[-1] = splitext(parts[-1])[0]
    # For metaschema files, move to root level
    if "@" in parts[1]:
        _, version = parts[1].split("@")
        parts[-1] = f"{parts[-1]}@{version}"
        parts.pop(1)
    return "/".join(parts[1:])


def replace_schema_base_url(temp_dir: Path, schema_base_url: str) -> None:
    """Do a replacement of the schema_base_url.

    Needed to valdidate schemas when served from another base url, e.g. for testing.
    """
    for root, _dirs, file_names in os.walk(temp_dir):
        root_path = Path(root)
        for file_name in file_names:
            file_path = root_path / file_name
            if file_path.suffix == ".json":
                with in_place.InPlace(root_path / file_name) as file:
                    for line in file:
                        line = line.replace(DEFAULT_BASE_URL, schema_base_url)  # type: ignore
                        file.write(line)


def azure_blob_uploader(
    container: str,
    files_root: Path,
    schema_pub_paths: List[List[str]],
    doc_pub_paths: List[List[str]],
    sql_pub_paths: List[List[str]],
    index_files: Dict[str, BytesIO],
) -> None:
    """Upload files to the Azure blob storage."""
    json_content_settings = ContentSettings(content_type="application/json")
    html_content_settings = ContentSettings(content_type="text/html")
    sql_content_settings = ContentSettings(content_type="text/plain")

    credential = os.getenv("SCHEMAS_SA_KEY")
    if credential is None:
        raise Exception("SCHEMAS_SA_KEY not set")

    blob_srv = BlobServiceClient(
        f"https://{SCHEMAS_SA_NAME}.blob.core.windows.net", credential=credential
    )

    # First delete all blobs in the container
    container_client = blob_srv.get_container_client(container)

    blobs = container_client.list_blobs()
    filtered_blobs = []

    for blob in blobs:
        if blob.name not in ['listing.html', 'profiles/index']:
            print(f"Adding { blob.name }")
            filtered_blobs.append(blob)

    # There is a hard limitation of 256 items on the `delete_blobs` azure method,
    # So we need to chunk the list of blobs.
    for chunk in chunked((b.name for b in filtered_blobs), 256):
        container_client.delete_blobs(*chunk)  # 256 items limit?

    # Upload indexes
    for filename, bytes_io_obj in index_files.items():
        blob = blob_srv.get_blob_client(container, filename)
        blob.upload_blob(bytes_io_obj, content_settings=json_content_settings, overwrite=True)

    for schema_path_parts in schema_pub_paths:
        file_path = str(files_root / "/".join(schema_path_parts))
        blob = blob_srv.get_blob_client(container, create_object_name(schema_path_parts))
        with open(file_path, "rb") as bf:
            blob.upload_blob(bf, content_settings=json_content_settings, overwrite=True)

    for doc_path_parts in doc_pub_paths:
        file_path = str(files_root / "/".join(doc_path_parts))
        object_name = "/".join(doc_path_parts[1:])

        blob = blob_srv.get_blob_client(container, object_name)
        with open(file_path, "rb") as bf:
            blob.upload_blob(bf, content_settings=html_content_settings, overwrite=True)

    for sql_path_parts in sql_pub_paths:
        file_path = str(files_root / "/".join(sql_path_parts))
        object_name = "/".join(sql_path_parts[1:])

        blob = blob_srv.get_blob_client(container, object_name)
        with open(file_path, "rb") as bf:
            blob.upload_blob(bf, content_settings=sql_content_settings, overwrite=True)


@click.command()  # type: ignore[misc]
@click.option(
    "--container",
    envvar="STORAGE_CONTAINER",
    default=DEFAULT_STORAGE_CONTAINER,
    help="""The name of the storage container, default is "schemas".""",
)  # type: ignore[misc]
@click.option(
    "--schema-base-url",
    envvar="SCHEMA_BASE_URL",
    help="Override the base url in schema files (for testing).",
)  # type: ignore[misc]
def main(container: str, schema_base_url: str) -> None:
    """Publish a set of amsterdam schema files to a storage container."""
    ROOT_PKG_NAME = "amsterdam_schema"
    with TemporaryDirectory() as temp_dir:
        files_root = Path(temp_dir)

        # First fetch the datasets and schemas
        schema_pub_paths = fetch_local_as_publishable(ROOT_PKG_NAME, files_root)
        if schema_base_url is not None:
            replace_schema_base_url(files_root, schema_base_url)

        # Create the index files
        index_files = {
            "datasets/index": get_index_file_obj(schema_pub_paths, files_root),
            "publishers/index": _bytes_io_json(fetch_publisher_files),
            "scopes/index": _bytes_io_json(fetch_scope_index),
            "scopes/packages": _bytes_io_json(fetch_access_packages),
            "scopes/scopes": _bytes_io_json(fetch_scope_files),
            "datasets/index.json": get_index_file_obj(schema_pub_paths, files_root),
            "publishers/index.json": _bytes_io_json(fetch_publisher_files),
            "scopes/index.json": _bytes_io_json(fetch_scope_index),
            "scopes/packages.json": _bytes_io_json(fetch_access_packages),
            "scopes/scopes.json": _bytes_io_json(fetch_scope_files),
        }

        # Then fetch the documentation
        doc_pub_paths = fetch_local_as_publishable(
            ROOT_PKG_NAME, files_root, ("docs",), "**/*.html"
        )

        sql_pub_paths = fetch_local_as_publishable(
            root_pkg_name=ROOT_PKG_NAME, temp_dir_path=files_root, glob="**/*.sql"
        )

        logger.info("Using azure blob uploader")
        azure_blob_uploader(
            container,
            files_root,
            schema_pub_paths,
            doc_pub_paths,
            sql_pub_paths,
            index_files,
        )


@click.command()  # type: ignore[misc]
def generate_indexjson() -> None:
    """Generate an index.json.

    With paths relative to the datasets directory.
    """
    with TemporaryDirectory() as name:
        tmpstore = Path(name)
        buf = get_index_file_obj(
            fetch_local_as_publishable("amsterdam_schema", tmpstore), tmpstore
        )
        sys.stdout.write(buf.read().decode())


def fetch_publisher_files() -> list[str]:
    """Get all publisher files from the filesystem.

    These are always stored under root/publishers
    """
    # filter publishers.json for backwards compat, this can be removed
    # when the file has been removed from the repo
    return sorted(
        [
            x.stem
            for x in Path(".").glob(PUBLISHERS_DIR + "/*.json")
            if x.name not in ("publishers.json", "index.json")
        ]
    )


def _bytes_io_json(fetcher: Callable) -> BytesIO:
    return BytesIO(json.dumps(fetcher()).encode())


def fetch_scope_index() -> Dict[str, List[str]]:
    result = {}
    for p in Path(".").glob(SCOPES_DIR + "/**/*.json"):
        if p.stem in SCOPES_IGNORED_FILES:
            continue
        if p.parent.stem not in result:
            result[p.parent.stem] = [p.stem]
        else:
            result[p.parent.stem].append(p.stem)
        result[p.parent.stem].sort()
    return result


def fetch_scope_files() -> list[dict]:
    result = []
    for p in Path(".").glob(SCOPES_DIR + "/**/*.json"):
        if p.stem in SCOPES_IGNORED_FILES + SCOPES_UNAVAILABLE_DATASETS:
            continue
        with open(p) as f:
            scope = json.load(f)
            scope["dbRole"] = "scope_" + scope["id"].lower().replace("/", "_")
            result.append(scope)
    return sorted(result, key=lambda s: s["id"])


def fetch_access_packages() -> list[str]:
    result = set()
    for p in Path(".").glob(SCOPES_DIR + "/**/*.json"):
        if p.stem in SCOPES_IGNORED_FILES:
            continue
        with open(p) as f:
            scope = json.load(f)
            result.update(scope["accessPackages"].values())
    return sorted(result)


if __name__ == "__main__":
    main()
