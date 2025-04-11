#!/bin/bash
# BBHunter Request Filter

PLUGIN_NAME="Request Filter"
PLUGIN_VERSION="1.3"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Filters and normalizes requests for testing"
PLUGIN_CATEGORY="utility"

run_request_filter() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/filtered_requests"
    
    local output_file="$output_dir/plugins/filtered_requests/urls_with_params.txt"
    local filtered=0

    while read -r url; do
        # Filter URLs with parameters
        if [[ "$url" == *"?"*"="* ]]; then
            echo "$url" >> "$output_file"
            ((filtered++))
        fi
    done < "$input_dir/recon/all_urls.txt"

    # Create filtered versions for testing
    cat "$output_file" | grep -iE "id=|user=|account=" > "$output_dir/plugins/filtered_requests/sensitive_params.txt"
    cat "$output_file" | grep -iE "redirect=|url=|next=" > "$output_dir/plugins/filtered_requests/redirect_params.txt"

    return $filtered
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_request_filter\"
    }"
}
