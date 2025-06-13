#!/bin/bash
set -e

echo "=================================================================="
echo "🚀 OpenShift + Kafka + ELK v8 Complete Demo"
echo "=================================================================="
echo ""
echo "This demo will showcase the complete modern log monitoring pipeline:"
echo "  OpenShift Apps → Filebeat → Kafka → Logstash → Elasticsearch → Kibana"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="$HOME/openshift-kafka-elk-demo"
KAFKA_VERSION="2.8.0"
SCALA_VERSION="2.13"

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for service
wait_for_service() {
    local service_name=$1
    local port=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for $service_name on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z localhost $port 2>/dev/null; then
            print_status "$service_name is ready!"
            return 0
        fi
        echo "   Attempt $attempt/$max_attempts - waiting..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name failed to start after $max_attempts attempts"
    return 1
}

# Check prerequisites
echo ""
print_info "Step 1: Checking prerequisites..."

# Check if ELK is already running
if ! curl -s http://localhost:9200 >/dev/null; then
    print_error "Elasticsearch is not running. Please run './install_elk_v8_latest_wsl.sh' first."
    exit 1
fi

if ! curl -s http://localhost:5601 >/dev/null; then
    print_error "Kibana is not running. Please start Kibana first."
    exit 1
fi

print_status "ELK Stack is running!"

# Install required tools
print_info "Installing required tools..."
sudo apt update >/dev/null 2>&1
sudo apt install -y docker.io docker-compose netcat bc npm >/dev/null 2>&1

print_status "Prerequisites checked!"

# Create project structure
echo ""
print_info "Step 2: Setting up project structure..."

mkdir -p "$PROJECT_DIR"/{kafka,openshift-sim,beats-config,logstash-config}
cd "$PROJECT_DIR"

print_status "Project structure created!"

# Install and configure Kafka
echo ""
print_info "Step 3: Installing and configuring Kafka..."

cd "$PROJECT_DIR/kafka"

if [ ! -d "kafka" ]; then
    print_info "Downloading Kafka ${KAFKA_VERSION}..."
    wget -q "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    mv "kafka_${SCALA_VERSION}-${KAFKA_VERSION}" kafka
    rm "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
fi

# Create Kafka data directories
mkdir -p kafka/logs/zookeeper kafka/logs/kafka-logs

# Configure Kafka
cat > kafka/config/server.properties << 'EOF'
broker.id=0
listeners=PLAINTEXT://localhost:9092
advertised.listeners=PLAINTEXT://localhost:9092
log.dirs=./logs/kafka-logs
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
num.partitions=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=18000
group.initial.rebalance.delay.ms=0
EOF

print_status "Kafka configured!"

# Start Kafka
echo ""
print_info "Step 4: Starting Kafka services..."

# Check if Kafka is already running
if ! nc -z localhost 9092 2>/dev/null; then
    print_info "Starting Zookeeper..."
    nohup kafka/bin/zookeeper-server-start.sh kafka/config/zookeeper.properties > kafka/logs/zookeeper.log 2>&1 &
    sleep 10
    
    print_info "Starting Kafka broker..."
    nohup kafka/bin/kafka-server-start.sh kafka/config/server.properties > kafka/logs/kafka.log 2>&1 &
    
    # Wait for Kafka to be ready
    wait_for_service "Kafka" 9092
else
    print_status "Kafka is already running!"
fi

# Create Kafka topic
print_info "Creating Kafka topics..."
kafka/bin/kafka-topics.sh --create --topic openshift-logs --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 --if-not-exists >/dev/null 2>&1 || true
kafka/bin/kafka-topics.sh --create --topic application-metrics --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 --if-not-exists >/dev/null 2>&1 || true

print_status "Kafka topics created!"

# Create OpenShift simulation
echo ""
print_info "Step 5: Creating OpenShift simulation with Docker..."

cd "$PROJECT_DIR/openshift-sim"

# Create docker-compose for simulated OpenShift environment
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web-app:
    image: nginx:alpine
    container_name: openshift-web-app
    ports:
      - "8080:80"
    volumes:
      - ./nginx-logs:/var/log/nginx
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    labels:
      - "app=web-frontend"
      - "version=v1.2.3"
      - "environment=production"

  api-app:
    image: node:18-alpine
    container_name: openshift-api-app
    working_dir: /app
    ports:
      - "3000:3000"
    volumes:
      - ./api-app:/app
      - ./api-logs:/app/logs
    command: node server.js
    labels:
      - "app=api-backend"
      - "version=v2.1.0"
      - "environment=production"

  database-app:
    image: postgres:13
    container_name: openshift-database
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: dbuser
      POSTGRES_PASSWORD: dbpass123
    ports:
      - "5432:5432"
    volumes:
      - ./db-logs:/var/log/postgresql
    labels:
      - "app=database"
      - "version=v13.0"
      - "environment=production"

  worker-app:
    image: python:3.9-slim
    container_name: openshift-worker
    working_dir: /app
    volumes:
      - ./worker-app:/app
      - ./worker-logs:/app/logs
    command: python worker.py
    labels:
      - "app=background-worker"
      - "version=v1.0.0"
      - "environment=production"
EOF

# Create Nginx configuration
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    log_format json_combined escape=json
    '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"remote_user":"$remote_user",'
        '"method":"$request_method",'
        '"request":"$request",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"http_referer":"$http_referer",'
        '"http_user_agent":"$http_user_agent",'
        '"request_time":$request_time,'
        '"upstream_response_time":"$upstream_response_time",'
        '"application":"web-frontend",'
        '"environment":"production",'
        '"version":"v1.2.3"'
    '}';

    access_log /var/log/nginx/access.log json_combined;
    error_log /var/log/nginx/error.log warn;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }

        location /api/ {
            return 200 '{"status":"ok","message":"API endpoint"}';
            add_header Content-Type application/json;
        }

        location /health {
            return 200 '{"status":"healthy"}';
            add_header Content-Type application/json;
        }
    }
}
EOF

# Create directories for logs
mkdir -p nginx-logs api-logs db-logs worker-logs

# Create Node.js API application
mkdir -p api-app
cat > api-app/server.js << 'EOF'
const http = require('http');
const fs = require('fs');
const path = require('path');

const logFile = path.join(__dirname, 'logs', 'api.log');

// Ensure logs directory exists
if (!fs.existsSync(path.dirname(logFile))) {
    fs.mkdirSync(path.dirname(logFile), { recursive: true });
}

function log(level, message, data = {}) {
    const logEntry = {
        timestamp: new Date().toISOString(),
        level: level,
        message: message,
        application: 'api-backend',
        environment: 'production',
        version: 'v2.1.0',
        ...data
    };
    
    fs.appendFileSync(logFile, JSON.stringify(logEntry) + '\n');
    console.log(JSON.stringify(logEntry));
}

const server = http.createServer((req, res) => {
    const start = Date.now();
    
    // Simulate different response times
    const delay = Math.random() * 1000;
    
    setTimeout(() => {
        let status = 200;
        let response = { status: 'ok', timestamp: new Date().toISOString() };
        
        // Simulate errors occasionally
        if (Math.random() < 0.05) {
            status = 500;
            response = { error: 'Internal server error', code: 'E001' };
        } else if (Math.random() < 0.1) {
            status = 404;
            response = { error: 'Not found', path: req.url };
        }
        
        const duration = Date.now() - start;
        
        // Log the request
        log('info', 'HTTP request processed', {
            method: req.method,
            url: req.url,
            status: status,
            duration: duration,
            user_agent: req.headers['user-agent'],
            remote_addr: req.connection.remoteAddress
        });
        
        res.writeHead(status, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(response));
    }, delay);
});

server.listen(3000, () => {
    log('info', 'API server started', { port: 3000 });
});

// Generate some background activity
setInterval(() => {
    const activities = [
        'Database query executed',
        'Cache updated',
        'Background job completed',
        'Metrics published',
        'Health check performed'
    ];
    
    const activity = activities[Math.floor(Math.random() * activities.length)];
    log('info', activity, { job_id: Math.random().toString(36).substr(2, 9) });
}, 5000);
EOF

# Create Python worker application
mkdir -p worker-app
cat > worker-app/worker.py << 'EOF'
import json
import time
import random
import logging
import os
from datetime import datetime

# Setup logging
log_dir = '/app/logs'
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    handlers=[
        logging.FileHandler(f'{log_dir}/worker.log'),
        logging.StreamHandler()
    ]
)

def log_message(level, message, **kwargs):
    log_entry = {
        'timestamp': datetime.now().isoformat(),
        'level': level,
        'message': message,
        'application': 'background-worker',
        'environment': 'production',
        'version': 'v1.0.0',
        **kwargs
    }
    logging.info(json.dumps(log_entry))

def process_job():
    job_types = [
        'email_notification',
        'data_processing',
        'file_upload',
        'report_generation',
        'data_cleanup'
    ]
    
    job_type = random.choice(job_types)
    job_id = f"job_{random.randint(1000, 9999)}"
    
    log_message('info', f'Starting {job_type}', job_id=job_id, job_type=job_type)
    
    # Simulate processing time
    processing_time = random.uniform(1, 10)
    time.sleep(processing_time)
    
    # Simulate success/failure
    if random.random() < 0.1:
        log_message('error', f'Job failed: {job_type}', 
                   job_id=job_id, 
                   job_type=job_type,
                   error_code='PROC_ERR_001',
                   duration=processing_time)
    else:
        log_message('info', f'Job completed successfully: {job_type}', 
                   job_id=job_id, 
                   job_type=job_type,
                   duration=processing_time,
                   records_processed=random.randint(10, 1000))

if __name__ == '__main__':
    log_message('info', 'Worker started')
    
    while True:
        try:
            process_job()
            # Wait between jobs
            time.sleep(random.uniform(2, 8))
        except Exception as e:
            log_message('error', f'Worker error: {str(e)}', error_type='WORKER_ERROR')
            time.sleep(5)
EOF

print_status "OpenShift simulation created!"

# Start the simulated OpenShift environment
print_info "Starting OpenShift simulation containers..."
docker-compose up -d

# Wait for containers to be ready
sleep 10

print_status "OpenShift simulation is running!"

# Configure Filebeat to send logs to Kafka
echo ""
print_info "Step 6: Configuring Filebeat to send logs to Kafka..."

cd "$PROJECT_DIR/beats-config"

cat > filebeat-kafka.yml << 'EOF'
###################### Filebeat Configuration Example #########################

# ============================== Filebeat inputs =============================

filebeat.inputs:

# Log files from OpenShift simulation
- type: log
  enabled: true
  paths:
    - /var/lib/docker/containers/*/*-json.log
  json.keys_under_root: true
  json.add_error_key: true
  fields:
    logtype: docker
    environment: production
  fields_under_root: true
  processors:
    - add_docker_metadata:
        host: "unix:///var/run/docker.sock"

# Nginx access logs
- type: log
  enabled: true
  paths:
    - ${PROJECT_DIR}/openshift-sim/nginx-logs/access.log
  json.keys_under_root: true
  json.add_error_key: true
  fields:
    logtype: nginx_access
    application: web-frontend
    environment: production
  fields_under_root: true

# API application logs
- type: log
  enabled: true
  paths:
    - ${PROJECT_DIR}/openshift-sim/api-logs/api.log
  json.keys_under_root: true
  json.add_error_key: true
  fields:
    logtype: api_logs
    application: api-backend
    environment: production
  fields_under_root: true

# Worker application logs
- type: log
  enabled: true
  paths:
    - ${PROJECT_DIR}/openshift-sim/worker-logs/worker.log
  json.keys_under_root: true
  json.add_error_key: true
  fields:
    logtype: worker_logs
    application: background-worker
    environment: production
  fields_under_root: true

# ============================== Filebeat modules ==============================

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

# ================================== General ===================================

name: openshift-filebeat
tags: ["openshift", "kafka", "demo"]

# ================================== Outputs ===================================

# ---------------------------- Kafka Output -----------------------------------
output.kafka:
  enabled: true
  hosts: ["localhost:9092"]
  topic: "openshift-logs"
  partition.round_robin:
    reachable_only: false
  required_acks: 1
  compression: gzip
  max_message_bytes: 1000000

# ================================= Processors =================================

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_kubernetes_metadata:
      host: ${NODE_NAME}
      matchers:
      - logs_path:
          logs_path: "/var/log/containers/"
  - timestamp:
      field: timestamp
      layouts:
        - '2006-01-02T15:04:05.000Z'
        - '2006-01-02T15:04:05Z'
      test:
        - '2019-06-22T16:33:51.000Z'

# ================================== Logging ===================================

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644

# ============================= X-Pack Monitoring =============================

monitoring.enabled: false
EOF

# Substitute PROJECT_DIR in the config
sed -i "s|\${PROJECT_DIR}|$PROJECT_DIR|g" filebeat-kafka.yml

print_status "Filebeat configured for Kafka output!"

# Configure Logstash to read from Kafka
echo ""
print_info "Step 7: Configuring Logstash to read from Kafka..."

cd "$PROJECT_DIR/logstash-config"

cat > kafka-logstash.conf << 'EOF'
input {
  kafka {
    bootstrap_servers => "localhost:9092"
    topics => ["openshift-logs"]
    group_id => "logstash-openshift"
    consumer_threads => 3
    decorate_events => true
    codec => "json"
  }
}

filter {
  # Add timestamp if not present
  if ![timestamp] {
    mutate {
      add_field => { "timestamp" => "%{@timestamp}" }
    }
  }

  # Parse different log types
  if [logtype] == "nginx_access" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
      overwrite => [ "message" ]
    }
    
    date {
      match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
    
    mutate {
      convert => { "response_time" => "float" }
      convert => { "body_bytes_sent" => "integer" }
      add_field => { "log_source" => "nginx" }
    }
  }

  if [logtype] == "api_logs" {
    mutate {
      add_field => { "log_source" => "api" }
    }
    
    if [duration] {
      mutate {
        convert => { "duration" => "float" }
      }
    }
  }

  if [logtype] == "worker_logs" {
    mutate {
      add_field => { "log_source" => "worker" }
    }
    
    if [duration] {
      mutate {
        convert => { "duration" => "float" }
      }
    }
  }

  if [logtype] == "docker" {
    mutate {
      add_field => { "log_source" => "docker" }
    }
  }

  # Add performance categorization
  if [duration] {
    if [duration] < 100 {
      mutate { add_field => { "performance_category" => "fast" } }
    } else if [duration] < 1000 {
      mutate { add_field => { "performance_category" => "medium" } }
    } else {
      mutate { add_field => { "performance_category" => "slow" } }
    }
  }

  # Enrich with additional metadata
  mutate {
    add_field => { 
      "pipeline" => "kafka-openshift"
      "processed_at" => "%{@timestamp}"
    }
  }

  # Remove unnecessary fields
  mutate {
    remove_field => [ "agent", "ecs", "host", "input", "log" ]
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "openshift-logs-%{+YYYY.MM.dd}"
    template_name => "openshift-logs"
    template_pattern => "openshift-logs-*"
    template => {
      "index_patterns" => ["openshift-logs-*"]
      "settings" => {
        "number_of_shards" => 1
        "number_of_replicas" => 0
        "index.refresh_interval" => "30s"
      }
      "mappings" => {
        "properties" => {
          "@timestamp" => { "type" => "date" }
          "timestamp" => { "type" => "date" }
          "level" => { "type" => "keyword" }
          "message" => { "type" => "text" }
          "application" => { "type" => "keyword" }
          "environment" => { "type" => "keyword" }
          "version" => { "type" => "keyword" }
          "logtype" => { "type" => "keyword" }
          "log_source" => { "type" => "keyword" }
          "duration" => { "type" => "float" }
          "status" => { "type" => "integer" }
          "performance_category" => { "type" => "keyword" }
        }
      }
    }
  }

  # Also output to console for debugging
  stdout {
    codec => rubydebug
  }
}
EOF

# Copy Logstash configuration to the system directory
sudo cp kafka-logstash.conf /etc/logstash/conf.d/

print_status "Logstash configured for Kafka input!"

# Restart Logstash with new configuration
print_info "Restarting Logstash with new configuration..."
sudo systemctl restart logstash
sleep 15

print_status "Logstash restarted!"

# Start Filebeat with Kafka configuration
echo ""
print_info "Step 8: Starting Filebeat with Kafka configuration..."

# Stop default filebeat if running
sudo systemctl stop filebeat 2>/dev/null || true

# Start filebeat with custom configuration
sudo /usr/share/filebeat/bin/filebeat -e -c "$PROJECT_DIR/beats-config/filebeat-kafka.yml" --path.logs /var/log/filebeat-kafka &

FILEBEAT_PID=$!
echo "Filebeat PID: $FILEBEAT_PID"

print_status "Filebeat started with Kafka output!"

# Generate some traffic
echo ""
print_info "Step 9: Generating sample traffic and logs..."

# Create traffic generator script
cat > "$PROJECT_DIR/generate_traffic.sh" << 'EOF'
#!/bin/bash

echo "🚀 Generating sample traffic for OpenShift applications..."

# Generate web traffic
for i in {1..50}; do
    curl -s http://localhost:8080/ > /dev/null
    curl -s http://localhost:8080/api/ > /dev/null
    curl -s http://localhost:8080/health > /dev/null
    
    # Generate some API traffic
    curl -s http://localhost:3000/users > /dev/null
    curl -s http://localhost:3000/orders > /dev/null
    curl -s http://localhost:3000/products > /dev/null
    
    sleep 0.5
done

echo "✅ Traffic generation completed!"
EOF

chmod +x "$PROJECT_DIR/generate_traffic.sh"

# Run traffic generator
"$PROJECT_DIR/generate_traffic.sh"

print_status "Sample traffic generated!"

# Wait for logs to be processed
print_info "Waiting for logs to be processed through the pipeline..."
sleep 30

# Check pipeline status
echo ""
print_info "Step 10: Verifying the complete pipeline..."

# Check Kafka topic
print_info "Checking Kafka topic for messages..."
cd "$PROJECT_DIR/kafka"
MESSAGE_COUNT=$(kafka/bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic openshift-logs --time -1 2>/dev/null | awk -F: '{sum += $3} END {print sum}')
echo "📊 Messages in Kafka topic: $MESSAGE_COUNT"

# Check Elasticsearch indices
print_info "Checking Elasticsearch for log data..."
INDICES=$(curl -s "http://localhost:9200/_cat/indices/openshift-logs-*?h=index,docs.count" 2>/dev/null)
echo "📊 Elasticsearch indices:"
echo "$INDICES"

# Verify log data in Elasticsearch
LOG_COUNT=$(curl -s "http://localhost:9200/openshift-logs-*/_count" 2>/dev/null | jq '.count' 2>/dev/null || echo "0")
echo "📊 Total logs in Elasticsearch: $LOG_COUNT"

print_status "Pipeline verification completed!"

# Show access information
echo ""
echo "=================================================================="
print_status "🎉 OpenShift + Kafka + ELK Demo Successfully Deployed!"
echo "=================================================================="
echo ""
echo "📊 Access Points:"
echo "  • Kibana Dashboard: http://localhost:5601"
echo "  • Elasticsearch API: http://localhost:9200"
echo "  • Web Application: http://localhost:8080"
echo "  • API Application: http://localhost:3000"
echo ""
echo "📁 Project Directory: $PROJECT_DIR"
echo ""
echo "🔧 Management Commands:"
echo "  • View Kafka messages: cd $PROJECT_DIR/kafka && kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic openshift-logs --from-beginning"
echo "  • Check Logstash logs: sudo journalctl -u logstash -f"
echo "  • Generate more traffic: $PROJECT_DIR/generate_traffic.sh"
echo ""
echo "🏗️  Architecture Flow:"
echo "  OpenShift Apps → Docker Logs → Filebeat → Kafka → Logstash → Elasticsearch → Kibana"
echo ""
print_status "Demo is ready for exploration!"
echo ""
