import shutil
import requests


# download the zip
# unzip in python
# push to objectstore


tmp_file = "/tmp/out.zip"
url = "https://github.com/Amsterdam/amsterdam-schema/archive/master.zip"

response = requests.get(url, stream=True)

with open(tmp_file, "wb") as wf:
    shutil.copyfileobj(response.raw, wf)
