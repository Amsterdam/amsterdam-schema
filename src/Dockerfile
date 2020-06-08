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

COPY publish.py /app
