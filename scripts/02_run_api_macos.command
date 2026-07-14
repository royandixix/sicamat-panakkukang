#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
API_DIR="$ROOT_DIR/kantor_camat_api"

if ! command -v dart >/dev/null 2>&1; then
  echo "Dart tidak ditemukan pada PATH. Jalankan 'dart --version' untuk memeriksa instalasi."
  exit 1
fi

cd "$API_DIR"

if [[ -f ".env" ]]; then
  set -a
  source ".env"
  set +a
fi

echo "Mengambil dependency API..."
dart pub get

echo "Menjalankan SICAMAT API..."
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-8081}"
export ALLOWED_ORIGIN="${ALLOWED_ORIGIN:-*}"
export DB_HOST="${DB_HOST:-127.0.0.1}"
export DB_PORT="${DB_PORT:-3306}"
export DB_USER="${DB_USER:-root}"
export DB_PASSWORD="${DB_PASSWORD:-}"
export DB_NAME="${DB_NAME:-sicamat_db}"
export DB_POOL_SIZE="${DB_POOL_SIZE:-10}"
export DB_SECURE="${DB_SECURE:-false}"

echo "API: http://localhost:$PORT/api"
dart run bin/server.dart
