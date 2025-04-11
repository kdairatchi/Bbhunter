#!/bin/bash
# BBHunter Groq AI Analyzer

PLUGIN_NAME="Groq AI Analyzer"
PLUGIN_VERSION="1.5"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Performs AI-powered analysis of scan results using Groq API"
PLUGIN_CATEGORY="analysis"

run_groq_analysis() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/groq_analysis"
    
    local output_file="$output_dir/plugins/groq_analysis/results.txt"
    local json_file="$output_dir/plugins/groq_analysis/results.json"
    local api_key="${GROQ_API_KEY}"
    
    if [ -z "$api_key" ]; then
        echo -e "${RED}[!] GROQ_API_KEY not set${NC}"
        return 1
    fi

    # Analyze vulnerabilities
    if [ -f "$input_dir/vulnerabilities/nuclei_results.txt" ]; then
        echo -e "${BLUE}[*] Sending vulnerabilities for AI analysis...${NC}"
        vulns=$(cat "$input_dir/vulnerabilities/nuclei_results.txt")
        
        response=$(curl -s -X POST "https://api.groq.com/v1/analyze" \
            -H "Authorization: Bearer $api_key" \
            -H "Content-Type: application/json" \
            -d "{
                \"text\": \"$vulns\",
                \"analysis_type\": \"vulnerability_assessment\"
            }")
        
        echo "$response" | jq '.' > "$json_file"
        echo "AI Analysis Results:" >> "$output_file"
        echo "$response" | jq -r '.summary' >> "$output_file"
    fi

    # Analyze recon data
    if [ -f "$input_dir/recon/all_subdomains.txt" ]; then
        echo -e "${BLUE}[*] Sending recon data for AI analysis...${NC}"
        recon_data=$(head -n 50 "$input_dir/recon/all_subdomains.txt")
        
        response=$(curl -s -X POST "https://api.groq.com/v1/analyze" \
            -H "Authorization: Bearer $api_key" \
            -H "Content-Type: application/json" \
            -d "{
                \"text\": \"$recon_data\",
                \"analysis_type\": \"recon_analysis\"
            }")
        
        echo "$response" | jq '.' >> "$json_file"
        echo "Recon Analysis:" >> "$output_file"
        echo "$response" | jq -r '.summary' >> "$output_file"
    fi

    return 0
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_groq_analysis\"
    }"
}
