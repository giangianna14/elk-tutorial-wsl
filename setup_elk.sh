#!/bin/bash

clear
echo "============================================================"
echo "🚀 ELK Stack Installer - WSL Ubuntu Setup Tool"
echo "============================================================"
echo ""
echo "Pilih versi ELK Stack yang ingin diinstall:"
echo ""
echo "1️⃣  ELK Stack v7.17.28 (Stable & Lightweight)"
echo "   ✅ Resource ringan (RAM < 4GB)"
echo "   ✅ Setup cepat untuk learning"
echo "   ✅ Kompatibel dengan tutorial lama"
echo "   📊 Total RAM usage: ~1.3GB"
echo ""
echo "2️⃣  ELK Stack v8.15.0 (Latest & Modern)"
echo "   ✅ Fitur terbaru dan security modern" 
echo "   ✅ Production ready"
echo "   ✅ Enhanced observability features"
echo "   📊 Total RAM usage: ~1.8GB"
echo ""
echo "3️⃣  Lihat perbandingan detail kedua versi"
echo ""
echo "4️⃣  Uninstall ELK Stack yang sudah ada"
echo ""
echo "0️⃣  Keluar"
echo ""
echo "============================================================"

read -p "Masukkan pilihan Anda (0-4): " choice

case $choice in
    1)
        echo ""
        echo "🔧 Memulai instalasi ELK Stack v7.17.28..."
        echo ""
        if [ -f "install_elk_v7.17.28_wsl.sh" ]; then
            chmod +x install_elk_v7.17.28_wsl.sh
            ./install_elk_v7.17.28_wsl.sh
        else
            echo "❌ File install_elk_v7.17.28_wsl.sh tidak ditemukan!"
            exit 1
        fi
        ;;
    2)
        echo ""
        echo "🚀 Memulai instalasi ELK Stack v8.15.0..."
        echo ""
        if [ -f "install_elk_v8_latest_wsl.sh" ]; then
            chmod +x install_elk_v8_latest_wsl.sh
            ./install_elk_v8_latest_wsl.sh
        else
            echo "❌ File install_elk_v8_latest_wsl.sh tidak ditemukan!"
            exit 1
        fi
        ;;
    3)
        echo ""
        if [ -f "compare_elk_versions.sh" ]; then
            chmod +x compare_elk_versions.sh
            ./compare_elk_versions.sh
        else
            echo "❌ File compare_elk_versions.sh tidak ditemukan!"
            exit 1
        fi
        echo ""
        read -p "Tekan Enter untuk kembali ke menu utama..."
        exec "$0"
        ;;
    4)
        echo ""
        echo "🗑️  Memulai uninstall ELK Stack..."
        echo ""
        if [ -f "uninstall_elk_wsl.sh" ]; then
            chmod +x uninstall_elk_wsl.sh
            ./uninstall_elk_wsl.sh
        else
            echo "❌ File uninstall_elk_wsl.sh tidak ditemukan!"
            exit 1
        fi
        ;;
    0)
        echo ""
        echo "👋 Terima kasih telah menggunakan ELK Stack Installer!"
        echo ""
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Pilihan tidak valid! Silakan pilih 0-4."
        echo ""
        read -p "Tekan Enter untuk mencoba lagi..."
        exec "$0"
        ;;
esac

echo ""
echo "============================================================"
echo "✅ Proses selesai!"
echo ""
echo "📚 Dokumentasi lengkap:"
echo "   • README.md - Panduan umum project"
echo "   • hands-on-observability-kibana.md - Tutorial observability"
echo ""
echo "🌐 Akses web interfaces:"
echo "   • Kibana: http://localhost:5601"
echo "   • Elasticsearch: http://localhost:9200"
echo ""
echo "🚀 Happy monitoring!"
echo "============================================================"
