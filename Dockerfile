FROM ubuntu:22.04

ARG USER_ID
ARG GROUP_ID

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bash \
    nano \
    rsync \
    sudo \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup user & group for development, fixes permissions issues
RUN addgroup --gid $GROUP_ID notifi-dev \
    && adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID notifi-dev \
    && mkdir -p /etc/sudoers.d \
    && echo 'notifi-dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/notifi-dev \
    && chmod 0440 /etc/sudoers.d/notifi-dev

WORKDIR /home/notifi-dev/
# Copy assets and executables
RUN git clone https://github.com/notifi-network/notifi-parser-sdk.git \
    && mv notifi-parser-sdk/assets assets \
    && mv notifi-parser-sdk/executables/* /usr/local/bin/ \
    && rm -rf notifi-parser-sdk


USER notifi-dev

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 20.11.0 \
    && npm install -g @notifi-network/local-fusion@3.0.21 


# Make executables executable
RUN sudo chmod +x /usr/local/bin/newparser /usr/local/bin/entrypoint

# Update PATH environment variable
ENV PATH="/usr/local/bin:${PATH}"

# Set the working directory to the development environment
WORKDIR /home/notifi-dev/fusion-sources

USER notifi-dev

# Expose the port the app runs on
EXPOSE 9229

# Set the container's entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
