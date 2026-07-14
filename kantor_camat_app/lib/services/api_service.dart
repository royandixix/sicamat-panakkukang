import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sesi_service.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081/api',
  );

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (authenticated) {
        final token = await SesiService.token();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final uri = Uri.parse('$baseUrl$path');
      late http.Response response;
      switch (method) {
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 25));
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 25));
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 25));
          break;
        default:
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 25));
      }

      Map<String, dynamic> result;
      try {
        result = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      } catch (_) {
        result = {
          'sukses': false,
          'pesan': 'Respons server tidak valid (${response.statusCode})',
        };
      }
      result['_status'] = response.statusCode;
      if (response.statusCode == 401) await SesiService.hapus();
      return result;
    } catch (error) {
      return {
        'sukses': false,
        'pesan':
            'Tidak dapat terhubung ke server SICAMAT. Periksa API dan jaringan.',
        'detail': error.toString(),
        '_status': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) =>
      _request(
        'POST',
        '/login',
        body: {'email': email, 'password': password},
        authenticated: false,
      );

  static Future<Map<String, dynamic>> logout() => _request('POST', '/logout');

  static Future<Map<String, dynamic>> publicGet(String path) =>
      _request('GET', path, authenticated: false);

  static Future<Map<String, dynamic>> get(String path) => _request('GET', path);

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) => _request('POST', path, body: body);

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) => _request('PUT', path, body: body);

  static Future<Map<String, dynamic>> delete(String path) =>
      _request('DELETE', path);
}
