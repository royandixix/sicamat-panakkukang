# SICAMAT Panakkukang

SICAMAT adalah Sistem Informasi dan Layanan Online Kantor Camat Panakkukang yang dibangun menggunakan Flutter Web, Dart Shelf REST API, dan MySQL/MariaDB. Sistem ini dirancang untuk mendukung penyampaian informasi publik, pengajuan layanan masyarakat, pengelolaan persuratan, disposisi, pelaporan, serta pengelompokan surat masuk menggunakan algoritma K-Means berbasis TF-IDF.

![Flutter](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart)
![MySQL](https://img.shields.io/badge/Database-MySQL%20%7C%20MariaDB-4479A1?logo=mysql)
![API](https://img.shields.io/badge/API-Dart%20Shelf-00B4AB)
![Version](https://img.shields.io/badge/version-2.0.0-green)

---

## Tentang SICAMAT

SICAMAT dikembangkan sebagai platform digital untuk membantu proses administrasi dan pelayanan publik pada Kantor Camat Panakkukang. Aplikasi menyediakan dua bagian utama, yaitu halaman publik untuk masyarakat dan ruang kerja internal untuk pegawai kecamatan.

Halaman publik menyediakan informasi profil kecamatan, layanan, kegiatan, alur pelayanan, kontak, dan pelacakan pengajuan. Ruang kerja internal menyediakan dashboard, pengelolaan surat, disposisi, pengajuan, master data, pengguna, laporan, dan clustering K-Means.

Sistem menerapkan pembatasan akses berdasarkan peran pengguna. Menu, data, dan tindakan yang tersedia akan disesuaikan dengan role pengguna yang sedang login.

---

## Tujuan Pengembangan

SICAMAT dikembangkan untuk:

1. Menyediakan informasi layanan kecamatan secara terpusat.
2. Mempermudah masyarakat memperoleh informasi persyaratan pelayanan.
3. Memfasilitasi pengajuan dan pelacakan layanan secara daring.
4. Membantu pegawai mengelola surat masuk dan surat keluar.
5. Mempermudah proses disposisi surat kepada seksi terkait.
6. Menyediakan laporan operasional bagi pimpinan.
7. Mengelompokkan surat masuk berdasarkan kemiripan perihal.
8. Meningkatkan efisiensi, transparansi, dan keteraturan administrasi.

---

## Fitur Utama

### 1. Halaman Publik

Halaman publik dapat diakses tanpa login dan menyediakan:

- Informasi Kantor Camat Panakkukang.
- Profil, visi, dan misi kecamatan.
- Alamat, kontak, dan jam pelayanan.
- Daftar layanan publik.
- Persyaratan setiap layanan.
- Estimasi waktu penyelesaian.
- Informasi biaya pelayanan.
- Daftar kegiatan kecamatan.
- Penjelasan alur pelayanan.
- Pelacakan pengajuan berdasarkan kode.
- Akses menuju halaman login.

### 2. Autentikasi

Sistem autentikasi mencakup:

- Login menggunakan email dan password.
- Verifikasi pengguna aktif.
- Token sesi pengguna.
- Penyimpanan sesi pada database.
- Pemeriksaan identitas pengguna.
- Pembatasan akses berdasarkan role.
- Logout dan penghapusan sesi.

### 3. Dashboard Berbasis Role

Dashboard menggunakan desain yang konsisten, tetapi isi dan menunya disesuaikan berdasarkan role.

Informasi dashboard antara lain:

- Jumlah surat masuk.
- Jumlah surat keluar.
- Jumlah disposisi.
- Jumlah pengajuan layanan.
- Pengajuan yang masih diproses.
- Surat terbaru.
- Aktivitas operasional.
- Informasi yang relevan dengan role pengguna.

### 4. Manajemen Persuratan

Modul persuratan menyediakan:

- Daftar surat masuk.
- Daftar surat keluar.
- Tambah surat.
- Edit surat.
- Detail surat.
- Perubahan status surat.
- Penghapusan surat sesuai hak akses.
- Penyimpanan nomor surat.
- Penyimpanan perihal surat.
- Data pengirim dan tujuan.
- Tanggal surat dan tanggal diterima.
- Alamat atau URL berkas.
- Hasil cluster surat.
- Cetak lembar data surat.

### 5. Disposisi Surat

Modul disposisi mendukung:

- Pembuatan disposisi.
- Penentuan surat yang didisposisikan.
- Penentuan pengguna atau seksi penerima.
- Catatan atau instruksi disposisi.
- Batas waktu penyelesaian.
- Status disposisi.
- Pemantauan proses disposisi.
- Penyelesaian disposisi oleh seksi terkait.

### 6. Pengajuan Layanan

Masyarakat dapat:

- Melihat daftar layanan.
- Mengajukan layanan.
- Mengisi keperluan dan deskripsi.
- Menentukan lokasi kegiatan.
- Mengisi tanggal pelaksanaan.
- Memperoleh kode pengajuan.
- Melacak status pengajuan.
- Melihat riwayat pengajuan sendiri.
- Membatalkan pengajuan sesuai aturan.
- Mencetak bukti pengajuan.

Petugas dapat:

- Melihat seluruh pengajuan yang diizinkan.
- Memverifikasi pengajuan.
- Mengubah status pengajuan.
- Memberikan catatan petugas.
- Memantau proses penyelesaian layanan.

### 7. Master Data

Data master yang tersedia meliputi:

- Data layanan.
- Data kegiatan.
- Data pengguna.
- Profil kecamatan.
- Aktivasi dan nonaktivasi layanan.
- Aktivasi dan nonaktivasi pengguna.

### 8. Laporan

Modul laporan menyediakan:

- Rekap status pengajuan.
- Rekap status surat.
- Daftar layanan populer.
- Tren pengajuan bulanan.
- Ringkasan manajemen.
- Fasilitas cetak laporan melalui browser.

### 9. Clustering K-Means

SICAMAT menerapkan algoritma K-Means untuk mengelompokkan surat masuk berdasarkan perihal surat.

Tahapan pengolahan meliputi:

1. Mengambil data perihal surat masuk.
2. Mengubah teks menjadi huruf kecil.
3. Menghapus karakter yang tidak diperlukan.
4. Melakukan tokenisasi.
5. Menghapus stopword Bahasa Indonesia.
6. Melakukan stemming sederhana.
7. Menghitung document frequency.
8. Menyusun vocabulary.
9. Mengubah teks menjadi vektor TF-IDF.
10. Melakukan normalisasi vektor.
11. Menentukan centroid awal.
12. Menghitung jarak Euclidean.
13. Menempatkan dokumen ke cluster terdekat.
14. Menghitung ulang centroid.
15. Mengulangi proses sampai konvergen.
16. Menghitung silhouette score.
17. Membentuk label cluster berdasarkan istilah teratas.

Minimal tiga surat masuk diperlukan agar proses clustering dapat dijalankan.

---

## Role dan Hak Akses

SICAMAT memiliki empat jenis role utama.

### Kasubag Umum

Kasubag memiliki akses administratif dan operasional yang luas, meliputi:

- Dashboard operasional.
- Manajemen surat.
- Manajemen disposisi.
- Manajemen pengajuan.
- Manajemen layanan.
- Manajemen kegiatan.
- Manajemen pengguna.
- Profil kecamatan.
- Laporan.
- Clustering K-Means.

### Camat

Camat berperan sebagai pimpinan dan memiliki akses untuk:

- Melihat dashboard pimpinan.
- Memantau surat.
- Memantau disposisi.
- Melihat pengajuan.
- Melihat laporan manajemen.
- Melihat hasil clustering.
- Mengambil keputusan sesuai kewenangan.

### Seksi

Pengguna dengan role seksi memiliki akses untuk:

- Melihat dashboard seksi.
- Melihat surat yang relevan.
- Menerima disposisi.
- Memproses disposisi.
- Mengubah status pekerjaan.
- Melihat data yang berkaitan dengan seksi.
- Mengakses profil pengguna.

### Masyarakat atau Warga

Masyarakat memiliki akses untuk:

- Melihat halaman publik.
- Melihat layanan.
- Membuat pengajuan.
- Melacak pengajuan.
- Melihat pengajuan sendiri.
- Membatalkan pengajuan sesuai ketentuan.
- Mengelola profil pengguna.

Pembatasan akses diterapkan pada frontend dan backend. Menyembunyikan menu pada sidebar tidak menjadi satu-satunya mekanisme keamanan. Backend tetap memeriksa token, identitas pengguna, dan role sebelum memproses permintaan.

---

## Teknologi yang Digunakan

### Frontend

- Flutter Web.
- Dart.
- Material Design.
- HTTP Client.
- Shared Preferences.
- Package Web untuk fungsi browser dan cetak.

### Backend

- Dart.
- Shelf.
- Shelf Router.
- MySQL Client Plus.
- REST API.
- Token-based session authentication.

### Database

- MySQL.
- MariaDB.
- UTF-8 `utf8mb4`.
- Foreign key.
- Index database.
- Full-text index.

### Perangkat Pengembangan

- Visual Studio Code.
- Google Chrome.
- Git.
- GitHub.
- XAMPP untuk macOS.
- Flutter DevTools.

---

## Arsitektur Sistem

```text
┌──────────────────────────────────┐
│          Flutter Web             │
│                                  │
│ Halaman Publik                   │
│ Login                            │
│ Dashboard Berbasis Role          │
│ Pengajuan, Surat, dan Laporan    │
└────────────────┬─────────────────┘
                 │
                 │ HTTP / JSON
                 ▼
┌──────────────────────────────────┐
│       Dart Shelf REST API        │
│                                  │
│ Autentikasi                      │
│ Otorisasi Role                   │
│ Business Logic                   │
│ K-Means dan TF-IDF               │
└────────────────┬─────────────────┘
                 │
                 │ SQL
                 ▼
┌──────────────────────────────────┐
│        MySQL / MariaDB           │
│                                  │
│ Users dan Sessions               │
│ Surat dan Disposisi              │
│ Pengajuan dan Layanan            │
│ Kegiatan dan Profil              │
│ Cluster Runs dan Members         │
└──────────────────────────────────┘
```

---

## Struktur Folder

```text
sicamat-panakkukang/
├── kantor_camat_api/
│   ├── bin/
│   │   └── server.dart
│   ├── database/
│   │   └── database.sql
│   ├── lib/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── services/
│   │   └── utils/
│   ├── test/
│   ├── .env.example
│   ├── Dockerfile
│   └── pubspec.yaml
│
├── kantor_camat_app/
│   ├── lib/
│   │   ├── config/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   ├── public/
│   │   │   ├── masyarakat/
│   │   │   ├── seksi/
│   │   │   └── workspace/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   ├── web/
│   ├── test/
│   └── pubspec.yaml
│
├── scripts/
│   ├── 01_import_database_macos.command
│   ├── 02_run_api_macos.command
│   └── 03_run_web_macos.command
│
├── MIGRATION_NOTES.md
├── START_HERE.md
├── .gitignore
└── README.md
```

---

## Persyaratan Sistem

Pastikan perangkat sudah memiliki:

- Flutter SDK versi kompatibel dengan Dart 3.12.
- Dart SDK.
- Google Chrome.
- MySQL atau MariaDB.
- XAMPP apabila menggunakan MySQL lokal di macOS.
- Git.
- Visual Studio Code atau editor lain.

Periksa instalasi dengan:

```bash
flutter --version
dart --version
git --version
```

Periksa kondisi Flutter:

```bash
flutter doctor
```

---

## Instalasi Proyek

### 1. Clone repository

```bash
git clone https://github.com/USERNAME_GITHUB/sicamat-panakkukang.git
cd sicamat-panakkukang
```

Ganti `USERNAME_GITHUB` dengan username GitHub pemilik repository.

### 2. Berikan izin script macOS

```bash
chmod +x scripts/*.command
```

### 3. Jalankan MySQL

Apabila menggunakan XAMPP:

1. Buka XAMPP Manager.
2. Aktifkan MySQL Database.
3. Pastikan MySQL berjalan pada port `3306`.

---

## Konfigurasi Backend

Masuk ke folder API:

```bash
cd kantor_camat_api
```

Salin file konfigurasi:

```bash
cp .env.example .env
```

Isi konfigurasi `.env`:

```env
HOST=0.0.0.0
PORT=8081
ALLOWED_ORIGIN=*
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=sicamat_db
DB_POOL_SIZE=10
DB_SECURE=false
```

Untuk produksi, jangan menggunakan `ALLOWED_ORIGIN=*`. Gunakan domain frontend resmi.

Contoh:

```env
ALLOWED_ORIGIN=https://sicamat.example.go.id
```

---

## Instalasi Database

> Perhatian: file `database.sql` dapat menghapus dan membuat ulang tabel SICAMAT. Cadangkan database lama sebelum melakukan import.

### Menggunakan script macOS

Dari folder utama proyek:

```bash
./scripts/01_import_database_macos.command
```

Ketik:

```text
LANJUT
```

ketika diminta konfirmasi.

### Menggunakan Terminal XAMPP

```bash
/Applications/XAMPP/xamppfiles/bin/mysql -u root \
  < kantor_camat_api/database/database.sql
```

Apabila MySQL menggunakan password:

```bash
/Applications/XAMPP/xamppfiles/bin/mysql -u root -p \
  < kantor_camat_api/database/database.sql
```

### Menggunakan phpMyAdmin

1. Buka phpMyAdmin.
2. Pilih menu **Import**.
3. Pilih file:

```text
kantor_camat_api/database/database.sql
```

4. Jalankan proses import.

Database yang dibuat bernama:

```text
sicamat_db
```

Tabel utama:

```text
users
sessions
profil_kecamatan
layanan
kegiatan
surat
disposisi
pengajuan
cluster_runs
cluster_members
data_historis
seksi
```

---

## Menjalankan Backend API

Dari folder utama proyek:

```bash
./scripts/02_run_api_macos.command
```

Atau secara manual:

```bash
cd kantor_camat_api
dart pub get
dart run bin/server.dart
```

API berjalan pada:

```text
http://localhost:8081/api
```

Periksa kesehatan API:

```bash
curl -i http://localhost:8081/api/health
```

Respons yang diharapkan:

```json
{
  "sukses": true,
  "data": {
    "status": "ok",
    "aplikasi": "SICAMAT API",
    "versi": "2.0.0"
  }
}
```

---

## Menjalankan Flutter Web

Buka Terminal baru dan jalankan:

```bash
./scripts/03_run_web_macos.command
```

Atau secara manual:

```bash
cd kantor_camat_app
flutter pub get
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8081/api
```

Chrome akan terbuka secara otomatis menggunakan alamat localhost yang dibuat Flutter.

Backend harus tetap berjalan pada Terminal lain.

---

## Akun Demo Lokal

Semua akun demo menggunakan password:

```text
Sicamat123!
```

| Role | Email | Keterangan |
|---|---|---|
| Kasubag Umum | `kasubag@sicamat.local` | Akses administrasi utama |
| Camat | `camat@sicamat.local` | Akses pimpinan dan laporan |
| Seksi Pemerintahan | `pemerintahan@sicamat.local` | Akses sebagai pengguna seksi |
| Seksi Ketenteraman | `trantib@sicamat.local` | Akses sebagai pengguna seksi |
| Masyarakat | `warga@sicamat.local` | Akses pengajuan masyarakat |

Akun tersebut hanya ditujukan untuk pengujian lokal. Ganti seluruh password sebelum aplikasi digunakan pada server produksi.

---

## Alur Penggunaan

### Alur Persuratan

1. Kasubag login ke sistem.
2. Kasubag menambahkan surat masuk.
3. Surat disimpan dengan status awal.
4. Kasubag atau pimpinan membuat disposisi.
5. Disposisi diarahkan kepada seksi terkait.
6. Seksi menerima dan memproses disposisi.
7. Seksi memperbarui status pekerjaan.
8. Pimpinan memantau penyelesaian surat.

### Alur Pengajuan Masyarakat

1. Masyarakat login.
2. Masyarakat memilih layanan.
3. Masyarakat mengisi formulir pengajuan.
4. Sistem membuat kode pengajuan.
5. Petugas memeriksa pengajuan.
6. Petugas memperbarui status dan catatan.
7. Masyarakat memantau status menggunakan akun atau kode pelacakan.
8. Bukti pengajuan dapat dicetak melalui browser.

### Alur Clustering

1. Kasubag menambahkan minimal tiga surat masuk.
2. Pengguna membuka menu clustering.
3. Sistem mengambil perihal surat.
4. Sistem mengubah teks menjadi vektor TF-IDF.
5. K-Means mengelompokkan surat.
6. Sistem menghitung silhouette score.
7. Sistem membuat label setiap cluster.
8. Hasil cluster disimpan dan ditampilkan.

---

## Dokumentasi Endpoint API

Base URL:

```text
http://localhost:8081/api
```

### Endpoint Publik dan Autentikasi

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/health` | Memeriksa kondisi API dan database |
| POST | `/login` | Login pengguna |
| GET | `/me` | Mendapatkan data pengguna aktif |
| POST | `/logout` | Menghapus sesi pengguna |
| GET | `/public/profil` | Mendapatkan profil kecamatan |
| GET | `/public/layanan` | Mendapatkan layanan publik |
| GET | `/public/kegiatan` | Mendapatkan kegiatan publik |
| GET | `/public/pengajuan/{kode}` | Melacak pengajuan berdasarkan kode |

### Dashboard dan Laporan

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/dashboard` | Mendapatkan ringkasan dashboard |
| GET | `/laporan` | Mendapatkan data laporan |

### Surat

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/surat` | Mendapatkan daftar surat |
| GET | `/surat/{id}` | Mendapatkan detail surat |
| POST | `/surat` | Menambahkan surat |
| PUT | `/surat/{id}` | Mengubah surat |
| PUT | `/surat/{id}/status` | Mengubah status surat |
| DELETE | `/surat/{id}` | Menghapus surat |

### Disposisi

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/disposisi` | Mendapatkan daftar disposisi |
| POST | `/disposisi` | Menambahkan disposisi |
| PUT | `/disposisi/{id}/status` | Mengubah status disposisi |

### Pengajuan

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/pengajuan` | Mendapatkan daftar pengajuan |
| POST | `/pengajuan` | Menambahkan pengajuan |
| PUT | `/pengajuan/{id}/status` | Mengubah status pengajuan |
| PUT | `/pengajuan/{id}/batalkan` | Membatalkan pengajuan |

### Layanan

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/layanan` | Mendapatkan daftar layanan |
| POST | `/layanan` | Menambahkan layanan |
| PUT | `/layanan/{id}` | Mengubah layanan |
| DELETE | `/layanan/{id}` | Menonaktifkan atau menghapus layanan |

### Kegiatan

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/kegiatan` | Mendapatkan daftar kegiatan |
| POST | `/kegiatan` | Menambahkan kegiatan |
| PUT | `/kegiatan/{id}` | Mengubah kegiatan |
| DELETE | `/kegiatan/{id}` | Menghapus kegiatan |

### Pengguna dan Profil

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/pengguna` | Mendapatkan daftar pengguna |
| POST | `/pengguna` | Menambahkan pengguna |
| PUT | `/pengguna/{id}` | Mengubah pengguna |
| DELETE | `/pengguna/{id}` | Menonaktifkan pengguna |
| PUT | `/profil` | Mengubah profil kecamatan |

### Clustering

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/clustering` | Mendapatkan hasil clustering terakhir |
| POST | `/clustering/run` | Menjalankan algoritma K-Means |

Endpoint internal membutuhkan token autentikasi pada header:

```text
Authorization: Bearer TOKEN_PENGGUNA
```

---

## Pengujian dan Analisis Kode

### Backend

```bash
cd kantor_camat_api
dart pub get
dart format .
dart analyze
dart test
```

### Frontend

```bash
cd kantor_camat_app
flutter pub get
dart format lib
flutter analyze
flutter test
```

### Build Flutter Web

```bash
cd kantor_camat_app
flutter build web \
  --dart-define=API_BASE_URL=https://alamat-api.example.com/api
```

Hasil build berada di:

```text
kantor_camat_app/build/web
```

---

## Troubleshooting

### Port 8081 sudah digunakan

Pesan:

```text
Address already in use
```

Periksa proses yang menggunakan port:

```bash
lsof -nP -iTCP:8081 -sTCP:LISTEN
```

Hentikan proses:

```bash
kill -15 $(lsof -tiTCP:8081 -sTCP:LISTEN)
```

### Flutter tidak menemukan `pubspec.yaml`

Pastikan perintah Flutter dijalankan dari:

```bash
cd kantor_camat_app
```

Bukan dari folder utama proyek.

### API tidak dapat terhubung ke MySQL

Periksa:

- MySQL sudah aktif.
- Port MySQL sesuai.
- Database `sicamat_db` tersedia.
- Username dan password pada `.env` benar.
- Host menggunakan `127.0.0.1`.

### Perubahan Flutter belum terlihat

Pada Terminal Flutter:

```text
r
```

untuk hot reload, atau:

```text
R
```

untuk hot restart.

Untuk restart penuh:

```bash
flutter clean
flutter pub get
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8081/api
```

### Error CORS

Periksa nilai:

```env
ALLOWED_ORIGIN=*
```

Untuk produksi, ganti dengan domain frontend resmi.

---

## Keamanan

Sebelum aplikasi digunakan dalam lingkungan produksi:

1. Ganti seluruh password akun demo.
2. Jangan mengunggah file `.env`.
3. Gunakan HTTPS.
4. Batasi `ALLOWED_ORIGIN`.
5. Gunakan pengguna database dengan hak minimum.
6. Jangan menggunakan akun database `root`.
7. Simpan password menggunakan Argon2 atau bcrypt.
8. Tambahkan rate limiting pada endpoint login.
9. Tambahkan validasi file upload.
10. Simpan dokumen pada penyimpanan yang memiliki kontrol akses.
11. Tambahkan audit log.
12. Atur masa berlaku dan rotasi token.
13. Lakukan backup database berkala.
14. Jangan menampilkan stack trace pada produksi.

---

## Rencana Pengembangan

Pengembangan lanjutan yang dapat dilakukan:

- Upload dokumen surat secara langsung.
- Penyimpanan dokumen pada object storage.
- Notifikasi email atau WhatsApp.
- Tanda tangan elektronik.
- Export Excel dan PDF.
- Audit trail aktivitas pengguna.
- Manajemen permission yang lebih rinci.
- Reset password melalui email.
- Dashboard analitik yang lebih lengkap.
- Optimasi algoritma K-Means.
- Evaluasi jumlah cluster otomatis.
- Penggunaan stemming Bahasa Indonesia yang lebih komprehensif.
- Deployment menggunakan Docker.
- Continuous Integration melalui GitHub Actions.
- Progressive Web App.
- Pengujian integrasi dan end-to-end.

---

## Catatan Repository

Repository ini dibuat untuk pengembangan, pembelajaran, dan penelitian sistem informasi pelayanan publik.

Data akun, nomor telepon, surat, kegiatan, dan pengajuan yang terdapat pada file database merupakan data demo untuk pengujian lokal.

Jangan menggunakan data pribadi atau dokumen pemerintahan asli pada repository publik.

---

## Kontribusi

Kontribusi dapat dilakukan dengan alur berikut:

1. Fork repository.
2. Buat branch fitur:

```bash
git checkout -b feature/nama-fitur
```

3. Commit perubahan:

```bash
git commit -m "feat: menambahkan nama fitur"
```

4. Push branch:

```bash
git push origin feature/nama-fitur
```

5. Buat Pull Request.

---

## Penulis

**Nama:** Isi nama pengembang  
**Program Studi:** Teknik Informatika  
**Institusi:** Isi nama institusi  
**Lokasi Penelitian:** Kantor Camat Panakkukang, Makassar

---

## Lisensi

Proyek ini digunakan untuk kepentingan akademik dan pengembangan sistem informasi.

Penggunaan, distribusi, dan pengembangan lanjutan harus menyesuaikan izin penulis serta kebijakan instansi terkait.

---

## Kontak

Untuk pertanyaan mengenai proyek, gunakan menu **Issues** pada repository GitHub.
