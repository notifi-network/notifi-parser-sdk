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

# Clone the repo into /tmp directory
WORKDIR /tmp
RUN git clone https://github.com/notifi-network/notifi-parser-sdk.git

# Ensure the script is executable
RUN chmod +x /tmp/notifi-parser-sdk/executables/user-group-handle.sh

# Run the user/group handling script
RUN /tmp/notifi-parser-sdk/executables/user-group-handle.sh ${USER_ID} ${GROUP_ID}

# Switch to root to move files and change ownership
USER root

# Move assets and executables to the proper locations and set correct ownership
RUN mv /tmp/notifi-parser-sdk/assets /home/notifi-dev/ \
    && mv /tmp/notifi-parser-sdk/executables/* /usr/local/bin/ \
    && chown -R notifi-dev:notifi-dev /home/notifi-dev/assets \
    && chown notifi-dev:notifi-dev /usr/local/bin/*

# Cleanup the /tmp directory
RUN rm -rf /tmp/notifi-parser-sdk

# Switch back to notifi-dev user
USER notifi-dev
WORKDIR /home/notifi-dev/

# Install NVM and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 20.11.0 \
    && npm install -g @notifi-network/local-fusion@3.0.22


# Make executables executable
RUN sudo chmod +x /usr/local/bin/newparser /usr/local/bin/entrypoint

# Update PATH environment variable
ENV PATH="/usr/local/bin:${PATH}"

# Set the working directory to the development environment
WORKDIR /home/notifi-dev/fusion-sources

# Expose the port the app runs on
EXPOSE 9229

# Set the container's entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
