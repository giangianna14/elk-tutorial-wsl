#!/bin/bash

echo "=================================================================="
echo "🚀 OpenShift + Kafka + ELK v8 - Complete Pipeline Demonstration"
echo "=================================================================="
echo ""
echo "This demonstration shows the complete modern log monitoring pipeline:"
echo "  OpenShift Applications → Filebeat → Kafka → Logstash → Elasticsearch → Kibana"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

PROJECT_DIR="$HOME/openshift-kafka-elk-demo"

# Step 1: Check Prerequisites
echo ""
print_info "Step 1: Verifying ELK Stack and Kafka are running..."

# Check Elasticsearch
if curl -s http://localhost:9200 >/dev/null; then
    ES_VERSION=$(curl -s http://localhost:9200 | jq -r '.version.number' 2>/dev/null || echo "unknown")
    print_status "Elasticsearch v$ES_VERSION is running"
else
    print_error "Elasticsearch is not running. Please start it first."
    exit 1
fi

# Check Kibana
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5601 | grep -q "302\|200"; then
    print_status "Kibana is accessible"
else
    print_error "Kibana is not accessible. Please start it first."
    exit 1
fi

# Check Logstash
if sudo systemctl is-active logstash >/dev/null 2>&1; then
    print_status "Logstash is running"
else
    print_error "Logstash is not running. Please start it first."
    exit 1
fi

# Check Kafka
if ss -tlnp | grep -q :9092; then
    print_status "Kafka is running on port 9092"
else
    print_error "Kafka is not running. Please start it first."
    exit 1
fi

# Step 2: Generate OpenShift Application Logs
echo ""
print_info "Step 2: Generating OpenShift application logs..."

mkdir -p "$PROJECT_DIR/openshift-sim/logs"
cd "$PROJECT_DIR/openshift-sim/logs"

# Generate web application logs
print_info "Generating web application logs..."
for i in {1..20}; do
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    ip="192.168.1.$((RANDOM % 254 + 1))"
    methods=("GET" "POST" "PUT" "DELETE")
    method=${methods[$((RANDOM % 4))]}
    paths=("/api/users" "/api/orders" "/health" "/metrics" "/login" "/dashboard")
    path=${paths[$((RANDOM % 6))]}
    
    # Simulate different response statuses
    if [ $((RANDOM % 20)) -eq 0 ]; then
        status=500
    elif [ $((RANDOM % 10)) -eq 0 ]; then
        status=404
    else
        status=200
    fi
    
    duration=$((RANDOM % 1000 + 50))
    
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"info\",\"application\":\"web-frontend\",\"environment\":\"production\",\"version\":\"v1.2.3\",\"remote_addr\":\"$ip\",\"method\":\"$method\",\"request\":\"$method $path HTTP/1.1\",\"status\":$status,\"duration\":$duration,\"user_agent\":\"Mozilla/5.0 (K8s/1.0)\",\"logtype\":\"web_access\"}" >> web-app.log
done

# Generate API application logs
print_info "Generating API application logs..."
for i in {1..15}; do
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    levels=("info" "warn" "error" "debug")
    level=${levels[$((RANDOM % 4))]}
    messages=("User authentication successful" "Database query executed" "Cache miss occurred" "API rate limit exceeded" "Background job completed" "Error processing request")
    message=${messages[$((RANDOM % 6))]}
    job_id="job_$((RANDOM % 10000))"
    duration=$((RANDOM % 2000 + 10))
    
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"application\":\"api-backend\",\"environment\":\"production\",\"version\":\"v2.1.0\",\"message\":\"$message\",\"job_id\":\"$job_id\",\"duration\":$duration,\"logtype\":\"api_logs\"}" >> api-app.log
done

# Generate worker application logs
print_info "Generating background worker logs..."
for i in {1..10}; do
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    job_types=("email_notification" "data_processing" "file_upload" "report_generation" "data_cleanup")
    job_type=${job_types[$((RANDOM % 5))]}
    job_id="worker_$((RANDOM % 10000))"
    duration=$((RANDOM % 5000 + 100))
    records_processed=$((RANDOM % 1000 + 10))
    
    if [ $((RANDOM % 10)) -eq 0 ]; then
        # Generate error log
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"error\",\"application\":\"background-worker\",\"environment\":\"production\",\"version\":\"v1.0.0\",\"message\":\"Job failed: $job_type\",\"job_id\":\"$job_id\",\"job_type\":\"$job_type\",\"error_code\":\"PROC_ERR_001\",\"duration\":$duration,\"logtype\":\"worker_logs\"}" >> worker-app.log
    else
        # Generate success log
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"info\",\"application\":\"background-worker\",\"environment\":\"production\",\"version\":\"v1.0.0\",\"message\":\"Job completed successfully: $job_type\",\"job_id\":\"$job_id\",\"job_type\":\"$job_type\",\"duration\":$duration,\"records_processed\":$records_processed,\"logtype\":\"worker_logs\"}" >> worker-app.log
    fi
done

print_status "Generated log files:"
ls -la "$PROJECT_DIR/openshift-sim/logs/"
echo ""

# Step 3: Send logs through Kafka
echo ""
print_info "Step 3: Sending logs through Kafka message broker..."

cd "$PROJECT_DIR/kafka"

# Send web logs to Kafka
print_info "Sending web application logs to Kafka..."
cat "$PROJECT_DIR/openshift-sim/logs/web-app.log" | kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic openshift-logs

# Send API logs to Kafka
print_info "Sending API application logs to Kafka..."
cat "$PROJECT_DIR/openshift-sim/logs/api-app.log" | kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic openshift-logs

# Send worker logs to Kafka
print_info "Sending worker application logs to Kafka..."
cat "$PROJECT_DIR/openshift-sim/logs/worker-app.log" | kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic openshift-logs

print_status "All logs sent to Kafka!"

# Step 4: Verify processing
echo ""
print_info "Step 4: Waiting for logs to be processed through the pipeline..."
print_info "Pipeline: Kafka → Logstash → Elasticsearch"

sleep 20

# Check Elasticsearch indices
print_info "Checking Elasticsearch for processed logs..."
LOG_COUNT=$(curl -s "http://localhost:9200/openshift-logs-*/_count" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
print_status "Total logs in Elasticsearch: $LOG_COUNT"

# Show some sample processed logs
if [ "$LOG_COUNT" -gt 0 ]; then
    echo ""
    print_info "Sample processed logs from Elasticsearch:"
    echo "----------------------------------------"
    curl -s "http://localhost:9200/openshift-logs-*/_search?size=3&sort=@timestamp:desc" | jq '.hits.hits[]._source | {application, level, message, duration, performance_category, logtype}' 2>/dev/null || echo "Error retrieving logs"
fi

# Step 5: Real-time monitoring
echo ""
print_info "Step 5: Setting up real-time log monitoring..."

# Create a script for continuous log generation
cat > "$PROJECT_DIR/continuous_logs.sh" << 'EOF'
#!/bin/bash
LOG_DIR="$HOME/openshift-kafka-elk-demo/openshift-sim/logs"
KAFKA_DIR="$HOME/openshift-kafka-elk-demo/kafka"

echo "🔄 Starting continuous log generation..."

while true; do
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    
    # Generate random web log
    ip="192.168.1.$((RANDOM % 254 + 1))"
    status_codes=(200 200 200 201 400 404 500)
    status=${status_codes[$((RANDOM % 7))]}
    duration=$((RANDOM % 1000 + 50))
    
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"info\",\"application\":\"web-frontend\",\"environment\":\"production\",\"remote_addr\":\"$ip\",\"method\":\"GET\",\"request\":\"GET /api/health HTTP/1.1\",\"status\":$status,\"duration\":$duration,\"logtype\":\"web_access\"}" | $KAFKA_DIR/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic openshift-logs
    
    sleep $((RANDOM % 5 + 1))
done
EOF

chmod +x "$PROJECT_DIR/continuous_logs.sh"

print_info "Continuous log generator created at: $PROJECT_DIR/continuous_logs.sh"

# Step 6: Display access information
echo ""
echo "=================================================================="
print_status "🎉 OpenShift + Kafka + ELK Pipeline Demonstration Complete!"
echo "=================================================================="
echo ""
echo "📊 Access Points:"
echo "  • Kibana Dashboard: http://localhost:5601"
echo "  • Elasticsearch API: http://localhost:9200"
echo ""
echo "📈 Useful Elasticsearch Queries:"
echo "  • All logs: curl 'http://localhost:9200/openshift-logs-*/_search?pretty'"
echo "  • Count logs: curl 'http://localhost:9200/openshift-logs-*/_count'"
echo "  • Error logs: curl 'http://localhost:9200/openshift-logs-*/_search?q=level:error&pretty'"
echo "  • Slow requests: curl 'http://localhost:9200/openshift-logs-*/_search?q=performance_category:slow&pretty'"
echo ""
echo "🔧 Management Commands:"
echo "  • View Kafka messages: cd $PROJECT_DIR/kafka && kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic openshift-logs --from-beginning"
echo "  • Check Logstash logs: sudo journalctl -u logstash -f"
echo "  • Start continuous logs: $PROJECT_DIR/continuous_logs.sh &"
echo ""
echo "🏗️  Architecture Flow:"
echo "  OpenShift Apps → JSON Logs → Kafka Topic → Logstash Processing → Elasticsearch Storage → Kibana Visualization"
echo ""
echo "📊 Log Processing Features:"
echo "  • Performance categorization (fast/medium/slow based on duration)"
echo "  • Log source identification and enrichment"  
echo "  • Timestamp normalization and metadata addition"
echo "  • Error level detection and categorization"
echo ""

# Create Kibana index pattern instructions
echo "🔍 To set up Kibana dashboards:"
echo "  1. Open http://localhost:5601 in your browser"
echo "  2. Go to 'Stack Management' → 'Index Patterns'"
echo "  3. Create index pattern: 'openshift-logs-*'"
echo "  4. Set time field: '@timestamp'"
echo "  5. Go to 'Discover' to explore the logs"
echo "  6. Create visualizations and dashboards as needed"
echo ""

print_status "Pipeline demonstration completed successfully!"
echo ""
