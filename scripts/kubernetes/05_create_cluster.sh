#!/bin/bash

# more details: https://eksctl.io/usage/creating-and-managing-clusters/
cd ~/eks_getting_started
eksctl create cluster -f ./configs/clusters/minimal.yaml
