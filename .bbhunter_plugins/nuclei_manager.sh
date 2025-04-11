#!/bin/bash
# BBHunter Nuclei Manager

PLUGIN_NAME="Nuclei Manager"
PLUGIN_VERSION="1.7"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Manages Nuclei templates and workflows"
PLUGIN_CATEGORY="management"

run_nuclei_manager() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/nuclei_manager"
    
    local output_file="$output_dir/plugins/nuclei_manager/report.txt"
    
    # Update nuclei templates
    echo -e "${BLUE}[*] Updating Nuclei templates...${NC}"
    nuclei -update-templates
    
    # List available templates
    echo -e "${BLUE}[*] Available templates:${NC}"
    nuclei -tl > "$output_file"
    
    # Run scan with all templates
    echo -e "${BLUE}[*] Running Nuclei scan...${NC}"
    nuclei -l "$input_dir/recon/live_hosts.txt" -o "$output_dir/plugins/nuclei_manager/results.txt"
    
    return 0
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_nuclei_manager\"
    }"
}
