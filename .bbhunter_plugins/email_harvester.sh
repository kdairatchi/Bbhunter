#!/bin/bash
# BBHunter Email Harvester

PLUGIN_NAME="Email Harvester"
PLUGIN_VERSION="1.3"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Extracts email addresses from web pages"
PLUGIN_CATEGORY="recon"

run_email_harvest() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/emails"
    
    local output_file="$output_dir/plugins/emails/results.txt"
    local emails_found=0

    while read -r url; do
        curl -s "$url" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | sort -u >> "$output_file"
        count=$(grep -c @ "$output_file")
        emails_found=$((emails_found + count))
    done < "$input_dir/recon/live_hosts.txt"

    return $emails_found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_email_harvest\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_email_harvest "$1" "$2"
fi
