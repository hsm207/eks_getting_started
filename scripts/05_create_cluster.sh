#!/bin/bash

# more details: https://eksctl.io/usage/creating-and-managing-clusters/
eksctl create cluster -f ./configs/clusters/minimal.yaml
