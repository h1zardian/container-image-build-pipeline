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
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y software-properties-common \
    && add-apt-repository universe \
    && rm -rf /var/lib/apt/lists/*


# Define build stage
FROM base AS build

# Install additional build tools
RUN apt-get update \
    && apt-get install -y build-essential cmake cppcheck valgrind clang lldb llvm gdb python3-dev \
    && apt-get install -yq vim vim-doc xtail software-properties-common libsecret-1-dev \
    && apt-get install -y --no-install-recommends libnss3 libnspr4 libatk-bridge2.0-0 libatk1.0-0 libx11-6 libpangocairo-1.0-0 \
                                                  libx11-xcb1 libcups2 libxcomposite1 libxdamage1 libxfixes3 libpango-1.0-0 libgbm1 libgtk-3-0 \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y \
    # Move first run notice to right spot
    && mkdir -p "/usr/local/etc/vscode-dev-containers/" \
    && mv -f /tmp/scripts/first-run-notice.txt /usr/local/etc/vscode-dev-containers/

# Define final stage
FROM base AS final

# Copy from build stage
COPY --from=build /usr/local/etc/vscode-dev-containers /usr/local/etc/vscode-dev-containers

# Default to bash shell (other shells available at /usr/bin/fish and /usr/bin/zsh)
ENV SHELL=/usr/bin/zsh

# User customizations
RUN python3 -m pip install --user --upgrade pip \
    && python3 -m pip install --user ansible-lint \
    && echo "alias tfm='terraform'" >> /etc/bash.bashrc

# Remove scripts now that we're done with them
RUN apt-get clean -y && rm -rf /tmp/scripts

# Mount for docker-in-docker 
VOLUME [ "/var/lib/docker" ]

# Fire Docker/Moby script if needed
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh"]
CMD [ "sleep", "infinity" ]
