#!/bin/bash

# based on https://www.kubeflow.org/docs/aws/deploy/install-kubeflow/

# install the the latest kfctl
LATEST_KFCTL=`curl -s https://api.github.com/repos/kubeflow/kfctl/releases |
    jq ".[0].assets | map(select(.name | contains(\"linux\"))) | .[0].browser_download_url" |
    tr -d '"'`

echo "Downloading kfctl from" $LATEST_KFCTL

curl --location $LATEST_KFCTL | 
    tar xz -C /tmp

sudo mv /tmp/kfctl /usr/local/bin


# set the config file
# match version with kfctl
KFCTL_VERSION=`basename $LATEST_KFCTL |
    cut -d _ -f 2 |
    cut -d - -f 1`

export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/master/kfdef/kfctl_aws.$KFCTL_VERSION.yaml"


# location to store kubeflow deployments
# assume there is only 1 cluster in the default region
export AWS_CLUSTER_NAME=`eksctl get clusters |
    tail -n 1 |
    cut -f 1`
export KF_NAME=${AWS_CLUSTER_NAME}

export BASE_DIR=$HOME/kubeflow
export KF_DIR=${BASE_DIR}/${KF_NAME}


# download configuration files
mkdir -p ${KF_DIR}
cd ${KF_DIR}

wget -O kfctl_aws.yaml $CONFIG_URI
export CONFIG_FILE=${KF_DIR}/kfctl_aws.yaml

# pick option 1: Use IAM For Service Account  
cat $CONFIG_FILE |
    awk -v default_region=$AWS_DEFAULT_REGION '{sub(/us-west-2/, default_region)}1' |
    awk '/region/ {print; print "      enablePodIamPolicy: true"; next}1' |
    awk '/(roles:)|(eksctl-kubeflow-aws-nodegroup-ng)/ {next}1' > \
    /tmp/config.yml

mv /tmp/config.yml $CONFIG_FILE


# deploy!!!
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_FILE}
# Important!!! By default, these scripts create an AWS Application Load Balancer for Kubeflow that is open to public. 
# This is good for development testing and for short term use, but we do not recommend that you use this configuration for 
# production workloads.
# See: https://www.kubeflow.org/docs/aws/authentication/


# access dashboard
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80