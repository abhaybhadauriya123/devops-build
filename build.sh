#!/bin/bash

set -e

IMAGE_NAME="devops-build-app"
TAG="${1:-dev}"

echo "Building Docker image..."
echo "Image: ${IMAGE_NAME}:${TAG}"

docker build -t "${IMAGE_NAME}:${TAG}" .

echo "Docker image build completed successfully."
docker images "${IMAGE_NAME}:${TAG}"
