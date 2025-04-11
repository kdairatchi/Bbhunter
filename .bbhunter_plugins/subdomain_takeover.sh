#!/bin/bash
# BBHunter Subdomain Takeover Checker

PLUGIN_NAME="Subdomain Takeover Checker"
PLUGIN_VERSION="1.8"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Checks for subdomain takeover vulnerabilities"
PLUGIN_CATEGORY="vulnerability"

run_takeover_check() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/takeover"
    
    local output_file="$output_dir/plugins/takeover/results.txt"
    local vulnerable=0

    while read -r subdomain; do
        response=$(curl -s -I "$subdomain" | head -n 1)
        if [[ "$response" == *"404"* ]] || [[ "$response" == *"NotFound"* ]]; then
            echo "$subdomain" >> "$output_file"
            ((vulnerable++))
        fi
    done < "$input_dir/recon/subdomains/all_subdomains.txt"

    return $vulnerable
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_takeover_check\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_takeover_check "$1" "$2"
fi
