#!/bin/bash

# delete kubeflow
cd ${KF_DIR}
kfctl delete -f ${CONFIG_FILE} --delete_storage

# remember to delete all services with an external ip
# refer to: https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html
cd ~/eks_getting_started
eksctl delete cluster -f ./configs/clusters/minimal.yaml