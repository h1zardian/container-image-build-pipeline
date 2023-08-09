#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/devcontainers/universal:2-linux

# User customizations
RUN echo "alias tfm='terraform'" >> /etc/bash.bashrc && \
    mkdir /home/codespace/.aws

RUN curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" && \
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep "Linux_amd64" | sha256sum --check && \
    tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && \
    rm eksctl_Linux_amd64.tar.gz && \
    mv /tmp/eksctl /usr/local/bin