#!/bin/bash
# BBHunter Cloud Bucket Scanner

PLUGIN_NAME="Cloud Bucket Scanner"
PLUGIN_VERSION="1.4"
PLUGIN_AUTHOR="BBHunter Team by kdairatchi"
PLUGIN_DESCRIPTION="Scans for misconfigured cloud storage buckets"
PLUGIN_CATEGORY="vulnerability"

run_bucket_scan() {
    local input_dir="$1"
    local output_dir="$2"
    mkdir -p "$output_dir/plugins/cloud_buckets"
    
    local output_file="$output_dir/plugins/cloud_buckets/results.txt"
    local open_buckets=0

    while read -r domain; do
        # Check AWS S3
        if aws s3 ls "s3://$domain" --no-sign-request 2>/dev/null; then
            echo "Open AWS S3 Bucket: s3://$domain" >> "$output_file"
            ((open_buckets++))
        fi
        
        # Check Google Cloud Storage
        if gsutil ls "gs://$domain" 2>/dev/null | grep -q "gs://"; then
            echo "Open GCS Bucket: gs://$domain" >> "$output_file"
            ((open_buckets++))
        fi
    done < "$input_dir/recon/subdomains/all_subdomains.txt"

    return $open_buckets
}

register_plugin() {
    echo "{
        \"name\": \"$PLUGIN_NAME\",
        \"version\": \"$PLUGIN_VERSION\",
        \"author\": \"$PLUGIN_AUTHOR\",
        \"description\": \"$PLUGIN_DESCRIPTION\",
        \"category\": \"$PLUGIN_CATEGORY\",
        \"run_function\": \"run_bucket_scan\"
    }"
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    register_plugin
else
    run_bucket_scan "$1" "$2"
fi
