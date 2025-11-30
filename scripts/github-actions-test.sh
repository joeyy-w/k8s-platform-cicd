#!/bin/bash
set -e

echo "=== GitHub Actions Test ==="

# Build the image
docker build -t sample-microservice:latest ./apps/sample-microservice

# Test the container
docker run -d --name test-container sample-microservice:latest
sleep 10

# Test health endpoint
if docker exec test-container curl -s http://localhost:8090/health | grep -q healthy; then
    echo "✅ Health endpoint working"
else
    echo "❌ Health endpoint failed"
    docker logs test-container
    exit 1
fi

# Clean up
docker stop test-container
docker rm test-container

echo "✅ All tests passed!"
