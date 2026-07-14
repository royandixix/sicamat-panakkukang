#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SQL_FILE="$ROOT_DIR/kantor_camat_api/database/database.sql"

if [[ ! -f "$SQL_FILE" ]]; then
  echo "File database tidak ditemukan: $SQL_FILE"
  exit 1
fi

MYSQL_BIN=""
if [[ -x "/Applications/XAMPP/xamppfiles/bin/mysql" ]]; then
  MYSQL_BIN="/Applications/XAMPP/xamppfiles/bin/mysql"
elif command -v mysql >/dev/null 2>&1; then
  MYSQL_BIN="$(command -v mysql)"
elif command -v mariadb >/dev/null 2>&1; then
  MYSQL_BIN="$(command -v mariadb)"
else
  echo "MySQL/MariaDB client tidak ditemukan. Gunakan phpMyAdmin untuk mengimpor:"
  echo "$SQL_FILE"
  exit 1
fi

cat <<'MSG'
PERINGATAN: skrip database akan menghapus dan membuat ulang tabel SICAMAT.
Cadangkan database lama apabila berisi data penting.
MSG
read -r -p "Ketik LANJUT untuk memulai impor: " CONFIRM
if [[ "$CONFIRM" != "LANJUT" ]]; then
  echo "Impor dibatalkan."
  exit 0
fi

DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
ARGS=("-u" "$DB_USER")
if [[ -n "$DB_PASSWORD" ]]; then
  ARGS+=("-p$DB_PASSWORD")
fi

"$MYSQL_BIN" "${ARGS[@]}" < "$SQL_FILE"
echo "Database SICAMAT berhasil diimpor."
