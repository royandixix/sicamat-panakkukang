import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

class PrintService {
  static bool get supported => true;

  static String _escape(dynamic value) {
    return htmlEscape.convert('${value ?? '-'}');
  }

  static String _document({required String title, required String body}) {
    return '''
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta
    name="viewport"
    content="width=device-width, initial-scale=1"
  >

  <title>${_escape(title)}</title>

  <style>
    @page {
      size: A4;
      margin: 18mm;
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      color: #202625;
      font-family: Arial, sans-serif;
    }

    .header {
      margin-bottom: 24px;
      padding-bottom: 14px;
      border-bottom: 2px solid #1d5148;
      text-align: center;
    }

    .header h1 {
      margin: 0 0 5px;
      font-size: 20px;
    }

    .header p {
      margin: 0;
      color: #5a6663;
      font-size: 12px;
    }

    h2 {
      margin: 0 0 18px;
      font-size: 17px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th,
    td {
      padding: 9px 10px;
      border: 1px solid #cbd6d3;
      font-size: 12px;
      text-align: left;
      vertical-align: top;
    }

    th {
      width: 31%;
      background: #eef5f3;
    }

    .report th {
      width: auto;
    }

    .section {
      margin: 0 0 22px;
    }

    .section h3 {
      margin: 0 0 9px;
      color: #174f45;
      font-size: 14px;
    }

    .footer {
      margin-top: 34px;
      color: #68736f;
      font-size: 10px;
      text-align: center;
    }
  </style>
</head>

<body onload="setTimeout(function () { window.print(); }, 250)">
  <div class="header">
    <h1>KANTOR CAMAT PANAKKUKANG</h1>
    <p>
      Sistem Informasi dan Layanan Online
      Kecamatan Panakkukang
    </p>
  </div>

  <h2>${_escape(title)}</h2>

  $body

  <div class="footer">
    Dicetak melalui SICAMAT pada
    ${_escape(DateTime.now().toLocal())}
  </div>
</body>
</html>
''';
  }

  static void _open(String content) {
    final parts = <JSAny>[content.toJS].toJS;

    final options = web.BlobPropertyBag(type: 'text/html;charset=utf-8');

    final blob = web.Blob(parts, options);

    final objectUrl = web.URL.createObjectURL(blob);

    web.window.open(objectUrl, '_blank', 'noopener,noreferrer');

    Future<void>.delayed(const Duration(seconds: 15), () {
      web.URL.revokeObjectURL(objectUrl);
    });
  }

  static String _tableFromRows(Map<String, dynamic> rows) {
    final tableRows = rows.entries.map((entry) {
      return '''
<tr>
  <th>${_escape(entry.key)}</th>
  <td>${_escape(entry.value)}</td>
</tr>
''';
    }).join();

    return '''
<table>
  <tbody>
    $tableRows
  </tbody>
</table>
''';
  }

  static String _dateValue(dynamic value) {
    final text = '${value ?? '-'}';

    if (text.trim().isEmpty) {
      return '-';
    }

    return text.split(' ').first;
  }

  static void printSurat(Map<String, dynamic> item) {
    final rows = <String, dynamic>{
      'Nomor Surat': item['nomor_surat'],
      'Jenis Surat': item['jenis'],
      'Perihal': item['perihal'],
      'Pengirim': item['pengirim'],
      'Tujuan': item['tujuan'],
      'Tanggal Surat': _dateValue(item['tanggal_surat']),
      'Tanggal Diterima': _dateValue(item['tanggal_diterima']),
      'Status': item['status'],
      'Hasil Klaster': item['cluster_label'] ?? '-',
      'Alamat Berkas': item['file_url'] ?? '-',
    };

    final body = _tableFromRows(rows);

    _open(_document(title: 'Lembar Data Surat', body: body));
  }

  static void printPengajuan(Map<String, dynamic> item) {
    final rows = <String, dynamic>{
      'Kode Pengajuan': item['kode'],
      'Nama Pemohon': item['nama_warga'] ?? item['nama_pemohon'] ?? '-',
      'Kelurahan': item['kelurahan'],
      'Jenis Layanan': item['layanan'] ?? item['nama_layanan'] ?? '-',
      'Judul / Keperluan': item['judul'],
      'Deskripsi': item['deskripsi'],
      'Lokasi': item['lokasi'],
      'Tanggal Mulai': _dateValue(item['tanggal_mulai']),
      'Tanggal Selesai': _dateValue(item['tanggal_selesai']),
      'Status': item['status'],
      'Catatan Petugas': item['catatan_petugas'] ?? '-',
    };

    final body = _tableFromRows(rows);

    _open(_document(title: 'Bukti Pengajuan Layanan', body: body));
  }

  static void printLaporan(Map<String, dynamic> data) {
    String section({
      required String title,
      required dynamic raw,
      required String key,
    }) {
      final rawRows = raw is List ? raw : <dynamic>[];

      final tableRows = rawRows.map((item) {
        if (item is! Map) {
          return '';
        }

        final row = Map<String, dynamic>.from(item);

        return '''
<tr>
  <td>${_escape(row[key])}</td>
  <td>${_escape(row['total'])}</td>
</tr>
''';
      }).join();

      return '''
<div class="section">
  <h3>${_escape(title)}</h3>

  <table class="report">
    <thead>
      <tr>
        <th>Keterangan</th>
        <th>Jumlah</th>
      </tr>
    </thead>

    <tbody>
      $tableRows
    </tbody>
  </table>
</div>
''';
    }

    final body = [
      section(
        title: 'Status Pengajuan',
        raw: data['status_pengajuan'],
        key: 'status',
      ),
      section(title: 'Status Surat', raw: data['status_surat'], key: 'status'),
      section(
        title: 'Layanan Paling Banyak Diajukan',
        raw: data['layanan_populer'],
        key: 'nama',
      ),
      section(
        title: 'Tren Pengajuan Bulanan',
        raw: data['pengajuan_bulanan'],
        key: 'bulan',
      ),
    ].join();

    _open(_document(title: 'Laporan Ringkas Manajemen', body: body));
  }
}
