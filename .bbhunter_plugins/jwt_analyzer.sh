#!/bin/bash
# BBHunter JWT Analyzer

PLUGIN_NAME="JWT Analyzer"
PLUGIN_VERSION="1.3"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Identifies and analyzes JWT tokens"
PLUGIN_CATEGORY="vulnerability"

run_jwt_analysis() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/jwt_analysis"
    
    local output_file="$output_dir/plugins/jwt_analysis/results.txt"
    local tokens_found=0

    while read -r url; do
        # Check cookies
        cookies=$(curl -s -I "$url" | grep -i "set-cookie")
        if echo "$cookies" | grep -qE "eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*"; then
            echo "JWT Found in Cookies for $url" >> "$output_file"
            echo "$cookies" >> "$output_file"
            ((tokens_found++))
        fi
        
        # Check Authorization header
        auth=$(curl -s -I -H "Authorization: Bearer dummy" "$url" | grep -i "www-authenticate")
        if [[ -n "$auth" ]]; then
            echo "JWT Auth Required for $url" >> "$output_file"
            ((tokens_found++))
        fi
    done < "$input_dir/recon/live_hosts.txt"

    return $tokens_found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_jwt_analysis\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_jwt_analysis "$1" "$2"
fi
