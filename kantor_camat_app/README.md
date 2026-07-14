# SICAMAT Web 2.0

Aplikasi Flutter Web untuk informasi kecamatan, pengajuan layanan, persuratan, disposisi, laporan Camat, pencetakan dokumen, data pengguna, pengelolaan profil publik, serta clustering K-Means terhadap perihal surat masuk.

## Menjalankan aplikasi

1. Jalankan API pada port `8081`.
2. Dari folder ini jalankan:

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8081/api
```

Untuk membuat versi produksi:

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://domain-api-anda.id/api
```

Hasil build berada di `build/web`.

## Alamat API pada perangkat berbeda

- Flutter Web di komputer yang sama: `http://localhost:8081/api`
- Emulator Android: `http://10.0.2.2:8081/api`
- HP fisik: gunakan IP LAN komputer, misalnya `http://192.168.1.10:8081/api`

Jangan menggunakan `localhost` pada HP fisik karena alamat tersebut menunjuk ke HP, bukan komputer server.
