#!/bin/bash
set -e # Keluar segera jika sebuah perintah keluar dengan status non-nol.

echo "===== Script Uninstall ELK Stack untuk WSL Ubuntu ====="
echo "PERINGATAN: Script ini akan menghapus semua komponen ELK Stack dan data yang terkait!"
read -p "Apakah Anda yakin ingin melanjutkan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall dibatalkan."
    exit 1
fi

# 0. Periksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" == "0" ]; then
  echo "Skrip ini sebaiknya tidak dijalankan sebagai root. Gunakan sudo jika diperlukan oleh perintah individual."
  exit 1
fi

echo ">>> Memulai proses uninstall ELK Stack..."

# 1. Stop semua service ELK
echo ">>> Menghentikan semua service ELK..."
sudo systemctl stop filebeat.service || echo "Filebeat sudah tidak aktif"
sudo systemctl stop kibana.service || echo "Kibana sudah tidak aktif"
sudo systemctl stop logstash.service || echo "Logstash sudah tidak aktif"
sudo systemctl stop elasticsearch.service || echo "Elasticsearch sudah tidak aktif"

# 2. Disable semua service ELK
echo ">>> Mendisable semua service ELK..."
sudo systemctl disable filebeat.service || echo "Filebeat sudah tidak enabled"
sudo systemctl disable kibana.service || echo "Kibana sudah tidak enabled"
sudo systemctl disable logstash.service || echo "Logstash sudah tidak enabled"
sudo systemctl disable elasticsearch.service || echo "Elasticsearch sudah tidak enabled"

# 3. Uninstall paket ELK
echo ">>> Menguninstall paket Filebeat..."
sudo apt-get remove --purge -y filebeat || echo "Filebeat tidak terinstall"

echo ">>> Menguninstall paket Kibana..."
sudo apt-get remove --purge -y kibana || echo "Kibana tidak terinstall"

echo ">>> Menguninstall paket Logstash..."
sudo apt-get remove --purge -y logstash || echo "Logstash tidak terinstall"

echo ">>> Menguninstall paket Elasticsearch..."
sudo apt-get remove --purge -y elasticsearch || echo "Elasticsearch tidak terinstall"

# 4. Hapus direktori konfigurasi dan data
echo ">>> Menghapus direktori konfigurasi dan data..."
sudo rm -rf /etc/elasticsearch
sudo rm -rf /etc/logstash
sudo rm -rf /etc/kibana
sudo rm -rf /etc/filebeat

echo ">>> Menghapus direktori data..."
sudo rm -rf /var/lib/elasticsearch
sudo rm -rf /var/lib/logstash
sudo rm -rf /var/lib/kibana
sudo rm -rf /var/lib/filebeat

echo ">>> Menghapus direktori log..."
sudo rm -rf /var/log/elasticsearch
sudo rm -rf /var/log/logstash
sudo rm -rf /var/log/kibana
sudo rm -rf /var/log/filebeat

echo ">>> Menghapus direktori instalasi..."
sudo rm -rf /usr/share/elasticsearch
sudo rm -rf /usr/share/logstash
sudo rm -rf /usr/share/kibana
sudo rm -rf /usr/share/filebeat

# 5. Hapus user ELK
echo ">>> Menghapus user ELK..."
sudo userdel -r elasticsearch 2>/dev/null || echo "User elasticsearch tidak ada"
sudo userdel -r logstash 2>/dev/null || echo "User logstash tidak ada"
sudo userdel -r kibana 2>/dev/null || echo "User kibana tidak ada"

# 6. Hapus group ELK
echo ">>> Menghapus group ELK..."
sudo groupdel elasticsearch 2>/dev/null || echo "Group elasticsearch tidak ada"
sudo groupdel logstash 2>/dev/null || echo "Group logstash tidak ada"
sudo groupdel kibana 2>/dev/null || echo "Group kibana tidak ada"

# 7. Hapus repository Elastic
echo ">>> Menghapus repository Elastic..."
sudo rm -f /etc/apt/sources.list.d/elastic-7.x.list
sudo rm -f /etc/apt/sources.list.d/elastic-*.list

# 8. Hapus GPG key Elastic
echo ">>> Menghapus GPG key Elastic..."
sudo rm -f /usr/share/keyrings/elasticsearch-keyring.gpg
sudo rm -f /etc/apt/trusted.gpg.d/elastic-key.gpg

# 9. Hapus systemd service files (jika ada yang tersisa)
echo ">>> Menghapus systemd service files..."
sudo rm -f /etc/systemd/system/elasticsearch.service
sudo rm -f /etc/systemd/system/logstash.service
sudo rm -f /etc/systemd/system/kibana.service
sudo rm -f /etc/systemd/system/filebeat.service

# 10. Reload systemd daemon
echo ">>> Reload systemd daemon..."
sudo systemctl daemon-reload

# 11. Update package list
echo ">>> Memperbarui daftar paket..."
sudo apt-get update

# 12. Clean apt cache
echo ">>> Membersihkan apt cache..."
sudo apt-get autoremove -y
sudo apt-get autoclean

# 13. Verifikasi uninstall
echo "===== Verifikasi Uninstall ====="
echo ">>> Memeriksa apakah paket ELK masih terinstall..."
if dpkg -l | grep -E "(elasticsearch|logstash|kibana|filebeat)" | grep -v "^rc"; then
    echo "PERINGATAN: Masih ada paket ELK yang terinstall:"
    dpkg -l | grep -E "(elasticsearch|logstash|kibana|filebeat)" | grep -v "^rc"
else
    echo "✓ Semua paket ELK sudah diuninstall"
fi

echo ">>> Memeriksa service yang masih aktif..."
if systemctl list-units --type=service --state=active | grep -E "(elasticsearch|logstash|kibana|filebeat)"; then
    echo "PERINGATAN: Masih ada service ELK yang aktif"
else
    echo "✓ Tidak ada service ELK yang aktif"
fi

echo ">>> Memeriksa direktori yang masih ada..."
remaining_dirs=""
for dir in /etc/elasticsearch /etc/logstash /etc/kibana /etc/filebeat \
           /var/lib/elasticsearch /var/lib/logstash /var/lib/kibana /var/lib/filebeat \
           /var/log/elasticsearch /var/log/logstash /var/log/kibana /var/log/filebeat \
           /usr/share/elasticsearch /usr/share/logstash /usr/share/kibana /usr/share/filebeat; do
    if [ -d "$dir" ]; then
        remaining_dirs="$remaining_dirs $dir"
    fi
done

if [ -n "$remaining_dirs" ]; then
    echo "PERINGATAN: Masih ada direktori ELK yang tersisa:"
    echo "$remaining_dirs"
    echo "Anda bisa menghapusnya manual dengan: sudo rm -rf <directory>"
else
    echo "✓ Semua direktori ELK sudah dihapus"
fi

echo ""
echo "===== Uninstall ELK Stack Selesai ====="
echo "ELK Stack telah diuninstall dari sistem WSL Ubuntu Anda."
echo ""
echo "CATATAN:"
echo "- Jika ada data penting dalam direktori ELK, pastikan sudah dibackup sebelumnya"
echo "- Repository Elastic dan GPG key sudah dihapus"
echo "- Untuk instalasi ulang, jalankan script install_elk_v7.17.28_wsl.sh"
echo ""
echo "Untuk menjalankan script ini, berikan izin eksekusi: chmod +x uninstall_elk_wsl.sh"
echo "Kemudian jalankan: ./uninstall_elk_wsl.sh"
