#!/bin/bash
# Favicon hash fuzzing plugin
INPUT="$1"
OUTPUT="$2/plugins/favfuzz.txt"

echo "[*] Running Favicon hash fuzzing..."
cat "$OUTPUT/vulns/live_hosts.txt" | while read -r url; do
    hash=$(curl -s "$url/favicon.ico" | base64 -w0 | sha256sum | awk '{print $1}')
    echo "$url - $hash" >> "$OUTPUT"
done
