FROM amsterdam/python:3.9-buster
MAINTAINER datapunt@amsterdam.nl

WORKDIR /app
COPY . ./
RUN pip --no-cache-dir install .
