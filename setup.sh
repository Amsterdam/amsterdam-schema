#!/bin/bash
set -e

cd "$(dirname "$0")"
python3 -m venv venv
source ./venv/bin/activate
pip install pre-commit;
pre-commit install
