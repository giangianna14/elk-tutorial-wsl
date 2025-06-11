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

Application Performance Monitoring (APM) memberikan visibilitas mendalam ke dalam kinerja aplikasi Anda dengan melacak request, dependencies, database queries, dan bottlenecks. Elastic APM mengumpulkan traces yang detail dari aplikasi terdistribusi untuk membantu Anda memahami alur request dan mengidentifikasi masalah performa.

**Tujuan Pembelajaran Bagian Ini:**
*   Memahami konsep traces, spans, dan transactions dalam APM.
*   Menginstal dan mengkonfigurasi APM Server.
*   Menginstrumentasi aplikasi Python sederhana dengan Elastic APM Agent.
*   Menganalisis traces dan performa aplikasi di Kibana APM UI.
*   Use Case: Mengidentifikasi bottleneck performa dalam aplikasi.

**Apa itu APM Traces?**

APM traces memberikan gambaran lengkap tentang perjalanan request melalui sistem Anda:
*   **Transaction**: Operasi tingkat tinggi seperti HTTP request atau background job.
*   **Span**: Unit kerja dalam transaction, seperti database query atau external API call.
*   **Service Map**: Visualisasi dependencies antar services.

**Langkah-langkah Hands-on:**

1.  **Instalasi APM Server** {#1-instalasi-apm-server}

    APM Server menerima data APM dari agents dan mengirimkannya ke Elasticsearch.

    *   **Unduh dan Instal APM Server**:
        ```bash
        curl -L -O https://artifacts.elastic.co/downloads/apm-server/apm-server-7.17.28-amd64.deb
        sudo dpkg -i apm-server-7.17.28-amd64.deb
        ```

    *   **Konfigurasi APM Server (`/etc/apm-server/apm-server.yml`)**:
        ```yaml
        apm-server:
          host: "localhost:8200"
          
        output.elasticsearch:
          hosts: ["localhost:9200"]
          
        setup.kibana:
          host: "localhost:5601"
        ```

    *   **Setup dan Start APM Server**:
        ```bash
        sudo apm-server setup -e
        sudo systemctl start apm-server
        sudo systemctl enable apm-server
        sudo systemctl status apm-server --no-pager
        ```

2.  **Menginstrumentasi Aplikasi Python** {#2-menginstrumentasi-aplikasi-python}

    Kita akan membuat aplikasi Python sederhana dengan Flask yang diinstrumentasi dengan Elastic APM.

    *   **Instal Dependencies**:
        ```bash
        cd /home/giangianna/elk-tutorial-wsl/hands-on-elk-monitoring/
        sudo apt-get install python3-pip -y
        pip3 install flask elastic-apm[flask] requests
        ```

    *   **Buat Aplikasi Web Sederhana**:
        Buat file `web-app/flask_app.py`:
        ```python
        from flask import Flask, jsonify, request
        from elasticapm.contrib.flask import ElasticAPM
        import requests
        import time
        import random
        import logging

        app = Flask(__name__)

        # Konfigurasi Elastic APM
        app.config['ELASTIC_APM'] = {
            'SERVICE_NAME': 'python-web-app',
            'SECRET_TOKEN': '',  # Kosong untuk development
            'SERVER_URL': 'http://localhost:8200',
            'ENVIRONMENT': 'development',
        }

        apm = ElasticAPM(app)

        # Setup logging
        logging.basicConfig(level=logging.INFO)
        logger = logging.getLogger(__name__)

        @app.route('/')
        def home():
            logger.info("Home endpoint accessed")
            return jsonify({"message": "Hello from APM monitored Flask app!"})

        @app.route('/slow')
        def slow_endpoint():
            """Endpoint yang lambat untuk demonstrasi APM"""
            logger.info("Slow endpoint accessed")
            
            # Simulasi operasi lambat
            time.sleep(random.uniform(1, 3))
            
            # Simulasi database query
            simulate_database_query()
            
            return jsonify({"message": "This was a slow operation"})

        @app.route('/error')
        def error_endpoint():
            """Endpoint yang menghasilkan error"""
            logger.error("Error endpoint accessed - generating error")
            raise Exception("This is a simulated error for APM testing")

        @app.route('/external')
        def external_call():
            """Endpoint yang memanggil service eksternal"""
            logger.info("External call endpoint accessed")
            
            try:
                # Simulasi panggilan ke API eksternal
                response = requests.get('https://httpbin.org/delay/1', timeout=5)
                return jsonify({
                    "external_response": response.json(),
                    "status": "success"
                })
            except Exception as e:
                logger.error(f"External call failed: {str(e)}")
                return jsonify({"error": str(e)}), 500

        def simulate_database_query():
            """Simulasi database query untuk APM tracing"""
            with apm.capture_span('database.query', span_type='db'):
                # Simulasi waktu database query
                time.sleep(random.uniform(0.1, 0.5))
                logger.info("Database query executed")

        if __name__ == '__main__':
            app.run(host='0.0.0.0', port=5000, debug=True)
        ```

    *   **Jalankan Aplikasi Flask**:
        ```bash
        mkdir -p /home/giangianna/elk-tutorial-wsl/hands-on-elk-monitoring/web-app
        cd /home/giangianna/elk-tutorial-wsl/hands-on-elk-monitoring/web-app
        python3 flask_app.py
        ```

3.  **Generate Traffic untuk APM Data** {#3-generate-traffic-untuk-apm-data}

    Buat script untuk menghasilkan traffic ke aplikasi:

    *   **Buat Load Testing Script (`load_test.py`)**:
        ```python
        import requests
        import time
        import random
        from concurrent.futures import ThreadPoolExecutor
        import logging

        logging.basicConfig(level=logging.INFO)
        logger = logging.getLogger(__name__)

        BASE_URL = "http://localhost:5000"

        endpoints = [
            "/",
            "/slow", 
            "/external",
            "/error"  # Ini akan menghasilkan error traces
        ]

        def make_request(endpoint):
            try:
                url = f"{BASE_URL}{endpoint}"
                response = requests.get(url, timeout=10)
                logger.info(f"Request to {endpoint}: Status {response.status_code}")
                return response.status_code
            except Exception as e:
                logger.error(f"Request to {endpoint} failed: {str(e)}")
                return None

        def generate_load():
            with ThreadPoolExecutor(max_workers=3) as executor:
                for _ in range(50):  # Generate 50 requests
                    endpoint = random.choice(endpoints)
                    executor.submit(make_request, endpoint)
                    time.sleep(random.uniform(0.5, 2))  # Random delay

        if __name__ == "__main__":
            logger.info("Starting load test...")
            generate_load()
            logger.info("Load test completed")
        ```

    *   **Jalankan Load Test** (di terminal terpisah):
        ```bash
        cd /home/giangianna/elk-tutorial-wsl/hands-on-elk-monitoring/web-app
        python3 load_test.py
        ```

4.  **Navigasi ke APM UI di Kibana** {#4-navigasi-ke-apm-ui-di-kibana}

    *   Buka Kibana: **Observability > APM**.
    *   Anda akan melihat service `python-web-app` dalam daftar services.

5.  **Eksplorasi APM UI** {#5-eksplorasi-apm-ui}

    *   **Services Overview**: 
        *   Menampilkan daftar semua services yang monitored.
        *   Metrics seperti Throughput (requests/minute), Response time, Error rate.
        
    *   **Service Details**:
        *   Klik pada service `python-web-app`.
        *   **Transactions**: Melihat semua HTTP endpoints dan performanya.
        *   **Dependencies**: Service maps yang menunjukkan dependencies.
        *   **Errors**: Daftar error yang terjadi dengan stack traces.
        
    *   **Transaction Details**:
        *   Klik pada salah satu transaction (misalnya `GET /slow`).
        *   **Trace Timeline**: Visualisasi spans dalam transaction.
        *   **Metadata**: Headers, user info, custom data.

6.  **Analisis Performa dan Troubleshooting** {#6-analisis-performa-dan-troubleshooting}

    *   **Identifikasi Slow Transactions**:
        *   Di halaman service, urutkan transactions berdasarkan response time.
        *   Klik pada transaction yang lambat untuk melihat trace detail.
        
    *   **Analisis Error Traces**:
        *   Buka tab "Errors" untuk melihat semua error.
        *   Klik pada error untuk melihat full stack trace.
        
    *   **Service Map**:
        *   Visualisasi dependencies antar services.
        *   Menunjukkan external calls dan database connections.

7.  **Use Case: Debugging Performance Issue** {#7-use-case-debugging-performance-issue}

    *   **Skenario**: Endpoint `/slow` dilaporkan sangat lambat.
    *   **Investigasi dengan APM**:
        1. Buka APM UI dan pilih service `python-web-app`.
        2. Lihat transaction `GET /slow` - perhatikan average response time.
        3. Klik pada transaction untuk melihat sample traces.
        4. Dalam trace timeline, identifikasi span mana yang paling lama:
           - `time.sleep()` operations
           - `database.query` span
           - External HTTP calls
        5. Gunakan informasi ini untuk optimasi code.

**Troubleshooting APM:**

*   **Tidak ada data APM**: Periksa APM Server status dan konfigurasi agent.
*   **Missing spans**: Pastikan instrumentasi manual benar untuk custom operations.
*   **High overhead**: Konfigurasikan sampling rate di APM agent untuk production.

### Bagian 4: Uptime Monitoring

Uptime Monitoring membantu Anda memantau ketersediaan services, endpoints, dan infrastruktur dengan melakukan health checks secara berkala. Heartbeat adalah agent Elastic yang melakukan ping ke services Anda dan melaporkan status ketersediaannya.

**Tujuan Pembelajaran Bagian Ini:**
*   Memahami konsep uptime monitoring dan health checks.
*   Mengonfigurasi Heartbeat untuk memonitor HTTP endpoints.
*   Menggunakan Uptime UI di Kibana untuk melihat status ketersediaan.
*   Membuat alerts untuk downtime detection.
*   Use Case: Monitoring ketersediaan aplikasi web dan API.

**Apa itu Uptime Monitoring?**

Uptime monitoring melakukan checks berkala terhadap:
*   **HTTP/HTTPS endpoints**: Memastikan web aplikasi dapat diakses.
*   **TCP services**: Database, message queues, dll.
*   **ICMP pings**: Basic network connectivity.

**Langkah-langkah Hands-on:**

1.  **Instalasi dan Konfigurasi Heartbeat** {#1-instalasi-dan-konfigurasi-heartbeat}

    *   **Instal Heartbeat**:
        ```bash
        curl -L -O https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.17.28-amd64.deb
        sudo dpkg -i heartbeat-7.17.28-amd64.deb
        ```

    *   **Konfigurasi Heartbeat (`/etc/heartbeat/heartbeat.yml`)**:
        ```yaml
        #==================== Heartbeat monitors =====================
        heartbeat.config.monitors:
          path: ${path.config}/monitors.d/*.yml
          reload.enabled: true
          reload.period: 5s

        heartbeat.monitors:
        # Monitor Flask app
        - type: http
          id: flask-app-home
          name: "Flask App Home"
          urls: ["http://localhost:5000/"]
          schedule: '@every 30s'
          timeout: 10s
          check.response.status: [200]
          tags: ["web-app", "python", "critical"]

        - type: http
          id: flask-app-slow
          name: "Flask App Slow Endpoint"
          urls: ["http://localhost:5000/slow"]
          schedule: '@every 1m'
          timeout: 15s
          check.response.status: [200]
          tags: ["web-app", "python", "performance"]

        # Monitor Kibana
        - type: http
          id: kibana-health
          name: "Kibana Health"
          urls: ["http://localhost:5601/api/status"]
          schedule: '@every 1m'
          timeout: 10s
          check.response.status: [200]
          tags: ["infrastructure", "kibana"]

        # Monitor Elasticsearch
        - type: http
          id: elasticsearch-health
          name: "Elasticsearch Health"
          urls: ["http://localhost:9200/_cluster/health"]
          schedule: '@every 1m'
          timeout: 10s
          check.response.status: [200]
          check.response.body: ["green", "yellow"]
          tags: ["infrastructure", "elasticsearch"]

        # External service monitoring
        - type: http
          id: external-api
          name: "External HTTP API"
          urls: ["https://httpbin.org/status/200"]
          schedule: '@every 2m'
          timeout: 10s
          check.response.status: [200]
          tags: ["external", "api"]

        # TCP monitoring example
        - type: tcp
          id: elasticsearch-tcp
          name: "Elasticsearch TCP"
          hosts: ["localhost:9200"]
          schedule: '@every 1m'
          timeout: 3s
          tags: ["infrastructure", "tcp"]

        #==================== Elasticsearch Output =====================
        output.elasticsearch:
          hosts: ["localhost:9200"]

        #============================== Kibana =====================================
        setup.kibana:
          host: "localhost:5601"

        #============================== Processors =====================================
        processors:
          - add_host_metadata:
              when.not.contains.tags: forwarded
        ```

    *   **Setup dan Start Heartbeat**:
        ```bash
        sudo heartbeat setup -e
        sudo systemctl start heartbeat
        sudo systemctl enable heartbeat
        sudo systemctl status heartbeat --no-pager
        ```

2.  **Navigasi ke Uptime UI di Kibana** {#2-navigasi-ke-uptime-ui-di-kibana}

    *   Buka Kibana: **Observability > Uptime**.
    *   Anda akan melihat dashboard dengan overview semua monitors.

3.  **Eksplorasi Uptime UI** {#3-eksplorasi-uptime-ui}

    *   **Overview Dashboard**:
        *   **Up/Down Status**: Jumlah monitors yang up vs down.
        *   **Monitor List**: Daftar semua monitors dengan status terkini.
        *   **Snapshot Counts**: Histogram ketersediaan.
        
    *   **Monitor Details**:
        *   Klik pada salah satu monitor untuk melihat detail.
        *   **Ping History**: Timeline status checks.
        *   **Monitor Duration**: Response time over time.
        *   **Ping List**: Detail individual pings dengan response times.
        
    *   **Certificates**: 
        *   Monitoring SSL certificate expiration.
        *   Alerts untuk certificates yang akan expire.

4.  **Simulasi Downtime untuk Testing** {#4-simulasi-downtime-untuk-testing}

    *   **Hentikan Flask App** (untuk simulasi downtime):
        ```bash
        # Hentikan Flask app yang berjalan
        # Ctrl+C di terminal tempat Flask app berjalan
        ```
        
    *   **Tambah Monitor untuk Endpoint yang Tidak Ada**:
        Buat file `/etc/heartbeat/monitors.d/test-down.yml`:
        ```yaml
        - type: http
          id: non-existent-service
          name: "Non-existent Service"
          urls: ["http://localhost:9999/nonexistent"]
          schedule: '@every 30s'
          timeout: 5s
          check.response.status: [200]
          tags: ["test", "downtime"]
        ```
        
    *   **Reload Heartbeat Configuration**:
        ```bash
        sudo systemctl reload heartbeat
        ```

5.  **Monitoring dan Alerting** {#5-monitoring-dan-alerting}

    *   **Buat Uptime Alert Rule**:
        1. Di Kibana, buka **Stack Management > Rules and Connectors**.
        2. Klik **"Create rule"**.
        3. Pilih rule type: **"Uptime monitor status"**.
        4. **Configure conditions**:
           - **Monitor status**: `down`
           - **Location**: `any`
           - **Number of monitors**: `1` or more
           - **Time window**: `3 minutes`
        5. **Add actions**: Server log atau index untuk notification.
        6. **Save rule** dengan nama: `"Service Downtime Alert"`.

    *   **Monitor Alert Status**:
        - Generate downtime dengan menghentikan services.
        - Periksa status alert di Rules dashboard.

6.  **Use Case: Comprehensive Service Health Monitoring** {#6-use-case-comprehensive-service-health-monitoring}

    *   **Skenario**: Monitoring kesehatan complete ELK stack dan aplikasi.
    *   **Setup Monitoring**:
        1. **Infrastructure Level**:
           - Elasticsearch cluster health
           - Kibana availability  
           - Logstash (jika ada HTTP endpoint)
           
        2. **Application Level**:
           - Critical business endpoints
           - API response times
           - Authentication services
           
        3. **External Dependencies**:
           - Third-party APIs
           - CDN endpoints
           - Database connections

    *   **Dashboard Creation**:
        1. Buat dashboard kustom di Kibana.
        2. Tambahkan visualizations untuk:
           - Service availability percentage
           - Response time trends
           - Downtime incidents
           - Geographic monitoring (jika multi-location)

7.  **Advanced Uptime Configuration** {#7-advanced-uptime-configuration}

    *   **Custom Response Validation**:
        ```yaml
        - type: http
          id: api-health-check
          name: "API Health Check"
          urls: ["http://localhost:5000/health"]
          schedule: '@every 30s'
          check.response.status: [200]
          check.response.headers:
            content-type: "application/json"
          check.response.body:
            - "status.*ok"
            - "database.*connected"
          tags: ["api", "health-check"]
        ```

    *   **Multi-location Monitoring** (jika ada multiple Heartbeat instances):
        ```yaml
        name: "production-heartbeat-east"
        tags: ["production", "us-east-1"]
        ```

**Troubleshooting Uptime:**

*   **Missing uptime data**: Periksa Heartbeat service status dan network connectivity.
*   **False positive downs**: Adjust timeout values dan check intervals.
*   **SSL certificate warnings**: Ensure proper certificate validation settings.

**Best Practices:**

*   **Realistic check intervals**: Jangan terlalu frequent untuk avoid noise.
*   **Meaningful tags**: Gunakan tags untuk grouping dan filtering.
*   **Response validation**: Check tidak hanya status code tapi juga content.
*   **Alert tuning**: Configure appropriate thresholds untuk minimize false alarms.

---
## 4. Menyatukan Semuanya: Observability yang Terkorelasi

Kekuatan sejati observability terletak pada kemampuan untuk mengorelasikan data dari logs, metrics, APM traces, dan uptime monitoring untuk mendapatkan pemahaman holistik tentang sistem Anda. Dalam bagian ini, kita akan melihat bagaimana menggabungkan semua pilar observability untuk investigasi masalah yang efektif.

### Skenario: Investigasi Performance Degradation

**Situasi**: Pengguna melaporkan aplikasi web terasa lambat dan kadang-kadang timeout.

### Langkah Investigasi Terkorelasi:

#### 1. **Mulai dengan Uptime Monitoring**
   
   *   **Buka Observability > Uptime**
   *   **Periksa Status Monitors**:
       ```
       Flask App Home: UP (tapi response time meningkat)
       Flask App Slow Endpoint: DOWN/TIMEOUT (beberapa failures)
       Elasticsearch Health: UP
       Kibana Health: UP
       ```
   *   **Identifikasi Time Window**: Catat kapan response time mulai meningkat (misalnya, 14:30-15:00).

#### 2. **Korelasi dengan APM Traces**

   *   **Buka Observability > APM**
   *   **Analisis Service Performance**:
       ```
       Service: python-web-app
       - Response time: Meningkat dari 200ms → 3000ms
       - Error rate: Meningkat dari 1% → 15%
       - Throughput: Turun dari 50 rpm → 20 rpm
       ```
   *   **Deep Dive ke Transaction Details**:
       - Klik transaction `GET /slow`
       - Lihat trace timeline: database spans mengambil 80% total time
       - Identifikasi bottleneck: `database.query` span consistently slow

#### 3. **Investigasi Infrastructure Metrics**

   *   **Buka Observability > Metrics**
   *   **Analisis Host Performance** (time range: 14:30-15:00):
       ```
       CPU Usage: Normal (30-40%)
       Memory Usage: High (85-95%) - POTENTIAL ISSUE
       Disk I/O: Elevated (vysoká zápis activity)
       Network: Normal
       ```
   *   **Periksa Process Details**:
       - High memory usage dari process `elasticsearch`
       - Disk I/O spikes korelasi dengan slow database queries

#### 4. **Analisis Logs untuk Root Cause**

   *   **Buka Observability > Logs**
   *   **Filter berdasarkan time window**: 14:30-15:00
   *   **Search query strategis**:
       ```kql
       log_level: ERROR OR log_level: WARN OR message: "timeout" OR message: "slow"
       ```
   *   **Findings**:
       ```
       14:32 ERROR: Database connection pool exhausted
       14:35 WARN: Query execution time exceeded 5000ms
       14:38 ERROR: OutOfMemoryError in application heap
       ```

#### 5. **Korelasi Timeline Events**

   **Membuat Timeline Investigasi**:
   
   | Time  | Uptime | APM | Metrics | Logs |
   |-------|--------|-----|---------|------|
   | 14:30 | Response time ↗ | Transaction latency ↗ | Memory 85% | Connection pool warnings |
   | 14:32 | Timeouts start | Error rate 10% | Memory 90% | Pool exhausted errors |
   | 14:35 | Monitor DOWN | Error rate 15% | Memory 95% | Query timeout errors |
   | 14:38 | Complete failure | Service unavailable | Disk I/O spike | OutOfMemory errors |

### Workflow Korelasi Otomatis

#### 1. **Menggunakan Kibana Lens untuk Cross-correlation**

   *   **Buat Dashboard Gabungan**:
       ```
       Panel 1: Uptime response times (line chart)
       Panel 2: APM transaction rate & errors (dual axis)
       Panel 3: Infrastructure CPU/Memory (area chart) 
       Panel 4: Log error counts (bar chart)
       ```

   *   **Sinkronisasi Time Picker**: Semua panels menggunakan time range yang sama.

#### 2. **Alerting Strategy Terintegrasi**

   *   **Multi-condition Alert Rules**:
       ```yaml
       Rule: "Application Performance Degradation"
       Conditions:
         - Uptime response time > 2000ms (1 minute)
         - APM error rate > 5% (2 minutes)
         - Memory usage > 90% (3 minutes)
       Actions:
         - Create incident in ticketing system
         - Send Slack notification with links ke relevant dashboards
       ```

#### 3. **Investigating dengan Service Maps**

   *   **APM Service Map** menunjukkan:
       ```
       Web App → Database: High latency, errors
       Web App → External API: Normal
       Web App → File System: Normal
       ```
   *   **Identifikasi dependency**: Database adalah bottleneck utama.

### Advanced Correlation Techniques

#### 1. **Custom Fields untuk Korelasi**

   **Menambahkan correlation IDs di semua telemetry data**:

   *   **Logs (Logstash config)**:
       ```logstash
       filter {
         if [agent][name] == "wsl-filebeat-app" {
           mutate {
             add_field => { "service.name" => "python-web-app" }
             add_field => { "service.environment" => "development" }
           }
         }
       }
       ```

   *   **APM traces sudah termasuk** `service.name` dan `service.environment`.

   *   **Metrics (Metricbeat config)**:
       ```yaml
       processors:
         - add_fields:
             target: service
             fields:
               name: "python-web-app"
               environment: "development"
       ```

#### 2. **Cross-app Navigation di Kibana**

   *   **Dari APM ke Logs**: Click "View logs" button di APM transaction detail.
   *   **Dari Logs ke Metrics**: Filter berdasarkan `host.name` dan jump ke Infrastructure view.
   *   **Dari Uptime ke APM**: Click monitor name untuk melihat corresponding APM service.

#### 3. **Machine Learning untuk Anomaly Correlation**

   *   **Enable ML jobs** untuk setiap data type:
       ```
       - Log rate anomaly detection
       - APM latency anomaly detection  
       - Infrastructure metric anomalies
       - Uptime response time anomalies
       ```

   *   **Correlate anomalies** berdasarkan time windows yang overlapping.

### Praktik Terbaik untuk Observability Terintegrasi

#### 1. **Standardisasi Naming dan Tagging**

   ```yaml
   Standard Tags:
     service.name: "consistent-service-names"
     service.environment: "dev|staging|prod"
     service.version: "1.2.3"
     team: "backend|frontend|infrastructure"
     criticality: "critical|high|medium|low"
   ```

#### 2. **Centralized Dashboards**

   *   **Service Health Dashboard**: Kombinasi uptime, APM, key metrics per service.
   *   **Infrastructure Overview**: Host metrics dengan overlay log error rates.
   *   **Incident Response Dashboard**: Real-time view semua critical alerts.

#### 3. **Runbooks Terintegrasi**

   **Template investigasi**:
   ```markdown
   1. Check Uptime status dan response times
   2. Review APM service overview untuk errors/latency
   3. Correlate dengan infrastructure metrics
   4. Search logs untuk error details dan root cause
   5. Check service dependencies di service map
   6. Escalate with correlated evidence
   ```

### Automation dan Intelligent Alerting

#### 1. **Smart Alert Correlation**

   ```yaml
   Intelligent Alert Rule:
     Trigger: Multiple related alerts dalam 5 menit
     Conditions:
       - Uptime monitor DOWN
       - APM error rate spike  
       - Infrastructure resource high
     Action: 
       - Group related alerts
       - Auto-create correlation timeline
       - Include suggested investigation steps
   ```

#### 2. **Automated Root Cause Suggestions**

   Menggunakan ML dan pattern recognition untuk suggest kemungkinan root causes berdasarkan historical incident data.

Dengan menggabungkan semua aspek observability ini, Anda dapat secara dramatis mengurangi Mean Time To Resolution (MTTR) dan meningkatkan kepercayaan sistem secara keseluruhan.

---
## 5. Kesimpulan

Dalam tutorial hands-on ini, kita telah menjelajahi komprehensif menu Observability di Kibana dan memahami bagaimana menggabungkan keempat pilar observability untuk menciptakan strategi monitoring yang holistik dan efektif.

### Ringkasan Pembelajaran

#### **1. Logs - Foundation of Observability**
*   **Implementasi**: Filebeat → Logstash → Elasticsearch pipeline untuk structured log processing
*   **Key Skills**: 
    - Konfigurasi log parsing dengan Grok patterns
    - KQL queries untuk investigasi logs
    - Real-time log streaming dan filtering
    - Alert rules untuk critical log events
*   **Use Cases**: Error investigation, audit trails, application debugging

#### **2. Metrics - Infrastructure Health Monitoring**
*   **Implementasi**: Metricbeat untuk system dan application metrics collection
*   **Key Skills**:
    - Infrastructure monitoring dengan CPU, memory, disk, network metrics
    - Custom dashboard creation untuk performance trends
    - Metrics exploration dan correlation analysis
    - Capacity planning berdasarkan historical data
*   **Use Cases**: Performance monitoring, resource planning, SLA compliance

#### **3. APM - Application Performance Deep Dive**
*   **Implementasi**: APM Server dengan Elastic APM agents untuk distributed tracing
*   **Key Skills**:
    - Transaction tracing dan span analysis
    - Service dependency mapping
    - Performance bottleneck identification
    - Error tracking dengan full stack traces
*   **Use Cases**: Application optimization, microservices debugging, user experience monitoring

#### **4. Uptime - Service Availability Monitoring**
*   **Implementasi**: Heartbeat untuk external dan internal service monitoring
*   **Key Skills**:
    - HTTP/TCP health checks configuration
    - SSL certificate monitoring
    - Multi-location availability tracking
    - Downtime alerting dan incident response
*   **Use Cases**: SLA monitoring, external dependency tracking, business continuity

#### **5. Integrated Observability - The Complete Picture**
*   **Korelasi Cross-platform**: Menghubungkan events dari semua telemetry sources
*   **Intelligent Alerting**: Multi-condition alerts yang mengurangi noise
*   **Root Cause Analysis**: Structured approach untuk incident investigation
*   **Automation**: ML-powered anomaly detection dan automated correlation

### Manfaat Strategis yang Dicapai

#### **Operational Excellence**
*   **Reduced MTTR**: Dari investigation manual yang memakan waktu jam menjadi menit dengan correlated data
*   **Proactive Monitoring**: Deteksi masalah sebelum berdampak ke end users
*   **Data-Driven Decisions**: Keputusan infrastruktur dan aplikasi berdasarkan real observability data

#### **Team Collaboration**
*   **Shared Visibility**: Developer, SRE, dan Operations teams menggunakan platform yang sama
*   **Standardized Processes**: Consistent troubleshooting workflows dan runbooks
*   **Knowledge Sharing**: Historical incident data menjadi pembelajaran untuk team

#### **Business Impact**
*   **Improved User Experience**: Faster issue resolution = better customer satisfaction
*   **Cost Optimization**: Right-sizing infrastructure berdasarkan actual usage patterns
*   **Risk Mitigation**: Early warning systems untuk potential business disruptions

### Next Steps dan Recommendations

#### **Immediate Actions**
1. **Implement Basic Setup**: Start dengan logs dan metrics untuk critical applications
2. **Establish Baselines**: Collect 2-4 weeks data untuk establish normal behavior patterns
3. **Create Essential Dashboards**: Service health, infrastructure overview, error tracking
4. **Setup Critical Alerts**: High-impact, low-noise alerts untuk immediate issues

#### **Medium-term Improvements**
1. **Expand APM Coverage**: Instrument semua critical applications dengan distributed tracing
2. **Advanced Alerting**: Implement intelligent alerting dengan correlation rules
3. **Automated Runbooks**: Create automated response untuk common incidents
4. **Team Training**: Ensure semua team members comfortable dengan observability tools

#### **Long-term Strategy**
1. **ML Integration**: Leverage machine learning untuk predictive monitoring
2. **Custom Solutions**: Develop domain-specific monitoring untuk unique business requirements
3. **Cross-platform Integration**: Extend observability ke cloud services, third-party systems
4. **Continuous Improvement**: Regular review dan optimization observability strategy

### Technology Evolution Considerations

#### **Elastic Stack Ecosystem**
*   **Stay Current**: Regular updates untuk security patches dan new features
*   **Cloud Migration**: Consider Elastic Cloud untuk managed services dan scalability
*   **Integration Opportunities**: Explore integrations dengan CI/CD, ticketing systems, communication tools

#### **Industry Best Practices**
*   **OpenTelemetry**: Consider adoption untuk vendor-neutral observability
*   **Site Reliability Engineering**: Implement SRE practices dengan observability sebagai foundation
*   **DevOps Culture**: Observability sebagai integral part of development lifecycle

### Final Thoughts

Observability bukan hanya tentang tools dan technology - ini adalah cultural shift menuju data-driven operations dan proactive system management. Dengan foundation yang kuat di Elastic Stack Observability seperti yang telah kita pelajari, Anda memiliki platform yang powerful untuk:

*   **Understand** sistem Anda di semua levels - dari business transactions sampai infrastructure details
*   **Respond** quickly ke incidents dengan correlated data dan automated workflows  
*   **Improve** continuously berdasarkan insights dari observability data
*   **Scale** operasi Anda dengan confidence karena comprehensive monitoring coverage

Ingatlah bahwa observability adalah journey, bukan destination. Mulai dengan basics, iterate berdasarkan pembelajaran, dan gradually build towards sophisticated monitoring dan alerting ecosystem yang truly supports business objectives Anda.

**Happy Monitoring!** 🚀

---

### Resources dan Further Reading

*   **Elastic Documentation**: [https://www.elastic.co/guide/](https://www.elastic.co/guide/)
*   **OpenTelemetry**: [https://opentelemetry.io/](https://opentelemetry.io/)
*   **SRE Book**: [https://sre.google/sre-book/](https://sre.google/sre-book/)
*   **Monitoring Best Practices**: Community forums dan industry blogs
*   **Elastic Community**: [https://discuss.elastic.co/](https://discuss.elastic.co/)

### Acknowledgments

Tutorial ini dikembangkan berdasarkan best practices dari komunitas Elastic Stack, SRE community, dan real-world implementation experiences. Terima kasih kepada semua kontributor dalam ecosystem observability yang telah membuat tools dan knowledge ini accessible untuk semua.