package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    "time"
)

func main() {
    // Enhanced logging
    log.Println("Starting sample-microservice...")
    log.Printf("PORT environment variable: %s", os.Getenv("PORT"))
    
    http.HandleFunc("/", handleRoot)
    http.HandleFunc("/health", handleHealth)
    http.HandleFunc("/ready", handleReady)
    http.HandleFunc("/metrics", handleMetrics)

    port := os.Getenv("PORT")
    if port == "" {
        port = "8090"
        log.Printf("Using default port: %s", port)
    }

    log.Printf("Server starting on port %s", port)
    
    // Test that we can bind to the port
    log.Printf("Testing port binding...")
    
    err := http.ListenAndServe(":"+port, nil)
    if err != nil {
        log.Fatalf("Failed to start server: %v", err)
    }
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
    log.Printf("Root endpoint accessed: %s", r.RemoteAddr)
    w.Header().Set("Content-Type", "application/json")
    fmt.Fprintf(w, `{"status": "ok", "timestamp": %d, "environment": "%s"}`, 
        time.Now().Unix(), os.Getenv("ENVIRONMENT"))
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    log.Printf("Health check from: %s", r.RemoteAddr)
    w.Header().Set("Content-Type", "application/json")
    fmt.Fprintf(w, `{"status": "healthy", "timestamp": %d}`, time.Now().Unix())
}

func handleReady(w http.ResponseWriter, r *http.Request) {
    log.Printf("Ready check from: %s", r.RemoteAddr)
    w.Header().Set("Content-Type", "application/json")
    fmt.Fprintf(w, `{"status": "ready", "timestamp": %d}`, time.Now().Unix())
}

func handleMetrics(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/plain")
    fmt.Fprintf(w, `# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="%s",endpoint="%s"} 1
`, r.Method, r.URL.Path)
}
