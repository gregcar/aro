#!/bin/sh

# Load up .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

oauthCallbackURL=https://oauth-openshift.apps.$CUSTOMCLUSTERDOMAIN/oauth2callback/AAD

app_id=$(az ad app create \
  --query appId -o tsv \
  --display-name $SSOAPPREGNAME \
  --reply-urls $oauthCallbackURL \
  --password $SSOCLIENTSECRET)

read -p "Continuing in 10 Seconds...." -t 10
echo "Continuing ...."

tenant_id=$(az account show --query tenantId -o tsv)

cat > manifest.json<< EOF
[{
  "name": "upn",
  "source": null,
  "essential": false,
  "additionalProperties": []
},
{
"name": "email",
  "source": null,
  "essential": false,
  "additionalProperties": []
}]
EOF

az ad app update \
  --set optionalClaims.idToken=@manifest.json \
  --id $app_id

az ad app permission add \
 --api 00000002-0000-0000-c000-000000000000 \
 --api-permissions 311a71cc-e848-46a1-bdf8-97ff7156d8e6=Scope \
 --id $app_id

 az ad app permission grant \
  --api 00000002-0000-0000-c000-000000000000 \
  --id $app_id