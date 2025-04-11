#!/bin/bash
# =============================================
# ULTIMATE BUG BOUNTY HUNTER - All-in-One Scanner
# An advanced automated script for bug bounty hunting
# Now with plugin support and enhanced automation
# =============================================

# Configuration variables
CONFIG_FILE="bbhunter_config.conf"
VERSION="3.0"
LAST_UPDATE="2024-03-25"
AUTHOR="Kdairatchi"

# Initialize default settings
initialize_defaults() {
    # Colors for terminal output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    ORANGE='\033[0;33m'
    NC='\033[0m' # No Color
    BOLD='\033[1m'
    UNDERLINE='\033[4m'

    # Default values
    THREADS=100
    TIMEOUT=15
    NUCLEI_THREADS=50
    TARGET_FILE="domains.txt"
    OUTPUT_DIR="results_$(date +%F_%H-%M-%S)"
    COLLABORATOR_URL="example.burpcollaborator.net"
    LHOST="evil.com"
    GF_PATTERNS_DIR="$HOME/.gf"
    SCAN_DELAY=1
    MAX_SCAN_TIME=86400 # 24 hours in seconds
    NOTIFY_BELL=false
    NOTIFY_DESKTOP=false
    NOTIFY_SLACK=false
    NOTIFY_DISCORD=false
    SLACK_WEBHOOK=""
    DISCORD_WEBHOOK=""
    PARAMS_ONLY=false
    SCAN_MODE="all"
    VERBOSE=true
    DEBUG=false
    COLOR_OUTPUT=true
    SAVE_LOGS=true
    LOG_FILE="bbhunter.log"
    MAX_FILESIZE=10000 # MB
    ENABLE_RATE_LIMITING=false
    RATE_LIMIT=100 # requests per second
    ENABLE_RETRY=true
    MAX_RETRIES=3
    RETRY_DELAY=5 # seconds
    ENABLE_PROXY=false
    PROXY_URL=""
    PROXY_AUTH=""
    ENABLE_TOR=false
    TOR_PROXY="socks5://127.0.0.1:9050"
    ENABLE_API_SCANS=true
    SHODAN_API=""
    CENSYS_API=""
    VIRUSTOTAL_API=""
    SECURITYTRAILS_API=""
    ENABLE_BRUTEFORCE=false
    BRUTEFORCE_WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    ENABLE_FUZZING=false
    FUZZING_WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    ENABLE_CRAWLING=true
    CRAWL_DEPTH=2
    ENABLE_SCREENSHOTS=true
    ENABLE_ARCHIVE=true
    ENABLE_BACKUP=true
    BACKUP_DIR="bbhunter_backups"
    ENABLE_UPDATE_CHECK=true
    ENABLE_AUTO_UPDATE=false
    GITHUB_REPO="kdairatchi/bbhunter"
    ENABLE_TELEMETRY=false
    TELEMETRY_URL=""
    ENABLE_BANNER=true
    ENABLE_PROGRESS_BAR=true
    ENABLE_SUMMARY=true
    ENABLE_TIMESTAMPS=true
    ENABLE_EXIT_HANDLERS=true
    ENABLE_ERROR_HANDLING=true
    ENABLE_SIGNAL_HANDLING=true
    ENABLE_CLEANUP=true
    ENABLE_VALIDATION=true
    ENABLE_SANITY_CHECKS=true
    ENABLE_PERFORMANCE_MONITORING=true
    ENABLE_RESOURCE_LIMITS=true
    CPU_LIMIT=90 # percentage
    MEMORY_LIMIT=90 # percentage
    ENABLE_TEMP_FILES=true
    TEMP_DIR="/tmp/bbhunter"
    ENABLE_HISTORY=true
    HISTORY_FILE="$HOME/.bbhunter_history"
    ENABLE_BOOKMARKS=false
    BOOKMARKS_FILE="$HOME/.bbhunter_bookmarks"
    ENABLE_PROFILES=false
    PROFILES_DIR="$HOME/.bbhunter_profiles"
    ENABLE_PLUGINS=true  # Enabled by default
    PLUGINS_DIR="$HOME/.bbhunter_plugins"
    ENABLE_TEMPLATES=false
    TEMPLATES_DIR="$HOME/.bbhunter_templates"
    ENABLE_AI=false
    AI_API_KEY=""
    ENABLE_REPORTING=true
    REPORT_FORMAT="html"
    ENABLE_DASHBOARD=false
    DASHBOARD_PORT=8080
    ENABLE_API_SERVER=false
    API_SERVER_PORT=9090
    ENABLE_CLOUD_SYNC=false
    CLOUD_PROVIDER=""
    CLOUD_BUCKET=""
    CLOUD_CREDENTIALS=""
    AUTO_INSTALL_PLUGINS=true  # Automatically install plugins
    PLUGIN_AUTO_UPDATE=true    # Automatically update plugins
}

# Enhanced plugin system
load_plugins() {
    if [[ "$ENABLE_PLUGINS" != true ]]; then
        return
    fi

    echo -e "${BLUE}[*] Loading plugins...${NC}"
    
    # Create plugins directory if it doesn't exist
    mkdir -p "$PLUGINS_DIR"
    
    # Load each plugin
    for plugin in "$PLUGINS_DIR"/*.sh; do
        if [[ -f "$plugin" ]]; then
            # Check if plugin is executable
            if [[ ! -x "$plugin" ]]; then
                chmod +x "$plugin"
            fi
            
            # Source the plugin
            source "$plugin"
            echo -e "${GREEN}[+] Loaded plugin: $(basename "$plugin")${NC}"
            
            # Check if plugin has an install function and auto-install is enabled
            if [[ "$AUTO_INSTALL_PLUGINS" == true ]] && declare -f "install_$(basename "$plugin" .sh)" &>/dev/null; then
                echo -e "${YELLOW}[*] Running install for $(basename "$plugin" .sh)${NC}"
                "install_$(basename "$plugin" .sh)"
            fi
        fi
    done
    
    # Check for plugin updates if enabled
    if [[ "$PLUGIN_AUTO_UPDATE" == true ]]; then
        update_plugins
    fi
}

# Update plugins
update_plugins() {
    echo -e "${BLUE}[*] Checking for plugin updates...${NC}"
    
    for plugin in "$PLUGINS_DIR"/*.sh; do
        if [[ -f "$plugin" ]]; then
            plugin_name=$(basename "$plugin")
            # Check if plugin has an update function
            if declare -f "update_${plugin_name%.sh}" &>/dev/null; then
                echo -e "${YELLOW}[*] Updating ${plugin_name%.sh}...${NC}"
                "update_${plugin_name%.sh}"
            fi
        fi
    done
}

# Plugin management menu
plugin_management() {
    while true; do
        echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}${BOLD}║           PLUGIN MANAGEMENT                 ║${NC}"
        echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}${BOLD}║ ${GREEN}1. List Installed Plugins${NC}               ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}2. Install New Plugin${NC}                   ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}3. Update All Plugins${NC}                   ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}4. Update Specific Plugin${NC}               ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}5. Remove Plugin${NC}                        ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}6. Toggle Auto-Install (Current: $AUTO_INSTALL_PLUGINS)${NC} ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}7. Toggle Auto-Update (Current: $PLUGIN_AUTO_UPDATE)${NC} ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}8. Back to Main Menu${NC}                    ║"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-8]: ${NC}")" choice
        
        case $choice in
            1) list_plugins ;;
            2) install_new_plugin ;;
            3) update_plugins ;;
            4) update_specific_plugin ;;
            5) remove_plugin ;;
            6) toggle_auto_install ;;
            7) toggle_auto_update ;;
            8) return ;;
            *) echo -e "${RED}[!] Invalid option!${NC}" ;;
        esac
    done
}

# List installed plugins
list_plugins() {
    echo -e "\n${BLUE}[*] Installed Plugins:${NC}"
    
    if [[ ! -d "$PLUGINS_DIR" ]] || [[ -z "$(ls -A "$PLUGINS_DIR")" ]]; then
        echo -e "${YELLOW}[!] No plugins installed${NC}"
        return
    fi
    
    for plugin in "$PLUGINS_DIR"/*.sh; do
        if [[ -f "$plugin" ]]; then
            plugin_name=$(basename "$plugin")
            plugin_desc="No description available"
            
            # Try to get plugin description if available
            if grep -q "# Description:" "$plugin"; then
                plugin_desc=$(grep "# Description:" "$plugin" | cut -d: -f2-)
            fi
            
            echo -e "${GREEN}• ${plugin_name%.sh}:${NC} $plugin_desc"
            
            # Check for update function
            if declare -f "update_${plugin_name%.sh}" &>/dev/null; then
                echo -e "  ${YELLOW}[✓] Update function available${NC}"
            fi
            
            # Check for install function
            if declare -f "install_${plugin_name%.sh}" &>/dev/null; then
                echo -e "  ${YELLOW}[✓] Install function available${NC}"
            fi
        fi
    done
}

# Install new plugin
install_new_plugin() {
    echo -e "\n${BLUE}[*] Available plugin sources:${NC}"
    echo -e "1. From local file"
    echo -e "2. From URL"
    echo -e "3. From built-in repository"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter source type [1-3]: ${NC}")" source_type
    
    case $source_type in
        1)
            read -p "$(echo -e "${BLUE}${BOLD}Enter path to plugin file: ${NC}")" plugin_path
            if [[ -f "$plugin_path" ]]; then
                cp "$plugin_path" "$PLUGINS_DIR/"
                chmod +x "$PLUGINS_DIR/$(basename "$plugin_path")"
                echo -e "${GREEN}[✓] Plugin installed successfully${NC}"
                
                # Run install function if available
                plugin_name=$(basename "$plugin_path" .sh)
                if declare -f "install_$plugin_name" &>/dev/null; then
                    echo -e "${YELLOW}[*] Running install function for $plugin_name${NC}"
                    "install_$plugin_name"
                fi
            else
                echo -e "${RED}[!] File not found${NC}"
            fi
            ;;
        2)
            read -p "$(echo -e "${BLUE}${BOLD}Enter plugin URL: ${NC}")" plugin_url
            plugin_name=$(basename "$plugin_url")
            
            echo -e "${YELLOW}[*] Downloading plugin...${NC}"
            if wget -q "$plugin_url" -O "$PLUGINS_DIR/$plugin_name"; then
                chmod +x "$PLUGINS_DIR/$plugin_name"
                echo -e "${GREEN}[✓] Plugin downloaded and installed successfully${NC}"
                
                # Run install function if available
                plugin_name_noext=$(basename "$plugin_name" .sh)
                if declare -f "install_$plugin_name_noext" &>/dev/null; then
                    echo -e "${YELLOW}[*] Running install function for $plugin_name_noext${NC}"
                    "install_$plugin_name_noext"
                fi
            else
                echo -e "${RED}[!] Failed to download plugin${NC}"
            fi
            ;;
        3)
            echo -e "\n${BLUE}[*] Available plugins in repository:${NC}"
            echo -e "1. Slack Notifier - Adds Slack notification support"
            echo -e "2. Discord Notifier - Adds Discord notification support"
            echo -e "3. Nuclei Templates Manager - Manages Nuclei templates"
            echo -e "4. Auto Recon - Automated reconnaissance plugin"
            echo -e "5. Vuln Scanner - Enhanced vulnerability scanning"
            
            read -p "$(echo -e "${BLUE}${BOLD}Enter plugin number to install [1-5]: ${NC}")" plugin_num
            
            case $plugin_num in
                1) plugin_url="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/slack_notifier.sh" ;;
                2) plugin_url="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/discord_notifier.sh" ;;
                3) plugin_url="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/nuclei_manager.sh" ;;
                4) plugin_url="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/auto_recon.sh" ;;
                5) plugin_url="https://raw.githubusercontent.com/kdairatchi/bbhunter-plugins/main/vuln_scanner.sh" ;;
                *) echo -e "${RED}[!] Invalid option!${NC}"; return ;;
            esac
            
            plugin_name=$(basename "$plugin_url")
            echo -e "${YELLOW}[*] Downloading plugin...${NC}"
            if wget -q "$plugin_url" -O "$PLUGINS_DIR/$plugin_name"; then
                chmod +x "$PLUGINS_DIR/$plugin_name"
                echo -e "${GREEN}[✓] Plugin downloaded and installed successfully${NC}"
                
                # Run install function if available
                plugin_name_noext=$(basename "$plugin_name" .sh)
                if declare -f "install_$plugin_name_noext" &>/dev/null; then
                    echo -e "${YELLOW}[*] Running install function for $plugin_name_noext${NC}"
                    "install_$plugin_name_noext"
                fi
            else
                echo -e "${RED}[!] Failed to download plugin${NC}"
            fi
            ;;
        *) echo -e "${RED}[!] Invalid option!${NC}" ;;
    esac
}

# Update specific plugin
update_specific_plugin() {
    list_plugins
    
    if [[ ! -d "$PLUGINS_DIR" ]] || [[ -z "$(ls -A "$PLUGINS_DIR")" ]]; then
        return
    fi
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter plugin name to update (without .sh): ${NC}")" plugin_name
    
    if [[ -f "$PLUGINS_DIR/$plugin_name.sh" ]]; then
        if declare -f "update_$plugin_name" &>/dev/null; then
            echo -e "${YELLOW}[*] Updating $plugin_name...${NC}"
            "update_$plugin_name"
        else
            echo -e "${RED}[!] No update function available for $plugin_name${NC}"
        fi
    else
        echo -e "${RED}[!] Plugin $plugin_name not found${NC}"
    fi
}

# Remove plugin
remove_plugin() {
    list_plugins
    
    if [[ ! -d "$PLUGINS_DIR" ]] || [[ -z "$(ls -A "$PLUGINS_DIR")" ]]; then
        return
    fi
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter plugin name to remove (without .sh): ${NC}")" plugin_name
    
    if [[ -f "$PLUGINS_DIR/$plugin_name.sh" ]]; then
        rm -f "$PLUGINS_DIR/$plugin_name.sh"
        echo -e "${GREEN}[✓] Plugin $plugin_name removed successfully${NC}"
    else
        echo -e "${RED}[!] Plugin $plugin_name not found${NC}"
    fi
}

# Toggle auto-install
toggle_auto_install() {
    AUTO_INSTALL_PLUGINS=$([[ "$AUTO_INSTALL_PLUGINS" == true ]] && echo false || echo true)
    echo -e "${GREEN}[✓] Auto-install plugins set to: $AUTO_INSTALL_PLUGINS${NC}"
}

# Toggle auto-update
toggle_auto_update() {
    PLUGIN_AUTO_UPDATE=$([[ "$PLUGIN_AUTO_UPDATE" == true ]] && echo false || echo true)
    echo -e "${GREEN}[✓] Auto-update plugins set to: $PLUGIN_AUTO_UPDATE${NC}"
}

# Enhanced main menu with plugin option
main_menu() {
    while true; do
        echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}${BOLD}║             ULTIMATE BBHUNTER MENU          ║${NC}"
        echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}${BOLD}║ ${GREEN}1. Reconnaissance${NC} - Subdomain enumeration  ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}2. Vulnerability Scanning${NC} - Nuclei scans   ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}3. Advanced Testing${NC} - Custom exploits     ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}4. Fingerprinting${NC} - Tech detection       ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}5. Run All Scans${NC} - Comprehensive test    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}6. Quick Scan${NC} - Fast overview           ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}7. Custom Scan${NC} - Targeted testing        ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}8. Notification Settings${NC} - Alerts        ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}9. Configuration${NC} - Settings & options    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}10. Help${NC} - Documentation                ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}11. Tools Management${NC} - Install/update    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}12. Reporting${NC} - Generate scan reports    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}13. Cloud Integration${NC} - Sync with cloud  ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}14. AI Analysis${NC} - Smart scan analysis    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}15. Plugin Management${NC} - Extend features  ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}16. Exit${NC} - Quit the program             ║"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-16]: ${NC}")" choice
        
        case $choice in
            1) run_reconnaissance ;;
            2) run_vulnerability_scanning ;;
            3) run_advanced_testing ;;
            4) run_fingerprinting ;;
            5) run_all_scans ;;
            6) run_quick_scan ;;
            7) run_custom_scan ;;
            8) notification_settings ;;
            9) configure_settings ;;
            10) show_help ;;
            11) manage_tools ;;
            12) generate_reports ;;
            13) cloud_integration ;;
            14) ai_analysis ;;
            15) plugin_management ;;
            16) echo -e "${GREEN}[*] Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}[!] Invalid option!${NC}" ;;
        esac
    done
}

# Enhanced configuration menu with plugin settings
configure_settings() {
    while true; do
        echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}${BOLD}║           CONFIGURATION SETTINGS             ║${NC}"
        echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}${BOLD}║ ${GREEN}1. General Settings${NC} - Threads, timeouts  ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}2. Scan Settings${NC} - Modes, verbosity     ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}3. Network Settings${NC} - Proxy, rate limit ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}4. API Settings${NC} - API keys & services   ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}5. Output Settings${NC} - Reports, formats   ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}6. System Settings${NC} - Performance, logs  ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}7. UI Settings${NC} - Display options        ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}8. Plugin Settings${NC} - Plugin options     ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}9. Save Configuration${NC}                   ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}10. Reset to Defaults${NC}                    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}11. Back to Main Menu${NC}                   ║"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-11]: ${NC}")" config_choice
        
        case $config_choice in
            1) general_settings ;;
            2) scan_settings ;;
            3) network_settings ;;
            4) api_settings ;;
            5) output_settings ;;
            6) system_settings ;;
            7) ui_settings ;;
            8) plugin_settings ;;
            9) save_config; echo -e "${GREEN}[*] Configuration saved!${NC}" ;;
            10) reset_defaults ;;
            11) return ;;
            *) echo -e "${RED}[!] Invalid option!${NC}" ;;
        esac
    done
}

# Plugin settings menu
plugin_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║             PLUGIN SETTINGS                 ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Enable Plugins (current: $ENABLE_PLUGINS)${NC}"
    echo -e "${BLUE}2. Plugins Directory (current: $PLUGINS_DIR)${NC}"
    echo -e "${BLUE}3. Auto-Install Plugins (current: $AUTO_INSTALL_PLUGINS)${NC}"
    echo -e "${BLUE}4. Auto-Update Plugins (current: $PLUGIN_AUTO_UPDATE)${NC}"
    echo -e "${BLUE}5. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-5]: ${NC}")" choice
    
    case $choice in
        1) 
            ENABLE_PLUGINS=$([[ "$ENABLE_PLUGINS" == true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Plugins set to: $ENABLE_PLUGINS${NC}"
            if [[ "$ENABLE_PLUGINS" == true ]]; then
                load_plugins
            fi
            ;;
        2) 
            read -p "Enter new plugins directory: " PLUGINS_DIR
            echo -e "${GREEN}[*] Plugins directory updated to: $PLUGINS_DIR${NC}"
            ;;
        3) 
            AUTO_INSTALL_PLUGINS=$([[ "$AUTO_INSTALL_PLUGINS" == true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Auto-install plugins set to: $AUTO_INSTALL_PLUGINS${NC}"
            ;;
        4) 
            PLUGIN_AUTO_UPDATE=$([[ "$PLUGIN_AUTO_UPDATE" == true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Auto-update plugins set to: $PLUGIN_AUTO_UPDATE${NC}"
            ;;
        5) 
            return 
            ;;
        *) 
            echo -e "${RED}[!] Invalid option!${NC}" 
            ;;
    esac
    
    plugin_settings
}

# Main execution with plugin loading
main() {
    initialize_defaults
    load_config
    
    # Parse command line arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0 ;;
            -t|--target) TARGET="$2"; shift ;;
            -f|--file) TARGET_FILE="$2"; shift ;;
            -T|--threads) THREADS="$2"; shift ;;
            -N|--nuclei-threads) NUCLEI_THREADS="$2"; shift ;;
            -o|--output) OUTPUT_DIR="$2"; shift ;;
            -c|--collaborator) COLLABORATOR_URL="$2"; shift ;;
            -H|--host) LHOST="$2"; shift ;;
            -m|--mode) SCAN_MODE="$2"; shift ;;
            -p|--params) PARAMS_ONLY=true ;;
            -n|--no-color) COLOR_OUTPUT=false ;;
            -v|--verbose) VERBOSE=true ;;
            -d|--debug) DEBUG=true ;;
            -u|--update) check_for_updates; exit 0 ;;
            -C|--config) configure_settings; exit 0 ;;
            -P|--profile) load_profile "$2"; shift ;;
            -R|--report) generate_reports; exit 0 ;;
            --enable-plugins) ENABLE_PLUGINS=true ;;
            --disable-plugins) ENABLE_PLUGINS=false ;;
            --plugins-dir) PLUGINS_DIR="$2"; shift ;;
            *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
        esac
        shift
    done
    
    # If a single target is provided, create a targets file with it
    if [[ -n "$TARGET" ]]; then
        echo "$TARGET" > "$TARGET_FILE"
        echo -e "${BLUE}[*] Created targets file with: $TARGET${NC}"
    fi
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"
    
    # Load plugins if enabled
    if [[ "$ENABLE_PLUGINS" == true ]]; then
        load_plugins
    fi
    
    # Start the main menu or run in command-line mode
    if [[ -z "$SCAN_MODE" ]]; then
        display_banner
        main_menu
    else
        display_banner
        case "$SCAN_MODE" in
            "all") run_all_scans ;;
            "passive") run_reconnaissance ;;
            "recon") run_reconnaissance ;;
            "vuln") run_vulnerability_scanning ;;
            "quick") run_quick_scan ;;
            "fingerprint") run_fingerprinting ;;
            "custom") run_custom_scan ;;
            *) echo -e "${RED}[!] Unknown scan mode: $SCAN_MODE${NC}"; show_help; exit 1 ;;
        esac
        
        if [[ "$ENABLE_REPORTING" = true ]]; then
            generate_reports
        fi
        
        if [[ "$ENABLE_CLOUD_SYNC" = true ]]; then
            cloud_integration
        fi
        
        if [[ "$ENABLE_AI" = true ]]; then
            ai_analysis
        fi
        
        send_notification "BBHunter scan completed for $TARGET_FILE"
    fi
}

# Start the script
main "$@"
