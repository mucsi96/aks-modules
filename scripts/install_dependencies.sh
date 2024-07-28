#!/bin/bash

brew update && brew install azure-cli terraform

terraform init --upgrade

helm repo add mucsi96 https://mucsi96.github.io/k8s-helm-charts