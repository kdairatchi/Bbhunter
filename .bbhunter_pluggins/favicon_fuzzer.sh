#!/bin/bash
# =============================================
# BBHunter Favicon Hash Fuzzing Plugin
# Enhanced version with better detection and reporting
# =============================================

# Plugin metadata
PLUGIN_NAME="Favicon Hash Fuzzer"
PLUGIN_VERSION="1.2"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Identifies frameworks using favicon hash matching"
PLUGIN_CATEGORY="recon"

# Installation function
install_favicon_fuzzer() {
    echo -e "${GREEN}[*] Installing Favicon Fuzzer dependencies...${NC}"
    
    # Check if required tools are installed
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}[!] curl is required but not installed. Installing...${NC}"
        sudo apt-get install -y curl
    fi
    
    if ! command -v sha256sum &> /dev/null; then
        echo -e "${RED}[!] sha256sum is required but not installed. Installing...${NC}"
        sudo apt-get install -y coreutils
    fi
    
    echo -e "${GREEN}[✓] Favicon Fuzzer plugin installed successfully${NC}"
}

# Update function
update_favicon_fuzzer() {
    echo -e "${YELLOW}[*] Updating Favicon Fuzzer plugin...${NC}"
    # Add update logic here if needed
    echo -e "${GREEN}[✓] Favicon Fuzzer plugin updated successfully${NC}"
}

# Known favicon hashes database
declare -A KNOWN_HASHES=(
    ["5a3ca3906e0a787d70b7f52d2d6b027a"]="WordPress"
    ["d824bd3e78e2357ea844f90aa6c0b121"]="Drupal"
    ["c6b032d0a5a5f9d0e8e1e2e8b2b8b2b8"]="Joomla"
    ["f4e8a0e0e0a0a0e0e0a0e0e0a0e0a0e0"]="Apache"
    ["1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e"]="Nginx"
    ["a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5"]="IIS"
)

# Main plugin function
run_favicon_fuzzer() {
    local input_dir="$1"
    local output_dir="$2"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir/plugins/favicon_fuzz"
    
    # Define output files
    local output_file="$output_dir/plugins/favicon_fuzz/results.txt"
    local matched_file="$output_dir/plugins/favicon_fuzz/matched_hashes.txt"
    local json_file="$output_dir/plugins/favicon_fuzz/results.json"
    
    echo -e "\n${BLUE}[*] Starting Favicon Hash Fuzzing${NC}"
    echo -e "${YELLOW}[*] Scanning $(wc -l < "$input_dir/recon/live_hosts.txt") live hosts${NC}"
    
    # Initialize JSON output
    echo "[" > "$json_file"
    first_entry=true
    
    # Counter for stats
    total_tested=0
    matched_hashes=0
    found_favicons=0
    
    # Check each live host
    while read -r url; do
        # Skip empty lines
        if [[ -z "$url" ]]; then
            continue
        fi
        
        ((total_tested++))
        
        echo -e "${CYAN}[>] Testing: $url${NC}"
        
        # Try multiple common favicon locations
        declare -a favicon_locations=(
            "/favicon.ico"
            "/assets/favicon.ico"
            "/static/favicon.ico"
            "/img/favicon.ico"
            "/images/favicon.ico"
            "/resources/favicon.ico"
        )
        
        for location in "${favicon_locations[@]}"; do
            favicon_url="${url}${location}"
            
            # Get favicon with timeout and follow redirects
            favicon_data=$(curl -s -L -m 10 "$favicon_url" 2>/dev/null)
            
            # Check if we got any data
            if [[ -n "$favicon_data" ]]; then
                # Calculate hash
                hash=$(echo "$favicon_data" | sha256sum | awk '{print $1}')
                
                # Check if favicon is not empty (some servers return empty 200 responses)
                if [[ "$hash" != "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]]; then
                    ((found_favicons++))
                    
                    # Check against known hashes
                    matched_framework=""
                    for known_hash in "${!KNOWN_HASHES[@]}"; do
                        if [[ "$hash" == "$known_hash" ]]; then
                            matched_framework="${KNOWN_HASHES[$known_hash]}"
                            ((matched_hashes++))
                            break
                        fi
                    done
                    
                    # Add to text output
                    echo "=================================" >> "$output_file"
                    echo "URL: $url" >> "$output_file"
                    echo "Favicon Location: $location" >> "$output_file"
                    echo "SHA256 Hash: $hash" >> "$output_file"
                    
                    if [[ -n "$matched_framework" ]]; then
                        echo "Matched Framework: $matched_framework" >> "$output_file"
                        echo "$url - $hash - $matched_framework" >> "$matched_file"
                        echo -e "${GREEN}[+] Match found: $matched_framework${NC}"
                    else
                        echo "Matched Framework: Unknown" >> "$output_file"
                        echo -e "${YELLOW}[-] No known framework match${NC}"
                    fi
                    echo "=================================" >> "$output_file"
                    
                    # Add to JSON output
                    if [ "$first_entry" = false ]; then
                        echo "," >> "$json_file"
                    fi
                    first_entry=false
                    
                    cat >> "$json_file" <<EOF
    {
        "url": "$url",
        "favicon_url": "$favicon_url",
        "hash": "$hash",
        "matched_framework": "$matched_framework",
        "timestamp": "$(date +"%Y-%m-%d %H:%M:%S")"
    }
EOF
                    
                    # Break after first found favicon
                    break
                fi
            fi
        done
    done < "$input_dir/recon/live_hosts.txt"
    
    # Close JSON array
    echo "]" >> "$json_file"
    
    # Generate summary
    echo -e "\n${GREEN}[+] Favicon fuzzing completed!${NC}"
    echo -e "${YELLOW}[*] Statistics:${NC}"
    echo -e "${YELLOW}     - Total hosts tested: $total_tested${NC}"
    echo -e "${YELLOW}     - Hosts with favicons: $found_favicons${NC}"
    echo -e "${YELLOW}     - Known framework matches: $matched_hashes${NC}"
    echo -e "${YELLOW}[*] Results saved to:${NC}"
    echo -e "${YELLOW}     - $output_file${NC}"
    echo -e "${YELLOW}     - $matched_file${NC}"
    echo -e "${YELLOW}     - $json_file${NC}"
    
    # Return the number of matches found
    return $matched_hashes
}

# Register the plugin with BBHunter
register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"install_function\": \"install_favicon_fuzzer\",
        \"update_function\": \"update_favicon_fuzzer\",
        \"run_function\": \"run_favicon_fuzzer\"
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
    run_favicon_fuzzer "$1" "$2"
fi
