#!/bin/bash

# Elasticsearch Cluster Metrics Collector

# Configuration (make sure to double check the next two values as they are subject of variation)
Target_HOST=${1:-localhost}
Target_PORT=${2:-9200}
OUTPUT_DIR="${HOME}/elasticsearch_metrics"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="${OUTPUT_DIR}/elasticsearch_metrics_${TIMESTAMP}.csv"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to fetch metrics and handle errors
fetch_metric() {
    local endpoint="$1"
    local metric_name="$2"
    
    # Fetch metric with error handling
    response=$(curl -s -X GET "http://${Target_HOST}:${Target_PORT}${endpoint}")
    
    if [ -z "$response" ]; then
        echo "Error: Unable to fetch ${metric_name}" >&2
        return 1
    fi
    
    echo "$response"
}

# Collect Metrics
collect_metrics() {
    # 1. Node Information
    fetch_metric "/_cat/nodes?v" "Node Information" > "${OUTPUT_DIR}/nodes_info.csv"
    
    # 2. Cluster Statistics
    fetch_metric "/_cluster/stats" "Cluster Statistics" > "${OUTPUT_DIR}/cluster_stats.json"
    
    # 3. Indices Information
    fetch_metric "/_cat/indices?v" "Indices Information" > "${OUTPUT_DIR}/indices_info.csv"
    
    # 4. JVM Memory Stats
    fetch_metric "/_nodes/stats/jvm" "JVM Memory Stats" > "${OUTPUT_DIR}/jvm_stats.json"
    
    # 5. Cluster Allocation
    fetch_metric "/_cluster/allocation/explain" "Cluster Allocation" > "${OUTPUT_DIR}/allocation_explain.json"
    
    # 6. Node Uptime
    fetch_metric "/_cat/nodes?v&h=name,uptime" "Node Uptime" > "${OUTPUT_DIR}/node_uptime.csv"
    
    # 7. Search Query Metrics
    fetch_metric "/_cat/indices?v&h=index,search.query.total,search.query.time" "Search Query Metrics" > "${OUTPUT_DIR}/search_metrics.csv"
}

# Combine metrics into single CSV 
combine_metrics() {
    # Simple header
    echo "Timestamp,Nodes,Cluster_Name,Indices_Count,Total_Docs,Search_Queries" > "$OUTPUT_FILE"
    
    # Extract key metrics 
    nodes=$(wc -l < "${OUTPUT_DIR}/nodes_info.csv")
    cluster_name=$(jq -r '.cluster_name' "${OUTPUT_DIR}/cluster_stats.json")
    indices_count=$(jq -r '.indices.count' "${OUTPUT_DIR}/cluster_stats.json")
    total_docs=$(jq -r '.indices.docs.count' "${OUTPUT_DIR}/cluster_stats.json")
    search_queries=$(awk '{sum+=$2} END {print sum}' "${OUTPUT_DIR}/search_metrics.csv")
    
    # Write combined metrics
    echo "${TIMESTAMP},${nodes},${cluster_name},${indices_count},${total_docs},${search_queries}" >> "$OUTPUT_FILE"
}

# Main execution
main() {
    # Collect metrics
    collect_metrics
    
    # Combine metrics
    combine_metrics
    
    echo "Metrics collected in ${OUTPUT_FILE}"
}

main
