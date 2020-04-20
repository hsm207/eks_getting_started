#!/bin/bash

# from: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

BUCKET=amazon-eks

LATEST_KUBECTL_VERSION=`aws s3 ls s3://$BUCKET/ |
    grep --invert-match "cloudformation\|manifests" |
    awk '{print $2}' |
    cut -d/ -f 1 |
    sort --version-sort --reverse |
    head -n 1`

echo "The latest kubectl version is" $LATEST_KUBECTL_VERSION

KEY=`aws s3 ls --recursive s3://$BUCKET/$LATEST_KUBECTL_VERSION/ |
    grep linux/amd64/kubectl$ |
    tr -s ' ' |
    cut -d ' ' -f 4`

echo "Copying kubectl from" s3://$BUCKET/$KEY
aws s3 cp s3://$BUCKET/$KEY .

chmod +x ./kubectl

# copy kubectl to a folder in PATH
sudo mv  kubectl /usr/local/bin

# verify version installed
 kubectl version --short --client