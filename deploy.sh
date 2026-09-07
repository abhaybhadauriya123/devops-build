#!/bin/bash

set -e

echo "Deploying application..."

docker compose down
docker compose up -d

echo "Checking running container..."
docker compose ps

echo "Checking application health..."
curl -I http://localhost

echo "Deployment completed successfully."
