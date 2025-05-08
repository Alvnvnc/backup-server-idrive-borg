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
