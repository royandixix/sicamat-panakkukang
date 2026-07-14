import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../services/auth_service.dart';
import '../utils/api_response.dart';

class DisposisiController {
  static Future<Map<String, dynamic>> _body(Request request) async {
    final raw = await request.readAsString();
    return raw.trim().isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static Future<Response> daftar(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag', 'camat', 'seksi'])) {
        return ApiResponse.forbidden();
      }
      final hanyaSaya = '${user['role']}' == 'seksi';
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT d.id, d.surat_id, s.nomor_surat, s.perihal,
                  pengirim.nama, penerima.nama, penerima.seksi,
                  d.catatan, d.batas_waktu, d.status, d.created_at
           FROM disposisi d
           JOIN surat s ON s.id = d.surat_id
           JOIN users pengirim ON pengirim.id = d.dari_user_id
           JOIN users penerima ON penerima.id = d.ke_user_id
           WHERE (:hanya_saya = 0 OR d.ke_user_id = :user_id)
           ORDER BY d.id DESC''',
        {'hanya_saya': hanyaSaya ? 1 : 0, 'user_id': user['id']},
      );
      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'surat_id': int.tryParse('${r.colAt(1)}') ?? r.colAt(1),
                'nomor_surat': r.colAt(2),
                'perihal': r.colAt(3),
                'dari': r.colAt(4),
                'kepada': r.colAt(5),
                'seksi': r.colAt(6),
                'catatan': r.colAt(7),
                'batas_waktu': '${r.colAt(8)}',
                'status': r.colAt(9),
                'dibuat': '${r.colAt(10)}',
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal memuat disposisi',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> tambah(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag']))
        return ApiResponse.forbidden();
      final body = await _body(request);
      if ('${body['surat_id'] ?? ''}'.isEmpty ||
          '${body['ke_user_id'] ?? ''}'.isEmpty) {
        return ApiResponse.error('Surat dan penerima disposisi wajib dipilih');
      }
      final conn = await Database.getConnection();
      await conn.execute(
        '''INSERT INTO disposisi
           (surat_id, dari_user_id, ke_user_id, catatan, batas_waktu, status)
           VALUES (:surat_id, :dari, :kepada, :catatan, :batas, 'dikirim')''',
        {
          'surat_id': body['surat_id'],
          'dari': user['id'],
          'kepada': body['ke_user_id'],
          'catatan': '${body['catatan'] ?? ''}'.trim(),
          'batas': body['batas_waktu'],
        },
      );
      await conn.execute(
        "UPDATE surat SET status = 'didisposisi' WHERE id = :id",
        {'id': body['surat_id']},
      );
      return ApiResponse.created(pesan: 'Surat berhasil didisposisikan');
    } catch (e) {
      return ApiResponse.error(
        'Gagal membuat disposisi',
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
      if (!['dikirim', 'diterima', 'diproses', 'selesai'].contains(status)) {
        return ApiResponse.error('Status disposisi tidak valid');
      }
      final conn = await Database.getConnection();
      if ('${user['role']}' == 'seksi') {
        final cek = await conn.execute(
          'SELECT surat_id FROM disposisi WHERE id = :id AND ke_user_id = :user_id',
          {'id': id, 'user_id': user['id']},
        );
        if (cek.rows.isEmpty) return ApiResponse.forbidden();
      }
      await conn.execute(
        'UPDATE disposisi SET status = :status WHERE id = :id',
        {'id': id, 'status': status},
      );
      if (status == 'selesai') {
        final row = await conn.execute(
          'SELECT surat_id FROM disposisi WHERE id = :id LIMIT 1',
          {'id': id},
        );
        if (row.rows.isNotEmpty) {
          await conn.execute(
            "UPDATE surat SET status = 'selesai' WHERE id = :surat_id",
            {'surat_id': row.rows.first.colAt(0)},
          );
        }
      }
      return ApiResponse.ok(pesan: 'Status disposisi berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui disposisi',
        status: 500,
        detail: e,
      );
    }
  }
}
