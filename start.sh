#!/bin/bash

# Constants
NOTIFI_DIRECTORY="$HOME/.notifi"
DEVELOPMENT_ENVIRONMENT_DIRECTORY="$NOTIFI_DIRECTORY/fusion-development"
CREDENTIALS_DIRECTORY="$NOTIFI_DIRECTORY/credentials"
FUSION_SOURCES_DIRECTORY="$DEVELOPMENT_ENVIRONMENT_DIRECTORY/fusion-sources"

DEV_AUTH_TOKEN_FILE="$CREDENTIALS_DIRECTORY/dev-token.txt"
DOCKER_COMPOSE_FILE_LOCATION="$DEVELOPMENT_ENVIRONMENT_DIRECTORY/docker-compose.yml"
DOCKER_FILE_LOCATION="$DEVELOPMENT_ENVIRONMENT_DIRECTORY/Dockerfile"

DOCKER_COMPOSE_DOWNLOAD_URL="https://raw.githubusercontent.com/notifi-network/notifi-parser-sdk/main/docker-compose.yml"
DOCKER_FILE_DOWNLOAD_URL="https://raw.githubusercontent.com/notifi-network/notifi-parser-sdk/main/Dockerfile"


# Check if Docker daemon is running, if not, exit with a message
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not reachable. Please start Docker and try again."
    exit 1
fi

# Step 1: Setup the required directories on host machine

# Array of directories to create
directories=($NOTIFI_DIRECTORY $DEVELOPMENT_ENVIRONMENT_DIRECTORY $CREDENTIALS_DIRECTORY $FUSION_SOURCES_DIRECTORY)

# Loop through the array of required directories and create if they don't exist
for dir in "${directories[@]}"; do
    if [[ ! -d $dir ]]; then
        mkdir -p "$dir"
    fi
done

if [[ ! -f $DEV_AUTH_TOKEN_FILE ]]; then        
    touch "$DEV_AUTH_TOKEN_FILE"
fi

# Step 2: Download the latest version of the docker-compose file
rm -f $DOCKER_COMPOSE_FILE_LOCATION
rm -f $DOCKER_FILE_LOCATION
curl -fsSL -o $DOCKER_COMPOSE_FILE_LOCATION $DOCKER_COMPOSE_DOWNLOAD_URL
curl -fsSL -o $DOCKER_FILE_LOCATION $DOCKER_FILE_DOWNLOAD_URL

# Step 3: Run the docker-compose file
# Stop existing containers, if any
docker-compose -f $DOCKER_COMPOSE_FILE_LOCATION down || true

# Run Docker Compose for localfusion service
docker-compose -f $DOCKER_COMPOSE_FILE_LOCATION up -d localfusion
# Run Docker Compose for fusion-development service
USER_ID=$(id -u) GROUP_ID=$(id -g) DOCKER_FILE_LOCATION=$DEVELOPMENT_ENVIRONMENT_DIRECTORY docker-compose -f $DOCKER_COMPOSE_FILE_LOCATION up --build --detach fusion-development

# Display the latest logs and then continue
docker-compose -f $DOCKER_COMPOSE_FILE_LOCATION logs fusion-development
# Attach to the container for interaction
docker attach fusion-development
