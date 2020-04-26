#!/bin/bash

kubectl delete -f /tmp/pod.yaml
kubectl delete -f /tmp/claim.yaml
kubectl delete -f /tmp/storage-class.yaml
kubectl delete -k github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/dev/?ref=master
aws ec2 delete-security-group --group-id ${SECURITY_GROUP_ID}
aws iam detach-role-policy --role-name ${INSTANCE_ROLE_NAME} --policy-arn ${POLICY_ARN}

aws iam delete-policy --policy-arn $POLICY_ARN

kubectl delete -f /tmp/deploy.yaml

# remember to delete all services with an external ip
# refer to: https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html
cd ~/eks_getting_started
eksctl delete cluster -f ./configs/clusters/minimal.yaml