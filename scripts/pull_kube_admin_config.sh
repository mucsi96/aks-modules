#!/bin/bash

mkdir -p .kube
terraform output -raw k8s_admin_config > .kube/admin-config