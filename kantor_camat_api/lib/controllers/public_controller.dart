import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../utils/api_response.dart';

class PublicController {
  static Future<Response> profil(Request request) async {
    try {
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT nama_instansi, alamat, telepon, email, jam_layanan, visi, misi
           FROM profil_kecamatan WHERE id = 1''',
      );
      if (result.rows.isEmpty) return ApiResponse.ok(data: {});
      final r = result.rows.first;
      return ApiResponse.ok(
        data: {
          'nama_instansi': r.colAt(0),
          'alamat': r.colAt(1),
          'telepon': r.colAt(2),
          'email': r.colAt(3),
          'jam_layanan': r.colAt(4),
          'visi': r.colAt(5),
          'misi': r.colAt(6),
        },
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal memuat profil kecamatan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> layanan(Request request) async {
    try {
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT id, nama, sektor, deskripsi, persyaratan, estimasi_hari, biaya
           FROM layanan WHERE aktif = 1 ORDER BY nama''',
      );
      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'nama': r.colAt(1),
                'sektor': r.colAt(2),
                'deskripsi': r.colAt(3),
                'persyaratan': r.colAt(4),
                'estimasi_hari': int.tryParse('${r.colAt(5)}') ?? 0,
                'biaya': double.tryParse('${r.colAt(6)}') ?? 0,
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Gagal memuat layanan', status: 500, detail: e);
    }
  }

  static Future<Response> kegiatan(Request request) async {
    try {
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT id, judul, isi, tanggal, lokasi
           FROM kegiatan
           WHERE publikasi = 1
             AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
           ORDER BY tanggal DESC LIMIT 20''',
      );
      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'judul': r.colAt(1),
                'isi': r.colAt(2),
                'tanggal': '${r.colAt(3)}',
                'lokasi': r.colAt(4),
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Gagal memuat kegiatan', status: 500, detail: e);
    }
  }

  static Future<Response> lacakPengajuan(Request request, String kode) async {
    try {
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT p.kode, l.nama, p.judul, p.status, p.catatan_petugas,
                  p.created_at, p.updated_at
           FROM pengajuan p
           JOIN layanan l ON l.id = p.layanan_id
           WHERE p.kode = :kode LIMIT 1''',
        {'kode': kode.trim().toUpperCase()},
      );
      if (result.rows.isEmpty) {
        return ApiResponse.notFound('Kode pengajuan tidak ditemukan');
      }
      final r = result.rows.first;
      return ApiResponse.ok(
        data: {
          'kode': r.colAt(0),
          'layanan': r.colAt(1),
          'judul': r.colAt(2),
          'status': r.colAt(3),
          'catatan_petugas': r.colAt(4),
          'dibuat': '${r.colAt(5)}',
          'diperbarui': '${r.colAt(6)}',
        },
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal melacak pengajuan',
        status: 500,
        detail: e,
      );
    }
  }
}
