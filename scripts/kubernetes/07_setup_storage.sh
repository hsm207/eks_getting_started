#!/bin/bash

# from https://aws.amazon.com/blogs/opensource/using-fsx-lustre-csi-driver-amazon-eks/
# and
# from https://github.com/kubernetes-sigs/aws-fsx-csi-driver
pushd /tmp

# create an IAM policy to allow FSx use
cat >policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy"
       ],
      "Resource": "arn:aws:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.amazonaws.com/*"
    },
    {
      "Action":"iam:CreateServiceLinkedRole",
      "Effect":"Allow",
      "Resource":"*",
      "Condition":{
        "StringLike":{
          "iam:AWSServiceName":[
            "fsx.amazonaws.com"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "fsx:CreateFileSystem",
        "fsx:DeleteFileSystem",
        "fsx:DescribeFileSystems"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF

POLICY_ARN=$(aws iam create-policy --policy-name fsx-csi --policy-document file://./policy.json --query "Policy.Arn" --output text)

popd

#  add the policy to the worker nodes
CLUSTER_NAME="dev"
NODEGROUP_NAME="ng-1"
CLUSTER_STACK_NAME="eksctl-$CLUSTER_NAME-nodegroup-$NODEGROUP_NAME"

INSTANCE_ROLE_NAME=$(aws cloudformation describe-stacks --stack-name $CLUSTER_STACK_NAME --output text --query "Stacks[0].Outputs[1].OutputValue" | 
    sed -e 's/.*\///g')

aws iam attach-role-policy --policy-arn ${POLICY_ARN} --role-name ${INSTANCE_ROLE_NAME}

# deploy the FSx CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"


# configure the storage class
# get cluster's VPC
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=eksctl-$CLUSTER_NAME-cluster/VPC" --query "Vpcs[0].VpcId" --output text)

# get the VPC's subnet
# note that we provisioned the nodegroup to be from "ap-southeast-1a" only
AZ=`echo ${AWS_DEFAULT_REGION^^}A | 
    tr -d '-'`
SUBNET_ID=`aws ec2 describe-subnets \
            --filters "[{\"Name\": \"vpc-id\",\"Values\": [\"$VPC_ID\"]},
                        {\"Name\": \"tag:aws:cloudformation:logical-id\",\"Values\": [\"SubnetPublic$AZ\"]}]" \
            --query "Subnets[0].SubnetId" \
            --output text`

# create the security group
SECURITY_GROUP_ID=`aws ec2 create-security-group \
                    --group-name eks-fsx-security-group \
                    --vpc-id ${VPC_ID} \
                    --description "FSx for Lustre Security Group" \
                    --query "GroupId" \
                    --output text`
aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 988 \
    --cidr 192.168.0.0/16

# create the storage class config
AWS_BUCKET="eks-volume"
pushd /tmp
cat >storage-class.yaml <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fsx-sc
provisioner: fsx.csi.aws.com
parameters:
  subnetId: ${SUBNET_ID}
  securityGroupIds: ${SECURITY_GROUP_ID}
  s3ImportPath: s3://$AWS_BUCKET
  s3ExportPath: s3://$AWS_BUCKET
  deploymentType: SCRATCH_2
EOF

# deploy the storage class config
kubectl apply -f storage-class.yaml
popd

# create and deploy the persistent volume claim
pushd /tmp
cat >claim.yaml <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fsx-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: fsx-sc
  resources:
    requests:
      storage: 1200Gi
EOF

kubectl apply -f claim.yaml
popd

# wait for the pv claim to be Bounded
kubectl get persistentvolumeclaims fsx-claim -w
