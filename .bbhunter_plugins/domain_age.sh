#!/bin/bash
# BBHunter Domain Age Checker

PLUGIN_NAME="Domain Age Checker"
PLUGIN_VERSION="1.1"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Checks domain registration age"
PLUGIN_CATEGORY="recon"

run_domain_age_check() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/domain_age"
    
    local output_file="$output_dir/plugins/domain_age/results.txt"
    local domains_checked=0

    while read -r domain; do
        whois_result=$(whois "$domain")
        creation_date=$(echo "$whois_result" | grep -i "creation date" | head -n 1)
        echo "$domain - $creation_date" >> "$output_file"
        ((domains_checked++))
    done < "$input_dir/recon/domains.txt"

    return $domains_checked
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_domain_age_check\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_domain_age_check "$1" "$2"
fi
