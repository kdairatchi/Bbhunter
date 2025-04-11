#!/bin/bash
# CORS misconfig check
INPUT="$1"
OUTPUT="$2/plugins/cors_results.txt"

echo "[*] Checking for CORS misconfigs..."
cat "$2/vulns/live_hosts.txt" | while read -r url; do
    curl -s -H "Origin: evil.com" -I "$url" | grep "Access-Control-Allow-Origin" >> "$OUTPUT"
done
