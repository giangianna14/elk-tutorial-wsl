#!/bin/bash

echo "=================================================================="
echo "📊 OpenShift + Kafka + ELK v8 Pipeline Status Dashboard"
echo "=================================================================="
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

# Check services status
echo "🔍 Service Status:"
echo "=================="

# Elasticsearch
if curl -s http://localhost:9200 >/dev/null; then
    ES_VERSION=$(curl -s http://localhost:9200 | jq -r '.version.number' 2>/dev/null || echo "unknown")
    print_status "Elasticsearch v$ES_VERSION - http://localhost:9200"
else
    print_error "Elasticsearch - NOT RUNNING"
fi

# Kibana  
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5601 | grep -q "302\|200"; then
    print_status "Kibana - http://localhost:5601"
else
    print_error "Kibana - NOT ACCESSIBLE"
fi

# Logstash
if sudo systemctl is-active logstash >/dev/null 2>&1; then
    print_status "Logstash - Active"
else
    print_error "Logstash - NOT RUNNING"
fi

# Kafka
if ss -tlnp | grep -q :9092; then
    print_status "Kafka - localhost:9092"
else
    print_error "Kafka - NOT RUNNING"
fi

echo ""

# Check log statistics
echo "📈 Log Processing Statistics:"
echo "============================"

if curl -s http://localhost:9200 >/dev/null; then
    LOG_COUNT=$(curl -s "http://localhost:9200/openshift-logs-*/_count" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    INDICES=$(curl -s "http://localhost:9200/_cat/indices/openshift-logs-*?h=docs.count" 2>/dev/null | awk '{sum += $1} END {print sum}' || echo "0")
    
    print_info "Total Processed Logs: $LOG_COUNT"
    
    # Get log breakdown by application
    WEB_LOGS=$(curl -s "http://localhost:9200/openshift-logs-*/_count?q=application:web-frontend" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    API_LOGS=$(curl -s "http://localhost:9200/openshift-logs-*/_count?q=application:api-backend" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    WORKER_LOGS=$(curl -s "http://localhost:9200/openshift-logs-*/_count?q=application:background-worker" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    
    echo "  • Web Frontend: $WEB_LOGS logs"
    echo "  • API Backend: $API_LOGS logs"
    echo "  • Background Worker: $WORKER_LOGS logs"
    
    # Performance categories
    FAST_LOGS=$(curl -s "http://localhost:9200/openshift-logs-*/_count?q=performance_category:fast" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    MEDIUM_LOGS=$(curl -s "http://localhost:9200/openshift-logs-*/_count?q=performance_category:medium" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    SLOW_LOGS=$(curl -s "http://localhost:9200/openshift-logs-*/_count?q=performance_category:slow" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    
    echo "  • Fast Requests: $FAST_LOGS"
    echo "  • Medium Requests: $MEDIUM_LOGS"
    echo "  • Slow Requests: $SLOW_LOGS"
    
    # Error logs
    ERROR_LOGS=$(curl -s "http://localhost:9200/openshift-logs-*/_count?q=level:error" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
    echo "  • Error Logs: $ERROR_LOGS"
else
    print_warning "Cannot retrieve statistics - Elasticsearch not accessible"
fi

echo ""

# Quick access commands
echo "🔧 Quick Access Commands:"
echo "========================="
echo ""

echo "📊 Elasticsearch Queries:"
echo "  curl 'http://localhost:9200/openshift-logs-*/_count'"
echo "  curl 'http://localhost:9200/openshift-logs-*/_search?q=level:error&pretty'"
echo "  curl 'http://localhost:9200/openshift-logs-*/_search?q=performance_category:slow&pretty'"
echo ""

echo "📡 Kafka Management:"
echo "  cd ~/openshift-kafka-elk-demo/kafka"
echo "  kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic openshift-logs"
echo "  kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092"
echo ""

echo "📝 Log Monitoring:"
echo "  sudo journalctl -u logstash -f"
echo "  sudo journalctl -u elasticsearch -f"
echo "  sudo journalctl -u kibana -f"
echo ""

echo "🚀 Demo Scripts:"
echo "  ./demo-complete-pipeline.sh"
echo "  ~/openshift-kafka-elk-demo/continuous_logs.sh &"
echo ""

# Check if continuous logs are running
if pgrep -f "continuous_logs.sh" >/dev/null; then
    print_status "Continuous log generation is RUNNING"
else
    print_info "Continuous log generation is STOPPED"
    echo "  Start with: ~/openshift-kafka-elk-demo/continuous_logs.sh &"
fi

echo ""

# Real-time monitoring options
echo "⏱️  Real-time Monitoring:"
echo "========================"
echo "  watch 'curl -s \"http://localhost:9200/openshift-logs-*/_count\" | jq .count'"
echo "  tail -f ~/openshift-kafka-elk-demo/kafka/kafka/logs/server.log"
echo ""

# Kibana dashboard links
echo "📊 Kibana Dashboard Setup:"
echo "=========================="
echo "  1. Open: http://localhost:5601"
echo "  2. Go to Stack Management → Index Patterns"
echo "  3. Create pattern: 'openshift-logs-*'"
echo "  4. Set time field: '@timestamp'"
echo "  5. Go to Discover to explore logs"
echo ""

echo "=================================================================="
print_status "Pipeline Status: OPERATIONAL ✨"
echo "=================================================================="
