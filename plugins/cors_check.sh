#!/bin/bash
# =============================================
# BBHunter CORS Misconfiguration Plugin
# Enhanced version with better detection and reporting
# =============================================

# Description: This plugin checks for CORS misconfigurations across all discovered hosts

# Plugin metadata
PLUGIN_NAME="CORS Checker"
PLUGIN_VERSION="1.2"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Advanced CORS misconfiguration detection with automated testing"
PLUGIN_CATEGORY="vulnerability"

# Installation function (optional)
install_cors_checker() {
    echo -e "${GREEN}[*] Installing CORS Checker dependencies...${NC}"
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}[!] curl is required but not installed. Installing...${NC}"
        sudo apt-get install -y curl
    fi
    
    echo -e "${GREEN}[✓] CORS Checker plugin installed successfully${NC}"
}

# Update function (optional)
update_cors_checker() {
    echo -e "${YELLOW}[*] Updating CORS Checker plugin...${NC}"
    # Add update logic here if needed
    echo -e "${GREEN}[✓] CORS Checker plugin updated successfully${NC}"
}

# Main plugin function
run_cors_check() {
    local input_dir="$1"
    local output_dir="$2"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir/plugins/cors"
    
    # Define output files
    local output_file="$output_dir/plugins/cors/results.txt"
    local vulnerable_file="$output_dir/plugins/cors/vulnerable_hosts.txt"
    local detailed_file="$output_dir/plugins/cors/detailed_results.json"
    
    echo -e "\n${BLUE}[*] Starting CORS Misconfiguration Check${NC}"
    echo -e "${YELLOW}[*] Scanning $(wc -l < "$input_dir/recon/live_hosts.txt") live hosts${NC}"
    
    # Initialize JSON output
    echo "[" > "$detailed_file"
    first_entry=true
    
    # Check each live host
    while read -r url; do
        # Skip empty lines
        if [[ -z "$url" ]]; then
            continue
        fi
        
        echo -e "${CYAN}[>] Testing: $url${NC}"
        
        # Test with different Origin headers
        declare -a origins=(
            "evil.com"
            "null"
            "$url"
            "https://attacker.com"
            "recondock.xyz"
            "http://attacker.com"
            "sub.attacker.com"
        )
        
        for origin in "${origins[@]}"; do
            response=$(curl -s -I -H "Origin: $origin" "$url")
            
            # Check for Access-Control-Allow-Origin header
            if echo "$response" | grep -i "Access-Control-Allow-Origin" > /dev/null; then
                acao=$(echo "$response" | grep -i "Access-Control-Allow-Origin" | tr -d '\r')
                acac=$(echo "$response" | grep -i "Access-Control-Allow-Credentials" | tr -d '\r' || echo "None")
                acam=$(echo "$response" | grep -i "Access-Control-Allow-Methods" | tr -d '\r' || echo "None")
                acah=$(echo "$response" | grep -i "Access-Control-Allow-Headers" | tr -d '\r' || echo "None")
                
                # Determine vulnerability level
                if [[ "$acao" == *"$origin"* ]] || [[ "$acao" == *"*"* ]] || [[ "$acao" == *"null"* ]]; then
                    if [[ "$acac" == *"true"* ]]; then
                        severity="CRITICAL"
                    elif [[ "$acao" == *"*"* ]]; then
                        severity="HIGH"
                    else
                        severity="MEDIUM"
                    fi
                    
                    # Add comma for JSON entries after the first one
                    if [ "$first_entry" = false ]; then
                        echo "," >> "$detailed_file"
                    fi
                    first_entry=false
                    
                    # Add to JSON output
                    cat >> "$detailed_file" <<EOF
    {
        "url": "$url",
        "origin": "$origin",
        "acao": "$acao",
        "acac": "$acac",
        "acam": "$acam",
        "acah": "$acah",
        "severity": "$severity",
        "timestamp": "$(date +"%Y-%m-%d %H:%M:%S")"
    }
EOF
                    
                    # Add to text output
                    echo "=================================" >> "$output_file"
                    echo "Vulnerable URL: $url" >> "$output_file"
                    echo "Tested Origin: $origin" >> "$output_file"
                    echo "Access-Control-Allow-Origin: $acao" >> "$output_file"
                    echo "Access-Control-Allow-Credentials: $acac" >> "$output_file"
                    echo "Access-Control-Allow-Methods: $acam" >> "$output_file"
                    echo "Access-Control-Allow-Headers: $acah" >> "$output_file"
                    echo "Severity: $severity" >> "$output_file"
                    echo "=================================" >> "$output_file"
                    
                    # Add to vulnerable hosts list
                    echo "$url - $severity - $acao" >> "$vulnerable_file"
                    
                    echo -e "${RED}[!] Potential CORS misconfiguration found on $url${NC}"
                    echo -e "${YELLOW}     $acao${NC}"
                    echo -e "${YELLOW}     $acac${NC}"
                fi
            fi
        done
    done < "$input_dir/recon/live_hosts.txt"
    
    # Close JSON array
    echo "]" >> "$detailed_file"
    
    # Count vulnerabilities
    vuln_count=$(grep -c "Vulnerable URL:" "$output_file" 2>/dev/null || echo 0)
    
    echo -e "\n${GREEN}[+] CORS check completed!${NC}"
    echo -e "${YELLOW}[*] Found $vuln_count potential CORS misconfigurations${NC}"
    echo -e "${YELLOW}[*] Detailed results saved to:${NC}"
    echo -e "${YELLOW}     - $output_file${NC}"
    echo -e "${YELLOW}     - $vulnerable_file${NC}"
    echo -e "${YELLOW}     - $detailed_file${NC}"
    
    # Return the number of vulnerabilities found
    return $vuln_count
}

# Register the plugin with BBHunter
register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"install_function\": \"install_cors_checker\",
        \"update_function\": \"update_cors_checker\",
        \"run_function\": \"run_cors_check\"
    }"
}

# When sourced, register the plugin
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    # When executed directly, run the plugin
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 <input_directory> <output_directory>"
        exit 1
    fi
    run_cors_check "$1" "$2"
fi
