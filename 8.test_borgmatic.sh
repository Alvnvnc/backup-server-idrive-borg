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
