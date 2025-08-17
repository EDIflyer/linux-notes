#!/bin/bash

set -e  # Exit on any error

# Configuration
REPO_DIR="$HOME/repositories/testube"
REPO_URL="https://github.com/EDIflyer/testube.git"
IMAGE_NAME="ediflyer/testube"
CONTAINER_NAME="testube"
NETWORK="nginx-proxy-manager_default"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting testube deployment script"

# Clone or update repository
NEEDS_REBUILD=false
if [ ! -d "$REPO_DIR" ]; then
    log "Creating $REPO_DIR and cloning repository"
    mkdir -p "$REPO_DIR"
    git clone "$REPO_URL" "$REPO_DIR"
    NEEDS_REBUILD=true
else
    log "Repository exists, checking for updates"
    cd "$REPO_DIR"
    
    # Get current commit hash
    OLD_COMMIT=$(git rev-parse HEAD)
    
    # Pull latest changes
    git pull
    
    # Get new commit hash
    NEW_COMMIT=$(git rev-parse HEAD)
    
    # Check if there were changes
    if [ "$OLD_COMMIT" != "$NEW_COMMIT" ]; then
        log "Changes detected (${OLD_COMMIT:0:7} -> ${NEW_COMMIT:0:7})"
        NEEDS_REBUILD=true
    else
        log "No changes detected, skipping rebuild"
    fi
fi

# Change to repository directory
cd "$REPO_DIR"

# Build Docker image only if needed
if [ "$NEEDS_REBUILD" = true ]; then
    log "Building Docker image: $IMAGE_NAME"
    docker build -t "$IMAGE_NAME" .
else
    log "Skipping image build - no changes detected"
fi

# Stop and remove existing container (if it exists)
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log "Stopping and removing existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
else
    log "No existing container found"
fi

# Run new container
log "Starting new container: $CONTAINER_NAME"
docker run -d \
    --net "$NETWORK" \
    --restart unless-stopped \
    --name "$CONTAINER_NAME" \
    --label "com.centurylinklabs.watchtower.enable=false" \
    "$IMAGE_NAME:latest"

if [ "$NEEDS_REBUILD" = true ]; then
    log "Deployment completed successfully with rebuild"
else
    log "Deployment completed successfully with restart only"
fi