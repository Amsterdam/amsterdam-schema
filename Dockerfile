FROM python:3.10-bookworm
MAINTAINER datapunt@amsterdam.nl

WORKDIR /app
COPY . ./
RUN pip --no-cache-dir install .
