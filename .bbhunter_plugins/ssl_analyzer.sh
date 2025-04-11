#!/bin/bash
# BBHunter SSL/TLS Analyzer

PLUGIN_NAME="SSL Analyzer"
PLUGIN_VERSION="1.4"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Analyzes SSL/TLS configurations"
PLUGIN_CATEGORY="recon"

install_ssl_analyzer() {
    echo -e "${GREEN}[*] Installing SSL Analyzer dependencies...${NC}"
    if ! command -v openssl &>/dev/null; then
        sudo apt-get install -y openssl
    fi
    echo -e "${GREEN}[✓] Installation complete${NC}"
}

run_ssl_analysis() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/ssl_analysis"
    
    local output_file="$output_dir/plugins/ssl_analysis/results.txt"
    local analyzed=0

    while read -r url; do
        domain=$(echo "$url" | awk -F/ '{print $3}')
        echo "=== $domain ===" >> "$output_file"
        echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | \
            openssl x509 -noout -text | grep -E "Issuer:|Subject:|Not Before:|Not After :|Signature Algorithm:" >> "$output_file"
        ((analyzed++))
    done < "$input_dir/recon/live_hosts.txt"

    return $analyzed
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"install_function\": \"install_ssl_analyzer\",
        \"run_function\": \"run_ssl_analysis\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_ssl_analysis "$1" "$2"
fi
