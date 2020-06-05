import logging
from pathlib import Path
from os.path import splitext
import requests
from tempfile import TemporaryDirectory
import shutil
from zipfile import ZipFile
from swiftclient.service import SwiftError, SwiftService, SwiftUploadObject

logger = logging.getLogger("__name__")
# download the zip
# unzip in python
# push to objectstore

# use env var to determine acc/prd

# generate full nested index in json format to be used from python
# saves a lot of roundtrips


publishable_folders = {"meta", "datasets", "schema@v1.1.1"}

# url = "https://github.com/Amsterdam/amsterdam-schema/archive/master.zip"
url = "https://github.com/Amsterdam/amsterdam-schema/archive/schema-repos-reorg-ds-269.zip"


def fetch_publishable_paths(paths):
    publishable_paths = []
    for path in paths:
        path_parts = path.split("/")
        if path_parts[1] in publishable_folders and path_parts[-1]:
            publishable_paths.append(path_parts)
    return publishable_paths


def main():
    publishable_paths = []
    response = requests.get(url, stream=True)

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

        with SwiftService() as swift:
            try:
                uploads = []
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
                for r in swift.upload("schemas", uploads):
                    if not r["success"]:
                        logger.error(r["error"])

            except SwiftError as e:
                logger.exception(e.value)


if __name__ == "__main__":
    main()
