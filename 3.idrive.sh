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
