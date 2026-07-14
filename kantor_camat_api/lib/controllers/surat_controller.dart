import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../services/auth_service.dart';
import '../utils/api_response.dart';

class SuratController {
  static const _rolesBaca = ['kasubag', 'camat', 'seksi'];

  static Future<Map<String, dynamic>> _body(Request request) async {
    final raw = await request.readAsString();
    if (raw.trim().isEmpty) return <String, dynamic>{};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static Future<Response> daftar(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, _rolesBaca))
        return ApiResponse.forbidden();

      final jenis = request.url.queryParameters['jenis'] ?? '';
      final status = request.url.queryParameters['status'] ?? '';
      final q = request.url.queryParameters['q'] ?? '';
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT s.id, s.nomor_surat, s.jenis, s.perihal, s.pengirim,
                  s.tujuan, s.tanggal_surat, s.tanggal_diterima, s.status,
                  s.file_url, s.cluster_no, s.cluster_label, u.nama
           FROM surat s
           LEFT JOIN users u ON u.id = s.created_by
           WHERE (:jenis = '' OR s.jenis = :jenis)
             AND (:status = '' OR s.status = :status)
             AND (:q = '' OR s.nomor_surat LIKE :cari OR s.perihal LIKE :cari
                  OR s.pengirim LIKE :cari OR s.tujuan LIKE :cari)
           ORDER BY s.id DESC''',
        {'jenis': jenis, 'status': status, 'q': q, 'cari': '%$q%'},
      );

      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'nomor_surat': r.colAt(1),
                'jenis': r.colAt(2),
                'perihal': r.colAt(3),
                'pengirim': r.colAt(4),
                'tujuan': r.colAt(5),
                'tanggal_surat': '${r.colAt(6)}',
                'tanggal_diterima': '${r.colAt(7)}',
                'status': r.colAt(8),
                'file_url': r.colAt(9),
                'cluster_no': r.colAt(10) == null
                    ? null
                    : int.tryParse('${r.colAt(10)}'),
                'cluster_label': r.colAt(11),
                'dibuat_oleh': r.colAt(12),
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Gagal memuat surat', status: 500, detail: e);
    }
  }

  static Future<Response> detail(Request request, String id) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, _rolesBaca))
        return ApiResponse.forbidden();
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT id, nomor_surat, jenis, perihal, pengirim, tujuan,
                  tanggal_surat, tanggal_diterima, status, file_url,
                  cluster_no, cluster_label, created_at, updated_at
           FROM surat WHERE id = :id LIMIT 1''',
        {'id': id},
      );
      if (result.rows.isEmpty)
        return ApiResponse.notFound('Surat tidak ditemukan');
      final r = result.rows.first;
      return ApiResponse.ok(
        data: {
          'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
          'nomor_surat': r.colAt(1),
          'jenis': r.colAt(2),
          'perihal': r.colAt(3),
          'pengirim': r.colAt(4),
          'tujuan': r.colAt(5),
          'tanggal_surat': '${r.colAt(6)}',
          'tanggal_diterima': '${r.colAt(7)}',
          'status': r.colAt(8),
          'file_url': r.colAt(9),
          'cluster_no': r.colAt(10),
          'cluster_label': r.colAt(11),
          'dibuat': '${r.colAt(12)}',
          'diperbarui': '${r.colAt(13)}',
        },
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal memuat detail surat',
        status: 500,
        detail: e,
      );
    }
  }

  static String? _validasi(Map<String, dynamic> body) {
    final wajib = [
      'nomor_surat',
      'jenis',
      'perihal',
      'pengirim',
      'tujuan',
      'tanggal_surat',
    ];
    for (final key in wajib) {
      if ('${body[key] ?? ''}'.trim().isEmpty) return '$key wajib diisi';
    }
    if (!['masuk', 'keluar'].contains('${body['jenis']}')) {
      return 'Jenis surat harus masuk atau keluar';
    }
    return null;
  }

  static Future<Response> tambah(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag']))
        return ApiResponse.forbidden();
      final body = await _body(request);
      final error = _validasi(body);
      if (error != null) return ApiResponse.error(error);

      final conn = await Database.getConnection();
      await conn.execute(
        '''INSERT INTO surat
           (nomor_surat, jenis, perihal, pengirim, tujuan, tanggal_surat,
            tanggal_diterima, status, file_url, created_by)
           VALUES (:nomor, :jenis, :perihal, :pengirim, :tujuan, :tgl_surat,
                   :tgl_terima, 'baru', :file_url, :created_by)''',
        {
          'nomor': '${body['nomor_surat']}'.trim(),
          'jenis': body['jenis'],
          'perihal': '${body['perihal']}'.trim(),
          'pengirim': '${body['pengirim']}'.trim(),
          'tujuan': '${body['tujuan']}'.trim(),
          'tgl_surat': body['tanggal_surat'],
          'tgl_terima': body['tanggal_diterima'] ?? body['tanggal_surat'],
          'file_url': '${body['file_url'] ?? ''}'.trim(),
          'created_by': user['id'],
        },
      );
      return ApiResponse.created(pesan: 'Surat berhasil ditambahkan');
    } catch (e) {
      final text = e.toString().toLowerCase();
      if (text.contains('duplicate')) {
        return ApiResponse.error('Nomor surat sudah terdaftar');
      }
      return ApiResponse.error(
        'Gagal menambahkan surat',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> ubah(Request request, String id) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag']))
        return ApiResponse.forbidden();
      final body = await _body(request);
      final error = _validasi(body);
      if (error != null) return ApiResponse.error(error);
      final conn = await Database.getConnection();
      await conn.execute(
        '''UPDATE surat SET nomor_surat = :nomor, jenis = :jenis,
           perihal = :perihal, pengirim = :pengirim, tujuan = :tujuan,
           tanggal_surat = :tgl_surat, tanggal_diterima = :tgl_terima,
           file_url = :file_url WHERE id = :id''',
        {
          'id': id,
          'nomor': '${body['nomor_surat']}'.trim(),
          'jenis': body['jenis'],
          'perihal': '${body['perihal']}'.trim(),
          'pengirim': '${body['pengirim']}'.trim(),
          'tujuan': '${body['tujuan']}'.trim(),
          'tgl_surat': body['tanggal_surat'],
          'tgl_terima': body['tanggal_diterima'] ?? body['tanggal_surat'],
          'file_url': '${body['file_url'] ?? ''}'.trim(),
        },
      );
      return ApiResponse.ok(pesan: 'Surat berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui surat',
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
      if (![
        'baru',
        'didisposisi',
        'diproses',
        'selesai',
        'arsip',
      ].contains(status)) {
        return ApiResponse.error('Status surat tidak valid');
      }
      final conn = await Database.getConnection();
      await conn.execute('UPDATE surat SET status = :status WHERE id = :id', {
        'id': id,
        'status': status,
      });
      return ApiResponse.ok(pesan: 'Status surat berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui status surat',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> hapus(Request request, String id) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag']))
        return ApiResponse.forbidden();
      final conn = await Database.getConnection();
      await conn.execute('DELETE FROM surat WHERE id = :id', {'id': id});
      return ApiResponse.ok(pesan: 'Surat berhasil dihapus');
    } catch (e) {
      return ApiResponse.error('Gagal menghapus surat', status: 500, detail: e);
    }
  }
}
