#!/bin/bash
# BBHunter Port Scanner

PLUGIN_NAME="Port Scanner"
PLUGIN_VERSION="1.6"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Fast port scanning for common services"
PLUGIN_CATEGORY="recon"

run_port_scan() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/port_scan"
    
    local output_file="$output_dir/plugins/port_scan/results.txt"
    local open_ports=0

    declare -a COMMON_PORTS=(21 22 80 443 3306 5432 8000 8080 8443)

    while read -r domain; do
        ip=$(dig +short "$domain" | head -n 1)
        if [[ -z "$ip" ]]; then
            continue
        fi
        
        echo "=== Port Scan for $domain ($ip) ===" >> "$output_file"
        for port in "${COMMON_PORTS[@]}"; do
            timeout 1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null && \
                echo "OPEN: $port" >> "$output_file" && \
                ((open_ports++))
        done
    done < "$input_dir/recon/domains.txt"

    return $open_ports
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_port_scan\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_port_scan "$1" "$2"
fi
