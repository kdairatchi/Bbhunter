#!/bin/bash
# BBHunter Sensitive Content Finder

PLUGIN_NAME="Sensitive Content Finder"
PLUGIN_VERSION="1.2"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Finds sensitive content in web pages"
PLUGIN_CATEGORY="vulnerability"

run_sensitive_find() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/sensitive_content"
    
    local output_file="$output_dir/plugins/sensitive_content/results.txt"
    local findings=0

    while read -r url; do
        content=$(curl -s "$url")
        
        # Check for passwords in comments
        if echo "$content" | grep -q "<!--.*password.*-->"; then
            echo "Password in comments: $url" >> "$output_file"
            ((findings++))
        fi
        
        # Check for API keys
        if echo "$content" | grep -qE "[a-f0-9]{32}"; then
            echo "Possible API key: $url" >> "$output_file"
            ((findings++))
        fi
    done < "$input_dir/recon/live_hosts.txt"

    return $findings
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_sensitive_find\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_sensitive_find "$1" "$2"
fi
