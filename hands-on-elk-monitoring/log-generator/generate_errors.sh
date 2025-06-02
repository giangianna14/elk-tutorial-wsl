#!/bin/bash

# Skrip untuk menghasilkan sejumlah besar log ERROR menggunakan app.py
# Ini akan memanggil app.py dengan argumen khusus 'burst'

PYTHON_SCRIPT_PATH="$(dirname "$0")/app.py"

echo "Memulai generasi log ERROR dalam jumlah besar..."

# Panggil skrip Python dengan argumen untuk burst error
python3 "$PYTHON_SCRIPT_PATH" "Triggering error burst" burst

echo "Selesai menghasilkan log ERROR."
echo "Periksa file app.log dan Kibana."
