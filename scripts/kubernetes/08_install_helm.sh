#!/bin/bash

# from https://docs.aws.amazon.com/eks/latest/userguide/helm.html
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

# verify
helm help