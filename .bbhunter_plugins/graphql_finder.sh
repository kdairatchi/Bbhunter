#!/bin/bash
# BBHunter GraphQL Endpoint Finder

PLUGIN_NAME="GraphQL Finder"
PLUGIN_VERSION="1.2"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Identifies GraphQL endpoints"
PLUGIN_CATEGORY="recon"

run_graphql_find() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/graphql"
    
    local output_file="$output_dir/plugins/graphql/results.txt"
    local endpoints_found=0

    declare -a GRAPHQL_PATHS=(
        "/graphql" "/graphql/console" "/graphiql" "/gql" 
        "/graphql.php" "/graphql-explorer"
    )

    while read -r url; do
        for path in "${GRAPHQL_PATHS[@]}"; do
            status=$(curl -s -o /dev/null -w "%{http_code}" "$url$path")
            if [[ "$status" == "200" ]]; then
                echo "GraphQL Endpoint: $url$path" >> "$output_file"
                ((endpoints_found++))
            fi
        done
    done < "$input_dir/recon/live_hosts.txt"

    return $endpoints_found
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_graphql_find\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_graphql_find "$1" "$2"
fi
