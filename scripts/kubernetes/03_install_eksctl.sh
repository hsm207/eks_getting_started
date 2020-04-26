#!/bin/bash

# from: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html

# download and extract the latest version of eksctl (including prerelease)

# from: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
LATEST_EKSCTL=`curl -s https://api.github.com/repos/weaveworks/eksctl/releases |
    jq ".[0].assets | map(select(.name == \"eksctl_Linux_amd64.tar.gz\")) | .[0].browser_download_url" |
    tr -d '"'`

echo "Downloading eksctl from" $LATEST_EKSCTL
curl --location $LATEST_EKSCTL | 
    tar xz -C /tmp

# move the extracted binary
sudo mv /tmp/eksctl /usr/local/bin

# install autocomplete
. <(eksctl completion bash)

# test if installation is successful
eksctl version