#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Define base stage
FROM ubuntu:focal AS base

COPY first-run-notice.txt /tmp/scripts/

# Set environment variables
ENV LANG="C.UTF-8"
ENV DOCKER_BUILDKIT=1
ENV DEBIAN_FRONTEND=noninteractive

# Install basic build tools
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        make \
        unzip \
        build-essential \
        swig3.0 \
        libpq-dev \
        moreutils \
        rsync \
        zip \
        libgdiplus \
        jq \
        python-pip-whl \
        python3-pip \
        libncurses5 \
        liblttng-ust0 \
        libssl-dev \
        zlib1g \
        libuuid1 \
        libunwind8 \
        sqlite3 \
        libsqlite3-dev \
        software-properties-common \
        tk-dev \
        uuid-dev \
        curl \
        gettext \
    && rm -rf /var/lib/apt/lists/* \
    # This is the folder containing 'links' to benv and build script generator
    && apt-get update \
    && apt-get upgrade -y \
    && add-apt-repository universe \
    # Restore man command
    && yes | unminimize 2>&1 \
    && rm -rf /var/lib/apt/lists/*


# Define build stage
FROM base AS build

# Install additional build tools
RUN apt-get update \
    && apt-get install -y valgrind clang lldb llvm gdb python3-dev \
    && apt-get install -yq vim vim-doc xtail libsecret-1-dev \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y \
    # Move first run notice to right spot
    && mkdir -p "/usr/local/etc/vscode-dev-containers/" \
    && mv -f /tmp/scripts/first-run-notice.txt /usr/local/etc/vscode-dev-containers/

# Define final stage
FROM build AS final

# Copy from build stage
COPY --from=build /usr/local/etc/vscode-dev-containers /usr/local/etc/vscode-dev-containers

# Default to bash shell (other shells available at /usr/bin/fish and /usr/bin/zsh)
ENV SHELL=/usr/bin/bash

# User customizations
RUN echo "alias tfm='terraform'" >> /etc/bash.bashrc

# Remove scripts now that we're done with them
RUN apt-get clean -y && rm -rf /tmp/scripts

# Mount for docker-in-docker 
VOLUME [ "/var/lib/docker" ]

# Fire Docker/Moby script if needed
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh"]
CMD [ "sleep", "infinity" ]
