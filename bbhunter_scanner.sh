#!/bin/bash
# =============================================
# ULTIMATE BUG BOUNTY HUNTER - All-in-One Scanner
# An advanced automated script for bug bounty hunting
# =============================================

# Configuration variables
CONFIG_FILE="bbhunter_config.conf"
VERSION="2.0"
LAST_UPDATE="2024-03-20"
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
    ENABLE_PLUGINS=false
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
}

# Load configuration file
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        echo -e "${GREEN}[*] Configuration loaded from $CONFIG_FILE${NC}"
    else
        echo -e "${YELLOW}[*] No configuration file found. Using defaults.${NC}"
        save_config
    fi
}

# Save configuration to file
save_config() {
    cat > "$CONFIG_FILE" << EOF
# BBHunter Configuration File
# Version: $VERSION
# Last Updated: $LAST_UPDATE

# General Settings
THREADS=$THREADS
TIMEOUT=$TIMEOUT
NUCLEI_THREADS=$NUCLEI_THREADS
TARGET_FILE="$TARGET_FILE"
OUTPUT_DIR="$OUTPUT_DIR"
COLLABORATOR_URL="$COLLABORATOR_URL"
LHOST="$LHOST"
GF_PATTERNS_DIR="$GF_PATTERNS_DIR"
SCAN_DELAY=$SCAN_DELAY
MAX_SCAN_TIME=$MAX_SCAN_TIME

# Notification Settings
NOTIFY_BELL=$NOTIFY_BELL
NOTIFY_DESKTOP=$NOTIFY_DESKTOP
NOTIFY_SLACK=$NOTIFY_SLACK
NOTIFY_DISCORD=$NOTIFY_DISCORD
SLACK_WEBHOOK="$SLACK_WEBHOOK"
DISCORD_WEBHOOK="$DISCORD_WEBHOOK"

# Scan Settings
PARAMS_ONLY=$PARAMS_ONLY
SCAN_MODE="$SCAN_MODE"
VERBOSE=$VERBOSE
DEBUG=$DEBUG
COLOR_OUTPUT=$COLOR_OUTPUT
SAVE_LOGS=$SAVE_LOGS
LOG_FILE="$LOG_FILE"
MAX_FILESIZE=$MAX_FILESIZE

# Network Settings
ENABLE_RATE_LIMITING=$ENABLE_RATE_LIMITING
RATE_LIMIT=$RATE_LIMIT
ENABLE_RETRY=$ENABLE_RETRY
MAX_RETRIES=$MAX_RETRIES
RETRY_DELAY=$RETRY_DELAY
ENABLE_PROXY=$ENABLE_PROXY
PROXY_URL="$PROXY_URL"
PROXY_AUTH="$PROXY_AUTH"
ENABLE_TOR=$ENABLE_TOR
TOR_PROXY="$TOR_PROXY"

# API Settings
ENABLE_API_SCANS=$ENABLE_API_SCANS
SHODAN_API="$SHODAN_API"
CENSYS_API="$CENSYS_API"
VIRUSTOTAL_API="$VIRUSTOTAL_API"
SECURITYTRAILS_API="$SECURITYTRAILS_API"

# Advanced Settings
ENABLE_BRUTEFORCE=$ENABLE_BRUTEFORCE
BRUTEFORCE_WORDLIST="$BRUTEFORCE_WORDLIST"
ENABLE_FUZZING=$ENABLE_FUZZING
FUZZING_WORDLIST="$FUZZING_WORDLIST"
ENABLE_CRAWLING=$ENABLE_CRAWLING
CRAWL_DEPTH=$CRAWL_DEPTH
ENABLE_SCREENSHOTS=$ENABLE_SCREENSHOTS
ENABLE_ARCHIVE=$ENABLE_ARCHIVE
ENABLE_BACKUP=$ENABLE_BACKUP
BACKUP_DIR="$BACKUP_DIR"
ENABLE_UPDATE_CHECK=$ENABLE_UPDATE_CHECK
ENABLE_AUTO_UPDATE=$ENABLE_AUTO_UPDATE
GITHUB_REPO="$GITHUB_REPO"
ENABLE_TELEMETRY=$ENABLE_TELEMETRY
TELEMETRY_URL="$TELEMETRY_URL"

# UI Settings
ENABLE_BANNER=$ENABLE_BANNER
ENABLE_PROGRESS_BAR=$ENABLE_PROGRESS_BAR
ENABLE_SUMMARY=$ENABLE_SUMMARY
ENABLE_TIMESTAMPS=$ENABLE_TIMESTAMPS

# System Settings
ENABLE_EXIT_HANDLERS=$ENABLE_EXIT_HANDLERS
ENABLE_ERROR_HANDLING=$ENABLE_ERROR_HANDLING
ENABLE_SIGNAL_HANDLING=$ENABLE_SIGNAL_HANDLING
ENABLE_CLEANUP=$ENABLE_CLEANUP
ENABLE_VALIDATION=$ENABLE_VALIDATION
ENABLE_SANITY_CHECKS=$ENABLE_SANITY_CHECKS
ENABLE_PERFORMANCE_MONITORING=$ENABLE_PERFORMANCE_MONITORING
ENABLE_RESOURCE_LIMITS=$ENABLE_RESOURCE_LIMITS
CPU_LIMIT=$CPU_LIMIT
MEMORY_LIMIT=$MEMORY_LIMIT
ENABLE_TEMP_FILES=$ENABLE_TEMP_FILES
TEMP_DIR="$TEMP_DIR"

# Data Settings
ENABLE_HISTORY=$ENABLE_HISTORY
HISTORY_FILE="$HISTORY_FILE"
ENABLE_BOOKMARKS=$ENABLE_BOOKMARKS
BOOKMARKS_FILE="$BOOKMARKS_FILE"
ENABLE_PROFILES=$ENABLE_PROFILES
PROFILES_DIR="$PROFILES_DIR"
ENABLE_PLUGINS=$ENABLE_PLUGINS
PLUGINS_DIR="$PLUGINS_DIR"
ENABLE_TEMPLATES=$ENABLE_TEMPLATES
TEMPLATES_DIR="$TEMPLATES_DIR"

# AI Settings
ENABLE_AI=$ENABLE_AI
AI_API_KEY="$AI_API_KEY"

# Output Settings
ENABLE_REPORTING=$ENABLE_REPORTING
REPORT_FORMAT="$REPORT_FORMAT"
ENABLE_DASHBOARD=$ENABLE_DASHBOARD
DASHBOARD_PORT=$DASHBOARD_PORT
ENABLE_API_SERVER=$ENABLE_API_SERVER
API_SERVER_PORT=$API_SERVER_PORT
ENABLE_CLOUD_SYNC=$ENABLE_CLOUD_SYNC
CLOUD_PROVIDER="$CLOUD_PROVIDER"
CLOUD_BUCKET="$CLOUD_BUCKET"
CLOUD_CREDENTIALS="$CLOUD_CREDENTIALS"
EOF

    echo -e "${GREEN}[*] Configuration saved to $CONFIG_FILE${NC}"
}

# Enhanced banner function
display_banner() {
    if [[ "$ENABLE_BANNER" = true ]]; then
        clear
        echo -e "${CYAN}"
        echo " ██████╗ ██████╗ ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ "
        echo "██╔════╝ ██╔══██╗██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗"
        echo "██║  ███╗██████╔╝███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝"
        echo "██║   ██║██╔══██╗██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗"
        echo "╚██████╔╝██║  ██║██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║"
        echo " ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝"
        echo -e "                                                   ${RED}ULTIMATE EDITION ${NC}v$VERSION"
        echo -e "${GREEN}===========================================================================${NC}"
        echo -e "${YELLOW}                Advanced Bug Bounty Hunting Automation Framework           ${NC}"
        echo -e "${BLUE}                     Author: $AUTHOR | Last Update: $LAST_UPDATE            ${NC}"
        echo -e "${GREEN}===========================================================================${NC}"
        echo ""
        
        if [[ "$ENABLE_UPDATE_CHECK" = true ]]; then
            check_for_updates
        fi
    fi
}

# Check for script updates
check_for_updates() {
    if [[ "$ENABLE_AUTO_UPDATE" = true ]]; then
        echo -e "${YELLOW}[*] Checking for updates...${NC}"
        latest_version=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        
        if [[ "$latest_version" != "$VERSION" ]]; then
            echo -e "${GREEN}[+] New version available: $latest_version${NC}"
            echo -e "${YELLOW}[*] Updating script...${NC}"
            curl -sL "https://github.com/$GITHUB_REPO/releases/download/$latest_version/bbhunter.sh" -o "$0"
            chmod +x "$0"
            echo -e "${GREEN}[+] Update successful! Restarting script...${NC}"
            exec "$0" "$@"
        else
            echo -e "${GREEN}[✓] You're running the latest version ($VERSION)${NC}"
        fi
    fi
}

# Enhanced help menu
show_help() {
    echo -e "${BLUE}${BOLD}Usage:${NC}"
    echo -e "  ./bbhunter.sh [options]"
    echo ""
    echo -e "${BLUE}${BOLD}Options:${NC}"
    echo -e "  ${GREEN}-h, --help${NC}                 Show this help message and exit"
    echo -e "  ${GREEN}-t, --target <domain>${NC}      Single target domain (alternative to target file)"
    echo -e "  ${GREEN}-f, --file <file>${NC}          File containing list of targets (default: domains.txt)"
    echo -e "  ${GREEN}-T, --threads <number>${NC}     Number of threads (default: 100)"
    echo -e "  ${GREEN}-N, --nuclei-threads <num>${NC} Number of nuclei threads (default: 50)"
    echo -e "  ${GREEN}-o, --output <directory>${NC}   Output directory (default: results_date_time)"
    echo -e "  ${GREEN}-c, --collaborator <url>${NC}   Burp Collaborator URL for SSRF testing"
    echo -e "  ${GREEN}-H, --host <url>${NC}           Your server URL for callbacks"
    echo -e "  ${GREEN}-m, --mode <mode>${NC}          Scan mode (all, passive, recon, vuln, quick, fingerprint)"
    echo -e "  ${GREEN}-p, --params${NC}               Only test URLs with parameters (faster)"
    echo -e "  ${GREEN}-n, --no-color${NC}             Disable colored output"
    echo -e "  ${GREEN}-v, --verbose${NC}              Enable verbose output"
    echo -e "  ${GREEN}-d, --debug${NC}                Enable debug mode"
    echo -e "  ${GREEN}-u, --update${NC}               Update the script to latest version"
    echo -e "  ${GREEN}-C, --config${NC}               Edit configuration file"
    echo -e "  ${GREEN}-P, --profile${NC}              Load scan profile"
    echo -e "  ${GREEN}-R, --report${NC}               Generate report after scan"
    echo ""
    echo -e "${BLUE}${BOLD}Scan Modes:${NC}"
    echo -e "  ${GREEN}all${NC}          - Run all scans (recon + vulnerability scanning)"
    echo -e "  ${GREEN}passive${NC}      - Passive reconnaissance only"
    echo -e "  ${GREEN}recon${NC}        - Active reconnaissance"
    echo -e "  ${GREEN}vuln${NC}         - Vulnerability scanning only"
    echo -e "  ${GREEN}quick${NC}        - Quick scan (basic checks)"
    echo -e "  ${GREEN}fingerprint${NC}  - Technology fingerprinting only"
    echo -e "  ${GREEN}custom${NC}       - Custom scan profile"
    echo ""
    echo -e "${BLUE}${BOLD}Examples:${NC}"
    echo -e "  ${CYAN}./bbhunter.sh -t example.com -m quick${NC}"
    echo -e "  ${CYAN}./bbhunter.sh -f my-targets.txt -T 100 -m all${NC}"
    echo -e "  ${CYAN}./bbhunter.sh -f domains.txt -m fingerprint -v${NC}"
    echo -e "  ${CYAN}./bbhunter.sh -P custom_profile -o custom_scan_results${NC}"
    echo ""
}

# Enhanced main menu with more options
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
        echo -e "${CYAN}${BOLD}║ ${GREEN}15. Exit${NC} - Quit the program             ║"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-15]: ${NC}")" choice
        
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
            15) echo -e "${GREEN}[*] Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}[!] Invalid option!${NC}" ;;
        esac
    done
}

# Enhanced configuration menu
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
        echo -e "${CYAN}${BOLD}║ ${GREEN}8. Save Configuration${NC}                   ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}9. Reset to Defaults${NC}                    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}10. Back to Main Menu${NC}                   ║"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-10]: ${NC}")" config_choice
        
        case $config_choice in
            1) general_settings ;;
            2) scan_settings ;;
            3) network_settings ;;
            4) api_settings ;;
            5) output_settings ;;
            6) system_settings ;;
            7) ui_settings ;;
            8) save_config; echo -e "${GREEN}[*] Configuration saved!${NC}" ;;
            9) reset_defaults ;;
            10) return ;;
            *) echo -e "${RED}[!] Invalid option!${NC}" ;;
        esac
    done
}

# General settings menu
general_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║             GENERAL SETTINGS                ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Threads (current: $THREADS)${NC}"
    echo -e "${BLUE}2. Timeout (current: $TIMEOUT sec)${NC}"
    echo -e "${BLUE}3. Nuclei Threads (current: $NUCLEI_THREADS)${NC}"
    echo -e "${BLUE}4. Target File (current: $TARGET_FILE)${NC}"
    echo -e "${BLUE}5. Output Directory (current: $OUTPUT_DIR)${NC}"
    echo -e "${BLUE}6. Collaborator URL (current: $COLLABORATOR_URL)${NC}"
    echo -e "${BLUE}7. Callback Host (current: $LHOST)${NC}"
    echo -e "${BLUE}8. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-8]: ${NC}")" choice
    
    case $choice in
        1) read -p "Enter new thread count: " THREADS
           echo -e "${GREEN}[*] Thread count updated to $THREADS${NC}" ;;
        2) read -p "Enter new timeout in seconds: " TIMEOUT
           echo -e "${GREEN}[*] Timeout updated to $TIMEOUT sec${NC}" ;;
        3) read -p "Enter new nuclei thread count: " NUCLEI_THREADS
           echo -e "${GREEN}[*] Nuclei thread count updated to $NUCLEI_THREADS${NC}" ;;
        4) read -p "Enter new target file path: " TARGET_FILE
           echo -e "${GREEN}[*] Target file updated to $TARGET_FILE${NC}" ;;
        5) read -p "Enter new output directory: " OUTPUT_DIR
           echo -e "${GREEN}[*] Output directory updated to $OUTPUT_DIR${NC}" ;;
        6) read -p "Enter new Collaborator URL: " COLLABORATOR_URL
           echo -e "${GREEN}[*] Collaborator URL updated to $COLLABORATOR_URL${NC}" ;;
        7) read -p "Enter new callback host: " LHOST
           echo -e "${GREEN}[*] Callback host updated to $LHOST${NC}" ;;
        8) return ;;
        *) echo -e "${RED}[!] Invalid option!${NC}" ;;
    esac
    
    general_settings
}

# Scan settings menu
scan_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║              SCAN SETTINGS                  ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Scan Mode (current: $SCAN_MODE)${NC}"
    echo -e "${BLUE}2. Parameters Only (current: $PARAMS_ONLY)${NC}"
    echo -e "${BLUE}3. Verbose Output (current: $VERBOSE)${NC}"
    echo -e "${BLUE}4. Debug Mode (current: $DEBUG)${NC}"
    echo -e "${BLUE}5. Save Logs (current: $SAVE_LOGS)${NC}"
    echo -e "${BLUE}6. Log File (current: $LOG_FILE)${NC}"
    echo -e "${BLUE}7. Max File Size (current: $MAX_FILESIZE MB)${NC}"
    echo -e "${BLUE}8. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-8]: ${NC}")" choice
    
    case $choice in
        1) 
            echo -e "${YELLOW}Available scan modes: all, passive, recon, vuln, quick, fingerprint, custom"
            read -p "Enter new scan mode: " SCAN_MODE
            echo -e "${GREEN}[*] Scan mode updated to $SCAN_MODE${NC}" 
            ;;
        2) 
            PARAMS_ONLY=$([[ "$PARAMS_ONLY" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Parameters only set to $PARAMS_ONLY${NC}" 
            ;;
        3) 
            VERBOSE=$([[ "$VERBOSE" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Verbose output set to $VERBOSE${NC}" 
            ;;
        4) 
            DEBUG=$([[ "$DEBUG" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Debug mode set to $DEBUG${NC}" 
            ;;
        5) 
            SAVE_LOGS=$([[ "$SAVE_LOGS" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Save logs set to $SAVE_LOGS${NC}" 
            ;;
        6) 
            read -p "Enter new log file path: " LOG_FILE
            echo -e "${GREEN}[*] Log file updated to $LOG_FILE${NC}" 
            ;;
        7) 
            read -p "Enter new max file size in MB: " MAX_FILESIZE
            echo -e "${GREEN}[*] Max file size updated to $MAX_FILESIZE MB${NC}" 
            ;;
        8) 
            return 
            ;;
        *) 
            echo -e "${RED}[!] Invalid option!${NC}" 
            ;;
    esac
    
    scan_settings
}

# Network settings menu
network_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║             NETWORK SETTINGS                ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Enable Rate Limiting (current: $ENABLE_RATE_LIMITING)${NC}"
    echo -e "${BLUE}2. Rate Limit (current: $RATE_LIMIT req/sec)${NC}"
    echo -e "${BLUE}3. Enable Retry (current: $ENABLE_RETRY)${NC}"
    echo -e "${BLUE}4. Max Retries (current: $MAX_RETRIES)${NC}"
    echo -e "${BLUE}5. Retry Delay (current: $RETRY_DELAY sec)${NC}"
    echo -e "${BLUE}6. Enable Proxy (current: $ENABLE_PROXY)${NC}"
    echo -e "${BLUE}7. Proxy URL (current: $PROXY_URL)${NC}"
    echo -e "${BLUE}8. Proxy Auth (current: $PROXY_AUTH)${NC}"
    echo -e "${BLUE}9. Enable Tor (current: $ENABLE_TOR)${NC}"
    echo -e "${BLUE}10. Tor Proxy (current: $TOR_PROXY)${NC}"
    echo -e "${BLUE}11. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-11]: ${NC}")" choice
    
    case $choice in
        1) 
            ENABLE_RATE_LIMITING=$([[ "$ENABLE_RATE_LIMITING" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Rate limiting set to $ENABLE_RATE_LIMITING${NC}" 
            ;;
        2) 
            read -p "Enter new rate limit (requests per second): " RATE_LIMIT
            echo -e "${GREEN}[*] Rate limit updated to $RATE_LIMIT req/sec${NC}" 
            ;;
        3) 
            ENABLE_RETRY=$([[ "$ENABLE_RETRY" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Retry set to $ENABLE_RETRY${NC}" 
            ;;
        4) 
            read -p "Enter new max retries: " MAX_RETRIES
            echo -e "${GREEN}[*] Max retries updated to $MAX_RETRIES${NC}" 
            ;;
        5) 
            read -p "Enter new retry delay in seconds: " RETRY_DELAY
            echo -e "${GREEN}[*] Retry delay updated to $RETRY_DELAY sec${NC}" 
            ;;
        6) 
            ENABLE_PROXY=$([[ "$ENABLE_PROXY" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Proxy set to $ENABLE_PROXY${NC}" 
            ;;
        7) 
            read -p "Enter new proxy URL: " PROXY_URL
            echo -e "${GREEN}[*] Proxy URL updated to $PROXY_URL${NC}" 
            ;;
        8) 
            read -p "Enter new proxy authentication (user:pass): " PROXY_AUTH
            echo -e "${GREEN}[*] Proxy auth updated${NC}" 
            ;;
        9) 
            ENABLE_TOR=$([[ "$ENABLE_TOR" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Tor set to $ENABLE_TOR${NC}" 
            ;;
        10) 
            read -p "Enter new Tor proxy URL: " TOR_PROXY
            echo -e "${GREEN}[*] Tor proxy updated to $TOR_PROXY${NC}" 
            ;;
        11) 
            return 
            ;;
        *) 
            echo -e "${RED}[!] Invalid option!${NC}" 
            ;;
    esac
    
    network_settings
}

# API settings menu
api_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║               API SETTINGS                  ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Enable API Scans (current: $ENABLE_API_SCANS)${NC}"
    echo -e "${BLUE}2. Shodan API Key (current: ${#SHODAN_API} chars)${NC}"
    echo -e "${BLUE}3. Censys API Key (current: ${#CENSYS_API} chars)${NC}"
    echo -e "${BLUE}4. VirusTotal API Key (current: ${#VIRUSTOTAL_API} chars)${NC}"
    echo -e "${BLUE}5. SecurityTrails API Key (current: ${#SECURITYTRAILS_API} chars)${NC}"
    echo -e "${BLUE}6. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-6]: ${NC}")" choice
    
    case $choice in
        1) 
            ENABLE_API_SCANS=$([[ "$ENABLE_API_SCANS" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] API scans set to $ENABLE_API_SCANS${NC}" 
            ;;
        2) 
            read -p "Enter Shodan API key: " SHODAN_API
            echo -e "${GREEN}[*] Shodan API key updated${NC}" 
            ;;
        3) 
            read -p "Enter Censys API key: " CENSYS_API
            echo -e "${GREEN}[*] Censys API key updated${NC}" 
            ;;
        4) 
            read -p "Enter VirusTotal API key: " VIRUSTOTAL_API
            echo -e "${GREEN}[*] VirusTotal API key updated${NC}" 
            ;;
        5) 
            read -p "Enter SecurityTrails API key: " SECURITYTRAILS_API
            echo -e "${GREEN}[*] SecurityTrails API key updated${NC}" 
            ;;
        6) 
            return 
            ;;
        *) 
            echo -e "${RED}[!] Invalid option!${NC}" 
            ;;
    esac
    
    api_settings
}

# Output settings menu
output_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║              OUTPUT SETTINGS                ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Enable Reporting (current: $ENABLE_REPORTING)${NC}"
    echo -e "${BLUE}2. Report Format (current: $REPORT_FORMAT)${NC}"
    echo -e "${BLUE}3. Enable Dashboard (current: $ENABLE_DASHBOARD)${NC}"
    echo -e "${BLUE}4. Dashboard Port (current: $DASHBOARD_PORT)${NC}"
    echo -e "${BLUE}5. Enable API Server (current: $ENABLE_API_SERVER)${NC}"
    echo -e "${BLUE}6. API Server Port (current: $API_SERVER_PORT)${NC}"
    echo -e "${BLUE}7. Enable Cloud Sync (current: $ENABLE_CLOUD_SYNC)${NC}"
    echo -e "${BLUE}8. Cloud Provider (current: $CLOUD_PROVIDER)${NC}"
    echo -e "${BLUE}9. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-9]: ${NC}")" choice
    
    case $choice in
        1) 
            ENABLE_REPORTING=$([[ "$ENABLE_REPORTING" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Reporting set to $ENABLE_REPORTING${NC}" 
            ;;
        2) 
            echo -e "${YELLOW}Available formats: html, json, pdf, markdown"
            read -p "Enter new report format: " REPORT_FORMAT
            echo -e "${GREEN}[*] Report format updated to $REPORT_FORMAT${NC}" 
            ;;
        3) 
            ENABLE_DASHBOARD=$([[ "$ENABLE_DASHBOARD" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Dashboard set to $ENABLE_DASHBOARD${NC}" 
            ;;
        4) 
            read -p "Enter new dashboard port: " DASHBOARD_PORT
            echo -e "${GREEN}[*] Dashboard port updated to $DASHBOARD_PORT${NC}" 
            ;;
        5) 
            ENABLE_API_SERVER=$([[ "$ENABLE_API_SERVER" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] API server set to $ENABLE_API_SERVER${NC}" 
            ;;
        6) 
            read -p "Enter new API server port: " API_SERVER_PORT
            echo -e "${GREEN}[*] API server port updated to $API_SERVER_PORT${NC}" 
            ;;
        7) 
            ENABLE_CLOUD_SYNC=$([[ "$ENABLE_CLOUD_SYNC" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Cloud sync set to $ENABLE_CLOUD_SYNC${NC}" 
            ;;
        8) 
            echo -e "${YELLOW}Available providers: aws, gcp, azure, digitalocean"
            read -p "Enter new cloud provider: " CLOUD_PROVIDER
            echo -e "${GREEN}[*] Cloud provider updated to $CLOUD_PROVIDER${NC}" 
            ;;
        9) 
            return 
            ;;
        *) 
            echo -e "${RED}[!] Invalid option!${NC}" 
            ;;
    esac
    
    output_settings
}

# System settings menu
system_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║              SYSTEM SETTINGS                ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Enable Exit Handlers (current: $ENABLE_EXIT_HANDLERS)${NC}"
    echo -e "${BLUE}2. Enable Error Handling (current: $ENABLE_ERROR_HANDLING)${NC}"
    echo -e "${BLUE}3. Enable Signal Handling (current: $ENABLE_SIGNAL_HANDLING)${NC}"
    echo -e "${BLUE}4. Enable Cleanup (current: $ENABLE_CLEANUP)${NC}"
    echo -e "${BLUE}5. Enable Validation (current: $ENABLE_VALIDATION)${NC}"
    echo -e "${BLUE}6. Enable Sanity Checks (current: $ENABLE_SANITY_CHECKS)${NC}"
    echo -e "${BLUE}7. Enable Performance Monitoring (current: $ENABLE_PERFORMANCE_MONITORING)${NC}"
    echo -e "${BLUE}8. Enable Resource Limits (current: $ENABLE_RESOURCE_LIMITS)${NC}"
    echo -e "${BLUE}9. CPU Limit (current: $CPU_LIMIT%)${NC}"
    echo -e "${BLUE}10. Memory Limit (current: $MEMORY_LIMIT%)${NC}"
    echo -e "${BLUE}11. Enable Temp Files (current: $ENABLE_TEMP_FILES)${NC}"
    echo -e "${BLUE}12. Temp Directory (current: $TEMP_DIR)${NC}"
    echo -e "${BLUE}13. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-13]: ${NC}")" choice
    
    case $choice in
        1) 
            ENABLE_EXIT_HANDLERS=$([[ "$ENABLE_EXIT_HANDLERS" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Exit handlers set to $ENABLE_EXIT_HANDLERS${NC}" 
            ;;
        2) 
            ENABLE_ERROR_HANDLING=$([[ "$ENABLE_ERROR_HANDLING" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Error handling set to $ENABLE_ERROR_HANDLING${NC}" 
            ;;
        3) 
            ENABLE_SIGNAL_HANDLING=$([[ "$ENABLE_SIGNAL_HANDLING" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Signal handling set to $ENABLE_SIGNAL_HANDLING${NC}" 
            ;;
        4) 
            ENABLE_CLEANUP=$([[ "$ENABLE_CLEANUP" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Cleanup set to $ENABLE_CLEANUP${NC}" 
            ;;
        5) 
            ENABLE_VALIDATION=$([[ "$ENABLE_VALIDATION" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Validation set to $ENABLE_VALIDATION${NC}" 
            ;;
        6) 
            ENABLE_SANITY_CHECKS=$([[ "$ENABLE_SANITY_CHECKS" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Sanity checks set to $ENABLE_SANITY_CHECKS${NC}" 
            ;;
        7) 
            ENABLE_PERFORMANCE_MONITORING=$([[ "$ENABLE_PERFORMANCE_MONITORING" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Performance monitoring set to $ENABLE_PERFORMANCE_MONITORING${NC}" 
            ;;
        8) 
            ENABLE_RESOURCE_LIMITS=$([[ "$ENABLE_RESOURCE_LIMITS" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Resource limits set to $ENABLE_RESOURCE_LIMITS${NC}" 
            ;;
        9) 
            read -p "Enter new CPU limit (percentage): " CPU_LIMIT
            echo -e "${GREEN}[*] CPU limit updated to $CPU_LIMIT%${NC}" 
            ;;
        10) 
            read -p "Enter new memory limit (percentage): " MEMORY_LIMIT
            echo -e "${GREEN}[*] Memory limit updated to $MEMORY_LIMIT%${NC}" 
            ;;
        11) 
            ENABLE_TEMP_FILES=$([[ "$ENABLE_TEMP_FILES" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Temp files set to $ENABLE_TEMP_FILES${NC}" 
            ;;
        12) 
            read -p "Enter new temp directory: " TEMP_DIR
            echo -e "${GREEN}[*] Temp directory updated to $TEMP_DIR${NC}" 
            ;;
        13) 
            return 
            ;;
        *) 
            echo -e "${RED}[!] Invalid option!${NC}" 
            ;;
    esac
    
    system_settings
}

# UI settings menu
ui_settings() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║               UI SETTINGS                   ║${NC}"
    echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}1. Enable Banner (current: $ENABLE_BANNER)${NC}"
    echo -e "${BLUE}2. Enable Progress Bar (current: $ENABLE_PROGRESS_BAR)${NC}"
    echo -e "${BLUE}3. Enable Summary (current: $ENABLE_SUMMARY)${NC}"
    echo -e "${BLUE}4. Enable Timestamps (current: $ENABLE_TIMESTAMPS)${NC}"
    echo -e "${BLUE}5. Color Output (current: $COLOR_OUTPUT)${NC}"
    echo -e "${BLUE}6. Back to Configuration Menu${NC}"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-6]: ${NC}")" choice
    
    case $choice in
        1) 
            ENABLE_BANNER=$([[ "$ENABLE_BANNER" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Banner set to $ENABLE_BANNER${NC}" 
            ;;
        2) 
            ENABLE_PROGRESS_BAR=$([[ "$ENABLE_PROGRESS_BAR" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Progress bar set to $ENABLE_PROGRESS_BAR${NC}" 
            ;;
        3) 
            ENABLE_SUMMARY=$([[ "$ENABLE_SUMMARY" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Summary set to $ENABLE_SUMMARY${NC}" 
            ;;
        4) 
            ENABLE_TIMESTAMPS=$([[ "$ENABLE_TIMESTAMPS" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Timestamps set to $ENABLE_TIMESTAMPS${NC}" 
            ;;
        5) 
            COLOR_OUTPUT=$([[ "$COLOR_OUTPUT" = true ]] && echo false || echo true)
            echo -e "${GREEN}[*] Color output set to $COLOR_OUTPUT${NC}" 
            ;;
        6) 
            return 
            ;;
        *) 
            echo -e "${RED}[!] Invalid option!${NC}" 
            ;;
    esac
    
    ui_settings
}

# Reset to defaults
reset_defaults() {
    echo -e "${YELLOW}[*] Resetting to default settings...${NC}"
    initialize_defaults
    echo -e "${GREEN}[*] Settings have been reset to defaults${NC}"
}

# Notification settings
notification_settings() {
    while true; do
        echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}${BOLD}║          NOTIFICATION SETTINGS              ║${NC}"
        echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}${BOLD}║ ${GREEN}1. Terminal Bell (current: $NOTIFY_BELL)${NC}      ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}2. Desktop Notification (current: $NOTIFY_DESKTOP)${NC} ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}3. Slack Webhook (current: ${#SLACK_WEBHOOK} chars)${NC} ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}4. Discord Webhook (current: ${#DISCORD_WEBHOOK} chars)${NC}║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}5. Test Notifications${NC}                     ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}6. Back to Main Menu${NC}                     ║"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-6]: ${NC}")" choice
        
        case $choice in
            1) 
                NOTIFY_BELL=$([[ "$NOTIFY_BELL" = true ]] && echo false || echo true)
                echo -e "${GREEN}[*] Terminal bell notification set to $NOTIFY_BELL${NC}" 
                ;;
            2) 
                if command -v notify-send &> /dev/null; then
                    NOTIFY_DESKTOP=$([[ "$NOTIFY_DESKTOP" = true ]] && echo false || echo true)
                    echo -e "${GREEN}[*] Desktop notification set to $NOTIFY_DESKTOP${NC}"
                else
                    echo -e "${RED}[!] notify-send not found. Cannot enable desktop notifications.${NC}"
                fi
                ;;
            3) 
                read -p "Enter Slack webhook URL: " SLACK_WEBHOOK
                NOTIFY_SLACK=true
                echo -e "${GREEN}[*] Slack webhook updated${NC}" 
                ;;
            4) 
                read -p "Enter Discord webhook URL: " DISCORD_WEBHOOK
                NOTIFY_DISCORD=true
                echo -e "${GREEN}[*] Discord webhook updated${NC}" 
                ;;
            5) 
                send_notification "This is a test notification from BBHunter"
                echo -e "${GREEN}[*] Test notification sent${NC}" 
                ;;
            6) 
                return 
                ;;
            *) 
                echo -e "${RED}[!] Invalid option!${NC}" 
                ;;
        esac
    done
}

# Send notification function
send_notification() {
    local message="$1"
    
    # Terminal bell
    if [[ "$NOTIFY_BELL" = true ]]; then
        echo -e "\a"
    fi
    
    # Desktop notification
    if [[ "$NOTIFY_DESKTOP" = true ]]; then
        notify-send "Bug Bounty Hunter" "$message"
    fi
    
    # Slack notification
    if [[ "$NOTIFY_SLACK" = true && -n "$SLACK_WEBHOOK" ]]; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$SLACK_WEBHOOK" &>/dev/null
    fi
    
    # Discord notification
    if [[ "$NOTIFY_DISCORD" = true && -n "$DISCORD_WEBHOOK" ]]; then
        curl -s -X POST -H "Content-Type: application/json" \
            --data "{\"content\":\"$message\"}" \
            "$DISCORD_WEBHOOK" &>/dev/null
    fi
}

# Tools management menu
manage_tools() {
    while true; do
        echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}${BOLD}║             TOOLS MANAGEMENT               ║${NC}"
        echo -e "${CYAN}${BOLD}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}${BOLD}║ ${GREEN}1. Check Installed Tools${NC}                ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}2. Install Missing Tools${NC}                ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}3. Update All Tools${NC}                    ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}4. Install Specific Tool${NC}               ║"
        echo -e "${CYAN}${BOLD}║ ${GREEN}5. Back to Main Menu${NC}                   ║"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-5]: ${NC}")" choice
        
        case $choice in
            1) check_requirements ;;
            2) install_missing_tools ;;
            3) update_all_tools ;;
            4) install_specific_tool ;;
            5) return ;;
            *) echo -e "${RED}[!] Invalid option!${NC}" ;;
        esac
    done
}

# Check tool requirements
check_requirements() {
    echo -e "\n${BLUE}[*] Checking for required tools...${NC}"
    
    local REQUIRED_TOOLS=("subfinder" "httpx" "gau" "waybackurls" "nuclei" "anew" "assetfinder" "findomain" "qsreplace" "dalfox" "gf" "ffuf" "whatweb" "nmap" "wafw00f")
    local MISSING_TOOLS=()
    local INSTALLED_TOOLS=()
    
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            INSTALLED_TOOLS+=("$tool")
            echo -e "${GREEN}[✓] $tool${NC}"
        else
            MISSING_TOOLS+=("$tool")
            echo -e "${RED}[✗] $tool${NC}"
        fi
    done
    
    echo -e "\n${BLUE}[*] Summary:${NC}"
    echo -e "${GREEN}Installed tools: ${#INSTALLED_TOOLS[@]}${NC}"
    echo -e "${RED}Missing tools: ${#MISSING_TOOLS[@]}${NC}"
    
    if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}[!] The following tools are missing:${NC}"
        for tool in "${MISSING_TOOLS[@]}"; do
            echo -e "${RED}- $tool${NC}"
        done
    fi
}

# Install missing tools
install_missing_tools() {
    check_requirements
    
    if [[ ${#MISSING_TOOLS[@]} -eq 0 ]]; then
        echo -e "${GREEN}[*] All required tools are already installed!${NC}"
        return
    fi
    
    echo -e "\n${YELLOW}[*] Installing missing tools...${NC}"
    
    for tool in "${MISSING_TOOLS[@]}"; do
        echo -e "${BLUE}[*] Installing $tool...${NC}"
        case $tool in
            "subfinder") go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest ;;
            "httpx") go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest ;;
            "gau") go install -v github.com/lc/gau/v2/cmd/gau@latest ;;
            "waybackurls") go install -v github.com/tomnomnom/waybackurls@latest ;;
            "nuclei") go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest ;;
            "anew") go install -v github.com/tomnomnom/anew@latest ;;
            "assetfinder") go install -v github.com/tomnomnom/assetfinder@latest ;;
            "findomain") 
                curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip
                unzip findomain-linux.zip
                chmod +x findomain
                sudo mv findomain /usr/local/bin/
                rm findomain-linux.zip
                ;;
            "qsreplace") go install -v github.com/tomnomnom/qsreplace@latest ;;
            "dalfox") go install -v github.com/hahwul/dalfox/v2@latest ;;
            "gf") go install -v github.com/tomnomnom/gf@latest ;;
            "ffuf") go install -v github.com/ffuf/ffuf@latest ;;
            "whatweb") sudo gem install whatweb ;;
            "wafw00f") pip3 install wafw00f ;;
            *) echo -e "${RED}[!] Unknown tool: $tool${NC}" ;;
        esac
        
        # Verify installation
        if command -v "$tool" &> /dev/null; then
            echo -e "${GREEN}[✓] Successfully installed $tool${NC}"
        else
            echo -e "${RED}[✗] Failed to install $tool${NC}"
        fi
    done
    
    echo -e "\n${GREEN}[*] Installation complete!${NC}"
    echo -e "${YELLOW}[*] You may need to add \$HOME/go/bin to your PATH${NC}"
    echo -e "${YELLOW}[*] Run: export PATH=\$PATH:\$HOME/go/bin${NC}"
}

# Update all tools
update_all_tools() {
    echo -e "\n${BLUE}[*] Updating all tools...${NC}"
    
    # Update Go-based tools
    if command -v go &> /dev/null; then
        echo -e "${YELLOW}[*] Updating Go-based tools...${NC}"
        local GO_TOOLS=("subfinder" "httpx" "gau" "waybackurls" "nuclei" "anew" "assetfinder" "qsreplace" "dalfox" "gf" "ffuf")
        
        for tool in "${GO_TOOLS[@]}"; do
            if command -v "$tool" &> /dev/null; then
                echo -e "${BLUE}[*] Updating $tool...${NC}"
                go install -v "github.com/$(curl -s "https://pkg.go.dev/search?q=$tool" | grep -m1 -oP 'github\.com/[^"]+' | head -1)"@latest
            fi
        done
    fi
    
    # Update other tools
    echo -e "${YELLOW}[*] Updating other tools...${NC}"
    
    # Update findomain
    if command -v findomain &> /dev/null; then
        echo -e "${BLUE}[*] Updating findomain...${NC}"
        curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip
        unzip findomain-linux.zip
        chmod +x findomain
        sudo mv findomain /usr/local/bin/
        rm findomain-linux.zip
    fi
    
    # Update whatweb
    if command -v whatweb &> /dev/null; then
        echo -e "${BLUE}[*] Updating whatweb...${NC}"
        sudo gem update whatweb
    fi
    
    # Update wafw00f
    if command -v wafw00f &> /dev/null; then
        echo -e "${BLUE}[*] Updating wafw00f...${NC}"
        pip3 install --upgrade wafw00f
    fi
    
    echo -e "\n${GREEN}[*] Update complete!${NC}"
}

# Install specific tool
install_specific_tool() {
    echo -e "\n${BLUE}Available tools:${NC}"
    echo -e "1. subfinder"
    echo -e "2. httpx"
    echo -e "3. gau"
    echo -e "4. waybackurls"
    echo -e "5. nuclei"
    echo -e "6. anew"
    echo -e "7. assetfinder"
    echo -e "8. findomain"
    echo -e "9. qsreplace"
    echo -e "10. dalfox"
    echo -e "11. gf"
    echo -e "12. ffuf"
    echo -e "13. whatweb"
    echo -e "14. nmap"
    echo -e "15. wafw00f"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter tool number to install [1-15]: ${NC}")" tool_num
    
    case $tool_num in
        1) tool="subfinder"; cmd="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" ;;
        2) tool="httpx"; cmd="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest" ;;
        3) tool="gau"; cmd="go install -v github.com/lc/gau/v2/cmd/gau@latest" ;;
        4) tool="waybackurls"; cmd="go install -v github.com/tomnomnom/waybackurls@latest" ;;
        5) tool="nuclei"; cmd="go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest" ;;
        6) tool="anew"; cmd="go install -v github.com/tomnomnom/anew@latest" ;;
        7) tool="assetfinder"; cmd="go install -v github.com/tomnomnom/assetfinder@latest" ;;
        8) 
            tool="findomain"
            cmd="curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip && unzip findomain-linux.zip && chmod +x findomain && sudo mv findomain /usr/local/bin/ && rm findomain-linux.zip"
            ;;
        9) tool="qsreplace"; cmd="go install -v github.com/tomnomnom/qsreplace@latest" ;;
        10) tool="dalfox"; cmd="go install -v github.com/hahwul/dalfox/v2@latest" ;;
        11) tool="gf"; cmd="go install -v github.com/tomnomnom/gf@latest" ;;
        12) tool="ffuf"; cmd="go install -v github.com/ffuf/ffuf@latest" ;;
        13) tool="whatweb"; cmd="sudo gem install whatweb" ;;
        14) tool="nmap"; cmd="sudo apt-get install nmap" ;;
        15) tool="wafw00f"; cmd="pip3 install wafw00f" ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; return ;;
    esac
    
    echo -e "${BLUE}[*] Installing $tool...${NC}"
    eval "$cmd"
    
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}[✓] Successfully installed $tool${NC}"
    else
        echo -e "${RED}[✗] Failed to install $tool${NC}"
    fi
}

# Run reconnaissance
run_reconnaissance() {
    echo -e "\n${YELLOW}${BOLD}[*] Starting Reconnaissance...${NC}\n"
    
    # Create output directories
    mkdir -p "$OUTPUT_DIR/recon"
    mkdir -p "$OUTPUT_DIR/recon/subdomains"
    mkdir -p "$OUTPUT_DIR/recon/urls"
    mkdir -p "$OUTPUT_DIR/recon/js"
    mkdir -p "$OUTPUT_DIR/recon/params"
    
    # 1. Subdomain Enumeration
    echo -e "${BLUE}[+] Finding subdomains...${NC}"
    while read -r domain; do
        echo -e "${GREEN}  Working on: $domain${NC}"
        
        # Run subdomain discovery tools in parallel
        echo -e "${YELLOW}  Running subfinder...${NC}"
        subfinder -d "$domain" -o "$OUTPUT_DIR/recon/subdomains/subfinder_$domain.txt" -silent &
        
        echo -e "${YELLOW}  Running assetfinder...${NC}"
        assetfinder --subs-only "$domain" > "$OUTPUT_DIR/recon/subdomains/assetfinder_$domain.txt" &
        
        echo -e "${YELLOW}  Running findomain...${NC}"
        findomain -t "$domain" -q -u "$OUTPUT_DIR/recon/subdomains/findomain_$domain.txt" &
        
        wait # Wait for all background processes to finish
        
        # Combine and sort unique results
        cat "$OUTPUT_DIR/recon/subdomains/subfinder_$domain.txt" \
            "$OUTPUT_DIR/recon/subdomains/assetfinder_$domain.txt" \
            "$OUTPUT_DIR/recon/subdomains/findomain_$domain.txt" 2>/dev/null | \
            sort -u > "$OUTPUT_DIR/recon/subdomains/all_subdomains_$domain.txt"
        
        local count=$(wc -l < "$OUTPUT_DIR/recon/subdomains/all_subdomains_$domain.txt" 2>/dev/null || echo "0")
        echo -e "${GREEN}  Found $count subdomains for $domain${NC}"
    done < "$TARGET_FILE"
    
    # 2. Live Host Detection
    echo -e "${BLUE}[+] Checking for live hosts...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/subdomains/all_subdomains_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        echo -e "${YELLOW}  Checking live hosts for: $domain${NC}"
        
        # Use httpx with additional options for better information
        cat "$domain_file" | httpx -silent -threads "$THREADS" -follow-redirects -status-code -title -tech-detect \
            -timeout "$TIMEOUT" -o "$OUTPUT_DIR/recon/live_hosts_$domain.txt"
        
        local count=$(wc -l < "$OUTPUT_DIR/recon/live_hosts_$domain.txt" 2>/dev/null || echo "0")
        echo -e "${GREEN}  Found $count live hosts for $domain${NC}"
    done
    
    # 3. URL Discovery
    echo -e "${BLUE}[+] Gathering URLs from wayback machine and gau...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        echo -e "${YELLOW}  Gathering URLs for: $domain${NC}"
        
        # Run waybackurls and gau in parallel
        cat "$domain_file" | waybackurls > "$OUTPUT_DIR/recon/urls/wayback_$domain.txt" &
        cat "$domain_file" | gau --threads "$THREADS" > "$OUTPUT_DIR/recon/urls/gau_$domain.txt" &
        
        wait
        
        # Combine results and filter
        cat "$OUTPUT_DIR/recon/urls/wayback_$domain.txt" \
            "$OUTPUT_DIR/recon/urls/gau_$domain.txt" 2>/dev/null | \
            sort -u > "$OUTPUT_DIR/recon/urls/all_urls_$domain.txt"
        
        local count=$(wc -l < "$OUTPUT_DIR/recon/urls/all_urls_$domain.txt" 2>/dev/null || echo "0")
        echo -e "${GREEN}  Found $count URLs for $domain${NC}"
        
        # Extract JavaScript files
        echo -e "${YELLOW}  Extracting JavaScript files...${NC}"
        cat "$OUTPUT_DIR/recon/urls/all_urls_$domain.txt" | grep -iE "\.js$" > "$OUTPUT_DIR/recon/js/js_files_$domain.txt"
        
        # Extract URLs with parameters
        echo -e "${YELLOW}  Extracting URLs with parameters...${NC}"
        cat "$OUTPUT_DIR/recon/urls/all_urls_$domain.txt" | grep -iE "\?[a-zA-Z0-9]+=" > "$OUTPUT_DIR/recon/params/urls_with_params_$domain.txt"
    done
    
    # 4. Content Discovery
    if [[ "$ENABLE_BRUTEFORCE" = true ]]; then
        echo -e "${BLUE}[+] Running content discovery...${NC}"
        for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
            domain=${domain_file##*_}
            domain=${domain%.txt}
            
            echo -e "${YELLOW}  Running ffuf on: $domain${NC}"
            ffuf -u "https://$domain/FUZZ" -w "$BRUTEFORCE_WORDLIST" -t "$THREADS" -o "$OUTPUT_DIR/recon/content_discovery_$domain.json" -of json
        done
    fi
    
    echo -e "\n${GREEN}[+] Reconnaissance complete!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/recon/${NC}"
}

# Run vulnerability scanning
run_vulnerability_scanning() {
    echo -e "\n${YELLOW}${BOLD}[*] Starting Vulnerability Scanning...${NC}\n"
    
    mkdir -p "$OUTPUT_DIR/vulnerabilities"
    
    # 1. Run Nuclei scans
    echo -e "${BLUE}[+] Running Nuclei scans...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        echo -e "${YELLOW}  Scanning $domain with Nuclei...${NC}"
        
        # Run different types of Nuclei scans
        nuclei -l "$domain_file" -t cves -o "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" -c "$NUCLEI_THREADS"
        nuclei -l "$domain_file" -t vulnerabilities -o "$OUTPUT_DIR/vulnerabilities/nuclei_vulns_$domain.txt" -c "$NUCLEI_THREADS"
        nuclei -l "$domain_file" -t exposures -o "$OUTPUT_DIR/vulnerabilities/nuclei_exposures_$domain.txt" -c "$NUCLEI_THREADS"
        nuclei -l "$domain_file" -t misconfiguration -o "$OUTPUT_DIR/vulnerabilities/nuclei_misconfig_$domain.txt" -c "$NUCLEI_THREADS"
    done
    
    # 2. Run specialized scans
    echo -e "${BLUE}[+] Running specialized scans...${NC}"
    
    # XSS scanning with dalfox
    echo -e "${YELLOW}  Checking for XSS vulnerabilities...${NC}"
    for params_file in "$OUTPUT_DIR/recon/params/urls_with_params_"*; do
        domain=${params_file##*_}
        domain=${domain%.txt}
        cat "$params_file" | dalfox pipe --silence --skip-bav -o "$OUTPUT_DIR/vulnerabilities/xss_$domain.txt"
    done
    
    # SQLi scanning
    echo -e "${YELLOW}  Checking for SQL injection vulnerabilities...${NC}"
    for params_file in "$OUTPUT_DIR/recon/params/urls_with_params_"*; do
        domain=${params_file##*_}
        domain=${domain%.txt}
        cat "$params_file" | gf sqli | qsreplace "' OR 1=1 --" | httpx -silent -match-string "SQL syntax" -o "$OUTPUT_DIR/vulnerabilities/sqli_$domain.txt"
    done
    
    # SSRF scanning
    echo -e "${YELLOW}  Checking for SSRF vulnerabilities...${NC}"
    for params_file in "$OUTPUT_DIR/recon/params/urls_with_params_"*; do
        domain=${params_file##*_}
        domain=${domain%.txt}
        cat "$params_file" | gf ssrf | qsreplace "$COLLABORATOR_URL" | httpx -silent -o /dev/null
    done
    
    # LFI scanning
    echo -e "${YELLOW}  Checking for LFI vulnerabilities...${NC}"
    for params_file in "$OUTPUT_DIR/recon/params/urls_with_params_"*; do
        domain=${params_file##*_}
        domain=${domain%.txt}
        cat "$params_file" | gf lfi | qsreplace "/etc/passwd" | httpx -silent -match-string "root:" -o "$OUTPUT_DIR/vulnerabilities/lfi_$domain.txt"
    done
    
    echo -e "\n${GREEN}[+] Vulnerability scanning complete!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/vulnerabilities/${NC}"
}

# Run advanced testing
run_advanced_testing() {
    echo -e "\n${YELLOW}${BOLD}[*] Starting Advanced Testing...${NC}\n"
    
    mkdir -p "$OUTPUT_DIR/advanced"
    
    # 1. Prototype Pollution
    echo -e "${BLUE}[+] Testing for Prototype Pollution...${NC}"
    for js_file in "$OUTPUT_DIR/recon/js/js_files_"*; do
        domain=${js_file##*_}
        domain=${domain%.txt}
        python3 ~/tools/ppfuzz/ppfuzz.py -l "$js_file" -o "$OUTPUT_DIR/advanced/prototype_pollution_$domain.txt"
    done
    
    # 2. CORS Misconfiguration
    echo -e "${BLUE}[+] Testing for CORS Misconfigurations...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        cat "$domain_file" | while read url; do
            curl -s -I -H "Origin: https://evil.com" "$url" | \
            if grep -iE "access-control-allow-origin: https://evil.com" || \
               grep -iE "access-control-allow-credentials: true"; then
                echo "$url" >> "$OUTPUT_DIR/advanced/cors_misconfig_$domain.txt"
            fi
        done
    done
    
    # 3. Open Redirects
    echo -e "${BLUE}[+] Testing for Open Redirects...${NC}"
    for params_file in "$OUTPUT_DIR/recon/params/urls_with_params_"*; do
        domain=${params_file##*_}
        domain=${domain%.txt}
        cat "$params_file" | gf redirect | qsreplace "$LHOST" | httpx -silent -location -match-string "$LHOST" -o "$OUTPUT_DIR/advanced/open_redirects_$domain.txt"
    done
    
    # 4. CRLF Injection
    echo -e "${BLUE}[+] Testing for CRLF Injection...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        cat "$domain_file" | while read url; do
            curl -s -I "$url/%0D%0ALocation:%20$LHOST" | \
            if grep -iE "Location: $LHOST"; then
                echo "$url" >> "$OUTPUT_DIR/advanced/crlf_injection_$domain.txt"
            fi
        done
    done
    
    echo -e "\n${GREEN}[+] Advanced testing complete!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/advanced/${NC}"
}

# Run fingerprinting
run_fingerprinting() {
    echo -e "\n${YELLOW}${BOLD}[*] Starting Fingerprinting...${NC}\n"
    
    mkdir -p "$OUTPUT_DIR/fingerprint"
    
    # 1. Technology Detection
    echo -e "${BLUE}[+] Detecting technologies...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        echo -e "${YELLOW}  Fingerprinting $domain...${NC}"
        whatweb -i "$domain_file" --log-verbose="$OUTPUT_DIR/fingerprint/tech_detection_$domain.txt"
    done
    
    # 2. WAF Detection
    echo -e "${BLUE}[+] Detecting WAFs...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        echo -e "${YELLOW}  Checking WAF for $domain...${NC}"
        wafw00f -i "$domain_file" -o "$OUTPUT_DIR/fingerprint/waf_detection_$domain.txt"
    done
    
    # 3. SSL/TLS Analysis
    echo -e "${BLUE}[+] Analyzing SSL/TLS configurations...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        echo -e "${YELLOW}  Analyzing SSL for $domain...${NC}"
        while read url; do
            host=$(echo "$url" | awk -F/ '{print $3}')
            testssl.sh "$host" > "$OUTPUT_DIR/fingerprint/ssl_analysis_$host.txt"
        done < "$domain_file"
    done
    
    echo -e "\n${GREEN}[+] Fingerprinting complete!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/fingerprint/${NC}"
}

# Run all scans
run_all_scans() {
    echo -e "\n${YELLOW}${BOLD}[*] Starting Comprehensive Scan...${NC}\n"
    
    run_reconnaissance
    run_vulnerability_scanning
    run_advanced_testing
    run_fingerprinting
    
    echo -e "\n${GREEN}[+] Comprehensive scan complete!${NC}"
    echo -e "${YELLOW}[*] All results saved to: $OUTPUT_DIR/${NC}"
}

# Run quick scan
# In the run_quick_scan function (around line 1885):
run_quick_scan() {
    echo -e "\n${YELLOW}${BOLD}[*] Starting Quick Scan...${NC}\n"
    
    mkdir -p "$OUTPUT_DIR/quick_scan"
    mkdir -p "$OUTPUT_DIR/recon/subdomains"  # Add this line
    
    # 1. Fast subdomain enumeration
    echo -e "${BLUE}[+] Running fast subdomain enumeration...${NC}"
    while read -r domain; do
        subfinder -d "$domain" -o "$OUTPUT_DIR/quick_scan/subdomains_$domain.txt" -silent
        assetfinder --subs-only "$domain" >> "$OUTPUT_DIR/quick_scan/subdomains_$domain.txt"
        sort -u "$OUTPUT_DIR/quick_scan/subdomains_$domain.txt" -o "$OUTPUT_DIR/quick_scan/subdomains_$domain.txt"
        
        # Also save to recon directory for consistency
        cp "$OUTPUT_DIR/quick_scan/subdomains_$domain.txt" "$OUTPUT_DIR/recon/subdomains/all_subdomains_$domain.txt"
    done < "$TARGET_FILE"
    
    # 2. Fast live host detection
    echo -e "${BLUE}[+] Checking for live hosts...${NC}"
    for domain_file in "$OUTPUT_DIR/quick_scan/subdomains_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        cat "$domain_file" | httpx -silent -threads "$THREADS" -o "$OUTPUT_DIR/quick_scan/live_hosts_$domain.txt"
    done
    
    # 3. Quick vulnerability scan
    echo -e "${BLUE}[+] Running quick vulnerability scan...${NC}"
    for domain_file in "$OUTPUT_DIR/quick_scan/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        # Use default nuclei templates if quick directory doesn't exist
        if [ -d "$HOME/nuclei-templates/quick" ]; then
            nuclei -l "$domain_file" -t "$HOME/nuclei-templates/quick" -o "$OUTPUT_DIR/quick_scan/quick_scan_$domain.txt" -c "$NUCLEI_THREADS"
        else
            echo -e "${YELLOW}[!] Quick templates not found, using default templates${NC}"
            nuclei -l "$domain_file" -t "$HOME/nuclei-templates" -o "$OUTPUT_DIR/quick_scan/quick_scan_$domain.txt" -c "$NUCLEI_THREADS"
        fi
    done
    
    echo -e "\n${GREEN}[+] Quick scan complete!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/quick_scan/${NC}"
}

# Run custom scan
run_custom_scan() {
    echo -e "\n${YELLOW}${BOLD}[*] Starting Custom Scan...${NC}\n"
    
    mkdir -p "$OUTPUT_DIR/custom_scan"
    
    # Show available custom scan options
    echo -e "${BLUE}Available custom scan options:${NC}"
    echo -e "1. Subdomain takeover check"
    echo -e "2. Cloud bucket check"
    echo -e "3. API endpoint discovery"
    echo -e "4. GitHub secrets scan"
    echo -e "5. Email harvesting"
    echo -e "6. All of the above"
    
    read -p "$(echo -e "${BLUE}${BOLD}Enter your choice [1-6]: ${NC}")" choice
    
    case $choice in
        1) run_subdomain_takeover_check ;;
        2) run_cloud_bucket_check ;;
        3) run_api_endpoint_discovery ;;
        4) run_github_secrets_scan ;;
        5) run_email_harvesting ;;
        6) 
            run_subdomain_takeover_check
            run_cloud_bucket_check
            run_api_endpoint_discovery
            run_github_secrets_scan
            run_email_harvesting
            ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; return ;;
    esac
    
    echo -e "\n${GREEN}[+] Custom scan complete!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/custom_scan/${NC}"
}

# Subdomain takeover check
run_subdomain_takeover_check() {
    echo -e "${BLUE}[+] Checking for subdomain takeovers...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/subdomains/all_subdomains_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        subjack -w "$domain_file" -t "$THREADS" -o "$OUTPUT_DIR/custom_scan/subdomain_takeover_$domain.txt"
    done
}

# Cloud bucket check
run_cloud_bucket_check() {
    echo -e "${BLUE}[+] Checking for open cloud buckets...${NC}"
    while read -r domain; do
        # Check AWS S3 buckets
        s3scanner scan -f "$domain" -o "$OUTPUT_DIR/custom_scan/aws_buckets_$domain.txt"
        
        # Check Google Cloud buckets
        gsutil ls "gs://$domain" &> /dev/null && echo "gs://$domain" >> "$OUTPUT_DIR/custom_scan/gcp_buckets_$domain.txt"
    done < "$TARGET_FILE"
}

# API endpoint discovery
run_api_endpoint_discovery() {
    echo -e "${BLUE}[+] Discovering API endpoints...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/urls/all_urls_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        cat "$domain_file" | grep -iE "api|rest|graphql|v1|v2" > "$OUTPUT_DIR/custom_scan/api_endpoints_$domain.txt"
    done
}

# GitHub secrets scan
run_github_secrets_scan() {
    echo -e "${BLUE}[+] Scanning for GitHub secrets...${NC}"
    for domain_file in "$OUTPUT_DIR/recon/urls/all_urls_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        cat "$domain_file" | grep -iE "github" | while read url; do
            curl -s "$url" | grep -iE "client_secret|api_key|access_token" >> "$OUTPUT_DIR/custom_scan/github_secrets_$domain.txt"
        done
    done
}

# Email harvesting
run_email_harvesting() {
    echo -e "${BLUE}[+] Harvesting emails...${NC}"
    while read -r domain; do
        theharvester -d "$domain" -b all -f "$OUTPUT_DIR/custom_scan/emails_$domain.txt"
    done < "$TARGET_FILE"
}

# Generate reports
generate_reports() {
    echo -e "\n${YELLOW}${BOLD}[*] Generating Reports...${NC}\n"
    
    mkdir -p "$OUTPUT_DIR/reports"
    
    # Check if recon files exist
    if ! ls "$OUTPUT_DIR/recon/subdomains/all_subdomains_"* 1> /dev/null 2>&1; then
        echo -e "${YELLOW}[!] No recon data found for reporting${NC}"
        return
    fi
    
    # 1. HTML Report
    if [[ "$REPORT_FORMAT" == "html" || "$REPORT_FORMAT" == "all" ]]; then
        echo -e "${BLUE}[+] Generating HTML report...${NC}"
        
        # Create HTML header
        cat > "$OUTPUT_DIR/reports/report.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>BBHunter Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; }
        h2 { color: #3498db; border-bottom: 1px solid #3498db; padding-bottom: 5px; }
        .vulnerability { background-color: #f8d7da; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .critical { background-color: #dc3545; color: white; padding: 3px 8px; border-radius: 3px; }
        .high { background-color: #fd7e14; color: white; padding: 3px 8px; border-radius: 3px; }
        .medium { background-color: #ffc107; padding: 3px 8px; border-radius: 3px; }
        .low { background-color: #28a745; color: white; padding: 3px 8px; border-radius: 3px; }
        .info { background-color: #17a2b8; color: white; padding: 3px 8px; border-radius: 3px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
    </style>
</head>
<body>
    <h1>BBHunter Scan Report</h1>
    <p>Generated on: $(date)</p>
    <p>Target(s): $(cat "$TARGET_FILE" | tr '\n' ' ')</p>
EOF
        
        # Add findings to the report
        for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
            domain=${domain_file##*_}
            domain=${domain%.txt}
            
            cat >> "$OUTPUT_DIR/reports/report.html" << EOF
    <h2>Findings for $domain</h2>
    
    <h3>Subdomains ($(wc -l < "$OUTPUT_DIR/recon/subdomains/all_subdomains_$domain.txt"))</h3>
    <table>
        <tr><th>Subdomain</th></tr>
        $(while read sub; do echo "<tr><td>$sub</td></tr>"; done < "$OUTPUT_DIR/recon/subdomains/all_subdomains_$domain.txt")
    </table>
    
    <h3>Vulnerabilities</h3>
    $(if [ -f "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" ]; then
        echo "<h4>CVEs</h4>"
        while read vuln; do
            severity=$(echo "$vuln" | grep -oE "\[critical|high|medium|low|info\]" | tr -d '[]' || echo "info")
            echo "<div class=\"vulnerability\">"
            echo "<span class=\"$severity\">$(echo "$severity" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')</span>"
            echo "<p>$vuln</p>"
            echo "</div>"
        done < "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt"
    fi)
    
    $(if [ -f "$OUTPUT_DIR/vulnerabilities/xss_$domain.txt" ]; then
        echo "<h4>XSS Vulnerabilities</h4>"
        while read vuln; do
            echo "<div class=\"vulnerability\">"
            echo "<span class=\"high\">High</span>"
            echo "<p>$vuln</p>"
            echo "</div>"
        done < "$OUTPUT_DIR/vulnerabilities/xss_$domain.txt"
    fi)
    
    $(if [ -f "$OUTPUT_DIR/vulnerabilities/sqli_$domain.txt" ]; then
        echo "<h4>SQL Injection Vulnerabilities</h4>"
        while read vuln; do
            echo "<div class=\"vulnerability\">"
            echo "<span class=\"critical\">Critical</span>"
            echo "<p>$vuln</p>"
            echo "</div>"
        done < "$OUTPUT_DIR/vulnerabilities/sqli_$domain.txt"
    fi)
EOF
        done
        
        # Close HTML
        cat >> "$OUTPUT_DIR/reports/report.html" << EOF
</body>
</html>
EOF
    fi
    
    # 2. JSON Report
    if [[ "$REPORT_FORMAT" == "json" || "$REPORT_FORMAT" == "all" ]]; then
        echo -e "${BLUE}[+] Generating JSON report...${NC}"
        
        echo "{" > "$OUTPUT_DIR/reports/report.json"
        echo "  \"scan_info\": {" >> "$OUTPUT_DIR/reports/report.json"
        echo "    \"tool\": \"BBHunter\"," >> "$OUTPUT_DIR/reports/report.json"
        echo "    \"version\": \"$VERSION\"," >> "$OUTPUT_DIR/reports/report.json"
        echo "    \"date\": \"$(date)\"," >> "$OUTPUT_DIR/reports/report.json"
        echo "    \"targets\": [" >> "$OUTPUT_DIR/reports/report.json"
        
        first=true
        while read -r domain; do
            if [ "$first" = false ]; then
                echo "," >> "$OUTPUT_DIR/reports/report.json"
            fi
            echo "      \"$domain\"" >> "$OUTPUT_DIR/reports/report.json"
            first=false
        done < "$TARGET_FILE"
        
        echo "    ]" >> "$OUTPUT_DIR/reports/report.json"
        echo "  }," >> "$OUTPUT_DIR/reports/report.json"
        echo "  \"findings\": [" >> "$OUTPUT_DIR/reports/report.json"
        
        first_domain=true
        for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
            domain=${domain_file##*_}
            domain=${domain%.txt}
            
            if [ "$first_domain" = false ]; then
                echo "," >> "$OUTPUT_DIR/reports/report.json"
            fi
            
            echo "    {" >> "$OUTPUT_DIR/reports/report.json"
            echo "      \"domain\": \"$domain\"," >> "$OUTPUT_DIR/reports/report.json"
            echo "      \"subdomains\": [" >> "$OUTPUT_DIR/reports/report.json"
            
            first_sub=true
            while read -r sub; do
                if [ "$first_sub" = false ]; then
                    echo "," >> "$OUTPUT_DIR/reports/report.json"
                fi
                echo "        \"$sub\"" >> "$OUTPUT_DIR/reports/report.json"
                first_sub=false
            done < "$OUTPUT_DIR/recon/subdomains/all_subdomains_$domain.txt"
            
            echo "      ]," >> "$OUTPUT_DIR/reports/report.json"
            echo "      \"vulnerabilities\": [" >> "$OUTPUT_DIR/reports/report.json"
            
            # Add vulnerabilities
            first_vuln=true
            
            # Add Nuclei CVEs
            if [ -f "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" ]; then
                while read -r vuln; do
                    if [ "$first_vuln" = false ]; then
                        echo "," >> "$OUTPUT_DIR/reports/report.json"
                    fi
                    severity=$(echo "$vuln" | grep -oE "\[critical|high|medium|low|info\]" | tr -d '[]' || echo "info")
                    echo "        {" >> "$OUTPUT_DIR/reports/report.json"
                    echo "          \"type\": \"cve\"," >> "$OUTPUT_DIR/reports/report.json"
                    echo "          \"severity\": \"$severity\"," >> "$OUTPUT_DIR/reports/report.json"
                    echo "          \"description\": \"$(echo "$vuln" | sed 's/"/\\"/g')\"" >> "$OUTPUT_DIR/reports/report.json"
                    echo "        }" >> "$OUTPUT_DIR/reports/report.json"
                    first_vuln=false
                done < "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt"
            fi
            
            # Add XSS vulnerabilities
            if [ -f "$OUTPUT_DIR/vulnerabilities/xss_$domain.txt" ]; then
                while read -r vuln; do
                    if [ "$first_vuln" = false ]; then
                        echo "," >> "$OUTPUT_DIR/reports/report.json"
                    fi
                    echo "        {" >> "$OUTPUT_DIR/reports/report.json"
                    echo "          \"type\": \"xss\"," >> "$OUTPUT_DIR/reports/report.json"
                    echo "          \"severity\": \"high\"," >> "$OUTPUT_DIR/reports/report.json"
                    echo "          \"description\": \"$(echo "$vuln" | sed 's/"/\\"/g')\"" >> "$OUTPUT_DIR/reports/report.json"
                    echo "        }" >> "$OUTPUT_DIR/reports/report.json"
                    first_vuln=false
                done < "$OUTPUT_DIR/vulnerabilities/xss_$domain.txt"
            fi
            
            echo "      ]" >> "$OUTPUT_DIR/reports/report.json"
            echo "    }" >> "$OUTPUT_DIR/reports/report.json"
            
            first_domain=false
        done
        
        echo "  ]" >> "$OUTPUT_DIR/reports/report.json"
        echo "}" >> "$OUTPUT_DIR/reports/report.json"
    fi
    
    echo -e "\n${GREEN}[+] Report generation complete!${NC}"
    echo -e "${YELLOW}[*] Reports saved to: $OUTPUT_DIR/reports/${NC}"
}

# Cloud integration
cloud_integration() {
    echo -e "\n${YELLOW}${BOLD}[*] Cloud Integration...${NC}\n"
    
    if [[ -z "$CLOUD_PROVIDER" ]]; then
        echo -e "${RED}[!] No cloud provider configured. Please set up in configuration.${NC}"
        return
    fi
    
    echo -e "${BLUE}[+] Syncing results to $CLOUD_PROVIDER...${NC}"
    
    case $CLOUD_PROVIDER in
        "aws")
            if command -v aws &> /dev/null; then
                aws s3 sync "$OUTPUT_DIR" "s3://$CLOUD_BUCKET/bbhunter_scan_$(date +%F)" \
                    --exclude "*" --include "*.txt" --include "*.json" --include "*.html"
                echo -e "${GREEN}[✓] Results synced to AWS S3${NC}"
            else
                echo -e "${RED}[!] AWS CLI not found. Please install and configure.${NC}"
            fi
            ;;
        "gcp")
            if command -v gsutil &> /dev/null; then
                gsutil -m cp -r "$OUTPUT_DIR" "gs://$CLOUD_BUCKET/bbhunter_scan_$(date +%F)"
                echo -e "${GREEN}[✓] Results synced to Google Cloud Storage${NC}"
            else
                echo -e "${RED}[!] gsutil not found. Please install and configure.${NC}"
            fi
            ;;
        "azure")
            if command -v az &> /dev/null; then
                az storage blob upload-batch -d "$CLOUD_BUCKET/bbhunter_scan_$(date +%F)" -s "$OUTPUT_DIR"
                echo -e "${GREEN}[✓] Results synced to Azure Blob Storage${NC}"
            else
                echo -e "${RED}[!] Azure CLI not found. Please install and configure.${NC}"
            fi
            ;;
        *)
            echo -e "${RED}[!] Unsupported cloud provider: $CLOUD_PROVIDER${NC}"
            ;;
    esac
}

# AI analysis
ai_analysis() {
    echo -e "\n${YELLOW}${BOLD}[*] AI Analysis...${NC}\n"
    
    if [[ "$ENABLE_AI" != true || -z "$AI_API_KEY" ]]; then
        echo -e "${RED}[!] AI analysis is not enabled or API key is missing. Please configure in settings.${NC}"
        return
    fi
    
    mkdir -p "$OUTPUT_DIR/ai_analysis"
    
    echo -e "${BLUE}[+] Analyzing results with AI...${NC}"
    
    # Prepare data for AI analysis
    TEMP_AI_FILE="$OUTPUT_DIR/ai_analysis/ai_input.txt"
    echo "Bug Bounty Hunter Scan Results Analysis" > "$TEMP_AI_FILE"
    echo "Scan Date: $(date)" >> "$TEMP_AI_FILE"
    echo "Targets: $(cat "$TARGET_FILE" | tr '\n' ' ')" >> "$TEMP_AI_FILE"
    
    # Add vulnerabilities summary
    echo -e "\nVulnerabilities Summary:" >> "$TEMP_AI_FILE"
    for domain_file in "$OUTPUT_DIR/recon/live_hosts_"*; do
        domain=${domain_file##*_}
        domain=${domain%.txt}
        
        echo -e "\nDomain: $domain" >> "$TEMP_AI_FILE"
        
        # Count vulnerabilities by severity
        critical=$(grep -c "\[critical\]" "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" 2>/dev/null || echo 0)
        high=$(grep -c "\[high\]" "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" 2>/dev/null || echo 0)
        medium=$(grep -c "\[medium\]" "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" 2>/dev/null || echo 0)
        low=$(grep -c "\[low\]" "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" 2>/dev/null || echo 0)
        
        echo "Critical: $critical" >> "$TEMP_AI_FILE"
        echo "High: $high" >> "$TEMP_AI_FILE"
        echo "Medium: $medium" >> "$TEMP_AI_FILE"
        echo "Low: $low" >> "$TEMP_AI_FILE"
        
        # Add top 3 critical/high vulnerabilities
        if [ -f "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" ]; then
            echo -e "\nTop Vulnerabilities:" >> "$TEMP_AI_FILE"
            grep -E "\[critical\]|\[high\]" "$OUTPUT_DIR/vulnerabilities/nuclei_cves_$domain.txt" | head -3 >> "$TEMP_AI_FILE"
        fi
    done
    
    # Call AI API (example with OpenAI)
    echo -e "${YELLOW}[*] Sending data for AI analysis...${NC}"
    response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AI_API_KEY" \
        -d '{
            "model": "gpt-4",
            "messages": [
                {
                    "role": "system",
                    "content": "You are a cybersecurity expert analyzing bug bounty scan results. Provide a detailed analysis of the findings, prioritize vulnerabilities, and suggest remediation steps."
                },
                {
                    "role": "user",
                    "content": "'"$(cat "$TEMP_AI_FILE" | sed -z 's/\n/\\n/g')"'"
                }
            ],
            "temperature": 0.7,
            "max_tokens": 1500
        }')
    
    # Process response
    if echo "$response" | jq -e '.choices[0].message.content' > /dev/null 2>&1; then
        analysis=$(echo "$response" | jq -r '.choices[0].message.content')
        echo "$analysis" > "$OUTPUT_DIR/ai_analysis/ai_report.txt"
        echo -e "${GREEN}[✓] AI analysis complete!${NC}"
        echo -e "${YELLOW}[*] AI report saved to: $OUTPUT_DIR/ai_analysis/ai_report.txt${NC}"
        
        # Display summary
        echo -e "\n${BLUE}AI Analysis Summary:${NC}"
        echo "$analysis" | head -10
        echo -e "\n${YELLOW}[...] See full report for complete analysis${NC}"
    else
        echo -e "${RED}[!] Failed to get AI analysis. Response:${NC}"
        echo "$response"
    fi
}

# Main execution
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
