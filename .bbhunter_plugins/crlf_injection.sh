#!/bin/bash
# BBHunter CRLF Injection Checker

PLUGIN_NAME="CRLF Injection Checker"
PLUGIN_VERSION="1.2"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Checks for CRLF injection vulnerabilities"
PLUGIN_CATEGORY="vulnerability"

run_crlf_check() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/crlf_injection"
    
    local output_file="$output_dir/plugins/crlf_injection/results.txt"
    local vulnerable=0

    while read -r url; do
        test_url="${url}%0d%0aX-Injected-Header:test"
        if curl -s -I "$test_url" | grep -q "X-Injected-Header: test"; then
            echo "$url" >> "$output_file"
            ((vulnerable++))
        fi
    done < "$input_dir/recon/live_hosts.txt"

    return $vulnerable
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_crlf_check\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_crlf_check "$1" "$2"
fi
