# SICAMAT API 2.0

Backend REST API untuk website informasi, layanan online, pengelolaan surat, disposisi, laporan, dan clustering K-Means pada Kantor Camat Panakkukang.

## Menjalankan

1. Impor `database/database.sql` melalui phpMyAdmin atau terminal MySQL.
2. Atur variabel lingkungan berdasarkan `.env.example`.
3. Jalankan:

```bash
dart pub get
dart run bin/server.dart
```

API lokal tersedia pada `http://localhost:8081/api`.

## Akun demo lokal

Semua akun menggunakan password `Sicamat123!`:

- `kasubag@sicamat.local`
- `camat@sicamat.local`
- `pemerintahan@sicamat.local`
- `trantib@sicamat.local`
- `warga@sicamat.local`

Akun ini hanya untuk instalasi lokal/demo. Ubah seluruh password sebelum deployment produksi.

## Keamanan

- Password tidak disimpan sebagai teks biasa; database menyimpan hasil `SHA2-256`.
- API menggunakan bearer token dengan masa berlaku 12 jam.
- Untuk produksi, gunakan HTTPS, batasi `ALLOWED_ORIGIN`, dan pertimbangkan migrasi hash password ke Argon2/bcrypt melalui layanan autentikasi khusus.
