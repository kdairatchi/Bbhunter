#!/bin/bash
# BBHunter Plugin Manager

PLUGIN_NAME="Plugin Manager"
PLUGIN_VERSION="2.1"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Manages plugin installation and updates"
PLUGIN_CATEGORY="management"

available_plugins() {
    declare -A PLUGIN_REPO=(
        ["xss_scanner"]="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/xss_scanner.sh"
        ["sqli_scanner"]="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/sqli_scanner.sh"
        ["groq_ai_analyzer"]="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/groq_ai_analyzer.sh"
        ["request_filter"]="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/request_filter.sh"
        ["nuclei_manager"]="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/nuclei_manager.sh"
        ["auto_recon"]="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/auto_recon.sh"
        ["vuln_scanner"]="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/vuln_scanner.sh"
    )

    for plugin in "${!PLUGIN_REPO[@]}"; do
        echo "$plugin - ${PLUGIN_REPO[$plugin]}"
    done
}

install_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    
    echo -e "${BLUE}[*] Installing $plugin_name...${NC}"
    curl -sL "$plugin_url" -o "$HOME/.bbhunter_plugins/${plugin_name}.sh"
    chmod +x "$HOME/.bbhunter_plugins/${plugin_name}.sh"
    
    # Run install function if exists
    if grep -q "install_${plugin_name}" "$HOME/.bbhunter_plugins/${plugin_name}.sh"; then
        source "$HOME/.bbhunter_plugins/${plugin_name}.sh"
        "install_${plugin_name}"
    fi
    
    echo -e "${GREEN}[✓] $plugin_name installed successfully${NC}"
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"available_plugins\": \"available_plugins\",
        \"install_plugin\": \"install_plugin\"
    }"
}
