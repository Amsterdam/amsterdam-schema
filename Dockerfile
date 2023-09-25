FROM python:3.9-bookworm
MAINTAINER datapunt@amsterdam.nl

WORKDIR /app
COPY . ./
RUN pip --no-cache-dir install .
