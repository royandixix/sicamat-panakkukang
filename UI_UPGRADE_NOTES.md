# SICAMAT UI Upgrade

Pembaruan ini hanya berfokus pada frontend Flutter dan tidak mengubah struktur database maupun endpoint API.

## Peningkatan utama

- Tema visual profesional dan konsisten melalui `lib/config/app_theme.dart`.
- Halaman publik baru dengan hero, penjelasan sistem, alur layanan, layanan dinamis, kegiatan, profil, FAQ, CTA, dan footer.
- Halaman login responsif dengan pilihan cepat akun demo untuk Kasubag, Camat, Seksi, dan Warga.
- Workspace dengan sidebar berbasis role, pengelompokan menu, header akun, transisi halaman, dan informasi hak akses.
- Dashboard baru dengan banner sambutan, kartu statistik, surat terbaru, dan fokus aktivitas sesuai role.
- Dialog bergaya SweetAlert untuk sukses, gagal, informasi, peringatan, input, dan konfirmasi tindakan berbahaya.
- Konfirmasi sebelum logout, menghapus surat/kegiatan, menonaktifkan layanan/pengguna, dan membatalkan pengajuan.
- Splash/loading HTML profesional sebelum Flutter menampilkan frame pertama.

## Menjalankan

```bash
cd "/Users/mac/Downloads/sicamat 2"
./scripts/02_run_api_macos.command
```

Buka Terminal baru:

```bash
cd "/Users/mac/Downloads/sicamat 2"
./scripts/03_run_web_macos.command
```

## Akun demo

Password seluruh akun: `Sicamat123!`

- `kasubag@sicamat.local`
- `camat@sicamat.local`
- `pemerintahan@sicamat.local`
- `trantib@sicamat.local`
- `warga@sicamat.local`
