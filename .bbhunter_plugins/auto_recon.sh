#!/bin/bash
# BBHunter Automated Recon

PLUGIN_NAME="Automated Recon"
PLUGIN_VERSION="2.2"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Performs automated reconnaissance"
PLUGIN_CATEGORY="recon"

run_auto_recon() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/auto_recon"
    
    # Subdomain enumeration
    echo -e "${BLUE}[*] Running subdomain enumeration...${NC}"
    subfinder -dL "$input_dir/domains.txt" -o "$output_dir/plugins/auto_recon/subdomains.txt"
    
    # HTTP probing
    echo -e "${BLUE}[*] Running HTTP probing...${NC}"
    httpx -l "$output_dir/plugins/auto_recon/subdomains.txt" -o "$output_dir/plugins/auto_recon/live_hosts.txt"
    
    # URL extraction
    echo -e "${BLUE}[*] Running URL extraction...${NC}"
    cat "$output_dir/plugins/auto_recon/live_hosts.txt" | waybackurls > "$output_dir/plugins/auto_recon/urls.txt"
    
    return 0
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_auto_recon\"
    }"
}
