#!/bin/bash
set -e # Keluar segera jika sebuah perintah keluar dengan status non-nol.

ELK_VERSION="8.15.0" # Versi ELK terbaru (Juni 2025)

echo "===== Skrip Instalasi ELK Stack v${ELK_VERSION} untuk WSL Ubuntu ====="
echo "Script ini akan menginstal Elasticsearch, Logstash, Kibana, dan Beats dengan konfigurasi modern"

# 0. Periksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" == "0" ]; then
  echo "❌ Skrip ini sebaiknya tidak dijalankan sebagai root. Gunakan sudo jika diperlukan oleh perintah individual."
  exit 1
fi

# 1. Perbarui sistem dan instal prasyarat
echo ">>> ⚙️  Memperbarui sistem dan menginstal prasyarat..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl wget lsb-release

# 2. Tambahkan Kunci PGP Elastic (metode modern)
echo ">>> 🔐 Menambahkan Kunci PGP Elastic..."
# Hapus kunci lama jika ada
sudo rm -f /etc/apt/trusted.gpg.d/elastic-*.gpg /usr/share/keyrings/elasticsearch-keyring.gpg

# Download dan install GPG key dengan metode modern
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# 3. Tambahkan Repositori Elastic untuk versi 8.x
echo ">>> 📦 Menambahkan repositori Elastic untuk versi 8.x..."
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# 4. Update package list
echo ">>> 🔄 Memperbarui daftar paket..."
sudo apt-get update

# 5. Install Elasticsearch
echo ">>> 🔍 Menginstal Elasticsearch v${ELK_VERSION}..."
sudo apt-get install -y elasticsearch=${ELK_VERSION}

# Konfigurasi Elasticsearch untuk development
echo ">>> ⚙️  Mengkonfigurasi Elasticsearch untuk lingkungan development..."

# Backup konfigurasi asli
sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.backup

# Buat konfigurasi development-friendly
sudo tee /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOF
# ======================== Elasticsearch Configuration =========================
cluster.name: elk-tutorial-cluster
node.name: elk-tutorial-node
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node

# ======================== Security Configuration =========================
# Disable security for development (TIDAK untuk production!)
xpack.security.enabled: false
xpack.security.enrollment.enabled: false
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false

# ======================== Memory & Performance =========================
bootstrap.memory_lock: false
indices.query.bool.max_clause_count: 10000
EOF

# Konfigurasi JVM untuk WSL (memory-friendly)
echo ">>> 💾 Mengkonfigurasi JVM Elasticsearch untuk WSL..."
sudo sed -i 's/^-Xms.*/-Xms1g/' /etc/elasticsearch/jvm.options
sudo sed -i 's/^-Xmx.*/-Xmx1g/' /etc/elasticsearch/jvm.options

# 6. Install Kibana
echo ">>> 📊 Menginstal Kibana v${ELK_VERSION}..."
sudo apt-get install -y kibana=${ELK_VERSION}

# Konfigurasi Kibana
echo ">>> ⚙️  Mengkonfigurasi Kibana..."
sudo cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.backup

sudo tee /etc/kibana/kibana.yml > /dev/null <<EOF
# ======================== Kibana Configuration =========================
server.port: 5601
server.host: "0.0.0.0"
server.name: "elk-tutorial-kibana"

# ======================== Elasticsearch Configuration =========================
elasticsearch.hosts: ["http://localhost:9200"]

# ======================== Development Settings =========================
# Disable security untuk development
elasticsearch.ssl.verificationMode: none
xpack.security.enabled: false
xpack.encryptedSavedObjects.encryptionKey: "fhjskloppd678ehkdfdlliverpoolfcr"

# ======================== Logging =========================
logging.appenders.file.type: file
logging.appenders.file.fileName: /var/log/kibana/kibana.log
logging.appenders.file.layout.type: json
logging.root.level: info
EOF

# 7. Install Logstash
echo ">>> 🔄 Menginstal Logstash v${ELK_VERSION}..."
sudo apt-get install -y logstash=1:${ELK_VERSION}-1

# Konfigurasi JVM Logstash untuk WSL
echo ">>> ⚙️  Mengkonfigurasi JVM Logstash untuk WSL..."
sudo sed -i 's/^-Xms.*/-Xms512m/' /etc/logstash/jvm.options
sudo sed -i 's/^-Xmx.*/-Xmx512m/' /etc/logstash/jvm.options

# Buat konfigurasi pipeline dasar untuk Logstash
echo ">>> 📝 Membuat konfigurasi pipeline Logstash..."
sudo mkdir -p /etc/logstash/conf.d
sudo tee /etc/logstash/conf.d/01-basic-pipeline.conf > /dev/null <<EOF
input {
  beats {
    port => 5044
  }
}

filter {
  if [agent][type] == "filebeat" {
    # Parse common log formats
    grok {
      match => { "message" => "\[%{TIMESTAMP_ISO8601:log_timestamp}\] %{LOGLEVEL:log_level}: %{GREEDYDATA:log_message}" }
      tag_on_failure => ["_grokparsefailure_basic"]
    }
    
    # Parse timestamp
    if "_grokparsefailure_basic" not in [tags] {
      date {
        match => [ "log_timestamp", "yyyy-MM-dd HH:mm:ss,SSS", "ISO8601" ]
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
  }
  
  # Debug output (optional)
  # stdout { codec => rubydebug }
}
EOF

# 8. Install Filebeat
echo ">>> 📄 Menginstal Filebeat v${ELK_VERSION}..."
sudo apt-get install -y filebeat=${ELK_VERSION}

# 9. Install Metricbeat
echo ">>> 📈 Menginstal Metricbeat v${ELK_VERSION}..."
sudo apt-get install -y metricbeat=${ELK_VERSION}

# 10. Install Heartbeat
echo ">>> 💓 Menginstal Heartbeat v${ELK_VERSION}..."
sudo apt-get install -y heartbeat-elastic=${ELK_VERSION}

# 11. Install APM Server (optional, versi 8.x integrated)
echo ">>> 🔍 Menginstal APM Server v${ELK_VERSION}..."
sudo apt-get install -y apm-server=${ELK_VERSION}

# Konfigurasi APM Server dasar
sudo tee /etc/apm-server/apm-server.yml > /dev/null <<EOF
apm-server:
  host: "localhost:8200"
  
output.elasticsearch:
  hosts: ["localhost:9200"]
  
setup.kibana:
  host: "localhost:5601"
EOF

# 12. Setup systemd services
echo ">>> 🚀 Mengkonfigurasi dan memulai services..."

# Elasticsearch
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
echo "Starting Elasticsearch..."
sudo systemctl start elasticsearch.service

# Tunggu Elasticsearch ready
echo "Menunggu Elasticsearch siap..."
sleep 30

# Kibana
sudo systemctl enable kibana.service
echo "Starting Kibana..."
sudo systemctl start kibana.service

# Logstash
sudo systemctl enable logstash.service
echo "Starting Logstash..."
sudo systemctl start logstash.service

# APM Server
sudo systemctl enable apm-server.service
echo "Starting APM Server..."
sudo systemctl start apm-server.service

# Enable beats (tapi jangan start otomatis - konfigurasi manual nanti)
sudo systemctl enable filebeat.service
sudo systemctl enable metricbeat.service
sudo systemctl enable heartbeat-elastic.service

# 13. Tunggu semua services startup
echo ">>> ⏳ Menunggu semua services untuk inisialisasi..."
sleep 60

# 14. Setup index templates dan dashboards
echo ">>> 📋 Setting up index templates dan dashboards..."

# Setup Metricbeat
sudo metricbeat setup --dashboards --template -e || echo "Metricbeat setup warning (normal untuk first run)"

# Setup Filebeat  
sudo filebeat setup --dashboards --template -e || echo "Filebeat setup warning (normal untuk first run)"

# Setup Heartbeat
sudo heartbeat setup --dashboards --template -e || echo "Heartbeat setup warning (normal untuk first run)"

# Setup APM
sudo apm-server setup --dashboards --template -e || echo "APM Server setup warning (normal untuk first run)"

# 15. Verifikasi instalasi
echo ""
echo "===== 🔍 Pemeriksaan Status Services ====="

# Function untuk check service health
check_service() {
    local service_name=$1
    local display_name=$2
    
    if sudo systemctl is-active --quiet $service_name; then
        echo "✅ $display_name: AKTIF"
        return 0
    else
        echo "❌ $display_name: TIDAK AKTIF"
        echo "   Cek log: sudo journalctl -u $service_name -n 20"
        return 1
    fi
}

# Check semua services
check_service "elasticsearch" "Elasticsearch"
check_service "kibana" "Kibana"
check_service "logstash" "Logstash"
check_service "apm-server" "APM Server"

echo ""
echo "===== 🌐 Pemeriksaan Konektivitas ====="

# Test Elasticsearch
echo "Testing Elasticsearch..."
if curl -s -f "http://localhost:9200" > /dev/null; then
    echo "✅ Elasticsearch (port 9200): RESPONSIF"
    ES_VERSION=$(curl -s "http://localhost:9200" | grep -o '"number" : "[^"]*"' | cut -d'"' -f4)
    echo "   Version: $ES_VERSION"
else
    echo "❌ Elasticsearch (port 9200): TIDAK RESPONSIF"
fi

# Test Kibana
echo "Testing Kibana..."
if curl -s -f "http://localhost:5601/api/status" > /dev/null; then
    echo "✅ Kibana (port 5601): RESPONSIF"
else
    echo "⚠️  Kibana (port 5601): Masih starting up atau ada masalah"
    echo "   Tunggu beberapa menit dan coba akses http://localhost:5601"
fi

# Test APM Server
echo "Testing APM Server..."
if curl -s -f "http://localhost:8200" > /dev/null; then
    echo "✅ APM Server (port 8200): RESPONSIF"
else
    echo "❌ APM Server (port 8200): TIDAK RESPONSIF"
fi

echo ""
echo "===== 📊 Status Beat Agents ====="
echo "ℹ️  Beat agents telah diinstall tapi belum dikonfigurasi:"
echo "   • Filebeat: sudo systemctl start filebeat (setelah konfigurasi)"
echo "   • Metricbeat: sudo systemctl start metricbeat (setelah konfigurasi)"  
echo "   • Heartbeat: sudo systemctl start heartbeat-elastic (setelah konfigurasi)"

echo ""
echo "===== 🎉 Instalasi ELK Stack v${ELK_VERSION} Selesai! ====="
echo ""
echo "🌐 Web Interfaces:"
echo "   • Kibana: http://localhost:5601"
echo "   • Elasticsearch: http://localhost:9200"
echo "   • APM Server: http://localhost:8200"
echo ""
echo "📁 Lokasi Konfigurasi:"
echo "   • Elasticsearch: /etc/elasticsearch/elasticsearch.yml"
echo "   • Kibana: /etc/kibana/kibana.yml"
echo "   • Logstash: /etc/logstash/conf.d/"
echo "   • APM Server: /etc/apm-server/apm-server.yml"
echo "   • Filebeat: /etc/filebeat/filebeat.yml"
echo "   • Metricbeat: /etc/metricbeat/metricbeat.yml"
echo "   • Heartbeat: /etc/heartbeat/heartbeat.yml"
echo ""
echo "📚 Next Steps:"
echo "   1. Akses Kibana di http://localhost:5601"
echo "   2. Konfigurasi Beat agents sesuai kebutuhan"
echo "   3. Import sample data atau setup data sources"
echo "   4. Explore Observability features!"
echo ""
echo "⚠️  PENTING: Konfigurasi ini untuk DEVELOPMENT only!"
echo "   Untuk production, enable security dan sesuaikan pengaturan."
echo ""
echo "📖 Dokumentasi lengkap tersedia di hands-on-observability-kibana.md"
echo ""
echo "Happy Monitoring! 🚀"
