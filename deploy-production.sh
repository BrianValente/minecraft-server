#!/bin/sh -e

IMAGE="docker.home.valente.ar/svc-minecraft:$(uuidgen)"
docker build -t $IMAGE .
docker push $IMAGE
helm upgrade --install --create-namespace --namespace svc-minecraft svc-minecraft ./chart -f ./values-production.yaml --set image=$IMAGE
