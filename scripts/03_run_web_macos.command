#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
APP_DIR="$ROOT_DIR/kantor_camat_app"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter tidak ditemukan pada PATH. Jalankan 'flutter --version' untuk memeriksa instalasi."
  exit 1
fi

cd "$APP_DIR"
API_BASE_URL="${API_BASE_URL:-http://localhost:8081/api}"

echo "Mengambil dependency aplikasi..."
flutter pub get

echo "Menjalankan SICAMAT Web dengan API: $API_BASE_URL"
flutter run -d chrome --dart-define="API_BASE_URL=$API_BASE_URL"
