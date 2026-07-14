import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import '../config/database.dart';

class AuthService {
  static String? bearerToken(Request request) {
    final header = request.headers['authorization'];
    if (header == null || !header.toLowerCase().startsWith('bearer ')) {
      return null;
    }
    return header.substring(7).trim();
  }

  static Future<Map<String, dynamic>?> userFromRequest(Request request) async {
    final token = bearerToken(request);
    if (token == null || token.isEmpty) return null;

    final conn = await Database.getConnection();
    final result = await conn.execute(
      '''SELECT u.id, u.nama, u.email, u.role, u.kelurahan, u.seksi, u.no_hp
         FROM sessions s
         JOIN users u ON u.id = s.user_id
         WHERE s.token = :token AND s.expires_at > NOW() AND u.aktif = 1
         LIMIT 1''',
      {'token': token},
    );
    if (result.rows.isEmpty) return null;
    final row = result.rows.first;
    return {
      'id': int.tryParse('${row.colAt(0)}') ?? row.colAt(0),
      'nama': row.colAt(1),
      'email': row.colAt(2),
      'role': row.colAt(3),
      'kelurahan': row.colAt(4),
      'seksi': row.colAt(5),
      'no_hp': row.colAt(6),
      'token': token,
    };
  }

  static bool hasRole(Map<String, dynamic> user, Iterable<String> roles) =>
      roles.contains('${user['role']}');

  static String generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(48, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
