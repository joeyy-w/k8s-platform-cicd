#!/bin/bash
set -e

echo "Running integration tests..."
kubectl wait --for=condition=ready pod -l app=sample-microservice -n guestbook-dev --timeout=300s

# Test application endpoints using port 8090
kubectl port-forward svc/sample-microservice -n guestbook-dev 8090:80 &
PORT_FORWARD_PID=$!
sleep 5

echo "Testing application on port 8090..."

# Health check
curl -f http://localhost:8090/health || { kill $PORT_FORWARD_PID; exit 1; }
curl -f http://localhost:8090/ready || { kill $PORT_FORWARD_PID; exit 1; }
curl -f http://localhost:8090/ || { kill $PORT_FORWARD_PID; exit 1; }

kill $PORT_FORWARD_PID
echo "Integration tests passed!"
