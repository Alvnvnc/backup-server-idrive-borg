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
