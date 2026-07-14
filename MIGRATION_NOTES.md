# Catatan Perubahan dari Prototipe Awal

## Perbaikan penting

- Menghapus `password.txt` dari proyek.
- Kredensial database tidak lagi ditulis permanen di kode; konfigurasi dibaca dari environment variable.
- Password pengguna disimpan sebagai hash SHA-256 di database, bukan teks biasa.
- Menambahkan bearer token dan tabel sesi dengan masa berlaku 12 jam.
- Logout menghapus sesi API dan penyimpanan lokal.
- Seluruh peran dapat login dan memperoleh ruang kerja sesuai hak akses.
- Dashboard menggunakan hasil query database, bukan angka statis.
- Menambahkan validasi input dan endpoint edit, hapus, detail, serta perubahan status.
- Menambahkan halaman publik, pengajuan layanan, disposisi, laporan, pengguna, layanan, kegiatan, dan profil kecamatan.
- Menambahkan implementasi TF-IDF + K-Means dan silhouette score.
- Menambahkan database instalasi, data contoh, dokumentasi, dan akun demo.
- Menghapus folder hasil build, cache, konfigurasi IDE, dan berkas mesin lokal dari paket.

## Batas teknis versi ini

- Unggah berkas fisik belum memakai multipart upload. Sistem menyimpan `file_url`; integrasikan object storage ketika server produksi tersedia.
- Fitur cetak browser tersedia untuk lembar surat, bukti pengajuan, dan laporan. Template kop/formulir resmi tetap perlu disesuaikan setelah format baku dari instansi ditetapkan.
- Hash SHA-256 dipilih agar instalasi tetap menggunakan dependency lama yang tersedia. Untuk produksi gunakan Argon2/bcrypt.
