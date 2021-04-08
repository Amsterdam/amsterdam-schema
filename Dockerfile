FROM amsterdam/python:3.8-buster
MAINTAINER datapunt@amsterdam.nl

WORKDIR /app
COPY . ./
RUN pip --no-cache-dir install .
