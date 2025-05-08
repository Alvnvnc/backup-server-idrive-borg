#!/usr/bin/env bash

set -euo pipefail

echo "=== [1] Memasang FUSE dan dependensi ==="
dnf install -y fuse fuse-libs curl python3-pip

echo "=== [2] Memasang rclone dari RPM resmi ==="
curl -LO https://downloads.rclone.org/rclone-current-linux-amd64.rpm
rpm -Uvh rclone-current-linux-amd64.rpm || echo "rclone sudah terpasang"

echo "=== [3] Memasang Borg & Borgmatic via pip ==="
pip3 install --upgrade borgbackup borgmatic

echo "=== [4] Mengaktifkan kernel module FUSE ==="
modprobe fuse
lsmod | grep fuse || echo "❌ FUSE tidak termuat!"

echo "=== [5] Menautkan fusermount3 → fusermount (dibutuhkan oleh rclone mount) ==="
if [[ ! -e /usr/bin/fusermount3 ]]; then
    ln -s /usr/bin/fusermount /usr/bin/fusermount3
    echo "✔️  fusermount3 → fusermount berhasil"
else
    echo "✔️  fusermount3 sudah ada"
fi

echo "✅ SEMUA utilitas terpasang & siap"
