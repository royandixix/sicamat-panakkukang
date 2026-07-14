import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../services/auth_service.dart';
import '../utils/api_response.dart';

class PengajuanController {
  static Future<Map<String, dynamic>> _body(Request request) async {
    final raw = await request.readAsString();
    return raw.trim().isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static String _kode() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffix = 1000 + Random.secure().nextInt(9000);
    return 'PGJ-$date-$suffix';
  }

  static Future<Response> daftar(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      final hanyaSaya = '${user['role']}' == 'warga';
      final status = request.url.queryParameters['status'] ?? '';
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT p.id, p.kode, p.user_id, u.nama, u.kelurahan, p.layanan_id,
                  l.nama, p.judul, p.deskripsi, p.lokasi, p.tanggal_mulai,
                  p.tanggal_selesai, p.status, p.catatan_petugas,
                  p.created_at, p.updated_at
           FROM pengajuan p
           JOIN users u ON u.id = p.user_id
           JOIN layanan l ON l.id = p.layanan_id
           WHERE (:hanya_saya = 0 OR p.user_id = :user_id)
             AND (:status = '' OR p.status = :status)
           ORDER BY p.id DESC''',
        {
          'hanya_saya': hanyaSaya ? 1 : 0,
          'user_id': user['id'],
          'status': status,
        },
      );
      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'kode': r.colAt(1),
                'user_id': int.tryParse('${r.colAt(2)}') ?? r.colAt(2),
                'nama_warga': r.colAt(3),
                'kelurahan': r.colAt(4),
                'layanan_id': int.tryParse('${r.colAt(5)}') ?? r.colAt(5),
                'layanan': r.colAt(6),
                'judul': r.colAt(7),
                'deskripsi': r.colAt(8),
                'lokasi': r.colAt(9),
                'tanggal_mulai': '${r.colAt(10)}',
                'tanggal_selesai': '${r.colAt(11)}',
                'status': r.colAt(12),
                'catatan_petugas': r.colAt(13),
                'dibuat': '${r.colAt(14)}',
                'diperbarui': '${r.colAt(15)}',
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal memuat pengajuan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> tambah(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      final body = await _body(request);
      if ('${body['layanan_id'] ?? ''}'.isEmpty ||
          '${body['judul'] ?? ''}'.trim().isEmpty ||
          '${body['deskripsi'] ?? ''}'.trim().isEmpty) {
        return ApiResponse.error('Layanan, judul, dan deskripsi wajib diisi');
      }
      final conn = await Database.getConnection();
      String kode = _kode();
      for (var i = 0; i < 5; i++) {
        final cek = await conn.execute(
          'SELECT id FROM pengajuan WHERE kode = :kode',
          {'kode': kode},
        );
        if (cek.rows.isEmpty) break;
        kode = _kode();
      }
      await conn.execute(
        '''INSERT INTO pengajuan
           (kode, user_id, layanan_id, judul, deskripsi, lokasi,
            tanggal_mulai, tanggal_selesai, status)
           VALUES (:kode, :user_id, :layanan_id, :judul, :deskripsi,
                   :lokasi, :mulai, :selesai, 'diajukan')''',
        {
          'kode': kode,
          'user_id': user['id'],
          'layanan_id': body['layanan_id'],
          'judul': '${body['judul']}'.trim(),
          'deskripsi': '${body['deskripsi']}'.trim(),
          'lokasi': '${body['lokasi'] ?? ''}'.trim(),
          'mulai': body['tanggal_mulai'],
          'selesai': body['tanggal_selesai'],
        },
      );
      return ApiResponse.created(
        pesan: 'Pengajuan berhasil dikirim',
        data: {'kode': kode},
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal mengirim pengajuan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> ubahStatus(Request request, String id) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag', 'seksi'])) {
        return ApiResponse.forbidden();
      }
      final body = await _body(request);
      final status = '${body['status'] ?? ''}';
      const valid = [
        'diajukan',
        'diverifikasi',
        'diproses',
        'disetujui',
        'ditolak',
        'selesai',
        'dibatalkan',
      ];
      if (!valid.contains(status))
        return ApiResponse.error('Status pengajuan tidak valid');
      final conn = await Database.getConnection();
      await conn.execute(
        '''UPDATE pengajuan SET status = :status,
           catatan_petugas = :catatan WHERE id = :id''',
        {
          'id': id,
          'status': status,
          'catatan': '${body['catatan_petugas'] ?? ''}'.trim(),
        },
      );
      return ApiResponse.ok(pesan: 'Status pengajuan berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui pengajuan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> batalkan(Request request, String id) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      final conn = await Database.getConnection();
      await conn.execute(
        '''UPDATE pengajuan SET status = 'dibatalkan'
           WHERE id = :id AND user_id = :user_id
             AND status IN ('diajukan', 'diverifikasi')''',
        {'id': id, 'user_id': user['id']},
      );
      return ApiResponse.ok(pesan: 'Pengajuan dibatalkan');
    } catch (e) {
      return ApiResponse.error(
        'Gagal membatalkan pengajuan',
        status: 500,
        detail: e,
      );
    }
  }
}
