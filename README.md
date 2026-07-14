# SICAMAT 2.0 — Kantor Camat Panakkukang

SICAMAT merupakan aplikasi informasi dan layanan online berbasis Flutter Web dengan REST API Dart Shelf dan database MySQL/MariaDB. Versi ini dikembangkan dari prototipe awal dan diselaraskan dengan kebutuhan penelitian: informasi layanan, pengajuan masyarakat, persuratan digital, disposisi lintas seksi, laporan Camat, serta clustering K-Means terhadap perihal surat masuk.

## Modul yang tersedia

- Halaman publik: profil kecamatan, jenis layanan, persyaratan, biaya, estimasi, dan kegiatan.
- Pelacakan pengajuan menggunakan kode pengajuan.
- Autentikasi token dan pembatasan menu berdasarkan peran.
- Peran: Kasubag Umum, Camat, Seksi, dan Masyarakat.
- Dashboard dengan data aktual dari database.
- CRUD surat masuk dan surat keluar.
- Distribusi/disposisi surat kepada seksi terkait.
- Pengajuan layanan dan perubahan status proses.
- Master data layanan, kegiatan, pengguna, dan profil publik kecamatan.
- Laporan ringkas untuk Camat serta fasilitas cetak melalui browser.
- K-Means berbasis TF-IDF untuk mengelompokkan perihal surat masuk.
- Silhouette score untuk mengevaluasi kualitas klaster.
- Cetak lembar data surat, bukti pengajuan, dan laporan manajemen.

## Struktur proyek

```text
sicamat/
├── kantor_camat_api/       REST API Dart Shelf
│   ├── bin/server.dart
│   ├── database/database.sql
│   └── lib/
└── kantor_camat_app/       Flutter Web/PWA
    ├── lib/
    └── web/
```


## Mulai cepat di macOS

Panduan langkah demi langkah tersedia di [`START_HERE.md`](START_HERE.md). Setelah XAMPP, Dart, dan Flutter siap, jalankan skrip berikut secara berurutan:

```bash
chmod +x scripts/*.command
./scripts/01_import_database_macos.command
./scripts/02_run_api_macos.command
# Buka Terminal kedua:
./scripts/03_run_web_macos.command
```

## Instalasi database

> `database/database.sql` menghapus tabel SICAMAT yang lama. Cadangkan database terlebih dahulu apabila berisi data penting.

Dengan phpMyAdmin:

1. Buka phpMyAdmin.
2. Pilih menu **Import**.
3. Pilih `kantor_camat_api/database/database.sql`.
4. Jalankan proses import.

Dengan terminal XAMPP di macOS:

```bash
/Applications/XAMPP/xamppfiles/bin/mysql -u root \
  < kantor_camat_api/database/database.sql
```

## Menjalankan API

```bash
cd kantor_camat_api
dart pub get

DB_HOST=127.0.0.1 \
DB_PORT=3306 \
DB_USER=root \
DB_PASSWORD= \
DB_NAME=sicamat_db \
PORT=8081 \
dart run bin/server.dart
```

Tes API:

```bash
curl http://localhost:8081/api/health
```

## Menjalankan Flutter Web

Buka terminal baru:

```bash
cd kantor_camat_app
flutter pub get
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8081/api
```

## Akun demo lokal

Semua akun menggunakan password `Sicamat123!`.

| Peran | Email |
|---|---|
| Kasubag Umum | `kasubag@sicamat.local` |
| Camat | `camat@sicamat.local` |
| Seksi Pemerintahan | `pemerintahan@sicamat.local` |
| Seksi Ketenteraman | `trantib@sicamat.local` |
| Masyarakat | `warga@sicamat.local` |

Ubah password akun demo sebelum aplikasi dipasang pada server produksi.

## Alur penggunaan utama

1. Kasubag menambahkan surat masuk.
2. Kasubag mendisposisikan surat kepada pengguna berperan Seksi.
3. Seksi menerima, memproses, lalu menyelesaikan disposisi.
4. Masyarakat mengajukan layanan dan memperoleh kode pelacakan.
5. Petugas memverifikasi serta memperbarui status pengajuan.
6. Camat melihat laporan dan hasil clustering.
7. Kasubag menjalankan K-Means setelah minimal tiga surat masuk tersedia.

## Catatan keamanan produksi

- Gunakan HTTPS.
- Batasi `ALLOWED_ORIGIN` ke domain frontend resmi.
- Ganti seluruh akun dan password demo.
- Gunakan pengguna database dengan hak akses minimum.
- Untuk implementasi produksi jangka panjang, migrasikan hash password SHA-256 ke Argon2 atau bcrypt.
- Simpan berkas surat pada object storage atau server berkas dengan kontrol akses; kolom `file_url` saat ini menyimpan alamat berkas.

## Status pengujian

Kode telah dirapikan dan diperiksa secara statis di lingkungan pembuatan. Pengujian eksekusi penuh tetap perlu dilakukan pada komputer yang memiliki Flutter SDK, Dart SDK, dan MySQL/MariaDB karena ketiga runtime tersebut tidak tersedia di lingkungan pembuatan paket ini.
# sicamat-panakkukang
