# Hands-on: Mempelajari Menu Observability di Kibana dari Dasar beserta Use Case

## Daftar Isi
1.  [Pendahuluan Observability di Kibana](#pendahuluan-observability-di-kibana)
    *   [Apa itu Observability?](#apa-itu-observability)
    *   [Gambaran Umum Bagian Observability di Kibana](#gambaran-umum-bagian-observability-di-kibana)
    *   [Manfaat Menggunakannya](#manfaat-menggunakannya)
2.  [Prasyarat](#prasyarat)
3.  [Hands-on](#hands-on)
    *   [Bagian 1: Eksplorasi Logs di Kibana Observability (dengan Filebeat dan Logstash)](#bagian-1-eksplorasi-logs-di-kibana-observability-dengan-filebeat-dan-logstash)
        *   [Tujuan Pembelajaran](#tujuan-pembelajaran)
        *   [Alur Pengiriman Log](#alur-pengiriman-log)
        *   [Langkah-langkah Hands-on](#langkah-langkah-hands-on)
            *   [1. Konfigurasi dan Verifikasi Filebeat](#1-konfigurasi-dan-verifikasi-filebeat)
            *   [2. Konfigurasi dan Verifikasi Logstash](#2-konfigurasi-dan-verifikasi-logstash)
            *   [3. Pastikan Elasticsearch dan Kibana Berjalan](#3-pastikan-elasticsearch-dan-kibana-berjalan)
            *   [4. Hasilkan Log Contoh](#4-hasilkan-log-contoh)
            *   [5. Navigasi ke Logs UI di Kibana](#5-navigasi-ke-logs-ui-di-kibana)
            *   [6. Mengkonfigurasi Sumber Log di Logs UI untuk `app-logs-*`](#6-mengkonfigurasi-sumber-log-di-logs-ui-untuk-app-logs-)
            *   [7. Eksplorasi Antarmuka Logs (Stream)](#7-eksplorasi-antarmuka-logs-stream)
            *   [8. Melakukan Pencarian dan Pemfilteran Dasar](#8-melakukan-pencarian-dan-pemfilteran-dasar)
            *   [9. Melihat Detail Log dan Streaming](#9-melihat-detail-log-dan-streaming)
            *   [10. Kustomisasi Tampilan Log Stream](#10-kustomisasi-tampilan-log-stream)
            *   [11. Use Case: Investigasi Error Aplikasi](#11-use-case-investigasi-error-aplikasi)
        *   [Troubleshooting Umum](#troubleshooting-umum)
        *   [Latihan Tambahan](#latihan-tambahan)
    *   [Bagian 2: Monitoring Metrics dengan Kibana Observability](#bagian-2-monitoring-metrics-dengan-kibana-observability)
        *   [Apa itu Metrics di Konteks Observability?](#apa-itu-metrics-di-konteks-observability)
        *   [Langkah-langkah Hands-on (Metrics)](#langkah-langkah-hands-on-metrics)
            *   [1. Mengirim Metrik Sistem (Metricbeat)](#1-mengirim-metrik-sistem-metricbeat)
            *   [2. Navigasi ke Metrics UI di Kibana](#2-navigasi-ke-metrics-ui-di-kibana)
            *   [3. Eksplorasi Antarmuka Metrics](#3-eksplorasi-antarmuka-metrics)
            *   [4. Hands-on: Menganalisis Metrik Sistem Dasar](#4-hands-on-menganalisis-metrik-sistem-dasar)
            *   [5. Use Case: Mengidentifikasi Potensi Masalah Kinerja Server](#5-use-case-mengidentifikasi-potensi-masalah-kinerja-server)
            *   [6. Troubleshooting Dasar Metricbeat](#6-troubleshooting-dasar-metricbeat)
    *   [Bagian 3: Application Performance Monitoring (APM)](#bagian-3-application-performance-monitoring-apm)
    *   [Bagian 4: Uptime Monitoring](#bagian-4-uptime-monitoring)
4.  [Menyatukan Semuanya: Observability yang Terkorelasi](#menyatukan-semuanya-observability-yang-terkorelasi)
5.  [Kesimpulan](#kesimpulan)

---

## 1. Pendahuluan Observability di Kibana

### Apa itu Observability?

Observability, atau keteramatan, adalah kemampuan untuk mengukur keadaan internal suatu sistem hanya dengan memeriksa output eksternalnya. Dalam konteks IT dan pengembangan perangkat lunak, ini berarti memahami apa yang terjadi di dalam aplikasi dan infrastruktur Anda berdasarkan data telemetri yang dihasilkannya.

Tiga pilar utama observability adalah:

1.  **Logs (Catatan Log)**: Ini adalah rekaman peristiwa yang terjadi dari waktu ke waktu, yang dihasilkan oleh aplikasi, server, atau komponen sistem lainnya. Logs memberikan detail kontekstual tentang apa yang terjadi pada titik waktu tertentu. Contoh: `ERROR: Failed to connect to database`, `INFO: User 'john.doe' logged in`.
2.  **Metrics (Metrik)**: Ini adalah pengukuran numerik dari kinerja atau kesehatan sistem selama interval waktu tertentu. Metrik bersifat agregat dan dapat digunakan untuk tren dan peringatan. Contoh: CPU utilization, memory usage, request rate, error rate.
3.  **APM Traces (Jejak APM)**: Application Performance Monitoring (APM) traces memberikan pandangan mendalam tentang alur permintaan saat bergerak melalui berbagai layanan dalam aplikasi terdistribusi. Traces membantu mengidentifikasi bottleneck performa dan memahami interaksi antar layanan. Contoh: jejak permintaan pengguna dari frontend ke backend, lalu ke database, dan kembali lagi.

Dengan menggabungkan ketiga pilar ini, tim dapat memperoleh pemahaman yang komprehensif tentang perilaku sistem mereka, mendiagnosis masalah lebih cepat, dan meningkatkan kinerja secara proaktif.

### Gambaran Umum Bagian Observability di Kibana

Kibana menyediakan bagian "Observability" yang terintegrasi untuk menyatukan alat dan visualisasi untuk logs, metrics, APM, dan uptime monitoring. Ini memungkinkan pengguna untuk:

*   **Menganalisis log** secara terpusat dari berbagai sumber.
*   **Memvisualisasikan metrik** infrastruktur dan aplikasi dalam dashboard yang interaktif.
*   **Melacak kinerja aplikasi** dan mengidentifikasi masalah dengan APM.
*   **Memantau ketersediaan** layanan dan endpoint dengan Uptime monitoring.
*   **Mengorelasikan data** dari berbagai sumber ini untuk mendapatkan wawasan yang lebih dalam.

### Manfaat Menggunakannya

Menggunakan bagian Observability di Kibana menawarkan beberapa manfaat:

*   **Pemecahan Masalah Lebih Cepat**: Dengan data telemetri yang terpusat dan terkorelasi, Anda dapat dengan cepat mengidentifikasi akar penyebab masalah.
*   **Peningkatan Kinerja**: Memahami bottleneck dan tren kinerja memungkinkan Anda untuk mengoptimalkan aplikasi dan infrastruktur.
*   **Pengalaman Pengguna yang Lebih Baik**: Dengan memantau dan meningkatkan kinerja serta ketersediaan, Anda dapat memberikan pengalaman yang lebih baik bagi pengguna akhir.
*   **Kolaborasi Tim yang Efisien**: Platform terpusat memudahkan berbagai tim (Dev, Ops, SRE) untuk bekerja sama dalam memantau dan memecahkan masalah.
*   **Pengambilan Keputusan Berbasis Data**: Wawasan dari data observability dapat menginformasikan keputusan teknis dan bisnis.

---

## 2. Prasyarat

Sebelum memulai hands-on ini, pastikan Anda memiliki:

1.  **Elastic Stack (ELK Stack) yang Berjalan**:
    *   Elasticsearch dan Kibana harus sudah terinstal dan berjalan. Anda dapat menggunakan versi terbaru atau versi yang kompatibel dengan fitur Observability yang ingin Anda jelajahi (umumnya versi 7.x ke atas memiliki fitur Observability yang kaya).
    *   Jika Anda telah mengikuti tutorial "Hands-on: Monitoring Log ERROR dengan ELK Stack di WSL Ubuntu" sebelumnya, Anda sudah memiliki dasar ELK Stack yang bisa digunakan.
    *   Pastikan Kibana dapat diakses melalui browser Anda (misalnya, `http://localhost:5601`).

2.  **Agen Pengumpul Data (Beats atau Elastic Agent)**:
    *   **Filebeat**: Untuk mengirim log ke Elasticsearch.
    *   **Metricbeat**: Untuk mengirim metrik sistem dan layanan ke Elasticsearch.
    *   **Heartbeat**: Untuk memantau ketersediaan layanan (Uptime).
    *   **APM Server & Agents**: Untuk Application Performance Monitoring. APM Server menerima data dari APM Agent yang diinstrumentasikan dalam aplikasi Anda.
    *   **Elastic Agent (Opsional, Pendekatan Terpadu)**: Elastic Agent adalah agen tunggal yang dapat mengumpulkan log, metrik, data APM, dan data keamanan, menyederhanakan pengelolaan agen.

3.  **Aplikasi Contoh (untuk APM dan Logs Lanjutan)**:
    *   Untuk bagian APM, Anda memerlukan aplikasi contoh yang dapat diinstrumentasikan dengan Elastic APM Agent. Contoh aplikasi sederhana menggunakan Python (Flask/Django), Node.js (Express), Java (Spring Boot), dll., akan sangat membantu.
    *   Untuk eksplorasi logs yang lebih mendalam, memiliki aplikasi yang menghasilkan berbagai jenis log (info, error, debug) akan bermanfaat. Aplikasi `app.py` dari tutorial sebelumnya bisa digunakan sebagai titik awal.

4.  **Akses Terminal/Shell**:
    *   Anda memerlukan akses ke terminal untuk menginstal agen, mengkonfigurasi, dan menjalankan perintah.

5.  **Koneksi Internet**:
    *   Untuk mengunduh paket instalasi agen dan dependensi aplikasi jika diperlukan.

**Catatan Penting untuk Setup Awal:**

*   Tutorial ini akan mengasumsikan Anda memiliki pemahaman dasar tentang cara menginstal dan mengkonfigurasi Beats. Jika belum, Anda mungkin perlu merujuk ke dokumentasi resmi Elastic untuk detail instalasi masing-masing Beat atau Elastic Agent.
*   Untuk kesederhanaan, banyak contoh akan menggunakan konfigurasi default atau minimal. Dalam lingkungan produksi, Anda perlu menyesuaikan konfigurasi sesuai kebutuhan spesifik Anda.

---
## 3. Hands-on

Kita akan membahas setiap komponen utama dari menu Observability di Kibana.

### Bagian 1: Eksplorasi Logs di Kibana Observability (dengan Filebeat dan Logstash)

Aplikasi Logs di bawah menu Observability Kibana adalah alat utama Anda untuk mencari, memfilter, dan menganalisis semua log yang dikumpulkan oleh Elasticsearch. Dalam bagian ini, kita akan menggunakan Filebeat untuk mengirim log ke Logstash, yang kemudian akan memproses dan mengirimkannya ke Elasticsearch. Pola indeks target kita di Elasticsearch adalah `app-logs-*`.

**Tujuan Pembelajaran Bagian Ini:** {#tujuan-pembelajaran}
*   Memahami alur pengiriman log dari Filebeat ke Logstash, lalu ke Elasticsearch.
*   Mengkonfigurasi Kibana Logs UI untuk membaca dari indeks kustom (`app-logs-*`).
*   Melakukan pencarian dan pemfilteran log menggunakan field yang diparsing oleh Logstash.
*   Melihat detail log dan streaming log secara real-time.
*   Use Case: Menganalisis log untuk menemukan akar penyebab error aplikasi.

**Alur Pengiriman Log:** {#alur-pengiriman-log}

Filebeat (`custom-filebeat.yml`) -> Logstash (`02-app-logs.conf`) -> Elasticsearch (indeks `app-logs-*`) -> Kibana Logs UI

**Langkah-langkah Hands-on:** {#langkah-langkah-hands-on}

1.  **Konfigurasi dan Verifikasi Filebeat** {#1-konfigurasi-dan-verifikasi-filebeat}

    Kita akan menggunakan konfigurasi Filebeat kustom Anda yang berada di `/home/giangianna/elk-tutorial/hands-on-elk-monitoring/filebeat-config/custom-filebeat.yml`.
    Pastikan file ini memiliki konten yang sesuai, terutama:
    *   **Input**: Mengarah ke file log aplikasi Anda (misalnya, `/home/giangianna/elk-tutorial/hands-on-elk-monitoring/log-generator/app.log`).
    *   **Output**: Dikonfigurasi untuk mengirim ke Logstash (misalnya, `output.logstash: hosts: ["localhost:5044"]`).
    *   **Nama Filebeat**: `name: "wsl-filebeat-app"` (seperti di file Anda).
    *   **Tags**: `tags: ["app-log", "python-app"]` (seperti di file Anda).

    *   **Salin Konfigurasi (Jika Perlu)**:
        Jika konfigurasi Filebeat default (`/etc/filebeat/filebeat.yml`) berbeda, Anda mungkin ingin menggantinya atau menjalankan Filebeat dengan file konfigurasi kustom:
        ```bash
        # Opsi 1: Ganti konfigurasi default (backup dulu yang lama)
        sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.backup
        sudo cp /home/giangianna/elk-tutorial/hands-on-elk-monitoring/filebeat-config/custom-filebeat.yml /etc/filebeat/filebeat.yml
        
        # Opsi 2: Jalankan Filebeat dengan konfigurasi kustom (lebih aman untuk testing)
        # sudo filebeat -c /home/giangianna/elk-tutorial/hands-on-elk-monitoring/filebeat-config/custom-filebeat.yml -e
        ```
        Untuk tutorial ini, kita asumsikan Anda telah mengganti `/etc/filebeat/filebeat.yml` dengan `custom-filebeat.yml`.

    *   **Perintah `sudo filebeat setup -e`**:
        Karena Filebeat mengirim ke Logstash, perintah `setup -e` tidak secara langsung mengkonfigurasi pola indeks `app-logs-*` di Elasticsearch. Peran utama Logstash adalah menentukan indeks tujuan. Namun, menjalankan `setup -e` sekali setelah instalasi Filebeat dapat berguna untuk memuat aset Kibana umum atau dashboard default jika ada modul Filebeat lain yang aktif dan mengirim langsung ke Elasticsearch. Untuk alur kita saat ini (Filebeat -> Logstash), dampaknya minimal pada data `app-logs-*`.
        ```bash
        # Jalankan jika belum pernah, atau jika ada perubahan besar pada instalasi Filebeat
        # sudo filebeat setup -e 
        ```
        Fokus utama kita adalah konfigurasi Logstash untuk indeks `app-logs-*`.

    *   **Pastikan Filebeat Berjalan**:
        ```bash
        sudo systemctl restart filebeat # atau sudo systemctl start filebeat
        sudo systemctl status filebeat --no-pager
        ```
        Periksa status dan log Filebeat (`sudo journalctl -u filebeat -f`) untuk memastikan tidak ada error koneksi ke Logstash.

2.  **Konfigurasi dan Verifikasi Logstash** {#2-konfigurasi-dan-verifikasi-logstash}

    Logstash akan menerima data dari Filebeat, memprosesnya, dan mengirimkannya ke Elasticsearch. Kita akan menggunakan konfigurasi `/home/giangianna/elk-tutorial/hands-on-elk-monitoring/logstash-config/02-app-logs.conf`.

    Pastikan file `02-app-logs.conf` Anda:
    *   **Input**: Memiliki `beats { port => 5044 }`.
    *   **Filter**: Menggunakan `grok` untuk mem-parse pesan log Anda (misalnya, `\\[%{TIMESTAMP_ISO8601:log_timestamp}\\] %{LOGLEVEL:log_level}: %{GREEDYDATA:log_message}`). Menggunakan `date` filter untuk mengatur `@timestamp` dari `log_timestamp`.
    *   **Output**: Menggunakan `elasticsearch` dengan `hosts => ["http://localhost:9200"]` dan `index => "app-logs-%{+YYYY.MM.dd}"`.

    *   **Jalankan Logstash dengan Konfigurasi Ini**:
        Anda perlu memastikan Logstash dijalankan dengan pipeline yang menyertakan file konfigurasi ini. Jika Anda menggunakan `pipelines.yml` atau menjalankan Logstash dengan direktori konfigurasi, pastikan `02-app-logs.conf` termuat.
        Contoh menjalankan Logstash dengan satu file konfigurasi (sesuaikan path ke binary Logstash Anda jika perlu):
        ```bash
        # Hentikan instance Logstash yang mungkin sudah berjalan
        # sudo systemctl stop logstash (jika berjalan sebagai service)
        
        # Jalankan Logstash di foreground untuk testing, arahkan ke file konfigurasi spesifik
        # Ganti /usr/share/logstash/bin/logstash dengan path instalasi Logstash Anda
        # sudo /usr/share/logstash/bin/logstash -f /home/giangianna/elk-tutorial/hands-on-elk-monitoring/logstash-config/02-app-logs.conf
        ```
        Atau, jika Logstash sudah dikonfigurasi untuk memuat semua file `.conf` dari direktori tertentu (misalnya `/etc/logstash/conf.d/`), pastikan `02-app-logs.conf` ada di sana.
        ```bash
        sudo cp /home/giangianna/elk-tutorial/hands-on-elk-monitoring/logstash-config/02-app-logs.conf /etc/logstash/conf.d/
        sudo systemctl restart logstash # atau sudo systemctl start logstash
        sudo systemctl status logstash --no-pager
        ```
        Periksa log Logstash (`sudo journalctl -u logstash -f` atau file lognya) untuk memastikan tidak ada error dan ia mendengarkan di port 5044 serta dapat terhubung ke Elasticsearch.

3.  **Pastikan Elasticsearch dan Kibana Berjalan** {#3-pastikan-elasticsearch-dan-kibana-berjalan}
    ```bash
    sudo systemctl status elasticsearch --no-pager
    sudo systemctl status kibana --no-pager
    ```
    Pastikan keduanya aktif dan tidak ada error.

4.  **Hasilkan Log Contoh** {#4-hasilkan-log-contoh}
    Jalankan aplikasi Python Anda beberapa kali untuk menghasilkan log baru yang akan dikirim melalui Filebeat -> Logstash -> Elasticsearch.
    ```bash
    cd /home/giangianna/elk-tutorial/hands-on-elk-monitoring/log-generator/
    python3 app.py "Ini adalah pesan log INFO untuk Observability via Logstash"
    python3 app.py "ERROR: Terjadi kesalahan fatal saat memproses pembayaran" --level ERROR
    python3 app.py "DEBUG: Nilai variabel koneksi adalah 'server123'" --level DEBUG
    ```

5.  **Navigasi ke Logs UI di Kibana** {#5-navigasi-ke-logs-ui-di-kibana}
    *   Buka Kibana di browser Anda (misalnya, `http://localhost:5601`).
    *   Dari menu navigasi utama (ikon hamburger di kiri atas), pilih **Observability > Logs**.
    *   Klik **Stream**.

6.  **Mengkonfigurasi Sumber Log di Logs UI untuk `app-logs-*`** {#6-mengkonfigurasi-sumber-log-di-logs-ui-untuk-app-logs-}

    Sangat penting untuk memberitahu Kibana Logs UI agar mencari log di pola indeks `app-logs-*`.
    1.  Di halaman **Observability > Logs > Stream**, cari ikon **Settings** atau **Configure source** (biasanya ikon roda gigi atau serupa, letaknya mungkin di kanan atas dekat time picker atau di panel konfigurasi).
    2.  Di dalam pengaturan sumber (Source configuration), Anda akan menemukan opsi untuk menentukan **index pattern** atau **data view** yang digunakan oleh Logs UI.
    3.  Ubah atau tambahkan pola indeks agar menunjuk ke `app-logs-*`. Anda mungkin perlu mengetikkan `app-logs-*` secara manual.
    4.  Pastikan field timestamp yang benar (`@timestamp`) dipilih. Karena Logstash sudah mengatur `@timestamp` dari log asli, ini seharusnya sudah benar.
    5.  Simpan perubahan konfigurasi sumber. Logs UI sekarang seharusnya menampilkan log dari indeks `app-logs-*` Anda.

    *Catatan*: Jika `app-logs-*` tidak muncul sebagai opsi, Anda mungkin perlu membuatnya terlebih dahulu di **Stack Management > Kibana > Data Views** (atau "Index Patterns" di versi lama). Saat membuatnya, pastikan Anda memilih `@timestamp` sebagai field waktu utama.

7.  **Eksplorasi Antarmuka Logs (Stream)** {#7-eksplorasi-antarmuka-logs-stream}
    Saat pertama kali membuka Logs UI (setelah konfigurasi sumber), Anda akan melihat beberapa komponen utama:
    *   **Search Bar (KQL - Kibana Query Language)**: Di bagian atas.
    *   **Time Picker**: Di pojok kanan atas.
    *   **Log Stream**: Area utama yang menampilkan aliran log.
        *   **Timestamp**: Waktu kejadian log (ini seharusnya `@timestamp` yang diparsing oleh Logstash).
        *   **Fields**: Kolom yang ditampilkan dapat dikustomisasi. Anda sekarang seharusnya bisa menambahkan kolom seperti `log_level` dan `log_message` (hasil parsing grok Logstash) selain `message` (yang mungkin berisi log asli sebelum parsing, tergantung konfigurasi `overwrite` di grok).
    *   **Settings (Customize)**: Ikon roda gigi untuk kustomisasi kolom, format timestamp, dll.
    *   **Filters**: Untuk menambahkan filter berdasarkan field.
    *   **Highlights**: Untuk menyorot istilah dalam log.
    *   **Streaming Controls**: Tombol "Stream live".

8.  **Melakukan Pencarian dan Pemfilteran Dasar** {#8-melakukan-pencarian-dan-pemfilteran-dasar}
    Dengan log yang diparsing oleh Logstash, Anda bisa melakukan query yang lebih terstruktur:
    *   **Pencarian**:
        *   Cari semua log ERROR: `log_level: ERROR`
        *   Cari log yang pesannya mengandung "pembayaran": `log_message: pembayaran`
        *   Kombinasikan: `log_level: ERROR AND log_message: pembayaran`
        *   Gunakan tag dari Filebeat: `tags: "python-app"`
        *   Gunakan nama Filebeat: `agent.name: "wsl-filebeat-app"` (Field ini biasanya ditambahkan oleh Filebeat secara otomatis dan berisi nilai dari `name` di `custom-filebeat.yml`).
    *   **Pemfilteran**:
        *   Klik pada salah satu entri log di Log Stream untuk melihat detailnya.
        *   Dalam detail log, arahkan kursor ke field `log_level`. Klik ikon "+" di sebelah nilai "ERROR" untuk memfilter hanya log error.
        *   Filter yang aktif akan muncul di bawah search bar.

9.  **Melihat Detail Log dan Streaming** {#9-melihat-detail-log-dan-streaming}
    *   **Detail Log**: Klik pada baris log. Anda akan melihat semua field, termasuk `log_level`, `log_message`, `tags` dari Filebeat, `agent.name`, `host.name`, dll.
    *   **Streaming Live**: Aktifkan "Stream live" dan hasilkan log baru dari `app.py` untuk melihatnya muncul secara real-time.

10. **Kustomisasi Tampilan Log Stream** {#10-kustomisasi-tampilan-log-stream}
    *   Gunakan **"Settings" / "Customize"** di Logs UI.
    *   **Tambahkan Kolom**: Tambahkan kolom `log_level` dan `log_message` ke tampilan utama untuk visibilitas yang lebih baik. Anda mungkin ingin menghapus kolom `message` jika `log_message` lebih bersih.

11. **Use Case: Investigasi Error Aplikasi** {#11-use-case-investigasi-error-aplikasi}

    *   **Skenario**: Pengguna melaporkan masalah "pembayaran gagal" sekitar pukul tertentu.
    *   **Langkah Investigasi**:
        1.  **Buka Logs UI**, pastikan sumbernya `app-logs-*`.
        2.  **Atur Rentang Waktu** yang relevan.
        3.  **Filter/Cari**:
            ```kql
            log_level: ERROR AND log_message: "pembayaran gagal"
            ```
            Atau jika Anda ingin lebih luas:
            ```kql
            log_message: pembayaran AND (log_level: ERROR OR log_level: WARN)
            ```
        4.  **Analisis Log Error**: Periksa detail `log_message` dan field lainnya.
        5.  **Lihat Log Sekitar**: Gunakan fitur "View surrounding documents" atau sesuaikan rentang waktu untuk melihat log INFO atau DEBUG di sekitar error tersebut untuk mendapatkan konteks.

**Troubleshooting Umum:** {#troubleshooting-umum}

*   **Tidak ada log di Kibana**:
    1.  **Periksa Filebeat**: `sudo systemctl status filebeat`, `sudo journalctl -u filebeat -f`. Pastikan terhubung ke Logstash.
    2.  **Periksa Logstash**: `sudo systemctl status logstash`, `sudo journalctl -u logstash -f`. Pastikan mendengarkan di port 5044, tidak ada error parsing (cek `_grokparsefailure_applog` jika Anda menambahkannya), dan terhubung ke Elasticsearch.
    3.  **Periksa Elasticsearch**: `sudo systemctl status elasticsearch`. Apakah ada data di indeks `app-logs-*`? Gunakan Dev Tools: `GET /app-logs-*/_search`.
    4.  **Konfigurasi Sumber Kibana Logs UI**: Pastikan sudah benar menunjuk ke `app-logs-*` dan field `@timestamp`.
    5.  **Rentang Waktu di Kibana**: Pastikan sudah benar.
*   **Timestamp Salah**: Jika `@timestamp` di Kibana tidak sesuai dengan waktu di log asli, periksa filter `date` di konfigurasi Logstash (`02-app-logs.conf`). Pastikan format `match` sudah benar.
*   **Pesan Tidak Diparsing (Grok Gagal)**: Jika field `log_level` dan `log_message` tidak muncul, atau ada tag `_grokparsefailure_applog`, periksa pola `grok` di Logstash. Anda bisa menggunakan Grok Debugger di Kibana (Dev Tools) untuk menguji pola Anda terhadap pesan log sampel.

**Latihan Tambahan:** {#latihan-tambahan}
*   Buat query KQL yang lebih kompleks menggunakan field yang diparsing (`log_level`, `log_message`) dan field dari Filebeat (`agent.name`, `tags`).
*   Simpan query investigasi yang sering Anda gunakan.
*   Eksplorasi fitur "Highlights".

**Membuat Alert Rules untuk Logs (Contoh: Error Pembayaran)** {#membuat-alert-rules-untuk-logs}

Selain menganalisis log secara manual, Kibana memungkinkan Anda membuat aturan peringatan (alert rules) untuk memberi tahu Anda secara proaktif ketika kondisi tertentu terpenuhi. Mari kita buat aturan untuk memberi tahu kita jika ada log error yang berkaitan dengan "payment".

**Tujuan:**
*   Membuat aturan peringatan di Kibana yang terpicu ketika ada log di indeks `app-logs-*` dengan `log_level` adalah `ERROR` dan `log_message` mengandung kata `payment`.

**Langkah-langkah (Lakukan di Kibana UI):**

1.  **Navigasi ke Fitur Rules (Alerts & Actions)**:
    *   Buka menu utama Kibana (ikon hamburger **☰**).
    *   Pergi ke **Stack Management**.
    *   Di bawah bagian **Alerts and Insights** (atau nama serupa tergantung versi Kibana Anda), klik **Rules and Connectors** (atau **Alerts and Actions**).
    *   Pastikan Anda berada di tab **Rules**.

2.  **Buat Rule Baru**:
    *   Klik tombol **"Create rule"**.
    *   **Beri Nama Rule**: Masukkan nama yang deskriptif, misalnya: `Error Pembayaran Aplikasi`.
    *   **Tags (Opsional)**: Tambahkan tag jika perlu, misalnya `critical`, `payment-system`.
    *   **Pilih Tipe Rule**: Di bagian "Select rule type", cari dan pilih tipe rule **"Log threshold"**. Tipe ini memungkinkan Anda untuk memicu peringatan berdasarkan jumlah entri log yang cocok dengan query tertentu.

3.  **Konfigurasi Kondisi Rule ("Define conditions")**:
    *   **Indices to query**: Masukkan pola indeks Anda, yaitu `app-logs-*`.
    *   **Timestamp field**: Pilih `@timestamp` (ini seharusnya default).
    *   **Query (KQL)**: Ini adalah bagian penting. Masukkan query KQL untuk kondisi yang Anda inginkan:
        ```kql
        log_level: "ERROR" AND log_message: *payment*
        ```
        *   `log_level: "ERROR"`: Mencocokkan log dengan level ERROR.
        *   `log_message: *payment*`: Mencocokkan log di mana field `log_message` mengandung kata "payment". Penggunaan wildcard `*payment*` memastikan kecocokan bahkan jika "payment" adalah bagian dari pesan yang lebih besar. Jika Anda ingin kecocokan persis dengan kata "payment" saja, Anda bisa menggunakan `log_message: payment` (tanpa wildcard) atau `log_message: "payment"` jika itu adalah token tunggal.
    *   **Alert when**: Konfigurasikan ambang batas. Misalnya:
        *   Pilih **`count`**
        *   **`IS ABOVE`** (atau `IS GREATER THAN`)
        *   **`0`**
        *   **`FOR THE LAST`**
        *   **`5 minutes`** (atau interval lain yang sesuai, misalnya `1 minute`)
        Ini berarti peringatan akan terpicu jika ada lebih dari 0 log (yaitu, setidaknya 1 log) yang cocok dengan KQL Anda dalam 5 menit terakhir.

4.  **Konfigurasi Tindakan ("Add actions")**:
    *   Di sinilah Anda menentukan apa yang harus terjadi ketika peringatan terpicu.
    *   Untuk tutorial ini, kita akan menggunakan tindakan sederhana. Klik **"Add action"**.
    *   **Pilih Tipe Konektor (Connector type)**:
        *   **Server log**: Ini akan menulis pesan ke log server Kibana. Ini adalah cara termudah untuk melihat bahwa peringatan terpicu tanpa konfigurasi eksternal.
        *   **Index**: Ini akan menulis detail peringatan sebagai dokumen ke indeks Elasticsearch. Anda bisa menentukan nama indeks (misalnya, `alerts-app-errors`).
        *   (Pilihan lain seperti Email, Slack, PagerDuty memerlukan konfigurasi "Connectors" terlebih dahulu, yang berada di luar cakupan dasar ini).
    *   **Konfigurasi Pesan (jika ada)**: Untuk Server log atau tindakan lain, Anda mungkin bisa mengkustomisasi pesan yang dikirim. Anda bisa menggunakan variabel seperti `{{context.rule.name}}`, `{{context.reason}}`, `{{context.resultsCount}}`. Contoh pesan untuk Server Log:
        ```
        Peringatan Terpicu: {{context.rule.name}}. Jumlah log: {{context.resultsCount}}. Alasan: {{context.reason}}
        ```
    *   **Frequency**: Atur seberapa sering tindakan harus dijalankan (misalnya, "Run when condition is met", atau "Run every 1 hour if condition persists"). Untuk notifikasi segera, "Run when condition is met" biasanya yang terbaik.

5.  **Pengaturan Tambahan (Opsional)**:
    *   **Rule details**: Anda bisa menambahkan deskripsi lebih lanjut.
    *   **Notify**: Kapan harus memberi notifikasi (misalnya, "On active alert", "On status change").

6.  **Simpan Rule**:
    *   Klik **"Save"** atau **"Create rule"**.

**Verifikasi Alert Rule:**

1.  **Hasilkan Log yang Sesuai**:
    Jalankan skrip `app.py` Anda untuk menghasilkan log yang akan memicu kondisi peringatan:
    ```bash
    cd /home/giangianna/elk-tutorial/hands-on-elk-monitoring/log-generator/
    python3 app.py "ERROR: Terjadi kegagalan pada sistem payment gateway" --level ERROR 
    ```
    (Pastikan pesan ini mengandung kata "payment" dan idealnya memiliki `log_level: ERROR` setelah diproses oleh Logstash).

2.  **Periksa Status Rule di Kibana**:
    *   Kembali ke halaman **Rules** (Stack Management > Rules and Connectors).
    *   Temukan rule yang baru saja Anda buat. Setelah beberapa saat (sesuai interval pengecekan rule), statusnya akan berubah menjadi "Active" atau "Firing" jika kondisi terpenuhi.
    *   Anda juga bisa melihat riwayat eksekusi atau detail instance peringatan.

3.  **Periksa Tindakan (Action)**:
    *   Jika Anda memilih **Server log** sebagai tindakan, periksa log server Kibana Anda.
    *   Jika Anda memilih **Index** sebagai tindakan, gunakan Dev Tools di Kibana untuk query indeks yang Anda tentukan (misalnya, `GET /alerts-app-errors/_search`) untuk melihat dokumen peringatan yang dibuat.

Dengan membuat aturan peringatan, Anda dapat secara otomatis diberitahu tentang masalah penting dalam log Anda, memungkinkan respons yang lebih cepat terhadap insiden.

**Deteksi Anomali pada Laju Log dengan Machine Learning** {#deteksi-anomali-laju-log-ml}

Selain membuat aturan peringatan manual berdasarkan query tertentu, Kibana Observability Logs UI menawarkan integrasi dengan fitur Machine Learning (ML) untuk secara otomatis mendeteksi anomali dalam laju (rate) log Anda. Fitur ini dapat membantu Anda menemukan pola yang tidak biasa atau lonjakan/penurunan jumlah log yang mungkin mengindikasikan insiden, serangan, atau perubahan perilaku sistem yang tidak terduga.

**Tujuan:**
*   Memahami cara menggunakan fitur deteksi anomali laju log bawaan di Logs UI.
*   Melihat bagaimana Kibana membuat dan mengelola pekerjaan (job) Machine Learning untuk ini.
*   Menginterpretasikan hasil deteksi anomali.

**Langkah-langkah (Lakukan di Kibana UI):**

1.  **Navigasi ke Logs UI dan Temukan Fitur Anomaly Detection**:
    *   Buka Kibana: **Observability > Logs**.
    *   Pastikan Anda telah mengkonfigurasi sumber log ke `app-logs-*` (atau pola indeks yang relevan).
    *   Di halaman Logs UI (biasanya di bagian atas, dekat dengan search bar atau di bawah tab "Anomalies" jika ada), Anda akan menemukan opsi yang berkaitan dengan Machine Learning atau deteksi anomali. Seringkali ini muncul sebagai ajakan seperti **"Use Machine Learning to automatically detect anomalous log entry rates"** atau tombol **"Enable anomaly detection"**.
    *   Anda mungkin juga melihat bagian **"Log rate"** di bawah kategori "Anomaly detection with Machine Learning" atau "All Machine Learning jobs".

2.  **Aktifkan Deteksi Anomali untuk Laju Log**:
    *   Klik pada opsi untuk mengaktifkan deteksi anomali laju log.
    *   Kibana biasanya akan memandu Anda melalui proses singkat untuk membuat pekerjaan (job) Machine Learning baru.
    *   **Konfigurasi Pekerjaan (Job) ML (jika diminta)**:
        *   **Source Index Pattern**: Seharusnya sudah terisi dengan pola indeks yang sedang Anda lihat (misalnya, `app-logs-*`).
        *   **Job ID**: Kibana akan menyarankan ID pekerjaan (misalnya, `logs-ui-log-rate-app-logs-star`). Anda biasanya dapat menggunakan default.
        *   **Bucket Span**: Ini adalah interval waktu di mana data diagregasi dan dianalisis untuk anomali. Defaultnya seringkali 15 menit. Pilih sesuai dengan granularitas yang Anda butuhkan.
        *   **Detector**: Kibana akan secara otomatis mengkonfigurasi detektor untuk menganalisis laju log (misalnya, `high_count over @timestamp`).
    *   Klik **\"Create job\"** atau **\"Enable\"**.

    *   **Penting: Potensi Masalah dengan `event.dataset`**:
        *   Anda mungkin melihat peringatan atau error seperti *"At least one index matching app-logs-* lacks a required field event.dataset"* atau *"Your index configuration is not valid"*.
        *   Ini terjadi karena fitur deteksi anomali laju log di Logs UI seringkali mengharapkan field `event.dataset` ada di log Anda, yang merupakan bagian dari Elastic Common Schema (ECS). Field ini membantu mengkategorikan data.
        *   Dalam pipeline Filebeat -> Logstash kustom kita, field `event.dataset` tidak dibuat secara otomatis.
        *   **Solusi/Workaround**:
            1.  **Jika UI mengizinkan untuk melanjutkan tanpa `event.dataset` (misalnya, hanya peringatan)**: Anda bisa melanjutkan, namun beberapa fitur kategorisasi mungkin tidak berfungsi optimal.
            2.  **Jika UI memblokir (error validasi)**:
                *   **Opsi Sederhana (Lewati Fitur Ini)**: Anda dapat memilih untuk melewati fitur deteksi anomali laju log otomatis *dari dalam Logs UI* jika Anda tidak ingin memodifikasi pipeline Logstash Anda. Anda masih bisa membuat pekerjaan deteksi anomali secara manual melalui aplikasi Machine Learning utama, yang mungkin menawarkan lebih banyak fleksibilitas untuk skema data kustom.
                *   **Opsi Lanjutan (Modifikasi Logstash)**: Untuk membuat fitur ini berfungsi penuh, Anda bisa memodifikasi konfigurasi Logstash (`02-app-logs.conf`) untuk menambahkan field `event.dataset` secara manual. Tambahkan filter `mutate` di dalam blok `filter {}` Anda:
                    ```logstash
                    filter {
                      # ... filter grok dan date Anda yang sudah ada ...

                      mutate {
                        add_field => { "[event][dataset]" => "app.myapplication" } # Ganti "app.myapplication" dengan nama yang sesuai
                        add_field => { "[event][module]" => "generic" } # Opsional, bisa membantu
                      }
                    }
                    ```
                    Setelah melakukan perubahan ini, Anda perlu me-restart Logstash dan mengirim ulang beberapa log agar perubahan diterapkan pada dokumen baru di Elasticsearch. Kemudian, coba lagi membuat pekerjaan ML di Logs UI. Pilih nilai yang deskriptif untuk `[event][dataset]`, misalnya `yourapp.logs` atau `custom.applog`.

3.  **Biarkan Machine Learning Bekerja**:
    *   Setelah pekerjaan ML dibuat, ia akan mulai menganalisis data log historis Anda dan kemudian data baru saat masuk. Proses pembelajaran awal ini mungkin memerlukan waktu, tergantung pada volume data Anda.
    *   Anda dapat melihat status pekerjaan ML ini di **Stack Management > Machine Learning > Anomaly Detection Jobs**.

4.  **Lihat Hasil Anomali di Logs UI**:
    *   Kembali ke **Observability > Logs**.
    *   Akan ada indikasi visual (seringkali berupa grafik atau penanda) yang menunjukkan anomali laju log yang terdeteksi.
    *   Biasanya, laju log aktual akan ditampilkan bersama dengan batas atas dan bawah yang diharapkan (model baseline yang dipelajari oleh ML). Ketika laju aktual melampaui batas ini secara signifikan, itu ditandai sebagai anomali.
    *   Anda dapat mengklik anomali untuk melihat detail lebih lanjut, seperti tingkat keparahan anomali, waktu terjadinya, dan metrik terkait.

5.  **Interpretasi Anomali**:
    *   **Lonjakan Laju Log (High Count Anomaly)**: Bisa menandakan adanya badai log karena error berulang, peningkatan aktivitas pengguna yang tidak biasa, atau bahkan serangan.
    *   **Penurunan Laju Log (Low Count Anomaly)**: Bisa menandakan bahwa suatu layanan atau aplikasi berhenti mengirim log, yang mungkin berarti layanan tersebut mati atau mengalami masalah.
    *   Selidiki anomali dengan melihat log aktual pada rentang waktu tersebut untuk memahami penyebabnya.

**Manfaat Menggunakan ML untuk Deteksi Anomali Laju Log:**
*   **Otomatis**: Tidak perlu menentukan ambang batas secara manual. ML mempelajari baseline normal untuk sistem Anda.
*   **Adaptif**: Model ML dapat beradaptasi dengan perubahan musiman atau tren jangka panjang dalam laju log Anda.
*   **Proaktif**: Dapat memberi tahu Anda tentang masalah sebelum berdampak signifikan.

**Catatan Penting:**
*   Fitur Machine Learning di Elastic Stack memerlukan lisensi yang sesuai (seringkali Platinum atau Enterprise). Pastikan langganan Anda mendukungnya.
*   Kualitas deteksi anomali bergantung pada jumlah data dan variasi normal dalam laju log Anda. Semakin banyak data yang dipelajari, semakin baik modelnya.

Dengan memanfaatkan fitur ini, Anda dapat meningkatkan kemampuan observabilitas Anda dengan mendeteksi penyimpangan yang mungkin terlewatkan oleh pemantauan berbasis ambang batas statis.

Ini adalah dasar-dasar penggunaan Logs UI di Kibana Observability dengan alur Filebeat -> Logstash -> Elasticsearch. Dengan log yang terpusat dan diparsing dengan baik, Anda memiliki fondasi yang kuat untuk memantau dan memecahkan masalah sistem Anda.

### Bagian 2: Monitoring Metrics dengan Kibana Observability

Metrik adalah pengukuran numerik dari kinerja atau kesehatan sistem Anda dari waktu ke waktu. Aplikasi Metrics di Kibana Observability memungkinkan Anda untuk memvisualisasikan, menganalisis, dan memberi peringatan pada metrik dari seluruh infrastruktur dan aplikasi Anda, termasuk server, kontainer, layanan, dan banyak lagi.

**Tujuan Pembelajaran Bagian Ini:**
*   Memahami peran metrik dalam observability.
*   Mengirim metrik sistem ke Elasticsearch menggunakan Metricbeat.
*   Menavigasi dan memahami antarmuka pengguna Metrics di Kibana.
*   Menganalisis metrik infrastruktur dasar (CPU, memori, disk, jaringan).
*   Use Case: Mengidentifikasi potensi masalah kinerja server berdasarkan metrik.

**Apa itu Metrics di Konteks Observability?**

Berbeda dengan log yang merupakan rekaman peristiwa diskrit, metrik adalah representasi numerik dari data yang dikumpulkan selama interval waktu tertentu. Contohnya termasuk:
*   Penggunaan CPU (%)
*   Memori yang tersedia (GB)
*   Lalu lintas jaringan (byte/detik)
*   Jumlah permintaan per menit
*   Tingkat error (%)

Metrik sangat baik untuk:
*   **Pemantauan Tren**: Melihat bagaimana kinerja berubah dari waktu ke waktu.
*   **Peringatan (Alerting)**: Memicu notifikasi ketika ambang batas tertentu terlampaui.
*   **Perencanaan Kapasitas**: Memahami pemanfaatan sumber daya.
*   **Korelasi dengan Pilar Lain**: Menghubungkan lonjakan metrik dengan log error atau jejak APM.

**Langkah-langkah Hands-on:**

1.  **Mengirim Metrik Sistem (Metricbeat)** {#1-mengirim-metrik-sistem-metricbeat}

    Metricbeat adalah agen ringan yang Anda instal di server Anda untuk secara berkala mengumpulkan metrik dari sistem operasi dan dari layanan yang berjalan di server tersebut.

    *   **Instal Metricbeat** (jika belum):
        Sama seperti Filebeat, Anda dapat mengunduh dan menginstal Metricbeat. Pilih versi yang sesuai dengan Elastic Stack Anda (misalnya, 7.17.28 jika itu yang Anda gunakan).
        ```bash
        curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.17.28-amd64.deb
        sudo dpkg -i metricbeat-7.17.28-amd64.deb
        ```

    *   **Konfigurasi Metricbeat (`/etc/metricbeat/metricbeat.yml`)**:
        File konfigurasi utama Metricbeat adalah `metricbeat.yml`. Anda perlu mengkonfigurasi output ke Elasticsearch dan modul mana yang ingin Anda aktifkan.

        Contoh konfigurasi dasar:
        ```yaml
        #========================== Modules configuration ============================
        metricbeat.config.modules:
          # Glob pattern for configuration loading
          path: ${path.config}/modules.d/*.yml

          # Set to true to enable config reloading
          reload.enabled: false

        #==================== Elasticsearch Output =====================
        output.elasticsearch:
          hosts: ["localhost:9200"] # Sesuaikan jika Elasticsearch Anda ada di host lain
          #username: "elastic"
          #password: "your_password"

        #============================== Kibana =====================================
        setup.kibana:
          host: "localhost:5601" # Sesuaikan jika Kibana Anda ada di host lain
        ```

    *   **Aktifkan Modul yang Diinginkan**:
        Metricbeat menggunakan modul untuk mengumpulkan metrik dari berbagai sumber. Modul `system` adalah yang paling umum untuk memulai, karena mengumpulkan metrik inti OS (CPU, memori, disk, jaringan).
        Secara default, modul `system` biasanya sudah diaktifkan. Anda dapat memeriksa direktori `/etc/metricbeat/modules.d/`. File `system.yml` harus ada dan tidak diakhiri dengan `.disabled`.

        Untuk mengaktifkan modul (misalnya, `system` jika belum aktif):
        ```bash
        sudo metricbeat modules enable system
        ```
        Untuk menonaktifkan:
        ```bash
        sudo metricbeat modules disable <nama_modul>
        ```
        Anda dapat melihat daftar modul yang tersedia dengan:
        ```bash
        sudo metricbeat modules list
        ```
        Modul populer lainnya termasuk `docker`, `kubernetes`, `nginx`, `mysql`, `prometheus`, dll.

    *   **Setup Metricbeat (Penting untuk Dashboard)**:
        Jalankan perintah setup untuk memuat aset Kibana yang telah ditentukan sebelumnya untuk Metricbeat, seperti dashboard dan visualisasi.
        ```bash
        sudo metricbeat setup -e
        ```
        *Catatan: Anda hanya perlu menjalankan ini sekali per instance Metricbeat, kecuali jika Anda mengupgrade atau mengubah konfigurasi secara signifikan.*

    *   **Mulai dan Aktifkan Metricbeat**:
        ```bash
        sudo systemctl start metricbeat
        sudo systemctl enable metricbeat
        ```
        Periksa statusnya:
        ```bash
        sudo systemctl status metricbeat --no-pager
        ```
        Anda juga bisa melihat log Metricbeat itu sendiri (biasanya di `/var/log/metricbeat/metricbeat` atau melalui journalctl) untuk memastikan tidak ada error.

2.  **Navigasi ke Metrics UI di Kibana** {#2-navigasi-ke-metrics-ui-di-kibana}
    *   Buka Kibana di browser Anda.
    *   Dari menu navigasi utama (ikon hamburger), pilih **Observability > Metrics**.

3.  **Eksplorasi Antarmuka Metrics** {#3-eksplorasi-antarmuka-metrics}
    Antarmuka Metrics UI dirancang untuk memberikan gambaran umum tentang kesehatan infrastruktur Anda dan memungkinkan Anda untuk menelusuri detail.
    *   **Inventory / Infrastructure View**: Ini seringkali merupakan tampilan default. Ini menunjukkan representasi visual dari host, pod, atau kontainer Anda, seringkali dalam bentuk "waffle map" atau daftar. Setiap item dapat diklik untuk melihat detail metriknya.
        *   Anda dapat mengelompokkan item berdasarkan berbagai kriteria (misalnya, platform cloud, ketersediaan zona).
        *   Anda dapat mengubah metrik yang ditampilkan di peta (misalnya, dari penggunaan CPU ke penggunaan memori atau "Network Traffic").
    *   **Metrics Explorer**: Bagian ini memungkinkan Anda untuk membuat visualisasi kustom dari metrik tertentu, memilih agregasi yang berbeda, dan membandingkan metrik dari berbagai sumber.
    *   **Time Picker**: Sama seperti di Logs UI, untuk memilih rentang waktu analisis metrik.

4.  **Hands-on: Menganalisis Metrik Sistem Dasar** {#4-hands-on-menganalisis-metrik-sistem-dasar}

    Setelah Metricbeat mengirimkan data dan Anda membuka Metrics UI:

    *   **Menggunakan Inventory View (Waffle Map/Host List)**:
        1.  Secara default, Anda mungkin melihat "Waffle Map" yang merepresentasikan host Anda. Setiap kotak mewakili satu host. Warna dan ukuran kotak dapat mengindikasikan metrik tertentu (misalnya, penggunaan CPU).
        2.  Arahkan kursor ke salah satu kotak untuk melihat ringkasan metrik host tersebut.
        3.  **Ubah Metrik Tampilan**: Cari opsi untuk mengubah metrik yang ditampilkan di peta (misalnya, dari "CPU Usage" ke "Memory Usage" atau "Network Traffic"). Ini biasanya ada di bagian atas peta atau dalam menu pengaturan tampilan.
        4.  **Kelompokkan Host**: Jika Anda memiliki banyak host, gunakan opsi "Group by" untuk mengelompokkan host berdasarkan field seperti `cloud.availability_zone`, `host.os.name`, dll.
        5.  **Klik pada Host**: Klik salah satu host (kotak di waffle map atau entri dalam daftar host) untuk masuk ke tampilan detail metrik untuk host tersebut.

    *   **Melihat Detail Metrik Host**:
        1.  Setelah mengklik host, Anda akan dibawa ke halaman detail yang menampilkan berbagai grafik time-series untuk metrik utama host tersebut:
            *   **CPU Usage**: Penggunaan CPU secara keseluruhan dan per core.
            *   **Memory Usage**: Penggunaan memori total, terpakai, dan tersedia.
            *   **Disk I/O**: Operasi baca/tulis disk.
            *   **Network Traffic**: Lalu lintas jaringan masuk dan keluar.
            *   **Proses**: Daftar proses yang berjalan di host tersebut beserta metriknya (CPU, memori).
        2.  **Ubah Rentang Waktu**: Gunakan Time Picker di pojok kanan atas untuk mengubah rentang waktu analisis (misalnya, "Last 1 hour", "Last 24 hours"). Perhatikan bagaimana grafik metrik diperbarui.
        3.  **Interaksi dengan Grafik**: Arahkan kursor ke grafik untuk melihat nilai metrik pada titik waktu tertentu. Anda mungkin bisa memperbesar (zoom in) pada periode waktu tertentu di grafik.

    *   **Menggunakan Metrics Explorer**:
        1.  Kembali ke halaman utama Metrics UI (Observability > Metrics).
        2.  Cari tab atau tombol untuk **"Metrics Explorer"** atau "Explore metrics".
        3.  Di Metrics Explorer, Anda dapat membuat visualisasi metrik kustom:
            *   **Pilih Metrik**: Pilih metrik yang ingin Anda visualisasikan dari daftar dropdown (misalnya, `system.cpu.user.pct`, `system.memory.actual.used.pct`).
            *   **Agregasi**: Pilih fungsi agregasi (misalnya, `average`, `max`, `min`).
            *   **Filter**: Tambahkan filter KQL untuk mempersempit data (misalnya, `host.name: "your-server-name"`).
            *   **Group By**: Kelompokkan grafik berdasarkan field tertentu (misalnya, `host.name` untuk membandingkan CPU usage antar beberapa host).
        4.  Ini sangat berguna untuk analisis yang lebih mendalam atau ketika Anda ingin melihat metrik yang tidak ditampilkan secara default di dashboard host.

    *   **Melihat Dashboard Bawaan (Jika Ada)**:
        1.  Setelah menjalankan `sudo metricbeat setup -e`, jika ada dashboard bawaan untuk modul yang aktif (seperti `system`), Anda seharusnya dapat menemukannya di Kibana.
        2.  Di Kibana, buka **Dashboard** dari menu utama.
        3.  Cari dashboard dengan nama yang mengandung "Metricbeat" atau nama modul yang Anda aktifkan (misalnya, "System Overview").
        4.  Dashboard ini biasanya memberikan ringkasan visual dari metrik penting dan dapat langsung digunakan untuk pemantauan.

    *   **Melihat Data Mentah (Opsional)**:
        1.  Untuk pemahaman lebih dalam, Anda bisa melihat data mentah yang dikirim oleh Metricbeat ke Elasticsearch.
        2.  Di Kibana, buka **Dev Tools** dari menu utama.
        3.  Gunakan perintah `GET` untuk mengambil data dari indeks Metricbeat. Misalnya:
            ```json
            GET metricbeat-*/_search
            {
              "query": {
                "match_all": {}
              },
              "size": 10
            }
            ```
            Ini akan mengambil 10 dokumen pertama dari semua indeks yang diawali dengan `metricbeat-`.

5.  **Use Case: Mengidentifikasi Potensi Masalah Kinerja Server** {#5-use-case-mengidentifikasi-potensi-masalah-kinerja-server}

    *   **Skenario**: Pengguna melaporkan aplikasi yang berjalan di salah satu server Anda terasa lambat selama beberapa jam terakhir.
    *   **Langkah Investigasi menggunakan Metrics UI**:
        1.  **Buka Metrics UI**: Navigasi ke Observability > Metrics.
        2.  **Identifikasi Server**: Temukan server yang dimaksud di Inventory View. Anda bisa menggunakan search bar jika Anda tahu nama host-nya.
        3.  **Periksa Metrik Utama Server**: Klik server tersebut untuk melihat detail metriknya.
            *   **Atur Rentang Waktu**: Sesuaikan Time Picker ke periode waktu ketika kelambatan dilaporkan (misalnya, "Last 4 hours").
            *   **Analisis CPU Usage**: Apakah ada lonjakan penggunaan CPU yang berkelanjutan? Apakah CPU usage mendekati 100%? Jika ya, ini bisa menjadi bottleneck. Periksa juga `CPU load average`.
            *   **Analisis Memory Usage**: Apakah penggunaan memori sangat tinggi? Apakah ada sedikit memori bebas yang tersisa? Perhatikan `system.memory.actual.used.pct` atau `system.memory.swap.used.bytes`. Penggunaan swap yang tinggi seringkali mengindikasikan kekurangan RAM.
            *   **Analisis Disk I/O**: Apakah ada aktivitas disk yang sangat tinggi (`system.diskio.iops` atau `system.diskio.total.bytes`)? Disk yang lambat atau jenuh bisa menyebabkan kelambatan aplikasi. Periksa juga `system.filesystem.used.pct` untuk memastikan disk tidak penuh.
            *   **Analisis Network Traffic**: Apakah ada lonjakan lalu lintas jaringan yang tidak biasa?
        4.  **Periksa Proses Teratas**: Di halaman detail host, lihat tab atau bagian "Processes". Urutkan berdasarkan penggunaan CPU atau memori untuk mengidentifikasi proses mana yang paling banyak menggunakan sumber daya.
        5.  **Korelasi dengan Log (Langkah Berikutnya)**: Jika Anda menemukan lonjakan CPU pada waktu tertentu, Anda bisa mencatat waktu tersebut dan beralih ke Logs UI untuk mencari error atau aktivitas yang tidak biasa dari aplikasi atau sistem pada rentang waktu yang sama.

6.  **Troubleshooting Dasar Metricbeat** {#6-troubleshooting-dasar-metricbeat}

    Jika Anda tidak melihat metrik di Kibana setelah mengkonfigurasi Metricbeat:
    *   **Pastikan Metricbeat Berjalan**:
        ```bash
        sudo systemctl status metricbeat
        ```
        Jika tidak aktif, coba jalankan:
        ```bash
        sudo systemctl start metricbeat
        ```
        Jika gagal memulai, periksa log Metricbeat untuk error:
        ```bash
        sudo journalctl -u metricbeat -f
        # atau periksa file log jika dikonfigurasi (misalnya /var/log/metricbeat/metricbeat*)
        ```
    *   **Verifikasi Konfigurasi**:
        Periksa kembali file `/etc/metricbeat/metricbeat.yml` untuk kesalahan ketik, terutama pada bagian `output.elasticsearch` (hosts, username/password jika ada) dan `setup.kibana`.
        Anda dapat menguji konfigurasi dengan perintah:
        ```bash
        sudo metricbeat test config -e
        ```
    *   **Test Output ke Elasticsearch**:
        ```bash
        sudo metricbeat test output -e
        ```
        Ini akan mencoba mengirim satu event tes ke Elasticsearch dan melaporkan apakah berhasil.
    *   **Jalankan `setup` Lagi (Jika Perlu)**:
        Jika Anda yakin konfigurasi sudah benar tetapi dashboard atau index pattern Metricbeat tidak ada di Kibana, coba jalankan kembali perintah setup. Pastikan Kibana dapat dijangkau dari server tempat Metricbeat berjalan.
        ```bash
        sudo metricbeat setup -e
        ```
        Perhatikan output dari perintah ini untuk setiap error.
    *   **Periksa Koneksi ke Elasticsearch**:
        Pastikan Elasticsearch berjalan dan dapat dijangkau dari server Metricbeat pada host dan port yang dikonfigurasi.
        ```bash
        curl http://localhost:9200 # Ganti localhost:9200 jika perlu
        ```
    *   **Periksa Index Pattern di Kibana**:
        Di Kibana, buka **Stack Management > Kibana > Data Views (atau Index Patterns)**. Pastikan ada data view yang cocok dengan indeks Metricbeat (biasanya `metricbeat-*`). Jika tidak ada, atau jika ada tetapi tidak ada dokumen, ini menunjukkan masalah pengiriman data atau setup.
    *   **Periksa Indeks di Elasticsearch**:
        Anda dapat langsung memeriksa apakah indeks Metricbeat dibuat dan berisi dokumen di Elasticsearch:
        ```bash
        curl -X GET "localhost:9200/_cat/indices/metricbeat-*?v&s=index&h=index,status,health,docs.count,store.size"
        ```
    *   **Periksa Modul yang Diaktifkan**:
        Pastikan modul yang Anda inginkan (misalnya `system`) diaktifkan di direktori `/etc/metricbeat/modules.d/` dan file konfigurasinya (misalnya `system.yml`) sudah benar.
        ```bash
        sudo metricbeat modules list
        ```

Dengan metrik yang dikumpulkan dan divisualisasikan dengan benar, Anda mendapatkan wawasan penting tentang kinerja infrastruktur Anda, yang merupakan komponen kunci dari strategi observability yang komprehensif.

### Bagian 3: Application Performance Monitoring (APM)
*(Konten akan ditambahkan di sini)*

### Bagian 4: Uptime Monitoring
*(Konten akan ditambahkan di sini)*

---
## 4. Menyatukan Semuanya: Observability yang Terkorelasi
*(Konten akan ditambahkan di sini)*

---
## 5. Kesimpulan
*(Konten akan ditambahkan di sini)*