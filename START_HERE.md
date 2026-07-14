# MULAI DARI SINI — SICAMAT 2.0

Panduan ini dibuat untuk menjalankan aplikasi pada macOS dengan XAMPP. Jalankan urut dari langkah 1 sampai 4.

## 1. Persiapan

Pastikan sudah tersedia:

- XAMPP dan MySQL/MariaDB aktif.
- Flutter SDK yang sudah dapat dipanggil dengan perintah `flutter`.
- Dart SDK yang sudah dapat dipanggil dengan perintah `dart`.
- Google Chrome.

Periksa melalui Terminal:

```bash
flutter --version
dart --version
```

## 2. Impor database

> Proses ini menghapus tabel SICAMAT lama pada database `sicamat_db`. Cadangkan data penting terlebih dahulu.

Cara paling mudah:

1. Buka XAMPP dan aktifkan MySQL.
2. Buka phpMyAdmin.
3. Pilih menu **Import**.
4. Pilih file `kantor_camat_api/database/database.sql`.
5. Jalankan impor.

Alternatif melalui skrip macOS:

```bash
chmod +x scripts/*.command
./scripts/01_import_database_macos.command
```

## 3. Jalankan API

Buka Terminal pertama dari folder proyek, lalu:

```bash
./scripts/02_run_api_macos.command
```

Apabila berhasil, API berjalan pada:

```text
http://localhost:8081/api
```

Tes pada browser:

```text
http://localhost:8081/api/health
```

Respons yang benar memiliki `"sukses": true`.

## 4. Jalankan aplikasi web

Biarkan Terminal API tetap terbuka. Buka Terminal kedua, lalu:

```bash
./scripts/03_run_web_macos.command
```

Chrome akan terbuka dan menampilkan halaman publik SICAMAT.

## Akun demo

Semua akun memakai password berikut:

```text
Sicamat123!
```

| Peran | Email |
|---|---|
| Kasubag Umum | `kasubag@sicamat.local` |
| Camat | `camat@sicamat.local` |
| Seksi Pemerintahan | `pemerintahan@sicamat.local` |
| Seksi Ketenteraman | `trantib@sicamat.local` |
| Masyarakat | `warga@sicamat.local` |

## Urutan uji aplikasi

1. Masuk sebagai Kasubag Umum.
2. Buka menu **Surat Masuk & Keluar**, lalu tambah atau ubah surat.
3. Buka **Distribusi Surat**, lalu kirim disposisi ke salah satu seksi.
4. Masuk sebagai akun Seksi untuk menerima dan menyelesaikan disposisi.
5. Masuk sebagai Masyarakat untuk mengajukan layanan.
6. Masuk sebagai Kasubag untuk memverifikasi pengajuan.
7. Masuk sebagai Camat untuk melihat laporan dan hasil clustering.
8. Pada akun Kasubag, jalankan **Clustering K-Means** setelah tersedia minimal tiga surat masuk.
9. Gunakan tombol cetak pada surat, pengajuan, atau laporan.

## Masalah umum

### `dart: command not found`

Pastikan Dart/Flutter sudah masuk ke PATH. Tutup lalu buka ulang Terminal setelah memperbarui PATH.

### `flutter: command not found`

Tambahkan folder `flutter/bin` ke PATH, kemudian jalankan `flutter doctor`.

### API tidak dapat tersambung ke database

Periksa bahwa MySQL XAMPP aktif. Pengaturan bawaan menggunakan:

```text
host     : 127.0.0.1
port     : 3306
user     : root
password : kosong
nama DB  : sicamat_db
```

Apabila password MySQL tidak kosong, jalankan API dengan:

```bash
DB_PASSWORD='password_mysql_anda' ./scripts/02_run_api_macos.command
```

### Browser menampilkan “Tidak dapat terhubung ke server SICAMAT”

Pastikan Terminal API masih berjalan dan `http://localhost:8081/api/health` dapat dibuka.

### Port 8081 sedang digunakan

Jalankan API pada port lain:

```bash
PORT=8082 ./scripts/02_run_api_macos.command
```

Kemudian jalankan web dengan alamat yang sama:

```bash
API_BASE_URL=http://localhost:8082/api ./scripts/03_run_web_macos.command
```
