# Sistem Otomatisasi Backup Server dengan BorgBackup dan iDrive E2

## Pengenalan

Repositori ini berisi kumpulan skrip bash untuk mengotomatiskan backup server Linux menggunakan BorgBackup (Borg) dan iDrive E2 sebagai penyimpanan cloud. Sistem ini dirancang untuk menyediakan solusi backup yang aman, terenkripsi, dan dapat diandalkan dengan proses pemulihan yang mudah.

### Fitur Utama

- ✅ **Backup Terenkripsi**: Semua data backup dienkripsi dengan aman menggunakan BorgBackup
- ✅ **Deduplikasi**: Menghemat ruang penyimpanan dengan hanya menyimpan perubahan data
- ✅ **Otomatisasi**: Penjadwalan backup menggunakan systemd timer
- ✅ **Penyimpanan Cloud**: Integrasi dengan layanan cloud iDrive E2 (kompatibel S3)
- ✅ **Pemulihan Mudah**: Skrip sederhana untuk memulihkan data dari backup terbaru

## Teknologi yang Digunakan

### iDrive E2

iDrive E2 adalah layanan penyimpanan cloud yang kompatibel dengan Amazon S3, menawarkan biaya yang lebih rendah dan cocok untuk penyimpanan jangka panjang. Layanan ini menyediakan API yang kompatibel dengan S3 sehingga dapat diakses menggunakan tools seperti rclone.

### BorgBackup (Borg)

BorgBackup adalah utilitas backup deduplikasi yang efisien dan aman. Fitur utamanya:
- **Deduplikasi**: Mengidentifikasi dan hanya menyimpan bagian file yang berubah
- **Kompresi**: Mendukung berbagai algoritma kompresi (zstd, lz4, dll)
- **Enkripsi**: Menyediakan enkripsi end-to-end untuk data backup
- **Verifikasi**: Memastikan integritas data dengan checksums

### Borgmatic

Borgmatic adalah wrapper untuk BorgBackup yang menyederhanakan konfigurasi dan penggunaan BorgBackup melalui file YAML sederhana. Dengan borgmatic, konfigurasi backup yang kompleks dapat dikelola dengan mudah.

### rclone

rclone adalah utilitas command line untuk mengelola file di penyimpanan cloud, termasuk layanan yang kompatibel dengan S3 seperti iDrive E2. Dalam sistem ini, rclone digunakan untuk memasang bucket iDrive E2 sebagai sistem file lokal.

## ⚠️ PERINGATAN PENTING ⚠️

### Tentang BORG_PASSPHRASE

Di dalam beberapa skrip, Anda akan menemukan baris berikut:
```bash
export BORG_PASSPHRASE="GantiPassphraseKuat"
```

**Passphrase ini adalah KUNCI ENKRIPSI untuk data backup Anda!**

- **WAJIB mengganti** "GantiPassphraseKuat" dengan passphrase yang kuat.
- **SIMPAN passphrase ini dengan aman**. Jika hilang, data backup TIDAK DAPAT dipulihkan!
- Gunakan **minimal 16 karakter** yang mencakup huruf, angka, dan simbol.
- Gunakan passphrase yang **sama** di semua skrip terkait Borg.
- **JANGAN gunakan karakter khusus** yang dapat mengganggu interpretasi shell seperti `$`, `\`, `"`, atau `'` tanpa escape yang tepat.

## Struktur Skrip

Kumpulan skrip ini disusun secara berurutan untuk memudahkan setup sistem backup. Jalankan skrip sesuai urutan berikut:

1. **depedencies.sh** - Menginstal semua tools yang diperlukan
2. **fuse.sh** - Mengaktifkan modul FUSE untuk mounting penyimpanan cloud
3. **idrive.sh** - Mengkonfigurasi rclone untuk akses iDrive E2
4. **setup_e2_mount.sh** - Memasang (mount) bucket iDrive E2 ke sistem file lokal
5. **init_borg_repo.sh** - Menginisialisasi repositori Borg terenkripsi
6. **setup_borgmatic_config.sh** - Mengkonfigurasi pengaturan backup borgmatic
7. **setup_borgmatic_timer.sh** - Mengatur jadwal backup otomatis menggunakan systemd
8. **test_borgmatic.sh** - Menjalankan dan menguji backup manual
9. **restore_server.sh** - Memulihkan data dari backup terbaru

## Persyaratan Sistem

- Sistem operasi Linux (direkomendasikan: CentOS, RHEL, Fedora, atau distribusi berbasis RPM lainnya)
- Akses root atau sudo
- Koneksi internet untuk mengunduh tools dan mengakses iDrive E2

Sekarang mari kita bahas masing-masing skrip secara detail:

# File: setup_backup_tools.sh

File ini bertujuan untuk menginstal dan mengkonfigurasi dependensi yang diperlukan untuk sistem backup pada server, khususnya yang berkaitan dengan `rclone`, `borgbackup`, dan `borgmatic`.

## Tujuan

- **Instalasi Dependensi**: Memastikan bahwa semua paket dan alat yang diperlukan tersedia di server, termasuk FUSE, rclone, BorgBackup, dan Borgmatic.
- **Konfigurasi Lingkungan**: Mengaktifkan modul kernel FUSE dan menyesuaikan tautan simbolik untuk memastikan kompatibilitas alat.

## Bagian-Bagian Penting

- **Logika Utama**:
  - Menginstal FUSE dan dependensi lainnya (`fuse`, `fuse-libs`, `curl`, `python3-pip`) menggunakan `dnf`.
  - Menginstal rclone dari RPM resmi yang diunduh dari situs web rclone.
  - Menginstal BorgBackup dan Borgmatic via `pip3`.
  - Mengaktifkan modul kernel FUSE dengan `modprobe`.
  - Membuat tautan simbolik `fusermount3` ke `fusermount` jika diperlukan untuk mendukung `rclone mount`.

- **Error Handling**: Menggunakan `set -euo pipefail` untuk menghentikan eksekusi pada kesalahan dan menangani kesalahan pipa dengan baik.

## Cara Kerja

1. **Instalasi FUSE dan Dependensi**  
   Menggunakan perintah `dnf install -y` untuk menginstal paket `fuse`, `fuse-libs`, `curl`, dan `python3-pip`.

2. **Instalasi rclone**  
   Mengunduh RPM rclone dari situs resmi dengan `curl`, lalu menginstalnya dengan `rpm -Uvh`. Jika rclone sudah terpasang, script akan mencetak pesan "rclone sudah terpasang".

3. **Instalasi BorgBackup dan Borgmatic**  
   Menggunakan `pip3 install --upgrade` untuk memasang atau memperbarui paket `borgbackup` dan `borgmatic`.

4. **Aktivasi Modul FUSE**  
   Memuat modul kernel `fuse` dengan `modprobe` dan memverifikasi keberhasilannya dengan `lsmod | grep fuse`. Jika gagal, mencetak pesan peringatan.

5. **Tautan Simbolik fusermount3**  
   Memeriksa keberadaan `/usr/bin/fusermount3`. Jika tidak ada, membuat tautan simbolik dari `/usr/bin/fusermount` ke `/usr/bin/fusermount3` dan mencetak pesan konfirmasi.

## Catatan

- Script ini diasumsikan dijalankan pada sistem berbasis `dnf` seperti Fedora atau CentOS.
- Penggunaan `set -euo pipefail` memastikan eksekusi yang aman dengan menghentikan script pada kesalahan.
- Tautan simbolik `fusermount3` diperlukan untuk mendukung fitur `rclone mount`.


Berikut adalah penjelasan untuk file Bash yang Kedua:


# File: activate_fuse.sh

File ini adalah skrip Bash yang bertujuan untuk mengaktifkan modul FUSE di kernel Linux dan memastikan tautan simbolik `fusermount3` tersedia, yang diperlukan untuk mendukung operasi seperti `rclone mount`.

## Kode Skrip

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [1] Aktifkan modul FUSE di kernel ==="
modprobe fuse || { echo "❌ Gagal memuat modul FUSE"; exit 1; }

if lsmod | grep -q '^fuse'; then
    echo "✔️  Modul FUSE aktif"
else
    echo "❌ Modul FUSE tidak terdeteksi di kernel"
    exit 1
fi

echo "=== [2] Buat symlink fusermount3 → fusermount (jika belum ada) ==="
if [[ ! -e /usr/bin/fusermount3 ]]; then
    ln -s /usr/bin/fusermount /usr/bin/fusermount3
    echo "✔️  Symlink fusermount3 dibuat"
else
    echo "✔️  fusermount3 sudah tersedia"
fi
```

## Tujuan

- **Mengaktifkan Modul FUSE**: Memastikan modul FUSE dimuat ke dalam kernel untuk mendukung sistem file di ruang pengguna (userspace filesystem).
- **Membuat Tautan Simbolik**: Menyediakan `fusermount3` sebagai tautan simbolik ke `fusermount` untuk kompatibilitas dengan perangkat lunak seperti `rclone`.

## Bagian-Bagian Penting

### 1. Pengaturan Awal
- **`set -euo pipefail`**: Mengatur Bash untuk menghentikan eksekusi jika ada kesalahan (`-e`), melaporkan variabel yang tidak diatur (`-u`), dan menangani kesalahan dalam pipa (`-o pipefail`).

### 2. Aktivasi Modul FUSE
- **`modprobe fuse`**: Memuat modul FUSE ke dalam kernel. Jika gagal, skrip akan mencetak pesan kesalahan dan keluar dengan kode 1.
- **`lsmod | grep -q '^fuse'`**: Memeriksa apakah modul FUSE sudah aktif. Jika aktif, mencetak pesan sukses; jika tidak, skrip berhenti dengan pesan kesalahan.

### 3. Pembuatan Tautan Simbolik
- **`[[ ! -e /usr/bin/fusermount3 ]]`**: Memeriksa apakah `/usr/bin/fusermount3` belum ada.
- **`ln -s /usr/bin/fusermount /usr/bin/fusermount3`**: Membuat tautan simbolik jika belum ada, diikuti dengan pesan konfirmasi.
- **Jika sudah ada**: Mencetak pesan bahwa `fusermount3` sudah tersedia.

## Cara Kerja

1. **Memuat Modul FUSE**  
   Skrip mencoba memuat modul FUSE dengan `modprobe`. Jika berhasil, memverifikasi keberadaannya dengan `lsmod`. Jika gagal pada salah satu langkah, skrip berhenti.

2. **Menangani fusermount3**  
   Skrip memeriksa keberadaan `fusermount3`. Jika tidak ada, skrip membuat tautan simbolik dari `fusermount`. Jika sudah ada, skrip hanya memberikan konfirmasi.

## Catatan

- Skrip ini memerlukan hak akses root atau `sudo` untuk menjalankan `modprobe` dan membuat tautan simbolik di `/usr/bin/`.
- Dirancang untuk sistem berbasis Linux yang mendukung `modprobe` dan `lsmod`, seperti distribusi berbasis RPM atau Debian.
- Tautan simbolik `fusermount3` penting untuk mendukung fitur `rclone mount` pada sistem dengan versi FUSE yang lebih lama atau berbeda.

Berikut adalah penjelasan untuk file Bash yang Ketiga:

# File: configure_rclone_idrive.sh

File ini adalah skrip Bash yang digunakan untuk mengkonfigurasi `rclone` agar dapat terhubung ke layanan penyimpanan iDrive E2 (kompatibel dengan S3) dan memastikan bucket yang dibutuhkan tersedia.

## Kode Skrip

```bash
#!/usr/bin/env bash
set -euo pipefail

# === [1] Variabel yang harus Anda isi ===
IDRIVE_E2_ACCESS_KEY="acces_dari_idrive"
IDRIVE_E2_SECRET_KEY="secret_dari_idrive"
IDRIVE_E2_ENDPOINT="endpoint_dari_idrive"
BUCKET_NAME="isi_nama_bucket_di_idrive"

# === [2] Tulis remote ke rclone.conf ===
echo "=== Membuat remote 'e2' di rclone ==="
mkdir -p /root/.config/rclone
cat > /root/.config/rclone/rclone.conf <<EOF
[e2]
type = s3
provider = Other
access_key_id = $IDRIVE_E2_ACCESS_KEY
secret_access_key = $IDRIVE_E2_SECRET_KEY
endpoint = $IDRIVE_E2_ENDPOINT
acl = private
bucket_acl = private
EOF
chmod 600 /root/.config/rclone/rclone.conf

# === [3] Tes remote & buat bucket jika perlu ===
echo "=== Menampilkan daftar bucket di akun Anda ==="
rclone lsd e2: || echo "⚠️ Remote error – cek endpoint/kunci"

if rclone lsd e2: | grep -q "$BUCKET_NAME"; then
    echo "✔️  Bucket '$BUCKET_NAME' sudah ada"
else
    echo "➕ Membuat bucket '$BUCKET_NAME'"
    rclone mkdir "e2:$BUCKET_NAME"
fi

echo "✅ Remote e2 & bucket siap digunakan"
```

## Penjelasan

### Tujuan
- **Mengkonfigurasi rclone**: Menyimpan kredensial dan endpoint iDrive E2 ke dalam file konfigurasi `rclone`.
- **Mengelola Bucket**: Memeriksa keberadaan bucket di iDrive E2 dan membuatnya jika belum ada.

### Bagian-Bagian Penting

1. **Pengaturan Awal**
   - `set -euo pipefail`: Menghentikan skrip jika ada kesalahan, memeriksa variabel yang tidak diatur, dan menangani kesalahan pipa.

2. **Variabel yang Harus Diisi**
   - `IDRIVE_E2_ACCESS_KEY`: Kunci akses dari iDrive E2.
   - `IDRIVE_E2_SECRET_KEY`: Kunci rahasia dari iDrive E2.
   - `IDRIVE_E2_ENDPOINT`: URL endpoint iDrive E2.
   - `BUCKET_NAME`: Nama bucket yang akan digunakan.

3. **Penulisan Konfigurasi rclone**
   - Membuat direktori konfigurasi `/root/.config/rclone`.
   - Menulis detail remote `e2` ke `rclone.conf`.
   - Mengatur izin file menjadi `600` untuk keamanan.

4. **Pemeriksaan dan Pembuatan Bucket**
   - `rclone lsd e2:`: Menampilkan daftar bucket di remote `e2`. Jika gagal, menunjukkan pesan kesalahan.
   - Memeriksa bucket dengan `grep`. Jika ada, konfirmasi; jika tidak, buat bucket baru dengan `rclone mkdir`.

## Cara Penggunaan
1. Ganti nilai variabel (`IDRIVE_E2_ACCESS_KEY`, dll.) dengan informasi dari akun iDrive E2 Anda.
2. Jalankan skrip sebagai root atau dengan akses yang cukup.
3. Skrip akan mengkonfigurasi remote `e2` dan memastikan bucket tersedia.

## Catatan
- Pastikan `rclone` sudah terinstal.
- Verifikasi kredensial dan endpoint agar koneksi berhasil.
- Skrip ini diasumsikan dijalankan di lingkungan Linux dengan Bash.

Berikut adalah penjelasan untuk file Bash yang Keempat:

# File: mount_idrive_e2.sh

Skrip Bash ini digunakan untuk memasang bucket iDrive E2 ke sistem file lokal menggunakan `rclone` dan FUSE, serta mengintegrasikannya sebagai layanan systemd agar bucket tetap terpasang secara otomatis.

## Kode Skrip

```bash
#!/usr/bin/env bash
set -euo pipefail

MOUNT_POINT="/mnt/e2"
REMOTE_NAME="e2"
BUCKET_NAME="lecsens"

echo "=== [1] Buat direktori mount-point ==="
mkdir -p "$MOUNT_POINT"

echo "=== [2] Tulis unit systemd e2.service ==="
cat > /etc/systemd/system/e2.service <<EOF
[Unit]
Description=Mount iDrive e2 bucket via rclone FUSE
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount ${REMOTE_NAME}:${BUCKET_NAME} ${MOUNT_POINT} \\
          --vfs-cache-mode=writes \\
          --dir-cache-time=12h
ExecStop=/usr/bin/fusermount -u ${MOUNT_POINT}
Restart=on-failure
Environment=RCLONE_CONFIG=/root/.config/rclone/rclone.conf

[Install]
WantedBy=multi-user.target
EOF

echo "=== [3] Reload systemd & aktifkan mount ==="
systemctl daemon-reload
systemctl enable --now e2.service

echo "=== [4] Status layanan mount e2.service ==="
systemctl status e2.service --no-pager
```

## Penjelasan

### Tujuan
- **Membuat Mount Point**: Menyiapkan direktori lokal `/mnt/e2` untuk memasang bucket iDrive E2.
- **Konfigurasi Systemd**: Mengatur layanan systemd agar bucket terpasang otomatis saat boot dan tetap aktif.

### Variabel Utama
- `MOUNT_POINT="/mnt/e2"`: Direktori tempat bucket akan dipasang.
- `REMOTE_NAME="e2"`: Nama remote yang dikonfigurasi di `rclone`.
- `BUCKET_NAME="lecsens"`: Nama bucket di iDrive E2.

### Langkah-Langkah
1. **Membuat Direktori Mount Point**  
   Perintah `mkdir -p "$MOUNT_POINT"` memastikan direktori `/mnt/e2` ada dan siap digunakan.

2. **Menulis Unit Systemd**  
   File `/etc/systemd/system/e2.service` dibuat untuk mendefinisikan layanan yang:
   - Menggunakan `rclone mount` untuk memasang bucket.
   - Mengatur caching dengan `--vfs-cache-mode=writes` dan `--dir-cache-time=12h`.
   - Menghentikan mount dengan `fusermount -u` saat layanan dimatikan.
   - Restart otomatis jika gagal (`Restart=on-failure`).

3. **Mengaktifkan Layanan**  
   - `systemctl daemon-reload`: Memuat ulang konfigurasi systemd.
   - `systemctl enable --now e2.service`: Mengaktifkan layanan untuk boot dan menjalankannya segera.

4. **Memeriksa Status**  
   Perintah `systemctl status e2.service --no-pager` menampilkan status layanan untuk memverifikasi bahwa mount berjalan dengan baik.

### Catatan Penting
- Skrip ini membutuhkan akses root untuk mengelola file systemd dan layanan.
- Remote `e2` harus sudah dikonfigurasi di `/root/.config/rclone/rclone.conf`.
- Layanan bergantung pada jaringan (`After=network-online.target`) untuk memastikan koneksi ke iDrive E2 tersedia.

Berikut adalah penjelasan untuk file Bash yang Kelima:

# Penjelasan File: initialize_borg_repo.sh

Skrip Bash berikut digunakan untuk menginisialisasi repositori Borg yang terenkripsi pada path tertentu. Borg adalah alat backup yang efisien dan aman dengan fitur deduplikasi dan enkripsi.

```bash
#!/usr/bin/env bash
set -euo pipefail

# === [1] Ganti passphrase sesuai kebutuhan ===
export BORG_PASSPHRASE="GantiPassphraseKuat"

REPO_PATH="/mnt/e2/borgrepo"

echo "=== [1] Membuat folder repo (jika belum ada) ==="
mkdir -p "$REPO_PATH"

echo "=== [2] Inisialisasi repositori Borg terenkripsi ==="
borg init --encryption=repokey-blake2 "$REPO_PATH"

echo "✅ Repo Borg berhasil dibuat di: $REPO_PATH"
echo "⚠️ Simpan passphrase Anda dengan aman!"
```

## Tujuan
- **Membuat Folder Repositori**: Memastikan folder untuk repositori Borg tersedia di path yang ditentukan.
- **Inisialisasi Repositori Borg**: Mengatur repositori Borg dengan enkripsi untuk menyimpan data backup dengan aman.

## Bagian-Bagian Penting
- **Shebang dan Pengaturan**: 
  - `#!/usr/bin/env bash`: Menjalankan skrip dengan Bash.
  - `set -euo pipefail`: Mengatur Bash untuk menghentikan eksekusi saat ada kesalahan, memeriksa variabel yang tidak diatur, dan menangani kesalahan pipa.

- **Variabel**:
  - `BORG_PASSPHRASE`: Passphrase untuk enkripsi repositori. Ganti `"GantiPassphraseKuat"` dengan passphrase yang lebih aman.
  - `REPO_PATH`: Lokasi repositori Borg, yaitu `/mnt/e2/borgrepo`.

- **Langkah-Langkah**:
  1. **Membuat Folder**: `mkdir -p "$REPO_PATH"` memastikan folder ada, membuatnya jika belum ada.
  2. **Inisialisasi Repositori**: `borg init --encryption=repokey-blake2 "$REPO_PATH"` menginisialisasi repositori dengan enkripsi `repokey-blake2`.

- **Output**: Pesan konfirmasi dan peringatan untuk menyimpan passphrase.

## Cara Kerja
1. **Membuat Folder Repositori**  
   Perintah `mkdir -p "$REPO_PATH"` membuat folder `/mnt/e2/borgrepo` jika belum ada. Opsi `-p` mencegah error jika folder sudah ada dan membuat direktori induk jika diperlukan.

2. **Inisialisasi Repositori Borg**  
   Perintah `borg init --encryption=repokey-blake2 "$REPO_PATH"` menginisialisasi repositori dengan enkripsi. Metode `repokey-blake2` menggunakan passphrase untuk mengenkripsi data dan menyimpannya di repositori, dengan algoritma BLAKE2 untuk hashing.

3. **Konfirmasi**  
   Skrip menampilkan pesan bahwa repositori berhasil dibuat dan mengingatkan pengguna untuk menyimpan passphrase dengan aman.

## Catatan Penting
- **Hak Akses**: Skrip memerlukan izin untuk membuat folder di `/mnt/e2` dan menginisialisasi repositori.
- **Keamanan Passphrase**: Gunakan passphrase yang kuat dan simpan dengan aman. Kehilangan passphrase berarti data tidak dapat diakses.
- **Prasyarat**: Pastikan `/mnt/e2` sudah terpasang dan dapat diakses (misalnya, mount point dari layanan seperti iDrive E2).
- **Dependensi**: Perintah `borg` harus sudah terinstal di sistem.

Skrip ini adalah langkah awal untuk menyiapkan backup aman menggunakan Borg. Setelah repositori diinisialisasi, Anda dapat mulai menyimpan data ke dalamnya.

# Penjelasan File: setup_borgmatic_config.sh

File ini berisi skrip Bash untuk membuat dan mengkonfigurasi file konfigurasi borgmatic, tool yang menyederhanakan penggunaan BorgBackup dengan menyediakan antarmuka yang lebih user-friendly.

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="/etc/borgmatic/config.yaml"

echo "=== [1] Membuat direktori konfigurasi borgmatic ==="
mkdir -p /etc/borgmatic

echo "=== [2] Menulis file config.yaml ==="
cat > "$CONFIG_PATH" <<EOF
location:
  source_directories:
    - /root
    - /etc/nginx
    - /var/www
  repositories:
    - /mnt/e2/borgrepo

storage:
  compression: zstd,3

retention:
  keep_weekly: 5
EOF

chmod 600 "$CONFIG_PATH"

echo "✅ Konfigurasi borgmatic ditulis ke: $CONFIG_PATH"
echo "🔍 Gunakan 'borgmatic --create' untuk uji backup pertama"
```

## Tujuan
- **Membuat File Konfigurasi**: Menyiapkan file konfigurasi YAML untuk borgmatic di lokasi standar.
- **Mengatur Parameter Backup**: Menentukan sumber data, repositori tujuan, kompresi, dan kebijakan retensi untuk backup.

## Bagian-Bagian Penting

### 1. Pengaturan Awal
- **`set -euo pipefail`**: Mengatur Bash untuk berhenti jika ada kesalahan, memeriksa variabel yang tidak diatur, dan menangani kesalahan pipa.
- **`CONFIG_PATH="/etc/borgmatic/config.yaml"`**: Mendefinisikan lokasi file konfigurasi borgmatic.

### 2. Pembuatan Direktori dan File Konfigurasi
- **Membuat Direktori**: `mkdir -p /etc/borgmatic` memastikan direktori konfigurasi ada.
- **Menulis Konfigurasi**: Menggunakan `cat` dengan here-document untuk menulis file YAML dengan konfigurasi berikut:
  - **location**: Mendefinisikan direktori sumber (`/root`, `/etc/nginx`, `/var/www`) dan repositori tujuan (`/mnt/e2/borgrepo`).
  - **storage**: Mengatur kompresi dengan algoritma `zstd` level 3.
  - **retention**: Menyimpan 5 backup mingguan (`keep_weekly: 5`).
- **Mengatur Izin File**: `chmod 600 "$CONFIG_PATH"` untuk membatasi akses hanya ke pemilik file.

## Cara Kerja
1. **Persiapan Direktori Konfigurasi**  
   Skrip membuat direktori `/etc/borgmatic` untuk menyimpan file konfigurasi.

2. **Pembuatan File Konfigurasi**  
   Skrip menulis konfigurasi YAML ke `/etc/borgmatic/config.yaml` yang menentukan:
   - Direktori yang akan di-backup (`source_directories`)
   - Lokasi repositori Borg (`repositories`)
   - Pengaturan kompresi (`compression`) menggunakan algoritma zstd level 3
   - Kebijakan retensi (`retention`) untuk menyimpan 5 backup mingguan

3. **Pengamanan**  
   Skrip mengatur izin file menjadi 600 (hanya pemilik yang dapat membaca/menulis) untuk keamanan.

## Catatan
- File konfigurasi ini merupakan konfigurasi minimal borgmatic. Anda dapat menambahkan opsi lain seperti penjadwalan, hooks, dll.
- Backup akan menyimpan data dari direktori `/root`, `/etc/nginx`, dan `/var/www` ke repositori Borg di `/mnt/e2/borgrepo`.
- Anda perlu menjalankan `borgmatic --create` secara manual untuk menguji backup pertama.
- Pastikan repositori Borg sudah diinisialisasi dengan `initialize_borg_repo.sh` sebelum menjalankan backup.

# Penjelasan File: setup_borgmatic_timer.sh

File ini berisi skrip Bash yang membuat dan mengkonfigurasi layanan systemd dan timer untuk menjalankan backup borgmatic secara otomatis setiap minggu.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [1] Membuat unit systemd manual untuk borgmatic.service ==="
cat > /etc/systemd/system/borgmatic.service <<'EOF'
[Unit]
Description=Run Borgmatic backup

[Service]
Type=oneshot
Environment=BORG_PASSPHRASE=GantiPassphraseKuat
ExecStart=/usr/local/bin/borgmatic --verbosity 1 --log-file /var/log/borgmatic.log
EOF

echo "=== [2] Membuat timer mingguan (Minggu 03:15 WIB) ==="
mkdir -p /etc/systemd/system/borgmatic.timer.d
cat > /etc/systemd/system/borgmatic.timer <<'EOF'
[Unit]
Description=Run Borgmatic backup weekly

[Timer]
OnCalendar=Sun *-*-* 03:15
RandomizedDelaySec=30m
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "=== [3] Reload systemd & aktifkan timer ==="
systemctl daemon-reload
systemctl enable --now borgmatic.timer

echo "✅ Timer mingguan siap! Backup akan berjalan Minggu 03:15"
systemctl list-timers borgmatic.timer --no-pager
```

## Tujuan
- **Mengotomatisasi Backup**: Mengkonfigurasi systemd untuk menjalankan backup borgmatic secara otomatis setiap minggu.
- **Penjadwalan yang Konsisten**: Memastikan backup berjalan secara rutin tanpa intervensi manual.

## Bagian-Bagian Penting

### 1. Pengaturan Unit Service borgmatic
- **Membuat Service File**: Membuat file `/etc/systemd/system/borgmatic.service` dengan konfigurasi:
  - **Type=oneshot**: Layanan berjalan sekali dan selesai.
  - **Environment=BORG_PASSPHRASE**: Mengatur passphrase Borg untuk enkripsi/dekripsi.
  - **ExecStart**: Menjalankan borgmatic dengan verbosity level 1 dan mencatat log ke `/var/log/borgmatic.log`.

### 2. Pengaturan Timer
- **Membuat Timer File**: Membuat file `/etc/systemd/system/borgmatic.timer` yang mengatur:
  - **OnCalendar=Sun *-*-* 03:15**: Menjalankan tugas setiap hari Minggu pukul 03:15.
  - **RandomizedDelaySec=30m**: Menambahkan delay acak hingga 30 menit untuk mengurangi beban sistem.
  - **Persistent=true**: Menjalankan tugas yang terlewat saat sistem dimatikan/reboot.

### 3. Aktivasi dan Validasi
- **Reload Systemd**: `systemctl daemon-reload` memuat ulang konfigurasi systemd.
- **Enable dan Start Timer**: `systemctl enable --now borgmatic.timer` mengaktifkan timer agar berjalan saat boot dan memulainya langsung.
- **Verifikasi Timer**: `systemctl list-timers` menampilkan informasi tentang timer yang aktif.

## Cara Kerja
1. **Pembuatan Unit Service**  
   Skrip membuat unit service systemd yang mengkonfigurasi cara menjalankan borgmatic dengan parameter yang tepat.

2. **Pembuatan Unit Timer**  
   Skrip membuat timer systemd yang dijadwalkan untuk menjalankan service borgmatic setiap minggu pada waktu yang ditentukan.

3. **Aktivasi Sistem**  
   Skrip memuat ulang konfigurasi systemd, mengaktifkan timer, dan memulainya segera.

## Catatan Penting
- **Keamanan Passphrase**: Passphrase Borg (`GantiPassphraseKuat`) terlihat di file service. Ini harus diganti dengan passphrase sebenarnya dan file harus dilindungi dengan izin yang tepat.
- **Waktu Backup**: Backup dijadwalkan berjalan pada dini hari (03:15) setiap Minggu untuk meminimalkan dampak pada operasi normal sistem.
- **Delay Acak**: RandomizedDelaySec menambahkan delay acak hingga 30 menit untuk menghindari beban puncak jika banyak tugas dijadwalkan pada waktu yang sama.
- **Dependensi**: Skrip mengasumsikan borgmatic sudah terinstal di `/usr/local/bin/borgmatic` dan direktori log (`/var/log`) dapat ditulisi.

# Penjelasan File: test_borgmatic.sh

File ini berisi skrip Bash untuk menguji konfigurasi borgmatic, menjalankan backup manual, dan memeriksa jadwal timer systemd.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== [1] Menjalankan backup manual ==="
export BORG_PASSPHRASE="GantiPassphraseKuat"
/usr/local/bin/borgmatic --create --verbosity 1

echo
echo "=== [2] Menampilkan daftar arsip backup ==="
/usr/local/bin/borgmatic --list

echo
echo "=== [3] Menampilkan jadwal timer systemd ==="
systemctl list-timers borgmatic.timer --no-pager || echo "❌ Timer belum tersedia atau belum aktif"
```

## Tujuan
- **Pengujian Manual**: Menjalankan backup borgmatic secara manual untuk memverifikasi konfigurasi berfungsi dengan baik.
- **Pemeriksaan Arsip**: Menampilkan daftar arsip backup yang telah dibuat untuk memastikan backup berhasil.
- **Verifikasi Timer**: Memeriksa status timer systemd untuk memastikan otomatisasi backup telah diatur dengan benar.

## Bagian-Bagian Penting

### 1. Pengaturan Awal
- **`set -euo pipefail`**: Mengatur Bash untuk berhenti jika ada kesalahan, memeriksa variabel yang tidak diatur, dan menangani kesalahan pipa.
- **`export BORG_PASSPHRASE="GantiPassphraseKuat"`**: Mengatur passphrase untuk akses ke repositori Borg terenkripsi.

### 2. Langkah Pengujian
- **Menjalankan Backup Manual**: 
  - `/usr/local/bin/borgmatic --create --verbosity 1` menjalankan borgmatic untuk membuat backup baru dengan tingkat verbosity 1.
  - Flag `--create` memerintahkan borgmatic untuk membuat arsip baru.

- **Menampilkan Daftar Arsip**:
  - `/usr/local/bin/borgmatic --list` menampilkan daftar arsip yang tersimpan di repositori.
  - Output ini memungkinkan untuk memverifikasi bahwa backup telah berhasil dibuat dan mencantumkan detail seperti tanggal dan ukuran.

- **Memeriksa Timer Systemd**:
  - `systemctl list-timers borgmatic.timer --no-pager` menampilkan informasi tentang jadwal timer borgmatic.
  - Output mencakup waktu eksekusi terakhir dan berikutnya serta status timer.
  - `|| echo "❌ Timer belum tersedia atau belum aktif"` menampilkan pesan error jika timer tidak ditemukan.

## Cara Kerja
1. **Menjalankan Backup Secara Manual**  
   Skrip mengatur passphrase Borg dan menjalankan borgmatic untuk membuat backup baru. Ini memvalidasi bahwa konfigurasi dapat berjalan dengan benar.

2. **Memverifikasi Hasil Backup**  
   Skrip menampilkan daftar arsip backup untuk konfirmasi visual bahwa backup telah berhasil dibuat.

3. **Memeriksa Konfigurasi Otomatisasi**  
   Skrip menampilkan status timer systemd untuk memastikan bahwa backup terjadwal akan berjalan pada waktu yang ditentukan.

## Catatan
- **Passphrase**: Ganti `"GantiPassphraseKuat"` dengan passphrase sebenarnya yang digunakan untuk repositori.
- **Lokasi Program**: Skrip mengasumsikan bahwa borgmatic diinstal di `/usr/local/bin/borgmatic`.
- **Hak Akses**: Untuk melihat timer systemd, skrip mungkin perlu dijalankan dengan hak akses root atau sudo.
- **Penggunaan**: Jalankan skrip ini setelah mengatur konfigurasi borgmatic dan timer untuk memastikan semuanya berfungsi dengan benar.

# Penjelasan File: restore_server.sh

File ini berisi skrip Bash untuk memulihkan (restore) data dari backup Borg terbaru ke direktori target yang ditentukan.

```bash
#!/usr/bin/env bash
set -euo pipefail

export BORG_PASSPHRASE="GantiPassphraseKuat"
REPO_PATH="/mnt/e2/borgrepo"
RESTORE_PATH="/restore"

echo "=== [1] Mencari arsip terbaru di repo Borg ==="
LATEST_ARCHIVE=$(borg list "$REPO_PATH" --short | sort | tail -n 1)

if [[ -z "$LATEST_ARCHIVE" ]]; then
    echo "❌ Tidak ada arsip ditemukan di repositori: $REPO_PATH"
    exit 1
fi

echo "📦 Arsip terbaru: $LATEST_ARCHIVE"

echo "=== [2] Membuat direktori tujuan restore: $RESTORE_PATH ==="
mkdir -p "$RESTORE_PATH"

echo "=== [3] Melakukan restore arsip ke: $RESTORE_PATH ==="
borg extract "$REPO_PATH::$LATEST_ARCHIVE" --destination "$RESTORE_PATH"

echo "✅ Restore selesai. Data ada di: $RESTORE_PATH"
```

## Tujuan
- **Pemulihan Data**: Mengekstrak dan memulihkan data dari arsip backup Borg terbaru ke direktori target.
- **Pemulihan Server**: Memudahkan proses pemulihan server dengan otomatisasi ekstraksi backup terbaru.

## Bagian-Bagian Penting

### 1. Konfigurasi Awal
- **`set -euo pipefail`**: Mengatur Bash untuk menghentikan eksekusi jika ada kesalahan.
- **`export BORG_PASSPHRASE="GantiPassphraseKuat"`**: Mengatur passphrase untuk mengakses repositori Borg terenkripsi.
- **`REPO_PATH="/mnt/e2/borgrepo"`**: Path ke repositori Borg yang berisi arsip backup.
- **`RESTORE_PATH="/restore"`**: Direktori tujuan untuk pemulihan data.

### 2. Identifikasi Arsip Terbaru
- **`LATEST_ARCHIVE=$(borg list "$REPO_PATH" --short | sort | tail -n 1)`**: 
  - `borg list "$REPO_PATH" --short`: Menampilkan daftar arsip dalam format pendek (hanya nama).
  - `sort`: Mengurutkan daftar arsip (biasanya berdasarkan timestamp dalam nama).
  - `tail -n 1`: Mengambil arsip terakhir (terbaru) dari daftar.
- **Verifikasi Arsip**: Memeriksa apakah arsip ditemukan dan menampilkan pesan error jika kosong.

### 3. Proses Pemulihan
- **Persiapan Direktori**: `mkdir -p "$RESTORE_PATH"` membuat direktori tujuan pemulihan jika belum ada.
- **Ekstraksi Data**: 
  - `borg extract "$REPO_PATH::$LATEST_ARCHIVE" --destination "$RESTORE_PATH"` mengekstrak isi arsip terbaru ke direktori tujuan.
  - Sintaks `REPO_PATH::ARCHIVE_NAME` adalah format standar Borg untuk merujuk ke arsip spesifik.

## Cara Kerja
1. **Persiapan Akses**  
   Skrip mengatur passphrase Borg untuk membuka repositori terenkripsi dan mendefinisikan lokasi repositori serta direktori pemulihan.

2. **Identifikasi Backup Terbaru**  
   Skrip mencari arsip terbaru dalam repositori dengan mengurutkan daftar arsip dan mengambil entri terakhir. Jika tidak ada arsip, skrip akan berhenti dengan pesan error.

3. **Pemulihan Data**  
   Setelah memastikan direktori tujuan ada, skrip menggunakan perintah `borg extract` untuk mengekstrak isi arsip terbaru ke direktori pemulihan.

4. **Konfirmasi**  
   Skrip menampilkan pesan sukses dengan lokasi data yang dipulihkan.

## Catatan Penting
- **Passphrase**: Ganti `"GantiPassphraseKuat"` dengan passphrase sebenarnya yang digunakan untuk repositori.
- **Hak Akses**: Skrip mungkin memerlukan hak akses root untuk membuat direktori `/restore` dan menulis data ke dalamnya.
- **Selektif Restore**: Skrip ini memulihkan seluruh arsip. Untuk memulihkan file atau direktori tertentu, tambahkan path spesifik setelah nama arsip dalam perintah `borg extract`.
- **Disk Space**: Pastikan ada cukup ruang disk di direktori tujuan untuk menampung data yang dipulihkan.
- **Pemulihan Penuh**: Untuk pemulihan server penuh, Anda mungkin perlu mengkonfigurasi ulang layanan atau memindahkan file ke lokasi aslinya setelah ekstraksi.

