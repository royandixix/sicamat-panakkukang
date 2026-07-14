import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SesiService {
  static const _kunci = 'sicamat_session';

  static Future<void> simpan({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kunci, jsonEncode({'token': token, 'user': user}));
  }

  static Future<Map<String, dynamic>?> ambil() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kunci);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      await prefs.remove(_kunci);
      return null;
    }
  }

  static Future<String?> token() async {
    final session = await ambil();
    return session?['token']?.toString();
  }

  static Future<void> hapus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kunci);
  }
}
