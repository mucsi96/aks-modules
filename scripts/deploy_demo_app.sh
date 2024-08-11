#!/bin/bash

host=$(az keyvault secret show --vault-name p02 --name hostname --query value --output tsv)
apiClientId=$(az keyvault secret show --vault-name p02 --name demo-api-client-id --query value -o tsv)
issuer=$(az keyvault secret show --vault-name p02 --name issuer --query value -o tsv)
dbUsername=$(az keyvault secret show --vault-name p02 --name demo-db-username --query value -o tsv)
dbPassword=$(az keyvault secret show --vault-name p02 --name demo-db-password --query value -o tsv)

helm repo update

helm upgrade \
    --install \
    --force \
    --kubeconfig .kube/admin-config \
    --namespace demo \
    --set image=mucsi96/demo-client \
    --set host=demo.$host \
    --set basePath="" \
    --set env.AUTH_TOKEN_AGENT=https://auth.$host \
    --set env.API_CLIENT_ID=$apiClientId \
    --wait \
    demo-client \
    mucsi96/client-app

helm upgrade \
    --install \
    --force \
    --kubeconfig .kube/admin-config \
    --namespace demo \
    --set image=mucsi96/demo-server \
    --set host=demo.$host \
    --set basePath="/api" \
    --set env.ISSUER=$issuer \
    --set env.POSTGRES_HOSTNAME=demo-db \
    --set env.POSTGRES_PORT=5432 \
    --set env.POSTGRES_DB=demo \
    --set env.POSTGRES_USER=$dbUsername \
    --set env.POSTGRES_PASSWORD="$dbPassword" \
    --wait \
    demo-server \
    mucsi96/spring-app