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
