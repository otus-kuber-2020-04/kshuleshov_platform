#!/bin/sh

docker build $@ \
  --progress plain \
  --tag kshuleshov/otus-kuber-2020-04_kubernetes-monitoring_nginx:latest \
  .
