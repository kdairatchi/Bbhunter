#!/bin/bash
# BBHunter Vulnerability Scanner

PLUGIN_NAME="Vulnerability Scanner"
PLUGIN_VERSION="2.5"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Comprehensive vulnerability scanning"
PLUGIN_CATEGORY="vulnerability"

run_vuln_scan() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/vuln_scan"
    
    # Run nuclei
    nuclei -l "$input_dir/recon/live_hosts.txt" -t cves -o "$output_dir/plugins/vuln_scan/nuclei_cves.txt"
    nuclei -l "$input_dir/recon/live_hosts.txt" -t vulnerabilities -o "$output_dir/plugins/vuln_scan/nuclei_vulns.txt"
    
    # Run custom checks
    while read -r url; do
        # Check for common vulnerabilities
        curl -s "$url/.env" | grep -q "DB_PASSWORD" && echo "Exposed .env: $url" >> "$output_dir/plugins/vuln_scan/custom_findings.txt"
        curl -s "$url/wp-config.php" | grep -q "DB_PASSWORD" && echo "Exposed wp-config: $url" >> "$output_dir/plugins/vuln_scan/custom_findings.txt"
    done < "$input_dir/recon/live_hosts.txt"
    
    return 0
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_vuln_scan\"
    }"
}
