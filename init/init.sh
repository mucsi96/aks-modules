#!/bin/bash

terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
terraform output -raw remote_backend_config > ../backend.tf

(cd ".." && terraform init -reconfigure)