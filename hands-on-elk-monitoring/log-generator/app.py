#!/usr/bin/env python3
import datetime
import sys
import os
import time

# Path ke file log, relatif terhadap direktori skrip ini
LOG_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_FILE = os.path.join(LOG_DIR, "app.log")

def write_log(level, message):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    log_entry = f"[{timestamp}] {level.upper()}: {message}\n"
    
    try:
        with open(LOG_FILE, "a") as f:
            f.write(log_entry)
    except Exception as e:
        print(f"Error writing to log file: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 app.py <message> [level]")
        print("Example: python3 app.py \"User logged in\" info")
        print("Example: python3 app.py \"Failed to connect to database\" error")
        sys.exit(1)

    message_text = sys.argv[1]
    log_level = "info" # Default level

    if len(sys.argv) > 2:
        log_level_arg = sys.argv[2].lower()
        if log_level_arg in ["info", "error", "warning", "debug"]:
            log_level = log_level_arg
        else:
            print(f"Warning: Unknown log level '{sys.argv[2]}'. Defaulting to 'info'.")

    # Jika argumen ketiga adalah 'burst', hasilkan banyak error
    if len(sys.argv) > 2 and sys.argv[2].lower() == 'burst':
        num_errors = 1100 # Hasilkan lebih dari 1000 untuk memastikan threshold terlewati
        print(f"Generating {num_errors} ERROR messages...")
        for i in range(num_errors):
            write_log("error", f"Simulated burst error message #{i+1}")
            if (i + 1) % 100 == 0: # Beri sedikit jeda agar tidak terlalu membebani I/O
                time.sleep(0.01)
        print(f"Finished generating {num_errors} ERROR messages.")
    else:
        write_log(log_level, message_text)
        # print(f"Logged to {LOG_FILE}: [{log_level.upper()}] {message_text}")
