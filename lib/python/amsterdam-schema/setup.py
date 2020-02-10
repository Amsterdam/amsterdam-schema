from os import path
from setuptools import find_packages
from setuptools import setup


def read(filename):
    this_directory = path.abspath(path.dirname(__file__))
    with open(path.join(this_directory, filename), encoding="utf-8") as f:
        return f.read()


setup(
    name="amsterdam-schema",
    version="0.1.2",
    url="https://github.com/Amsterdam/amsterdam-schema",
    license="Mozilla Public 2.0",
    author="Jan Murre",
    author_email="jan.murre@catalyz.nl",
    description="Python types for working with Amsterdam Schema",
    long_description=read("README.md"),
    long_description_content_type="text/markdown",
    packages=find_packages(exclude=("tests",)),
    install_requires=["requests", "jsonschema"],
    extras_require={"tests": ["pytest"]},
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "License :: OSI Approved :: Mozilla Public License 2.0 (MPL 2.0)",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
    ],
)
