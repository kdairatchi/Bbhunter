#!/bin/bash
# BBHunter Technology Detector

PLUGIN_NAME="Technology Detector"
PLUGIN_VERSION="1.6"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Identifies web technologies"
PLUGIN_CATEGORY="recon"

run_tech_detection() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/tech_detection"
    
    local output_file="$output_dir/plugins/tech_detection/results.txt"
    local detected=0

    while read -r url; do
        response=$(curl -s -I "$url")
        if [[ "$response" == *"X-Powered-By: PHP"* ]]; then
            echo "$url - PHP" >> "$output_file"
            ((detected++))
        elif [[ "$response" == *"Server: nginx"* ]]; then
            echo "$url - Nginx" >> "$output_file"
            ((detected++))
        fi
    done < "$input_dir/recon/live_hosts.txt"

    return $detected
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_tech_detection\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_tech_detection "$1" "$2"
fi
