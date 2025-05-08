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
