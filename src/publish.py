__doc__ = """

Script that publishes verified schemas to the objectstore.

Course of action is as follows:

* A zipfile of the master branch of the 'amsterdam-schema' repo is fetched from github
* The zip is unpacked to a temporary directory
* The relevant schema files (metaschema + datasets) are pushed to the objectstore
* An json file with an index of the datasets pushed to the the objectstore

"""
import json
import logging
from io import BytesIO
from pathlib import Path
from os.path import splitext
from environs import Env
import requests
from tempfile import TemporaryDirectory
import shutil
from zipfile import ZipFile
from swiftclient.service import SwiftError, SwiftService, SwiftUploadObject

logger = logging.getLogger("__name__")

env = Env()

DATAPUNT_ENVIRONMENT = env("DATAPUNT_ENVIRONMENT", "acceptance")


publishable_folders = {"meta", "datasets", "schema@v1.1.1", "schema@v1.1.0"}

# url = "https://github.com/Amsterdam/amsterdam-schema/archive/master.zip"
# XXX For testing we temporary use a branch with the new schema structure
# Because the master branch, for now, does not have the new directory structure that
# is needed.
url = "https://github.com/Amsterdam/amsterdam-schema/archive/schema-repos-reorg-ds-269.zip"


def fetch_publishable_paths(paths):
    publishable_paths = []
    for path in paths:
        path_parts = path.split("/")
        if path_parts[1] in publishable_folders and path_parts[-1]:
            publishable_paths.append(path_parts)
    return publishable_paths


def get_index_file_obj(publishable_paths):
    index = {}
    for path_parts in publishable_paths:
        if path_parts[1] != "datasets":
            continue
        folder, dataset_ext = path_parts[2:]
        dataset = splitext(dataset_ext)[0]
        index[folder] = f"{folder}/{dataset}"
    return BytesIO(json.dumps(index).encode("utf-8"))


def main():
    publishable_paths = []
    response = requests.get(url, stream=True)

    # We extract the zip, because otherwise we need a big set
    # of open file handles during upload, now we can use file-paths
    with TemporaryDirectory() as temp_dir:
        tmp_file = Path(temp_dir) / "out.zip"
        with open(tmp_file, "wb") as wf:
            shutil.copyfileobj(response.raw, wf)

        with ZipFile(tmp_file, "r") as zip_file:
            publishable_paths = fetch_publishable_paths(zip_file.namelist())
            zip_file.extractall(
                temp_dir,
                members=("/".join(path_parts) for path_parts in publishable_paths),
            )

        index_file_obj = get_index_file_obj(publishable_paths)

        with SwiftService() as swift:
            try:
                uploads = [SwiftUploadObject(index_file_obj, object_name="index.json")]
                for path_parts in publishable_paths:
                    # remove .json extension
                    object_name = "/".join(
                        path_parts[1:-1] + [splitext(path_parts[-1])[0]]
                    )
                    uploads.append(
                        SwiftUploadObject(
                            str(Path(temp_dir) / "/".join(path_parts)),
                            object_name=object_name,
                            options={"header": ["content-type:application/json"]},
                        )
                    )
                for r in swift.upload(f"schemas-{DATAPUNT_ENVIRONMENT}", uploads):
                    if not r["success"]:
                        logger.error(r["error"])

            except SwiftError as e:
                logger.exception(e.value)


if __name__ == "__main__":
    main()
