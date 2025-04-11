#!/bin/bash
# BBHunter Sensitive File Finder

PLUGIN_NAME="Sensitive File Finder"
PLUGIN_VERSION="1.5"
PLUGIN_AUTHOR="BBHunter Team"
PLUGIN_DESCRIPTION="Checks for common sensitive files"
PLUGIN_CATEGORY="vulnerability"

declare -a SENSITIVE_FILES=(
    ".env" "config.php" "backup.zip"
    "wp-config.php" "credentials.json"
)

run_sensitive_check() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/sensitive_files"
    
    local output_file="$output_dir/plugins/sensitive_files/results.txt"
    local found=0

    while read -r url; do
        for file in "${SENSITIVE_FILES[@]}"; do
            status=$(curl -s -o /dev/null -w "%{http_code}" "$url/$file")
            if [[ "$status" == "200" ]]; then
                echo "$url/$file" >> "$output_file"
                ((found++))
            fi
        done
    done < "$input_dir/recon/live_hosts.txt"

    return $found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_sensitive_check\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_sensitive_check "$1" "$2"
fi
