#!/bin/sh -e

IMAGE="harbor.home.valente.ar/library/svc-minecraft:$(uuidgen)"
docker build -t $IMAGE .
docker push $IMAGE
helm upgrade --install --create-namespace --namespace svc-minecraft-staging svc-minecraft ./chart -f ./values-staging.yaml --set image=$IMAGE
