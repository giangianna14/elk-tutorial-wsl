# Hands-on: Modern Log Monitoring - OpenShift → Kafka → ELK Stack v8

## Overview Architecture

Tutorial ini mendemonstrasikan implementasi modern log monitoring pipeline dengan:
- **OpenShift/Kubernetes** sebagai source aplikasi
- **Beats** (Filebeat) untuk log collection
- **Apache Kafka** sebagai message broker untuk scalability
- **Logstash** untuk log processing dan enrichment
- **Elasticsearch v8** untuk storage dan indexing
- **Kibana v8** untuk visualization dan analysis

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  OpenShift  │───▶│   Filebeat  │───▶│    Kafka    │───▶│  Logstash   │───▶│Elasticsearch│───▶│   Kibana    │
│ (K8s Pods)  │    │ (Log Agent) │    │ (Message Q) │    │(Processing) │    │  (Storage)  │    │(Visualization)│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## Daftar Isi

1. [Prerequisites](#prerequisites)
2. [Setup Environment](#setup-environment)
3. [Install Apache Kafka](#install-apache-kafka)
4. [Install ELK Stack v8](#install-elk-stack-v8)
5. [Simulate OpenShift Environment](#simulate-openshift-environment)
6. [Configure Filebeat dengan Kafka Output](#configure-filebeat-kafka)
7. [Configure Logstash dengan Kafka Input](#configure-logstash-kafka)
8. [Hands-on Log Processing](#hands-on-log-processing)
9. [Advanced Kibana Analysis](#advanced-kibana-analysis)
10. [Production Considerations](#production-considerations)

---

## Prerequisites

### System Requirements
- **OS**: WSL Ubuntu 20.04+ atau Ubuntu Server
- **RAM**: Minimum 8GB (Recommended 16GB)
- **Storage**: 20GB+ free space
- **Java**: OpenJDK 11 atau 17 (untuk Kafka dan ELK)

### Tools yang Diperlukan
- Docker dan Docker Compose (untuk simulasi OpenShift)
- Git untuk version control
- curl, wget untuk downloading packages

---

## Setup Environment

### 1. Persiapan Sistem

```bash
# Update sistem
sudo apt update && sudo apt upgrade -y

# Install Java 17 (required untuk ELK v8 dan Kafka)
sudo apt install -y openjdk-17-jdk

# Verify Java installation
java -version
javac -version

# Install Docker dan Docker Compose
sudo apt install -y docker.io docker-compose

# Add user ke docker group
sudo usermod -aG docker $USER
newgrp docker

# Install development tools
sudo apt install -y git curl wget unzip jq
```

### 2. Setup Working Directory

```bash
# Create project directory
mkdir -p ~/openshift-kafka-elk-demo
cd ~/openshift-kafka-elk-demo

# Create subdirectories
mkdir -p {kafka,elk-config,openshift-sim,beats-config,logstash-config}
```

---

## Install Apache Kafka

### 1. Download dan Install Kafka

```bash
cd ~/openshift-kafka-elk-demo/kafka

# Download Kafka 2.8.0 dengan built-in Zookeeper
wget https://downloads.apache.org/kafka/2.8.0/kafka_2.13-2.8.0.tgz
tar -xzf kafka_2.13-2.8.0.tgz
mv kafka_2.13-2.8.0 kafka

# Create Kafka data directories
mkdir -p kafka/logs/{kafka,zookeeper}
```

### 2. Configure Kafka

```bash
# Edit Kafka server properties
cat > kafka/kafka/config/server.properties << 'EOF'
# Basic Kafka Configuration
broker.id=0
listeners=PLAINTEXT://localhost:9092
advertised.listeners=PLAINTEXT://localhost:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

# Log configuration
log.dirs=/home/$USER/openshift-kafka-elk-demo/kafka/kafka/logs/kafka
num.partitions=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

# Log retention
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000

# Zookeeper
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=18000

# Group coordinator
group.initial.rebalance.delay.ms=0
EOF

# Edit Zookeeper properties
cat > kafka/kafka/config/zookeeper.properties << 'EOF'
dataDir=/home/$USER/openshift-kafka-elk-demo/kafka/kafka/logs/zookeeper
clientPort=2181
maxClientCnxns=0
admin.enableServer=false
EOF
```

### 3. Start Kafka Services

```bash
cd ~/openshift-kafka-elk-demo/kafka/kafka

# Start Zookeeper (Terminal 1)
bin/zookeeper-server-start.sh config/zookeeper.properties &

# Wait for Zookeeper to start
sleep 10

# Start Kafka (Terminal 2)
bin/kafka-server-start.sh config/server.properties &

# Wait for Kafka to start
sleep 15

# Verify Kafka is running
jps | grep -E "(Kafka|QuorumPeer)"
```

### 4. Create Kafka Topics

```bash
cd ~/openshift-kafka-elk-demo/kafka/kafka

# Create topic untuk OpenShift logs
bin/kafka-topics.sh --create \
  --topic openshift-logs \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

# Create topic untuk application logs
bin/kafka-topics.sh --create \
  --topic app-logs \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

# Verify topics
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

---

## Install ELK Stack v8

### 1. Install menggunakan script yang sudah ada

```bash
cd ~/elk-tutorial-wsl

# Gunakan script ELK v8 yang sudah dibuat
./install_elk_v8_latest_wsl.sh
```

### 2. Verify ELK Installation

```bash
# Check services
sudo systemctl status elasticsearch kibana logstash

# Test Elasticsearch
curl -X GET "localhost:9200/_cluster/health?pretty"

# Test Kibana (tunggu beberapa menit untuk startup)
curl -I "http://localhost:5601/api/status"
```

---

## Simulate OpenShift Environment

### 1. Create Docker Compose untuk Simulasi

```bash
cd ~/openshift-kafka-elk-demo/openshift-sim

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Simulate OpenShift application pods
  web-app-1:
    image: nginx:alpine
    container_name: openshift-web-app-1
    volumes:
      - ./logs:/var/log/nginx
      - ./app-configs/web-app-1:/etc/nginx/conf.d
    ports:
      - "8081:80"
    environment:
      - POD_NAME=web-app-1
      - NAMESPACE=production
      - APP_NAME=ecommerce-frontend
    labels:
      app: ecommerce-frontend
      tier: frontend
      environment: production

  web-app-2:
    image: nginx:alpine
    container_name: openshift-web-app-2
    volumes:
      - ./logs:/var/log/nginx
      - ./app-configs/web-app-2:/etc/nginx/conf.d
    ports:
      - "8082:80"
    environment:
      - POD_NAME=web-app-2
      - NAMESPACE=production
      - APP_NAME=ecommerce-frontend
    labels:
      app: ecommerce-frontend
      tier: frontend
      environment: production

  api-app-1:
    image: node:16-alpine
    container_name: openshift-api-app-1
    working_dir: /app
    volumes:
      - ./api-app:/app
      - ./logs:/app/logs
    ports:
      - "3001:3000"
    environment:
      - POD_NAME=api-app-1
      - NAMESPACE=production
      - APP_NAME=ecommerce-api
    labels:
      app: ecommerce-api
      tier: backend
      environment: production
    command: node server.js

  api-app-2:
    image: node:16-alpine
    container_name: openshift-api-app-2
    working_dir: /app
    volumes:
      - ./api-app:/app
      - ./logs:/app/logs
    ports:
      - "3002:3000"
    environment:
      - POD_NAME=api-app-2
      - NAMESPACE=production
      - APP_NAME=ecommerce-api
    labels:
      app: ecommerce-api
      tier: backend
      environment: production
    command: node server.js

volumes:
  logs:
EOF
```

### 2. Create Sample Applications

```bash
# Create directories
mkdir -p {logs,app-configs/web-app-1,app-configs/web-app-2,api-app}

# Create Nginx configs
cat > app-configs/web-app-1/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    access_log /var/log/nginx/web-app-1-access.log combined;
    error_log /var/log/nginx/web-app-1-error.log warn;
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
    
    location /api {
        proxy_pass http://host.docker.internal:3001;
    }
}
EOF

cat > app-configs/web-app-2/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    access_log /var/log/nginx/web-app-2-access.log combined;
    error_log /var/log/nginx/web-app-2-error.log warn;
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
    
    location /api {
        proxy_pass http://host.docker.internal:3002;
    }
}
EOF

# Create Node.js API application
cat > api-app/server.js << 'EOF'
const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;
const podName = process.env.POD_NAME || 'unknown-pod';
const namespace = process.env.NAMESPACE || 'default';
const appName = process.env.APP_NAME || 'unknown-app';

// Middleware untuk logging
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    const logEntry = {
        timestamp,
        level: 'INFO',
        pod_name: podName,
        namespace,
        app_name: appName,
        method: req.method,
        url: req.url,
        ip: req.ip,
        user_agent: req.get('User-Agent'),
        request_id: Math.random().toString(36).substr(2, 9)
    };
    
    // Write to log file
    fs.appendFileSync(
        path.join('/app/logs', `${podName}.log`),
        JSON.stringify(logEntry) + '\n'
    );
    
    console.log(JSON.stringify(logEntry));
    next();
});

// API endpoints
app.get('/health', (req, res) => {
    res.json({ status: 'healthy', pod: podName, timestamp: new Date().toISOString() });
});

app.get('/api/users', (req, res) => {
    // Simulate random errors (5% chance)
    if (Math.random() < 0.05) {
        const errorLog = {
            timestamp: new Date().toISOString(),
            level: 'ERROR',
            pod_name: podName,
            namespace,
            app_name: appName,
            error: 'Database connection timeout',
            endpoint: '/api/users',
            request_id: Math.random().toString(36).substr(2, 9)
        };
        
        fs.appendFileSync(
            path.join('/app/logs', `${podName}.log`),
            JSON.stringify(errorLog) + '\n'
        );
        
        return res.status(500).json({ error: 'Internal server error' });
    }
    
    res.json({
        users: [
            { id: 1, name: 'John Doe', email: 'john@example.com' },
            { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
        ],
        pod: podName,
        timestamp: new Date().toISOString()
    });
});

app.get('/api/orders', (req, res) => {
    // Simulate slow responses (10% chance)
    const delay = Math.random() < 0.1 ? 2000 : 100;
    
    setTimeout(() => {
        const responseLog = {
            timestamp: new Date().toISOString(),
            level: delay > 1000 ? 'WARN' : 'INFO',
            pod_name: podName,
            namespace,
            app_name: appName,
            message: delay > 1000 ? 'Slow response detected' : 'Request processed',
            endpoint: '/api/orders',
            response_time_ms: delay,
            request_id: Math.random().toString(36).substr(2, 9)
        };
        
        fs.appendFileSync(
            path.join('/app/logs', `${podName}.log`),
            JSON.stringify(responseLog) + '\n'
        );
        
        res.json({
            orders: [
                { id: 1, user_id: 1, total: 99.99, status: 'completed' },
                { id: 2, user_id: 2, total: 149.99, status: 'pending' }
            ],
            pod: podName,
            timestamp: new Date().toISOString()
        });
    }, delay);
});

app.listen(port, () => {
    const startLog = {
        timestamp: new Date().toISOString(),
        level: 'INFO',
        pod_name: podName,
        namespace,
        app_name: appName,
        message: `Server started on port ${port}`,
        event: 'startup'
    };
    
    fs.appendFileSync(
        path.join('/app/logs', `${podName}.log`),
        JSON.stringify(startLog) + '\n'
    );
    
    console.log(`Server running on port ${port}`);
});
EOF

# Create package.json for Node.js app
cat > api-app/package.json << 'EOF'
{
  "name": "openshift-api-simulator",
  "version": "1.0.0",
  "description": "Simulate OpenShift API application for ELK demo",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2"
  },
  "scripts": {
    "start": "node server.js"
  }
}
EOF
```

### 3. Start Simulated Applications

```bash
cd ~/openshift-kafka-elk-demo/openshift-sim

# Install Node.js dependencies
cd api-app && npm install && cd ..

# Start all containers
docker-compose up -d

# Verify containers are running
docker-compose ps

# Test applications
curl http://localhost:8081
curl http://localhost:3001/health
curl http://localhost:3002/api/users
```

---

## Configure Filebeat dengan Kafka Output {#configure-filebeat-kafka}

### 1. Create Filebeat Configuration

```bash
cd ~/openshift-kafka-elk-demo/beats-config

cat > filebeat-kafka.yml << 'EOF'
# ============================== Filebeat Configuration ==============================

# ============================== Inputs ==============================
filebeat.inputs:

# OpenShift/Container logs
- type: container
  enabled: true
  paths:
    - /var/lib/docker/containers/*/*.log
  processors:
    - add_docker_metadata:
        host: "unix:///var/run/docker.sock"
    - decode_json_fields:
        fields: ["message"]
        target: "json"
        overwrite_keys: true

# Application log files from our simulation
- type: log
  enabled: true
  paths:
    - /home/*/openshift-kafka-elk-demo/openshift-sim/logs/*.log
  fields:
    logtype: openshift-app
    environment: production
  fields_under_root: true
  json.keys_under_root: true
  json.add_error_key: true
  multiline.pattern: '^\{'
  multiline.negate: true
  multiline.match: after

# Nginx access logs
- type: log
  enabled: true
  paths:
    - /home/*/openshift-kafka-elk-demo/openshift-sim/logs/*-access.log
  fields:
    logtype: nginx-access
    service: web-frontend
  fields_under_root: true

# Nginx error logs  
- type: log
  enabled: true
  paths:
    - /home/*/openshift-kafka-elk-demo/openshift-sim/logs/*-error.log
  fields:
    logtype: nginx-error
    service: web-frontend
  fields_under_root: true

# ============================== Processors ==============================
processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  
  - add_kubernetes_metadata:
      host: ${NODE_NAME}
      matchers:
      - logs_path:
          logs_path: "/var/log/containers/"
  
  - add_fields:
      target: pipeline
      fields:
        source: openshift-cluster
        datacenter: aws-east-1
        environment: production

# ============================== Kafka Output ==============================
output.kafka:
  enabled: true
  hosts: ["localhost:9092"]
  topic: "openshift-logs"
  partition.round_robin:
    reachable_only: false
  required_acks: 1
  compression: gzip
  max_message_bytes: 1048576
  
  # Codec for message format
  codec.json:
    pretty: false
    escape_html: false

# ============================== Logging ==============================
logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat-kafka.log
  keepfiles: 7
  permissions: 0644

# ============================== Monitoring ==============================
monitoring.enabled: true
http.enabled: true
http.host: localhost
http.port: 5066
EOF
```

### 2. Start Filebeat dengan Kafka Output

```bash
# Stop default filebeat jika running
sudo systemctl stop filebeat

# Run Filebeat dengan custom config
sudo filebeat -e -c ~/openshift-kafka-elk-demo/beats-config/filebeat-kafka.yml &

# Monitor Filebeat logs
tail -f /var/log/filebeat/filebeat-kafka.log
```

### 3. Verify Data Flow ke Kafka

```bash
cd ~/openshift-kafka-elk-demo/kafka/kafka

# Check messages in Kafka topic
bin/kafka-console-consumer.sh \
  --topic openshift-logs \
  --from-beginning \
  --bootstrap-server localhost:9092 \
  --max-messages 5
```

---

## Configure Logstash dengan Kafka Input {#configure-logstash-kafka}

### 1. Create Logstash Configuration

```bash
cd ~/openshift-kafka-elk-demo/logstash-config

cat > openshift-kafka-pipeline.conf << 'EOF'
# ============================== Input ==============================
input {
  kafka {
    bootstrap_servers => "localhost:9092"
    topics => ["openshift-logs"]
    consumer_group_id => "logstash-openshift"
    codec => "json"
    decorate_events => true
    auto_offset_reset => "latest"
  }
}

# ============================== Filter ==============================
filter {
  # Add Kafka metadata
  mutate {
    add_field => { "[@metadata][kafka_topic]" => "%{[@metadata][kafka][topic]}" }
    add_field => { "[@metadata][kafka_partition]" => "%{[@metadata][kafka][partition]}" }
    add_field => { "[@metadata][kafka_offset]" => "%{[@metadata][kafka][offset]}" }
  }

  # Parse different log types
  if [logtype] == "openshift-app" {
    # Application logs are already in JSON format
    if [level] {
      mutate {
        lowercase => [ "level" ]
        add_field => { "log_level" => "%{level}" }
      }
    }
    
    # Extract OpenShift metadata
    if [pod_name] {
      mutate {
        add_field => { "kubernetes.pod.name" => "%{pod_name}" }
      }
    }
    
    if [namespace] {
      mutate {
        add_field => { "kubernetes.namespace" => "%{namespace}" }
      }
    }
    
    if [app_name] {
      mutate {
        add_field => { "kubernetes.labels.app" => "%{app_name}" }
      }
    }
    
  } else if [logtype] == "nginx-access" {
    # Parse Nginx access logs
    grok {
      match => { 
        "message" => '%{IPORHOST:remote_addr} - %{DATA:remote_user} \[%{HTTPDATE:time_local}\] "%{WORD:method} %{DATA:request} HTTP/%{NUMBER:http_version}" %{INT:status} %{INT:body_bytes_sent} "%{DATA:http_referer}" "%{DATA:http_user_agent}"'
      }
      tag_on_failure => ["_grokparsefailure_nginx_access"]
    }
    
    # Parse timestamp
    if "_grokparsefailure_nginx_access" not in [tags] {
      date {
        match => [ "time_local", "dd/MMM/yyyy:HH:mm:ss Z" ]
      }
      
      # Add response time category
      if [status] {
        if [status] >= 500 {
          mutate { add_field => { "log_level" => "error" } }
        } else if [status] >= 400 {
          mutate { add_field => { "log_level" => "warn" } }
        } else {
          mutate { add_field => { "log_level" => "info" } }
        }
      }
    }
    
  } else if [logtype] == "nginx-error" {
    # Parse Nginx error logs
    grok {
      match => { 
        "message" => '%{DATA:timestamp} \[%{DATA:level}\] %{INT:pid}#%{INT:tid}: \*%{INT:connection_id} %{GREEDYDATA:error_message}'
      }
      tag_on_failure => ["_grokparsefailure_nginx_error"]
    }
    
    if "_grokparsefailure_nginx_error" not in [tags] {
      mutate {
        lowercase => [ "level" ]
        add_field => { "log_level" => "%{level}" }
      }
    }
  }

  # Enrich with environment data
  mutate {
    add_field => { 
      "[@metadata][index_prefix]" => "openshift-logs"
      "infrastructure.platform" => "openshift"
      "infrastructure.cluster" => "production-cluster"
    }
  }

  # Geo IP enrichment untuk remote addresses
  if [remote_addr] and [remote_addr] !~ /^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|127\.)/ {
    geoip {
      source => "remote_addr"
      target => "geoip"
    }
  }

  # Security analysis
  if [http_user_agent] {
    if [http_user_agent] =~ /bot|crawler|spider/i {
      mutate { add_tag => ["bot_traffic"] }
    }
    
    if [http_user_agent] =~ /curl|wget|python/i {
      mutate { add_tag => ["api_client"] }
    }
  }

  # Performance analysis
  if [response_time_ms] {
    if [response_time_ms] > 1000 {
      mutate { 
        add_tag => ["slow_response"]
        add_field => { "performance.category" => "slow" }
      }
    } else if [response_time_ms] > 500 {
      mutate { 
        add_field => { "performance.category" => "medium" }
      }
    } else {
      mutate { 
        add_field => { "performance.category" => "fast" }
      }
    }
  }

  # Error categorization
  if [log_level] == "error" {
    if [error] =~ /timeout/i {
      mutate { add_tag => ["timeout_error"] }
    } else if [error] =~ /connection/i {
      mutate { add_tag => ["connection_error"] }
    } else if [error] =~ /database/i {
      mutate { add_tag => ["database_error"] }
    }
  }

  # Clean up unwanted fields
  mutate {
    remove_field => [ "host", "agent", "ecs", "input" ]
  }
}

# ============================== Output ==============================
output {
  # Main Elasticsearch output
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][index_prefix]}-%{+YYYY.MM.dd}"
    template_name => "openshift-logs"
    template_pattern => "openshift-logs-*"
    template => {
      "index_patterns" => ["openshift-logs-*"]
      "settings" => {
        "number_of_shards" => 1
        "number_of_replicas" => 0
        "refresh_interval" => "30s"
      }
      "mappings" => {
        "properties" => {
          "@timestamp" => { "type" => "date" }
          "message" => { "type" => "text", "analyzer" => "standard" }
          "log_level" => { "type" => "keyword" }
          "logtype" => { "type" => "keyword" }
          "service" => { "type" => "keyword" }
          "environment" => { "type" => "keyword" }
          "kubernetes" => {
            "properties" => {
              "pod" => { "properties" => { "name" => { "type" => "keyword" } } }
              "namespace" => { "type" => "keyword" }
              "labels" => { "properties" => { "app" => { "type" => "keyword" } } }
            }
          }
          "geoip" => {
            "properties" => {
              "location" => { "type" => "geo_point" }
              "country_name" => { "type" => "keyword" }
              "city_name" => { "type" => "keyword" }
            }
          }
          "performance" => {
            "properties" => {
              "category" => { "type" => "keyword" }
            }
          }
          "response_time_ms" => { "type" => "integer" }
          "status" => { "type" => "integer" }
        }
      }
    }
  }

  # Error logs ke separate index untuk alerting
  if [log_level] == "error" {
    elasticsearch {
      hosts => ["http://localhost:9200"]
      index => "openshift-errors-%{+YYYY.MM.dd}"
    }
  }

  # Debug output (uncomment untuk debugging)
  # stdout { codec => rubydebug }
}
EOF
```

### 2. Deploy Logstash Configuration

```bash
# Stop default logstash
sudo systemctl stop logstash

# Copy config ke Logstash directory
sudo cp ~/openshift-kafka-elk-demo/logstash-config/openshift-kafka-pipeline.conf /etc/logstash/conf.d/

# Start Logstash dengan new config
sudo systemctl start logstash

# Monitor Logstash logs
sudo tail -f /var/log/logstash/logstash-plain.log
```

---

## Hands-on Log Processing {#hands-on-log-processing}

### 1. Generate Sample Traffic

```bash
# Create traffic generator script
cat > ~/openshift-kafka-elk-demo/generate_traffic.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting traffic generation for OpenShift simulation..."

# URLs untuk testing
URLS=(
  "http://localhost:8081/"
  "http://localhost:8082/"
  "http://localhost:3001/health"
  "http://localhost:3002/health"
  "http://localhost:3001/api/users"
  "http://localhost:3002/api/users"
  "http://localhost:3001/api/orders"
  "http://localhost:3002/api/orders"
)

# Generate traffic for 10 minutes
for i in {1..300}; do
  # Random URL selection
  url=${URLS[$RANDOM % ${#URLS[@]}]}
  
  # Random user agents
  user_agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    "curl/7.68.0"
    "python-requests/2.25.1"
    "PostmanRuntime/7.28.0"
  )
  user_agent=${user_agents[$RANDOM % ${#user_agents[@]}]}
  
  # Make request
  curl -s -A "$user_agent" -w "Status: %{http_code}, Time: %{time_total}s\n" "$url" > /dev/null
  
  echo "[$i/300] Request to $url"
  
  # Random delay between requests
  sleep $(echo "scale=2; $(($RANDOM % 5 + 1)) / 10" | bc)
done

echo "✅ Traffic generation completed!"
EOF

chmod +x ~/openshift-kafka-elk-demo/generate_traffic.sh

# Start traffic generation
~/openshift-kafka-elk-demo/generate_traffic.sh &
```

### 2. Monitor Log Flow

```bash
# Monitor Kafka topic
cd ~/openshift-kafka-elk-demo/kafka/kafka
bin/kafka-console-consumer.sh \
  --topic openshift-logs \
  --bootstrap-server localhost:9092 \
  --property print.key=true \
  --property print.timestamp=true

# Check Elasticsearch indices
curl -X GET "localhost:9200/_cat/indices/openshift-*?v&s=index"

# Check sample documents
curl -X GET "localhost:9200/openshift-logs-*/_search?size=3&pretty"
```

### 3. Verify Data in Kibana

```bash
# Access Kibana
echo "🌐 Access Kibana at: http://localhost:5601"

# Wait for Kibana to be ready
echo "⏳ Waiting for Kibana to start..."
until curl -s -f "http://localhost:5601/api/status" > /dev/null; do
  echo "Still waiting for Kibana..."
  sleep 10
done

echo "✅ Kibana is ready!"
```

---

## Advanced Kibana Analysis {#advanced-kibana-analysis}

### 1. Create Index Patterns

Buka Kibana di browser dan ikuti langkah berikut:

#### A. OpenShift Logs Index Pattern
1. **Stack Management** → **Kibana** → **Data Views**
2. **Create data view**:
   - **Name**: `openshift-logs-*`
   - **Index pattern**: `openshift-logs-*`
   - **Timestamp field**: `@timestamp`
3. **Save data view**

#### B. Error Logs Index Pattern
1. **Create data view**:
   - **Name**: `openshift-errors-*`
   - **Index pattern**: `openshift-errors-*`
   - **Timestamp field**: `@timestamp`

### 2. Create Visualizations

#### A. Log Volume Over Time
```json
{
  "title": "OpenShift Log Volume",
  "type": "line",
  "params": {
    "index": "openshift-logs-*",
    "timeField": "@timestamp",
    "metrics": [
      {
        "type": "count",
        "field": "@timestamp"
      }
    ],
    "buckets": [
      {
        "type": "date_histogram",
        "field": "@timestamp",
        "interval": "auto"
      }
    ]
  }
}
```

#### B. Error Distribution by Service
```json
{
  "title": "Errors by Service",
  "type": "pie",
  "params": {
    "index": "openshift-errors-*",
    "metrics": [
      {
        "type": "count"
      }
    ],
    "buckets": [
      {
        "type": "terms",
        "field": "service.keyword",
        "size": 10
      }
    ]
  }
}
```

### 3. Create Dashboards

#### A. OpenShift Operations Dashboard
1. **Dashboard** → **Create new dashboard**
2. **Add panels**:
   - Log volume timeline
   - Error rate by service
   - Response time distribution
   - Geographic traffic map
   - Top error messages
   - Pod health status

#### B. Security Monitoring Dashboard
1. **Create dashboard** dengan panels:
   - Bot traffic detection
   - Failed authentication attempts
   - Suspicious IP addresses
   - API abuse patterns
   - Security events timeline

### 4. Setup Alerts

#### A. High Error Rate Alert
```yaml
Rule Type: "Index threshold"
Index: "openshift-errors-*"
Conditions:
  - Count of documents IS ABOVE 10
  - FOR THE LAST 5 minutes
Actions:
  - Send email notification
  - Create Slack alert
```

#### B. Service Unavailability Alert
```yaml
Rule Type: "Index threshold"
Index: "openshift-logs-*"
Query: "log_level:error AND message:*timeout*"
Conditions:
  - Count IS ABOVE 5
  - FOR THE LAST 2 minutes
```

---

## Production Considerations {#production-considerations}

### 1. Scalability Configuration

#### A. Kafka Scaling
```bash
# Multiple Kafka brokers
# Edit server.properties for each broker:
broker.id=1  # Unique for each broker
listeners=PLAINTEXT://localhost:9093  # Different ports
log.dirs=/kafka/kafka-logs-1  # Separate log directories

# Create topics with higher replication
bin/kafka-topics.sh --create \
  --topic openshift-logs \
  --bootstrap-server localhost:9092 \
  --partitions 6 \
  --replication-factor 3
```

#### B. Elasticsearch Cluster
```yaml
# elasticsearch.yml untuk production
cluster.name: openshift-elk-cluster
node.name: node-1
node.roles: [ master, data, ingest ]
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
discovery.seed_hosts: ["es-node-1", "es-node-2", "es-node-3"]
cluster.initial_master_nodes: ["node-1", "node-2", "node-3"]

# Enable security
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.http.ssl.enabled: true
```

### 2. Security Hardening

#### A. Kafka Security
```properties
# SASL/SCRAM authentication
security.inter.broker.protocol=SASL_SSL
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-256
sasl.enabled.mechanisms=SCRAM-SHA-256

# SSL configuration
ssl.keystore.location=/kafka/kafka.server.keystore.jks
ssl.keystore.password=password
ssl.key.password=password
ssl.truststore.location=/kafka/kafka.server.truststore.jks
ssl.truststore.password=password
```

#### B. ELK Security
```yaml
# Enable security di elasticsearch.yml
xpack.security.enabled: true
xpack.security.authc:
  realms:
    native:
      native1:
        order: 0

# Setup users
bin/elasticsearch-setup-passwords auto
```

### 3. Performance Optimization

#### A. Kafka Tuning
```properties
# Producer optimization
batch.size=16384
linger.ms=5
compression.type=gzip
acks=1

# Consumer optimization
fetch.min.bytes=1024
fetch.max.wait.ms=500
max.poll.records=500
```

#### B. Logstash Tuning
```yaml
# logstash.yml
pipeline.workers: 4
pipeline.batch.size: 1000
pipeline.batch.delay: 10
```

#### C. Elasticsearch Tuning
```yaml
# Index templates untuk performance
{
  "index_patterns": ["openshift-logs-*"],
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1,
    "refresh_interval": "30s",
    "index.codec": "best_compression",
    "index.merge.scheduler.max_thread_count": 1
  }
}
```

### 4. Monitoring dan Maintenance

#### A. Kafka Monitoring
```bash
# JMX metrics collection
export KAFKA_OPTS="-Dcom.sun.management.jmxremote=true"

# Monitor with Metricbeat Kafka module
metricbeat modules enable kafka
```

#### B. ELK Monitoring
```bash
# Enable monitoring di elasticsearch.yml
xpack.monitoring.enabled: true
xpack.monitoring.collection.enabled: true

# Monitor dengan Metricbeat
metricbeat modules enable elasticsearch kibana logstash
```

### 5. Backup dan Recovery

#### A. Kafka Backup
```bash
# Mirror maker for backup
bin/kafka-mirror-maker.sh \
  --consumer.config consumer.properties \
  --producer.config producer.properties \
  --whitelist "openshift-logs"
```

#### B. Elasticsearch Backup
```bash
# Setup snapshot repository
curl -X PUT "localhost:9200/_snapshot/backup_repository" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/backup/elasticsearch"
  }
}'

# Create snapshot
curl -X PUT "localhost:9200/_snapshot/backup_repository/snapshot_1"
```

---

## Troubleshooting

### 1. Common Issues

#### A. Kafka Connection Issues
```bash
# Check Kafka logs
tail -f ~/openshift-kafka-elk-demo/kafka/kafka/logs/*.log

# Test Kafka connectivity
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

#### B. Logstash Processing Issues
```bash
# Check Logstash logs
sudo tail -f /var/log/logstash/logstash-plain.log

# Test configuration
sudo /usr/share/logstash/bin/logstash --config.test_and_exit \
  -f /etc/logstash/conf.d/openshift-kafka-pipeline.conf
```

#### C. Elasticsearch Ingestion Issues
```bash
# Check cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Check indices status
curl -X GET "localhost:9200/_cat/indices?v"

# Check for rejected documents
curl -X GET "localhost:9200/_nodes/stats/thread_pool?pretty"
```

### 2. Performance Issues

#### A. High Memory Usage
```bash
# Check Java heap usage
jstat -gc $(pgrep -f elasticsearch) 5s

# Adjust heap size
export ES_JAVA_OPTS="-Xms2g -Xmx2g"
```

#### B. Slow Query Performance
```bash
# Enable slow query log
curl -X PUT "localhost:9200/openshift-logs-*/_settings" -H 'Content-Type: application/json' -d'
{
  "index.search.slowlog.threshold.query.warn": "2s",
  "index.search.slowlog.threshold.query.info": "1s"
}'
```

---

## Kesimpulan

Tutorial ini mendemonstrasikan implementasi modern log monitoring pipeline dengan:

### ✅ **Achievements:**
- **Scalable Architecture**: Kafka sebagai message broker untuk high-throughput
- **Real-time Processing**: Logstash dengan advanced filtering dan enrichment
- **Modern ELK v8**: Latest features dan security improvements
- **Production Ready**: Security, monitoring, dan performance considerations

### 🚀 **Key Benefits:**
- **Fault Tolerance**: Kafka provides durability dan replay capability
- **Scalability**: Easy horizontal scaling untuk semua components
- **Flexibility**: Rich data processing dengan Logstash filters
- **Observability**: Comprehensive monitoring dengan Kibana dashboards

### 📚 **Next Steps:**
1. **Scale to Production**: Implement cluster setup untuk all components
2. **Security Hardening**: Enable SSL/TLS dan authentication
3. **Advanced Analytics**: Machine learning anomaly detection
4. **Integration**: Connect dengan alert management systems

Happy Monitoring! 🎉
