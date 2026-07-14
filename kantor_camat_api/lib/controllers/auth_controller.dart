import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../services/auth_service.dart';
import '../utils/api_response.dart';

class AuthController {
  static Future<Response> login(Request request) async {
    try {
      final raw = await request.readAsString();
      final body = raw.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(raw) as Map<String, dynamic>;
      final email = '${body['email'] ?? ''}'.trim().toLowerCase();
      final password = '${body['password'] ?? ''}';

      if (email.isEmpty || password.isEmpty) {
        return ApiResponse.error('Email dan password wajib diisi');
      }

      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT id, nama, email, role, kelurahan, seksi, no_hp
           FROM users
           WHERE email = :email AND password_hash = SHA2(:password, 256)
             AND aktif = 1
           LIMIT 1''',
        {'email': email, 'password': password},
      );

      if (result.rows.isEmpty) {
        return ApiResponse.error('Email atau password salah', status: 401);
      }

      final row = result.rows.first;
      final userId = int.tryParse('${row.colAt(0)}') ?? 0;
      final token = AuthService.generateToken();

      await conn.execute(
        'DELETE FROM sessions WHERE user_id = :user_id OR expires_at <= NOW()',
        {'user_id': userId},
      );
      await conn.execute(
        '''INSERT INTO sessions (token, user_id, expires_at)
           VALUES (:token, :user_id, DATE_ADD(NOW(), INTERVAL 12 HOUR))''',
        {'token': token, 'user_id': userId},
      );

      return ApiResponse.ok(
        pesan: 'Login berhasil',
        data: {
          'token': token,
          'user': {
            'id': userId,
            'nama': row.colAt(1),
            'email': row.colAt(2),
            'role': row.colAt(3),
            'kelurahan': row.colAt(4),
            'seksi': row.colAt(5),
            'no_hp': row.colAt(6),
          },
        },
      );
    } catch (e) {
      return ApiResponse.error(
        'Terjadi kesalahan pada server',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> me(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      user.remove('token');
      return ApiResponse.ok(data: user);
    } catch (e) {
      return ApiResponse.error('Gagal membaca sesi', status: 500, detail: e);
    }
  }

  static Future<Response> logout(Request request) async {
    try {
      final token = AuthService.bearerToken(request);
      if (token != null) {
        final conn = await Database.getConnection();
        await conn.execute('DELETE FROM sessions WHERE token = :token', {
          'token': token,
        });
      }
      return ApiResponse.ok(pesan: 'Anda telah keluar dari sistem');
    } catch (e) {
      return ApiResponse.error('Gagal mengakhiri sesi', status: 500, detail: e);
    }
  }
}
