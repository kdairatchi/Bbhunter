#!/bin/bash
# BBHunter XSS Scanner Plugin

PLUGIN_NAME="XSS Scanner"
PLUGIN_VERSION="2.3"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Advanced XSS vulnerability detection with multiple attack vectors"
PLUGIN_CATEGORY="vulnerability"

install_xss_scanner() {
    echo -e "${GREEN}[*] Installing XSS Scanner dependencies...${NC}"
    if ! command -v qsreplace &>/dev/null; then
        echo -e "${RED}[!] qsreplace not found. Installing...${NC}"
        go install github.com/tomnomnom/qsreplace@latest
    fi
    if ! command -v dalfox &>/dev/null; then
        echo -e "${RED}[!] dalfox not found. Installing...${NC}"
        go install github.com/hahwul/dalfox/v2@latest
    fi
}

run_xss_scan() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/xss_scan"
    
    local output_file="$output_dir/plugins/xss_scan/results.txt"
    local json_file="$output_dir/plugins/xss_scan/results.json"
    local vulnerable=0

    echo "[" > "$json_file"
    first_entry=true

    while read -r url; do
        echo -e "${CYAN}[>] Testing: $url${NC}"
        
        # Test with multiple payloads
        declare -a payloads=(
            "'\"><script>alert(1)</script>"
            "javascript:alert(1)"
            "\" onmouseover=alert(1) "
            "${url}?test=<script>alert(1)</script>"
        )

        for payload in "${payloads[@]}"; do
            test_url=$(echo "$url" | qsreplace "$payload")
            response=$(curl -s -L "$test_url")
            
            if echo "$response" | grep -q "<script>alert(1)</script>"; then
                if [ "$first_entry" = false ]; then
                    echo "," >> "$json_file"
                fi
                first_entry=false
                
                cat >> "$json_file" <<EOF
    {
        "url": "$url",
        "payload": "$payload",
        "type": "Reflected XSS",
        "timestamp": "$(date +"%Y-%m-%d %H:%M:%S")"
    }
EOF
                echo "Vulnerable: $url" >> "$output_file"
                echo "Payload: $payload" >> "$output_file"
                ((vulnerable++))
            fi
        done

        # Use dalfox for advanced detection
        dalfox url "$url" --silence --no-color --output "$output_dir/plugins/xss_scan/dalfox_results.txt"
        if [ -s "$output_dir/plugins/xss_scan/dalfox_results.txt" ]; then
            ((vulnerable++))
            cat "$output_dir/plugins/xss_scan/dalfox_results.txt" >> "$output_file"
        fi

    done < "$input_dir/recon/urls_with_params.txt"

    echo "]" >> "$json_file"
    return $vulnerable
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"install_function\": \"install_xss_scanner\",
        \"run_function\": \"run_xss_scan\"
    }"
}
