#!/bin/bash
# BBHunter WordPress Scanner

PLUGIN_NAME="WordPress Scanner"
PLUGIN_VERSION="1.5"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Identifies WordPress sites and checks for common vulnerabilities"
PLUGIN_CATEGORY="vulnerability"

run_wordpress_scan() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/wordpress"
    
    local output_file="$output_dir/plugins/wordpress/results.txt"
    local wp_sites=0

    while read -r url; do
        # Check for WordPress
        if curl -s "$url/wp-includes/" | grep -q "wp-emoji"; then
            echo "WordPress Site: $url" >> "$output_file"
            ((wp_sites++))
            
            # Check version
            version=$(curl -s "$url/readme.html" | grep -i "version" | head -n 1)
            if [[ -n "$version" ]]; then
                echo "Version: $version" >> "$output_file"
            fi
            
            # Check for wp-config.php backup
            status=$(curl -s -o /dev/null -w "%{http_code}" "$url/wp-config.php~")
            if [[ "$status" == "200" ]]; then
                echo "wp-config.php backup found!" >> "$output_file"
            fi
        fi
    done < "$input_dir/recon/live_hosts.txt"

    return $wp_sites
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_wordpress_scan\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_wordpress_scan "$1" "$2"
fi
