#!/bin/sh

# Load up .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

CLUSTERSPAPPID=$(az ad sp list --filter "displayname eq '$CLUSTERSPNAME'" --query "[?appDisplayName=='$CLUSTERSPNAME'].appId" -o tsv)

az account set --subscription $SUBSCRIPTIONID
az provider register -n Microsoft.RedHatOpenShift --wait
az provider register -n Microsoft.Compute --wait
az provider register -n Microsoft.Storage --wait
az provider register -n Microsoft.Authorization --wait

az network vnet subnet update \
  --name $MASTERSUBNETNAME \
  --resource-group $RESOURCEGROUP \
  --vnet-name $VIRTUALNETWORKNAME \
  --disable-private-link-service-network-policies true \
  --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet update \
  --name $WORKERSUBNETNAME \
  --resource-group $RESOURCEGROUP \
  --vnet-name $VIRTUALNETWORKNAME \
  --disable-private-link-service-network-policies true \
  --service-endpoints Microsoft.ContainerRegistry

az aro create \
  --resource-group $RESOURCEGROUP \
  --name $CLUSTERNAME \
  --vnet $VIRTUALNETWORKNAME \
  --vnet-resource-group $VIRTUALNETWORKRESOURCEGROUP \
  --master-subnet $MASTERSUBNETNAME \
  --worker-subnet $WORKERSUBNETNAME \
  --client-id $CLUSTERSPAPPID \
  --client-secret $CLUSTERSPCLIENTSECRET \
  --domain $CUSTOMCLUSTERDOMAIN \
  --ingress-visibility $INGRESSVISIBILITY \
  --location $LOCATION \
  --master-vm-size $MASTERNODESIZE \
  --worker-vm-size $WORKERNODESIZE \
  --worker-count $WORKERNODECOUNT \
  --worker-vm-disk-size-gb $WORKERNODEDISKSIZE \
  --pull-secret @pull-secret.txt \
  --cluster-resource-group $CLUSTEROBJECTSRESOURCEGROUP

CLUSTERDOMAIN=$(az aro show -g $RESOURCEGROUP -n $CLUSTERNAME --query clusterProfile.domain -o tsv)
CLUSTERAPISERVERIP=$(az aro show -g $RESOURCEGROUP -n $CLUSTERNAME --query apiserverProfile.ip -o tsv)
CLUSTERINGRESSIP=$(az aro show -g $RESOURCEGROUP -n $CLUSTERNAME --query ingressProfiles[0].ip -o tsv)

az network dns record-set a add-record \
                              --resource-group $DNSZONERESOURCEGROUP \
                              --zone-name $CUSTOMCLUSTERDOMAIN \
                              --record-set-name api \
                              --ipv4-address $CLUSTERAPISERVERIP

az network dns record-set a add-record \
                              --resource-group $DNSZONERESOURCEGROUP \
                              --zone-name $CUSTOMCLUSTERDOMAIN \
                              --record-set-name *.apps \
                              --ipv4-address $CLUSTERINGRESSIP