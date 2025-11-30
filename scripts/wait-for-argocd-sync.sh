#!/bin/bash
set -e

APP_NAME=$1
TIMEOUT=600
INTERVAL=10

echo "Waiting for ArgoCD application $APP_NAME to sync..."

for ((i=0; i<TIMEOUT/INTERVAL; i++)); do
    STATUS=$(argocd app get $APP_NAME -o json | jq -r '.status.sync.status')
    
    if [ "$STATUS" == "Synced" ]; then
        echo "ArgoCD application $APP_NAME is synced!"
        exit 0
    fi
    
    echo "Current sync status: $STATUS (waiting...)"
    sleep $INTERVAL
done

echo "Timeout waiting for ArgoCD sync"
exit 1
