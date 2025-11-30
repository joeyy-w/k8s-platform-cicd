#!/bin/bash
set -e

echo "=== Building Microservice ==="

cd apps/sample-microservice

echo "Step 1: Cleaning up..."
rm -f main go.mod go.sum 2>/dev/null || true

echo "Step 2: Creating source files..."
cat > main.go << 'MAIN_EOF'
package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    "time"
)

func main() {
    http.HandleFunc("/", handleRoot)
    http.HandleFunc("/health", handleHealth)
    http.HandleFunc("/ready", handleReady)
    http.HandleFunc("/metrics", handleMetrics)

    port := os.Getenv("PORT")
    if port == "" {
        port = "8090"
    }

    log.Printf("Server starting on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    fmt.Fprintf(w, `{"status": "ok", "timestamp": %d, "environment": "%s"}`, 
        time.Now().Unix(), os.Getenv("ENVIRONMENT"))
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    fmt.Fprintf(w, `{"status": "healthy", "timestamp": %d}`, time.Now().Unix())
}

func handleReady(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    fmt.Fprintf(w, `{"status": "ready", "timestamp": %d}`, time.Now().Unix())
}

func handleMetrics(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/plain")
    fmt.Fprintf(w, `# Simple metrics endpoint
http_requests_total{method="%s",endpoint="%s"} 1
`, r.Method, r.URL.Path)
}
MAIN_EOF

echo "Step 3: Creating Dockerfile..."
cat > Dockerfile << 'DOCKER_EOF'
FROM golang:1.21-alpine as builder

WORKDIR /app

# Initialize go module and copy source
RUN go mod init sample-microservice
COPY main.go .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8090
CMD ["./main"]
DOCKER_EOF

echo "Step 4: Building Docker image..."
docker build -t sample-microservice:latest .

echo "Step 5: Testing the image..."
docker run -d --name test-container -p 8090:8090 sample-microservice:latest
sleep 5

echo "Step 6: Running tests..."
if curl -s http://localhost:8090/health | grep -q healthy; then
    echo "✅ Health endpoint working"
else
    echo "❌ Health endpoint failed"
    exit 1
fi

if curl -s http://localhost:8090/ready | grep -q ready; then
    echo "✅ Ready endpoint working"
else
    echo "❌ Ready endpoint failed"
    exit 1
fi

echo "Step 7: Cleaning up..."
docker stop test-container
docker rm test-container

echo "=== Build successful! ==="
cd ../..
