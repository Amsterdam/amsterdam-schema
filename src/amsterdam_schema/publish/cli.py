__doc__ = """

Script that publishes verified schemas to the objectstore.

Course of action is as follows:

* A zipfile of the master branch of the 'amsterdam-schema' repo is fetched from github
* The zip is unpacked to a temporary directory
* The relevant schema files (metaschema + datasets) are pushed to the objectstore
* An json file with an index of the datasets is pushed to the the objectstore
* It is possible to publish the local schema files to the objectstore using the --use-local flag

"""

import functools
import json
import logging
import os
import shutil
from importlib import resources
from io import BytesIO
from os.path import splitext
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Callable, ContextManager, Iterator, List
from zipfile import ZipFile

import click
import in_place
import requests
from swiftclient.service import SwiftError, SwiftService, SwiftUploadObject

logger = logging.getLogger("__name__")


publishable_prefixes = ("datasets", "schema@")
DEFAULT_BASE_URL = "https://schemas.data.amsterdam.nl"


def fetch_publishable_paths(paths: List[str]) -> List[List[str]]:
    publishable_paths = []
    for path in paths:
        path_parts = path.split("/")
        if path_parts[1].startswith(publishable_prefixes) and path_parts[-1]:
            publishable_paths.append(path_parts)
    return publishable_paths


def extract_and_fetch_paths(github_url: str, temp_dir: Path) -> List[List[str]]:
    response = requests.get(github_url, stream=True)
    tmp_file = temp_dir / "out.zip"
    with open(tmp_file, "wb") as wf:
        shutil.copyfileobj(response.raw, wf)

    with ZipFile(tmp_file, "r") as zip_file:
        publishable_paths = fetch_publishable_paths(zip_file.namelist())
        zip_file.extractall(
            temp_dir,
            members=("/".join(path_parts) for path_parts in publishable_paths),
        )
    return publishable_paths


def fetch_local_as_publishable(root_pkg_name: str, temp_dir_path: Path) -> List[List[str]]:
    """Fetch publishable artifacts from package as path components.

    Not sure how to describe this function best. I've kept the API, or at least that what it
    returns, identical to its predecessor. It copies the publishable artifacts from the package
    to the ``temp_dir_path`` and returns all relative paths from ``temp_dir_path`` down as a
    list of strings where each string represents a path component.

    Args:
        root_pkg_name: Name of the root package (eg "amsterdam_schema"
        temp_dir_path: Path of the temporary directory to copy publishable artifacts to

    Returns:
        A list of publishable artifacts in the ``temp_dir_path``. Each publishable
        artifacts is identified by a list of its path components from `temp_dir_path`` down
        (eg it does not include the path component of ``temp_dir_path``)

    """
    dst_path = temp_dir_path / root_pkg_name

    # Use importlib to extract resources from the package. This works for regularly installed
    # packages as well as editable installed packages.
    resource_names: Iterator[str] = filter(
        lambda res: any(map(lambda pre: res.startswith(pre), publishable_prefixes)),
        resources.contents(root_pkg_name),
    )
    resource_path_func: Callable[[str], ContextManager[Path]] = functools.partial(
        resources.path, root_pkg_name
    )
    res_path_ctx_mgrs: Iterator[ContextManager[Path]] = map(resource_path_func, resource_names)

    for rpcm in res_path_ctx_mgrs:
        with rpcm as dir_path:
            # if the package is a zip file the context manager unzips the resource (`dir_path`)
            # into a temporary directory.
            shutil.copytree(
                dir_path.as_posix(), (dst_path / dir_path.name).as_posix(), dirs_exist_ok=True
            )

    publishable_paths: List[List[str]] = []
    for schema_path in dst_path.glob("**/*json"):
        sub_path = schema_path.relative_to(dst_path.parent)
        publishable_paths.append(list(sub_path.parts))

    return publishable_paths


def get_index_file_obj(publishable_paths: List[List[str]]) -> BytesIO:
    index = {}
    for path_parts in publishable_paths:
        if path_parts[1] != "datasets":
            continue
        dataset_ext = path_parts[-1]
        folder = "/".join(path_parts[2:-1])
        dataset = splitext(dataset_ext)[0]
        index[dataset] = f"{folder}/{dataset}"
    return BytesIO(json.dumps(index).encode("utf-8"))


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
                        line = line.replace(DEFAULT_BASE_URL, schema_base_url)
                        file.write(line)


@click.command()
@click.option(
    "--dp-env",
    envvar="DATAPUNT_ENVIRONMENT",
    default="acceptance",
    help="Override the environment to be used, values can be 'acceptance' or 'production'",
)
@click.option(
    "--github-url",
    envvar="GITHUB_ZIP_URL",
    default="https://github.com/Amsterdam/amsterdam-schema/archive/master.zip",
    help="Override the url to the zip on github (to use a specific branch for testing)",
)
@click.option(
    "--schema-base-url",
    envvar="SCHEMA_BASE_URL",
    help="Override the base url in schema files (for testing)",
)
@click.option(
    "--use-local",
    is_flag=True,
    help="Use local schema files, not the github zip archive",
)
def main(dp_env: str, github_url: str, schema_base_url: str, use_local: bool) -> None:
    # We extract the zip, because otherwise we need a big set
    # of open file handles during upload, now we can use file-paths
    with TemporaryDirectory() as temp_dir:
        files_root = Path(temp_dir)
        if use_local:
            publishable_paths = fetch_local_as_publishable("amsterdam_schema", files_root)
        else:
            publishable_paths = extract_and_fetch_paths(github_url, files_root)

        if schema_base_url is not None:
            replace_schema_base_url(files_root, schema_base_url)
        index_file_obj = get_index_file_obj(publishable_paths)

        with SwiftService() as swift:
            try:
                uploads = [SwiftUploadObject(index_file_obj, object_name="datasets/index.json")]
                for path_parts in publishable_paths:
                    object_name = create_object_name(path_parts)
                    uploads.append(
                        SwiftUploadObject(
                            str(files_root / "/".join(path_parts)),
                            object_name=object_name,
                            options={"header": ["content-type:application/json"]},
                        )
                    )
                for r in swift.upload(f"schemas-{dp_env}", uploads):
                    if not r["success"]:
                        logger.error(r["error"])

            except SwiftError as e:
                logger.exception(e.value)


if __name__ == "__main__":
    main()
