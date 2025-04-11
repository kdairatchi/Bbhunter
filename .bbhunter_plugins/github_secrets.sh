#!/bin/bash
# BBHunter GitHub Secrets Scanner

PLUGIN_NAME="GitHub Secrets Scanner"
PLUGIN_VERSION="1.3"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Scans for exposed secrets in GitHub repositories"
PLUGIN_CATEGORY="vulnerability"

run_secrets_scan() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/github_secrets"
    
    local output_file="$output_dir/plugins/github_secrets/results.txt"
    local secrets_found=0

    while read -r url; do
        if [[ "$url" == *"github.com"* ]]; then
            if curl -s "$url" | grep -qE "api_key|secret|password"; then
                echo "$url" >> "$output_file"
                ((secrets_found++))
            fi
        fi
    done < "$input_dir/recon/urls/all_urls.txt"

    return $secrets_found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_secrets_scan\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_secrets_scan "$1" "$2"
fi
