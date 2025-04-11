#!/bin/bash
# BBHunter HTTP Header Analyzer

PLUGIN_NAME="Header Analyzer"
PLUGIN_VERSION="1.4"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Analyzes HTTP headers for security issues"
PLUGIN_CATEGORY="vulnerability"

run_header_analysis() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/headers"
    
    local output_file="$output_dir/plugins/headers/results.txt"
    local issues_found=0

    while read -r url; do
        headers=$(curl -s -I "$url")
        
        # Check for missing security headers
        if ! echo "$headers" | grep -q "X-Content-Type-Options"; then
            echo "Missing X-Content-Type-Options on $url" >> "$output_file"
            ((issues_found++))
        fi
        
        if ! echo "$headers" | grep -q "X-Frame-Options"; then
            echo "Missing X-Frame-Options on $url" >> "$output_file"
            ((issues_found++))
        fi
        
        # Check for server version disclosure
        if echo "$headers" | grep -qE "Server:.*[0-9]"; then
            echo "Server version disclosure on $url" >> "$output_file"
            ((issues_found++))
        fi
    done < "$input_dir/recon/live_hosts.txt"

    return $issues_found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_header_analysis\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_header_analysis "$1" "$2"
fi
