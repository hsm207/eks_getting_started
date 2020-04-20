# Steps to create storage

1. Create an S3 bucket named `eks-datasets`.
2. Create a Lustre filesystem using Amazon FSx for Lustre and link the S3 bucket to it. Click [here](https://docs.aws.amazon.com/fsx/latest/LustreGuide/getting-started.html) for details.
3. Make sure the filesystem's Network and Security settings matches the cluster's nodegroup settings. Click [here](https://www.kubeflow.org/docs/aws/storage/) for more details.
4. Take note of the following details of the filesystems:
    * File System ID
    * DNS Name
    * Mount Name