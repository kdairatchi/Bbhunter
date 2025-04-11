#!/bin/bash
# BBHunter DNS Enumeration

PLUGIN_NAME="DNS Enumeration"
PLUGIN_VERSION="1.5"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Performs comprehensive DNS enumeration"
PLUGIN_CATEGORY="recon"

run_dns_enum() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/dns_enum"
    
    local output_file="$output_dir/plugins/dns_enum/results.txt"
    local records_found=0

    while read -r domain; do
        echo "=== DNS Records for $domain ===" >> "$output_file"
        # A Records
        dig A "$domain" +short | while read ip; do
            echo "A: $ip" >> "$output_file"
            ((records_found++))
        done
        
        # MX Records
        dig MX "$domain" +short | while read mx; do
            echo "MX: $mx" >> "$output_file"
            ((records_found++))
        done
        
        # TXT Records
        dig TXT "$domain" +short | while read txt; do
            echo "TXT: $txt" >> "$output_file"
            ((records_found++))
        done
    done < "$input_dir/recon/domains.txt"

    return $records_found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_dns_enum\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_dns_enum "$1" "$2"
fi
