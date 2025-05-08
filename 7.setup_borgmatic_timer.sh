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
