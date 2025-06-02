#!/bin/bash
set -e # Keluar segera jika sebuah perintah keluar dengan status non-nol.

ELK_VERSION="7.17.28" # Tentukan versi ELK

echo "===== Skrip Instalasi ELK Stack v${ELK_VERSION} untuk WSL Ubuntu ====="

# 0. Periksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" == "0" ]; then
  echo "Skrip ini sebaiknya tidak dijalankan sebagai root. Gunakan sudo jika diperlukan oleh perintah individual."
  exit 1
fi

# 1. Perbarui daftar paket dan instal prasyarat
echo ">>> Memperbarui daftar paket dan menginstal prasyarat (apt-transport-https, gnupg)..."
sudo apt-get update
sudo apt-get install -y apt-transport-https gnupg curl

# 2. Tambahkan Kunci PGP Elastic
echo ">>> Menambahkan Kunci PGP Elastic..."
# Hapus metode lama jika ada file kunci lama dari apt-key
sudo rm -f /etc/apt/trusted.gpg.d/elastic-key.gpg
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# 3. Tambahkan Repositori Elastic
echo ">>> Menambahkan repositori Elastic untuk versi 7.x..."
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

# 4. Perbarui daftar paket lagi setelah menambahkan repo baru
echo ">>> Memperbarui daftar paket lagi..."
sudo apt-get update

# 5. Instal Elasticsearch
echo ">>> Menginstal Elasticsearch versi ${ELK_VERSION}..."
sudo apt-get install -y elasticsearch=${ELK_VERSION}
echo ">>> Mengkonfigurasi Elasticsearch (jvm.options untuk WSL - contoh, sesuaikan jika perlu)..."
# Pengaturan memori dasar untuk WSL, bisa disesuaikan.
# Default adalah 1g, mungkin terlalu besar untuk beberapa setup WSL.
# Atur ke 512m sebagai default yang lebih aman untuk lingkungan tutorial.
sudo sed -i 's/^-Xms[0-9]\+[gmk]$/-Xms512m/' /etc/elasticsearch/jvm.options
sudo sed -i 's/^-Xmx[0-9]\+[gmk]$/-Xmx512m/' /etc/elasticsearch/jvm.options
echo ">>> Mengaktifkan dan memulai layanan Elasticsearch..."
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# 6. Instal Logstash
echo ">>> Menginstal Logstash versi ${ELK_VERSION}..."
sudo apt-get install -y logstash=1:${ELK_VERSION}-1 # Assuming Logstash still needs the epoch
echo ">>> Mengkonfigurasi Logstash (jvm.options untuk WSL - contoh)..."
sudo sed -i 's/^-Xms[0-9]\+[gmk]$/-Xms512m/' /etc/logstash/jvm.options
sudo sed -i 's/^-Xmx[0-9]\+[gmk]$/-Xmx512m/' /etc/logstash/jvm.options
echo ">>> Mengaktifkan dan memulai layanan Logstash..."
sudo systemctl enable logstash.service
sudo systemctl start logstash.service

# 7. Instal Kibana
echo ">>> Menginstal Kibana versi ${ELK_VERSION}..."
sudo apt-get install -y kibana=${ELK_VERSION}
echo ">>> Mengkonfigurasi Kibana (server.host agar bisa diakses dari host Windows)..."
sudo sed -i 's/^#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
echo ">>> Mengaktifkan dan memulai layanan Kibana..."
sudo systemctl enable kibana.service
sudo systemctl start kibana.service

# 8. Instal Filebeat
echo ">>> Menginstal Filebeat versi ${ELK_VERSION}..."
sudo apt-get install -y filebeat=${ELK_VERSION}
echo ">>> Mengaktifkan layanan Filebeat (biasanya dikonfigurasi dan dimulai secara manual nanti)..."
sudo systemctl enable filebeat.service
sudo systemctl start filebeat.service # Biasanya dimulai dengan konfigurasi kustom

# 9. Tunggu layanan dimulai dan periksa status
echo ">>> Menunggu layanan untuk inisialisasi (ini mungkin memakan waktu beberapa menit)..."
sleep 90 # Waktu tunggu yang lebih lama untuk memastikan layanan siap

echo "===== Pemeriksaan Status ====="
echo ">>> Status Elasticsearch:"
if sudo systemctl is-active --quiet elasticsearch; then
    echo "Elasticsearch aktif dan berjalan."
    echo ">>> Verifikasi Elasticsearch dengan curl (localhost:9200):"
    if curl -s -X GET "localhost:9200" | grep -q "You Know, for Search"; then
        echo "Elasticsearch merespons dengan benar."
    else
        echo "Gagal mendapatkan respons yang diharapkan dari Elasticsearch di localhost:9200."
    fi
else
    echo "Elasticsearch TIDAK aktif. Periksa log: sudo journalctl -u elasticsearch -n 50 --no-pager"
fi

echo ">>> Status Logstash:"
if sudo systemctl is-active --quiet logstash; then
    echo "Logstash aktif dan berjalan."
else
    echo "Logstash TIDAK aktif. Periksa log: sudo journalctl -u logstash -n 50 --no-pager"
fi

echo ">>> Status Kibana:"
if sudo systemctl is-active --quiet kibana; then
    echo "Kibana aktif dan berjalan."
    echo ">>> Verifikasi Kibana (localhost:5601):"
    if curl -s -I "http://localhost:5601/api/status" | grep -q "HTTP/1.1 200 OK"; then
        echo "Kibana merespons dengan benar."
    else
        echo "Gagal mendapatkan respons yang diharapkan dari Kibana di localhost:5601. Mungkin masih memulai."
        echo "Periksa log Kibana: sudo journalctl -u kibana -n 50 --no-pager"
    fi
else
    echo "Kibana TIDAK aktif. Periksa log: sudo journalctl -u kibana -n 50 --no-pager"
fi

echo ">>> Status Filebeat:"
if sudo systemctl is-active --quiet filebeat; then
    echo "Filebeat aktif dan berjalan (meskipun mungkin belum dikonfigurasi)."
else
    echo "Filebeat TIDAK aktif atau belum dimulai. Ini normal jika Anda belum memulainya secara manual."
fi

echo "===== Upaya Instalasi Selesai ====="
echo "Jika semua layanan berjalan, Anda dapat mengakses Kibana di http://localhost:5601 dari browser mesin host Anda."
echo "Ingatlah untuk mengkonfigurasi Filebeat (misalnya, /etc/filebeat/filebeat.yml) untuk menunjuk ke log Anda dan Elasticsearch/Logstash."
echo "Untuk tutorial langsung, Anda kemungkinan akan menggunakan konfigurasi Filebeat kustom."
echo ""
echo "Untuk menjalankan skrip ini, simpan sebagai \'install_elk_v7.17.28_wsl.sh\', berikan izin eksekusi (chmod +x install_elk_v7.17.28_wsl.sh), lalu jalankan dengan ./install_elk_v7.17.28_wsl.sh"
