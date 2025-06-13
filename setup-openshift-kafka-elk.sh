#!/bin/bash
set -e

echo "=================================================================="
echo "🚀 OpenShift + Kafka + ELK v8 Demo Setup Script"
echo "=================================================================="
echo ""
echo "This script will setup a complete modern log monitoring pipeline:"
echo "  OpenShift Simulation → Kafka → Logstash → Elasticsearch → Kibana"
echo ""

# Check if running as root
if [ "$(id -u)" == "0" ]; then
  echo "❌ Please do not run this script as root. Use sudo when needed."
  exit 1
fi

# Variables
PROJECT_DIR="$HOME/openshift-kafka-elk-demo"
KAFKA_VERSION="2.8.0"
SCALA_VERSION="2.13"

echo "📁 Project directory: $PROJECT_DIR"
echo ""

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
            echo "✅ $service_name is ready!"
            return 0
        fi
        echo "   Attempt $attempt/$max_attempts - waiting..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "❌ $service_name failed to start after $max_attempts attempts"
    return 1
}

# Step 1: Prerequisites check
echo "🔍 Step 1: Checking prerequisites..."

# Check Java
if ! command_exists java; then
    echo "Installing Java 17..."
    sudo apt update
    sudo apt install -y openjdk-17-jdk
else
    echo "✅ Java is installed"
fi

# Check Docker
if ! command_exists docker; then
    echo "Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io docker-compose
    sudo usermod -aG docker $USER
    echo "⚠️  Please log out and log back in to use Docker without sudo"
else
    echo "✅ Docker is installed"
fi

# Check other tools
echo "Installing additional tools..."
sudo apt update
sudo apt install -y curl wget unzip jq netcat bc npm

# Step 2: Create project structure
echo ""
echo "📁 Step 2: Creating project structure..."

mkdir -p "$PROJECT_DIR"/{kafka,elk-config,openshift-sim,beats-config,logstash-config}
cd "$PROJECT_DIR"

echo "✅ Project structure created"

# Step 3: Install Kafka
echo ""
echo "📦 Step 3: Installing Apache Kafka..."

cd "$PROJECT_DIR/kafka"

if [ ! -d "kafka" ]; then
    echo "Downloading Kafka ${KAFKA_VERSION}..."
    wget -q "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    mv "kafka_${SCALA_VERSION}-${KAFKA_VERSION}" kafka
    rm "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    
    # Create data directories
    mkdir -p kafka/logs/{kafka,zookeeper}
    
    echo "✅ Kafka downloaded and extracted"
else
    echo "✅ Kafka already exists"
fi

# Configure Kafka
echo "Configuring Kafka..."

cat > kafka/kafka/config/server.properties << EOF
broker.id=0
listeners=PLAINTEXT://localhost:9092
advertised.listeners=PLAINTEXT://localhost:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

log.dirs=$PROJECT_DIR/kafka/kafka/logs/kafka
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

cat > kafka/kafka/config/zookeeper.properties << EOF
dataDir=$PROJECT_DIR/kafka/kafka/logs/zookeeper
clientPort=2181
maxClientCnxns=0
admin.enableServer=false
EOF

echo "✅ Kafka configured"

# Step 4: Install ELK Stack
echo ""
echo "🔍 Step 4: Installing ELK Stack v8..."

# Check if ELK is already installed
if ! command_exists elasticsearch || ! command_exists kibana || ! command_exists logstash; then
    echo "Installing ELK Stack v8..."
    
    if [ -f "$HOME/elk-tutorial-wsl/install_elk_v8_latest_wsl.sh" ]; then
        cd "$HOME/elk-tutorial-wsl"
        chmod +x install_elk_v8_latest_wsl.sh
        ./install_elk_v8_latest_wsl.sh
    else
        echo "❌ ELK installation script not found. Please install ELK Stack v8 manually."
        exit 1
    fi
else
    echo "✅ ELK Stack is already installed"
fi

# Step 5: Setup OpenShift simulation
echo ""
echo "🐳 Step 5: Setting up OpenShift simulation..."

cd "$PROJECT_DIR/openshift-sim"

# Create Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
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
EOF

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

# Create Node.js API
cat > api-app/server.js << 'EOF'
const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;
const podName = process.env.POD_NAME || 'unknown-pod';
const namespace = process.env.NAMESPACE || 'default';
const appName = process.env.APP_NAME || 'unknown-app';

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
    
    fs.appendFileSync(
        path.join('/app/logs', `${podName}.log`),
        JSON.stringify(logEntry) + '\n'
    );
    
    console.log(JSON.stringify(logEntry));
    next();
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy', pod: podName, timestamp: new Date().toISOString() });
});

app.get('/api/users', (req, res) => {
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

echo "✅ OpenShift simulation configured"

# Step 6: Configure Filebeat for Kafka
echo ""
echo "📄 Step 6: Configuring Filebeat for Kafka output..."

cd "$PROJECT_DIR/beats-config"

cat > filebeat-kafka.yml << EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - $PROJECT_DIR/openshift-sim/logs/*.log
  fields:
    logtype: openshift-app
    environment: production
  fields_under_root: true
  json.keys_under_root: true
  json.add_error_key: true

- type: log
  enabled: true
  paths:
    - $PROJECT_DIR/openshift-sim/logs/*-access.log
  fields:
    logtype: nginx-access
    service: web-frontend
  fields_under_root: true

- type: log
  enabled: true
  paths:
    - $PROJECT_DIR/openshift-sim/logs/*-error.log
  fields:
    logtype: nginx-error
    service: web-frontend
  fields_under_root: true

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_fields:
      target: pipeline
      fields:
        source: openshift-cluster
        datacenter: aws-east-1
        environment: production

output.kafka:
  enabled: true
  hosts: ["localhost:9092"]
  topic: "openshift-logs"
  partition.round_robin:
    reachable_only: false
  required_acks: 1
  compression: gzip
  max_message_bytes: 1048576
  codec.json:
    pretty: false
    escape_html: false

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat-kafka.log
  keepfiles: 7
  permissions: 0644

monitoring.enabled: true
http.enabled: true
http.host: localhost
http.port: 5066
EOF

echo "✅ Filebeat configured for Kafka output"

# Step 7: Configure Logstash for Kafka input
echo ""
echo "🔄 Step 7: Configuring Logstash for Kafka input..."

cd "$PROJECT_DIR/logstash-config"

cat > openshift-kafka-pipeline.conf << 'EOF'
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

filter {
  mutate {
    add_field => { "[@metadata][kafka_topic]" => "%{[@metadata][kafka][topic]}" }
    add_field => { "[@metadata][kafka_partition]" => "%{[@metadata][kafka][partition]}" }
    add_field => { "[@metadata][kafka_offset]" => "%{[@metadata][kafka][offset]}" }
  }

  if [logtype] == "openshift-app" {
    if [level] {
      mutate {
        lowercase => [ "level" ]
        add_field => { "log_level" => "%{level}" }
      }
    }
    
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
    grok {
      match => { 
        "message" => '%{IPORHOST:remote_addr} - %{DATA:remote_user} \[%{HTTPDATE:time_local}\] "%{WORD:method} %{DATA:request} HTTP/%{NUMBER:http_version}" %{INT:status} %{INT:body_bytes_sent} "%{DATA:http_referer}" "%{DATA:http_user_agent}"'
      }
      tag_on_failure => ["_grokparsefailure_nginx_access"]
    }
    
    if "_grokparsefailure_nginx_access" not in [tags] {
      date {
        match => [ "time_local", "dd/MMM/yyyy:HH:mm:ss Z" ]
      }
      
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

  mutate {
    add_field => { 
      "[@metadata][index_prefix]" => "openshift-logs"
      "infrastructure.platform" => "openshift"
      "infrastructure.cluster" => "production-cluster"
    }
  }

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

  if [log_level] == "error" {
    if [error] =~ /timeout/i {
      mutate { add_tag => ["timeout_error"] }
    } else if [error] =~ /connection/i {
      mutate { add_tag => ["connection_error"] }
    } else if [error] =~ /database/i {
      mutate { add_tag => ["database_error"] }
    }
  }

  mutate {
    remove_field => [ "host", "agent", "ecs", "input" ]
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][index_prefix]}-%{+YYYY.MM.dd}"
  }

  if [log_level] == "error" {
    elasticsearch {
      hosts => ["http://localhost:9200"]
      index => "openshift-errors-%{+YYYY.MM.dd}"
    }
  }
}
EOF

echo "✅ Logstash configured for Kafka input"

# Step 8: Create startup scripts
echo ""
echo "📝 Step 8: Creating startup scripts..."

# Kafka startup script
cat > "$PROJECT_DIR/start-kafka.sh" << EOF
#!/bin/bash
echo "🚀 Starting Kafka services..."

cd "$PROJECT_DIR/kafka/kafka"

# Start Zookeeper
echo "Starting Zookeeper..."
bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
ZOOKEEPER_PID=\$!

sleep 10

# Start Kafka
echo "Starting Kafka..."
bin/kafka-server-start.sh config/server.properties > /dev/null 2>&1 &
KAFKA_PID=\$!

sleep 15

# Create topics
echo "Creating Kafka topics..."
bin/kafka-topics.sh --create --topic openshift-logs --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || echo "Topic might already exist"

echo "✅ Kafka services started"
echo "   Zookeeper PID: \$ZOOKEEPER_PID"
echo "   Kafka PID: \$KAFKA_PID"
echo ""
echo "📊 Topics created:"
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
EOF

# OpenShift startup script
cat > "$PROJECT_DIR/start-openshift-sim.sh" << EOF
#!/bin/bash
echo "🐳 Starting OpenShift simulation..."

cd "$PROJECT_DIR/openshift-sim"

# Install NPM dependencies
echo "Installing Node.js dependencies..."
cd api-app && npm install --silent && cd ..

# Start containers
echo "Starting Docker containers..."
docker-compose up -d

echo "✅ OpenShift simulation started"
echo ""
echo "🌐 Services available at:"
echo "   Web App 1: http://localhost:8081"
echo "   Web App 2: http://localhost:8082"
echo "   API App 1: http://localhost:3001"
echo "   API App 2: http://localhost:3002"
EOF

# Traffic generator script
cat > "$PROJECT_DIR/generate-traffic.sh" << 'EOF'
#!/bin/bash
echo "🚀 Starting traffic generation..."

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

for i in {1..100}; do
  url=${URLS[$RANDOM % ${#URLS[@]}]}
  curl -s "$url" > /dev/null
  echo "[$i/100] Request to $url"
  sleep $(echo "scale=2; $(($RANDOM % 3 + 1)) / 10" | bc)
done

echo "✅ Traffic generation completed!"
EOF

# Complete startup script
cat > "$PROJECT_DIR/start-demo.sh" << EOF
#!/bin/bash
echo "=================================================================="
echo "🚀 Starting OpenShift + Kafka + ELK Demo"
echo "=================================================================="

# Start Kafka
echo "1️⃣  Starting Kafka..."
bash "$PROJECT_DIR/start-kafka.sh"
echo ""

# Wait for Kafka
if wait_for_service "Kafka" 9092; then
    echo ""
else
    echo "❌ Failed to start Kafka"
    exit 1
fi

# Start ELK services
echo "2️⃣  Starting ELK services..."
sudo systemctl start elasticsearch
sudo systemctl start kibana  
sudo systemctl stop logstash  # Stop default logstash

# Deploy custom Logstash config
sudo cp "$PROJECT_DIR/logstash-config/openshift-kafka-pipeline.conf" /etc/logstash/conf.d/
sudo systemctl start logstash

echo ""

# Wait for Elasticsearch
if wait_for_service "Elasticsearch" 9200; then
    echo ""
else
    echo "❌ Failed to start Elasticsearch"
    exit 1
fi

# Start OpenShift simulation
echo "3️⃣  Starting OpenShift simulation..."
bash "$PROJECT_DIR/start-openshift-sim.sh"
echo ""

# Wait for applications
sleep 30

# Start Filebeat with Kafka output
echo "4️⃣  Starting Filebeat with Kafka output..."
sudo systemctl stop filebeat 2>/dev/null || true
sudo filebeat -e -c "$PROJECT_DIR/beats-config/filebeat-kafka.yml" > /dev/null 2>&1 &
echo "✅ Filebeat started with Kafka output"
echo ""

echo "=================================================================="
echo "🎉 Demo is ready!"
echo "=================================================================="
echo ""
echo "🌐 Access points:"
echo "   • Kibana: http://localhost:5601"
echo "   • Elasticsearch: http://localhost:9200"
echo "   • Web Apps: http://localhost:8081, http://localhost:8082"
echo "   • API Apps: http://localhost:3001, http://localhost:3002"
echo ""
echo "📊 To generate traffic:"
echo "   bash $PROJECT_DIR/generate-traffic.sh"
echo ""
echo "📚 Check the tutorial: hands-on-openshift-kafka-elk-v8.md"
echo "=================================================================="
EOF

# Make all scripts executable
chmod +x "$PROJECT_DIR"/*.sh

echo "✅ Startup scripts created"

# Step 9: Final setup
echo ""
echo "🎯 Step 9: Final setup..."

echo "Installing Node.js dependencies..."
cd "$PROJECT_DIR/openshift-sim/api-app"
npm install --silent

echo ""
echo "=================================================================="
echo "✅ Setup completed successfully!"
echo "=================================================================="
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo ""
echo "🚀 To start the demo:"
echo "   cd $PROJECT_DIR"
echo "   bash start-demo.sh"
echo ""
echo "📚 Full tutorial available in:"
echo "   hands-on-openshift-kafka-elk-v8.md"
echo ""
echo "🌐 After starting, access:"
echo "   • Kibana: http://localhost:5601"
echo "   • Elasticsearch: http://localhost:9200"
echo ""
echo "Happy monitoring! 🎉"
echo "=================================================================="
