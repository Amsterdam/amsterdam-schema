FROM amsterdam/python:3.8-buster AS builder
MAINTAINER datapunt@amsterdam.nl

COPY requirements* ./
ARG PIP_REQUIREMENTS=requirements.txt
RUN pip install --no-cache-dir -r $PIP_REQUIREMENTS
#
# Start runtime image,
FROM amsterdam/python:3.8-slim-buster

# Copy python build artifacts from builder image
COPY --from=builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/

# We want to publish using `--use-local`. For that we need the entire repo
# to be copied.
WORKDIR /repo
COPY . ./

# Change the workdir to were `publish.py` resides. This way we keep the entrypoint
# to where external systems expect it to be.
WORKDIR /repo/src
