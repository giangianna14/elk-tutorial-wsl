#!/bin/bash

# Skrip untuk menghasilkan sejumlah log acak secara terus menerus menggunakan app.py

PYTHON_SCRIPT_PATH="$(dirname "$0")/app.py"

# Interval tidur default (detik) jika tidak ada argumen yang diberikan
DEFAULT_SLEEP_INTERVAL=1
# Ambil interval dari argumen pertama, atau gunakan default
SLEEP_INTERVAL=${1:-$DEFAULT_SLEEP_INTERVAL}

echo "Memulai generasi log acak terus menerus..."
echo "Interval antar log: $SLEEP_INTERVAL detik. Tekan Ctrl+C untuk berhenti."

# Daftar contoh pesan
messages=(
    "User logged in successfully"
    "Processing request for item_id=123"
    "Payment received for order_id=456"
    "Database connection established"
    "File uploaded: report.pdf"
    "Cache cleared for user_id=789"
    "User profile updated"
    "New comment posted on article_id=777"
    "Search query processed: 'elk stack monitoring'"
    "Scheduled task 'backup_db' completed"
    "Invalid input detected for field 'username' - too short"
    "Resource not found: /api/v3/items/nonexistent"
    "Service unavailable: EmailService timeout"
    "High CPU usage detected on worker_node_5 - current: 85%"
    "Disk space running low on /data partition - 90% used"
    "Unexpected null pointer exception in PaymentProcessorModule"
    "Failed to process batch job_id=2025052201 - retrying"
    "Security alert: Potential XSS attempt detected from IP 10.0.0.5"
    "Configuration reloaded successfully"
    "User session timed out for user_id=321"
    "Attempting to reconnect to message queue..."
    "Data synchronization started for replica_set_2"
    "API rate limit exceeded for client_id='abc123xyz'"
    "Certificate for domain 'example.com' is about to expire in 7 days"
    "Database query took longer than expected: 3.5s"
)

# Daftar level log
# Adjusted probabilities: more INFO, some WARNING, fewer ERROR
levels=(
    "info" "info" "info" "info" "info" "info" "info" "info"
    "warning" "warning" "warning"
    "error" "error"
)

log_counter=0

while true
do
    log_counter=$((log_counter + 1))
    # Pilih pesan acak
    random_message_index=$((RANDOM % ${#messages[@]}))
    message="${messages[$random_message_index]}"

    # Pilih level log acak
    random_level_index=$((RANDOM % ${#levels[@]}))
    level="${levels[$random_level_index]}"

    # Tambahkan detail acak ke pesan
    detail_type=$((RANDOM % 4))
    case $detail_type in
        0) # No extra detail
            ;;
        1) # Add a random number
            message="$message (transaction_id=$((RANDOM % 100000)))"
            ;;
        2) # Add a random user ID
            message="$message (user_id='user$((RANDOM % 1000))')"
            ;;
        3) # Add a random IP-like address
            message="$message (client_ip='192.168.$((RANDOM % 256)).$((RANDOM % 256))')"
            ;;
    esac

    echo "Generating log #$log_counter: LEVEL=$level, MESSAGE='$message'"
    
    # Panggil skrip Python
    # Asumsi: app.py menerima pesan sebagai arg1 dan level sebagai arg2 (opsional, default ke INFO)
    if [ "$level" == "info" ]; then
        python3 "$PYTHON_SCRIPT_PATH" "$message"
    else
        python3 "$PYTHON_SCRIPT_PATH" "$message" "$level"
    fi

    # Gunakan interval tidur yang ditentukan pengguna atau default
    sleep "$SLEEP_INTERVAL"
done

echo "Skrip generasi log dihentikan."
# Pesan ini mungkin tidak akan pernah tercapai karena loop tak terbatas, kecuali dihentikan secara eksternal.
