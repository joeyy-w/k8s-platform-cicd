#!/bin/bash
set -e

echo "Running smoke tests in production..."

kubectl wait --for=condition=ready pod -l app=sample-microservice -n guestbook --timeout=300s

# Test using port-forward to avoid port conflicts
kubectl port-forward svc/sample-microservice -n guestbook 8091:80 &
PORT_FORWARD_PID=$!
sleep 5

curl -s http://localhost:8091/health | grep -q healthy || { kill $PORT_FORWARD_PID; exit 1; }

kill $PORT_FORWARD_PID
echo "Smoke tests passed!"
