#!/bin/sh -e

IMAGE="docker.home.valente.ar/svc-minecraft:$(uuidgen)"
docker build -t $IMAGE .
helm upgrade --install --create-namespace --namespace svc-minecraft-staging svc-minecraft ./chart -f ./values-staging.yaml --set image=$IMAGE
