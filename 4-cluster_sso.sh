#!/bin/sh

# Load up .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

CLUSTERAPISERVER=$(az aro show -g $RESOURCEGROUP -n $CLUSTERNAME --query apiserverProfile.url -o tsv)
tenant_id=$(az account show --query tenantId -o tsv)
app_id=$(az ad app list --display-name $SSOAPPREGNAME --query [].appId -o tsv);

kubeadmin_password=$(az aro list-credentials \
  --name $CLUSTERNAME \
  --resource-group $RESOURCEGROUP \
  --query kubeadminPassword --output tsv)

oc login $CLUSTERAPISERVER -u kubeadmin -p $kubeadmin_password

oc create secret generic openid-client-secret-azuread \
  --namespace openshift-config \
  --from-literal=clientSecret=$SSOCLIENTSECRET

cat > oidc.yaml<< EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: AAD
    mappingMethod: claim
    type: OpenID
    openID:
      clientID: $app_id
      clientSecret:
        name: openid-client-secret-azuread
      extraScopes:
      - email
      - profile
      extraAuthorizeParameters:
        include_granted_scopes: "true"
      claims:
        preferredUsername:
        - email
        - upn
        name:
        - name
        email:
        - email
      issuer: https://login.microsoftonline.com/$tenant_id
EOF

oc apply -f oidc.yaml

#oauth.config.openshift.io/cluster configured