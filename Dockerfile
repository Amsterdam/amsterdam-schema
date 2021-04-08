FROM amsterdam/python:3.8-buster AS builder
MAINTAINER datapunt@amsterdam.nl

WORKDIR /app
COPY . ./
RUN pip --no-cache-dir install .
