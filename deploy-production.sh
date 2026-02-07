#!/bin/sh -e

IMAGE="harbor.home.valente.ar/library/svc-minecraft:$(uuidgen)"
docker build -t $IMAGE .
docker push $IMAGE
helm upgrade --install --create-namespace --namespace svc-minecraft svc-minecraft ./chart -f ./values-production.yaml --set image=$IMAGE
