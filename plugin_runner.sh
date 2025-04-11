#!/bin/bash
# =============================================
# BBHunter Ultimate Plugin Runner
# Advanced plugin management and execution system
# =============================================

# Plugin Runner Configuration
PLUGIN_RUNNER_VERSION="3.2"
MAX_PARALLEL_PLUGINS=5
PLUGIN_TIMEOUT=300  # 5 minutes per plugin
PLUGIN_DIR="$HOME/.bbhunter_plugins"
PLUGIN_CACHE_FILE="$HOME/.bbhunter_plugin_cache.json"
LOG_DIR="/tmp/bbhunter_plugin_logs"

# Initialize the plugin runner
init_plugin_runner() {
    mkdir -p "$LOG_DIR"
    touch "$PLUGIN_CACHE_FILE"
    load_plugin_cache
}

# Load plugin cache
load_plugin_cache() {
    if [[ -f "$PLUGIN_CACHE_FILE" ]]; then
        PLUGIN_CACHE=$(cat "$PLUGIN_CACHE_FILE")
    else
        PLUGIN_CACHE="{}"
    fi
}

# Update plugin cache
update_plugin_cache() {
    echo "$PLUGIN_CACHE" > "$PLUGIN_CACHE_FILE"
}

# Discover available plugins
discover_plugins() {
    declare -A discovered_plugins
    
    for plugin_file in "$PLUGIN_DIR"/*.sh; do
        if [[ -f "$plugin_file" ]]; then
            plugin_name=$(basename "$plugin_file" .sh)
            plugin_meta=$(source "$plugin_file" && register_plugin)
            plugin_json=$(echo "$plugin_meta" | jq -r '.')
            
            discovered_plugins["$plugin_name"]=$plugin_json
        fi
    done
    
    echo "${discovered_plugins[@]}"
}

# Verify plugin dependencies
verify_dependencies() {
    local plugin_name=$1
    local plugin_file="$PLUGIN_DIR/$plugin_name.sh"
    
    if [[ ! -f "$plugin_file" ]]; then
        echo -e "${RED}[!] Plugin $plugin_name not found${NC}"
        return 1
    fi
    
    # Check if plugin has install function
    if grep -q "install_$plugin_name" "$plugin_file"; then
        source "$plugin_file"
        "install_$plugin_name"
    fi
    
    # Check for required tools
    if grep -q "# Requires:" "$plugin_file"; then
        required_tools=$(grep "# Requires:" "$plugin_file" | cut -d: -f2-)
        for tool in $required_tools; do
            if ! command -v "$tool" &>/dev/null; then
                echo -e "${RED}[!] Missing dependency: $tool for plugin $plugin_name${NC}"
                return 1
            fi
        done
    fi
    
    return 0
}

# Execute a single plugin
execute_plugin() {
    local plugin_name=$1
    local input_dir=$2
    local output_dir=$3
    local log_file="$LOG_DIR/${plugin_name}_$(date +%s).log"
    
    echo -e "${BLUE}[*] Starting plugin: $plugin_name${NC}"
    
    # Timeout and run plugin
    timeout $PLUGIN_TIMEOUT bash -c \
        "source '$PLUGIN_DIR/$plugin_name.sh' && \
         run_$(basename "$plugin_name" .sh) '$input_dir' '$output_dir'" &> "$log_file"
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}[✓] Plugin $plugin_name completed successfully${NC}"
        return 0
    elif [[ $exit_code -eq 124 ]]; then
        echo -e "${YELLOW}[!] Plugin $plugin_name timed out${NC}"
        return 124
    else
        echo -e "${RED}[!] Plugin $plugin_name failed with code $exit_code${NC}"
        return $exit_code
    fi
}

# Run plugins by category
run_plugins_by_category() {
    local category=$1
    local input_dir=$2
    local output_dir=$3
    
    declare -A plugins
    eval plugins=($(discover_plugins))
    
    local category_plugins=()
    for plugin_name in "${!plugins[@]}"; do
        plugin_category=$(echo "${plugins[$plugin_name]}" | jq -r '.category')
        if [[ "$plugin_category" == "$category" ]]; then
            category_plugins+=("$plugin_name")
        fi
    done
    
    if [[ ${#category_plugins[@]} -eq 0 ]]; then
        echo -e "${YELLOW}[!] No plugins found for category: $category${NC}"
        return 0
    fi
    
    echo -e "${CYAN}[*] Running ${#category_plugins[@]} $category plugins${NC}"
    
    # Run plugins in parallel with limited concurrency
    local running=0
    for plugin_name in "${category_plugins[@]}"; do
        if verify_dependencies "$plugin_name"; then
            execute_plugin "$plugin_name" "$input_dir" "$output_dir" &
            ((running++))
            
            if [[ $running -ge $MAX_PARALLEL_PLUGINS ]]; then
                wait -n
                ((running--))
            fi
        fi
    done
    wait
    
    echo -e "${GREEN}[✓] Completed all $category plugins${NC}"
}

# Run all plugins
run_all_plugins() {
    local input_dir=$1
    local output_dir=$2
    
    declare -A plugins
    eval plugins=($(discover_plugins))
    
    if [[ ${#plugins[@]} -eq 0 ]]; then
        echo -e "${YELLOW}[!] No plugins found in $PLUGIN_DIR${NC}"
        return 1
    fi
    
    echo -e "${CYAN}[*] Running ${#plugins[@]} discovered plugins${NC}"
    
    # Group plugins by category
    declare -A categories
    for plugin_name in "${!plugins[@]}"; do
        plugin_category=$(echo "${plugins[$plugin_name]}" | jq -r '.category')
        categories["$plugin_category"]+="$plugin_name "
    done
    
    # Execute plugins by category
    for category in "${!categories[@]}"; do
        echo -e "\n${PURPLE}=== Running $category Plugins ===${NC}"
        run_plugins_by_category "$category" "$input_dir" "$output_dir"
    done
    
    echo -e "\n${GREEN}[✓] All plugins completed execution${NC}"
}

# Generate plugin report
generate_plugin_report() {
    local output_dir=$1
    local report_file="$output_dir/plugin_report_$(date +%Y%m%d_%H%M%S).html"
    
    echo "<html><head><title>BBHunter Plugin Report</title></head><body>" > "$report_file"
    echo "<h1>BBHunter Plugin Execution Report</h1>" >> "$report_file"
    echo "<p>Generated: $(date)</p>" >> "$report_file"
    
    for plugin_log in "$LOG_DIR"/*.log; do
        if [[ -f "$plugin_log" ]]; then
            plugin_name=$(basename "$plugin_log" | cut -d'_' -f1)
            echo "<h2>$plugin_name</h2>" >> "$report_file"
            echo "<pre>" >> "$report_file"
            cat "$plugin_log" | sed 's/</\&lt;/g; s/>/\&gt;/g' >> "$report_file"
            echo "</pre>" >> "$report_file"
        fi
    done
    
    echo "</body></html>" >> "$report_file"
    
    echo -e "${GREEN}[*] Plugin report generated: $report_file${NC}"
}

# Main plugin runner function
main_plugin_runner() {
    local mode=$1
    local input_dir=$2
    local output_dir=$3
    
    init_plugin_runner
    
    case "$mode" in
        "all")
            run_all_plugins "$input_dir" "$output_dir"
            ;;
        "category")
            local category=$4
            run_plugins_by_category "$category" "$input_dir" "$output_dir"
            ;;
        "single")
            local plugin_name=$4
            if verify_dependencies "$plugin_name"; then
                execute_plugin "$plugin_name" "$input_dir" "$output_dir"
            fi
            ;;
        *)
            echo -e "${RED}[!] Invalid mode: $mode${NC}"
            echo "Usage: $0 [all|category|single] <input_dir> <output_dir> [category|plugin_name]"
            return 1
            ;;
    esac
    
    generate_plugin_report "$output_dir"
    return 0
}

# Start the plugin runner
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [[ $# -lt 3 ]]; then
        echo "BBHunter Ultimate Plugin Runner v$PLUGIN_RUNNER_VERSION"
        echo "Usage: $0 [all|category|single] <input_dir> <output_dir> [category|plugin_name]"
        exit 1
    fi
    
    main_plugin_runner "$@"
    exit $?
else
    # When sourced, register the plugin runner
    register_plugin_runner() {
        echo "{
            \"name\": \"Ultimate Plugin Runner\",
            \"version\": \"$PLUGIN_RUNNER_VERSION\",
            \"author\": \"BBHunter Team\",
            \"description\": \"Advanced plugin management and execution system\",
            \"category\": \"core\",
            \"functions\": {
                \"run_all_plugins\": \"Run all available plugins\",
                \"run_plugins_by_category\": \"Run plugins by category\",
                \"execute_plugin\": \"Execute a single plugin\"
            }
        }"
    }
fi
