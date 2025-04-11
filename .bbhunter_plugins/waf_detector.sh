#!/bin/bash
# BBHunter WAF Detector

PLUGIN_NAME="WAF Detector"
PLUGIN_VERSION="1.2"
PLUGIN_AUTHOR="BBHunter Team"
PLUGIN_DESCRIPTION="Identifies Web Application Firewalls"
PLUGIN_CATEGORY="recon"

run_waf_detection() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/waf_detection"
    
    local output_file="$output_dir/plugins/waf_detection/results.txt"
    local wafs_detected=0

    while read -r url; do
        response=$(curl -s -I "$url")
        if [[ "$response" == *"Cloudflare"* ]]; then
            echo "$url - Cloudflare" >> "$output_file"
            ((wafs_detected++))
        elif [[ "$response" == *"Akamai"* ]]; then
            echo "$url - Akamai" >> "$output_file"
            ((wafs_detected++))
        fi
    done < "$input_dir/recon/live_hosts.txt"

    return $wafs_detected
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_waf_detection\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_waf_detection "$1" "$2"
fi
