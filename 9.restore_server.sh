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
