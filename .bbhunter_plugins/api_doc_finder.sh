#!/bin/bash
# BBHunter API Documentation Finder

PLUGIN_NAME="API Doc Finder"
PLUGIN_VERSION="1.1"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Identifies API documentation endpoints"
PLUGIN_CATEGORY="recon"

run_api_doc_find() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/api_docs"
    
    local output_file="$output_dir/plugins/api_docs/results.txt"
    local docs_found=0

    declare -a DOC_PATHS=(
        "/api-docs" "/swagger" "/swagger-ui" "/openapi" 
        "/redoc" "/api.html" "/docs" "/developer"
    )

    while read -r url; do
        for path in "${DOC_PATHS[@]}"; do
            status=$(curl -s -o /dev/null -w "%{http_code}" "$url$path")
            if [[ "$status" == "200" ]]; then
                echo "API Docs: $url$path" >> "$output_file"
                ((docs_found++))
            fi
        done
    done < "$input_dir/recon/live_hosts.txt"

    return $docs_found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_api_doc_find\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_api_doc_find "$1" "$2"
fi
