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
