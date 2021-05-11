#!/bin/sh

# Load up .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

az ad sp create-for-rbac --name $CLUSTERSPNAME
az ad sp list --filter "displayname eq '$CLUSTERSPNAME'" --query "[?appDisplayName=='$CLUSTERSPNAME'].{name: appDisplayName, objectId: objectId}"