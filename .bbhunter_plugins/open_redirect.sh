#!/bin/bash
# BBHunter Open Redirect Checker

PLUGIN_NAME="Open Redirect Checker"
PLUGIN_VERSION="1.3"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Checks for open redirect vulnerabilities"
PLUGIN_CATEGORY="vulnerability"

run_redirect_check() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/open_redirects"
    
    local output_file="$output_dir/plugins/open_redirects/results.txt"
    local vulnerable=0

    while read -r url; do
        if [[ "$url" == *"redirect="* ]] || [[ "$url" == *"url="* ]]; then
            test_url="${url/redirect=/redirect=http://evil.com}"
            test_url="${test_url/url=/url=http://evil.com}"
            if curl -s -I "$test_url" | grep -q "Location: http://evil.com"; then
                echo "$url" >> "$output_file"
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
        \"run_function\": \"run_redirect_check\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_redirect_check "$1" "$2"
fi
