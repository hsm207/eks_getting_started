#!/bin/bash

# from https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

BUCKET=amazon-eks

VERSION=`aws s3 ls s3://$BUCKET/ |
    grep --invert-match "cloudformation\|manifests" |
    awk '{print $2}' |
    cut -d/ -f 1 |
    sort --version-sort --reverse |
    head -n 1`

echo "The latest aws-iam-authenticator version is" $VERSION

KEY=`aws s3 ls --recursive s3://$BUCKET/$VERSION/ |
    grep linux/amd64/aws-iam-authenticator$ |
    tr -s ' ' |
    cut -d ' ' -f 4`

echo "Copying aws-iam-authenticator from" s3://$BUCKET/$KEY

aws s3 cp s3://$BUCKET/$KEY .
chmod +x ./aws-iam-authenticator
sudo mv  aws-iam-authenticator /usr/local/bin

# verify installation
aws-iam-authenticator help