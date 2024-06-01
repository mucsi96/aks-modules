#!/bin/bash

terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

az keyvault secret show --vault-name p02 --name remote-backend-config --query value --output tsv > ../backend.tf

(cd ".." && terraform init -reconfigure)