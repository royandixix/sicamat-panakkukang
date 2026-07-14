import 'dart:convert';
import 'package:shelf/shelf.dart';

class ApiResponse {
  static const _headers = {'Content-Type': 'application/json; charset=utf-8'};

  static Response ok({dynamic data, String? pesan}) => Response.ok(
    jsonEncode({'sukses': true, 'pesan': ?pesan, 'data': ?data}),
    headers: _headers,
  );

  static Response created({dynamic data, String? pesan}) => Response(
    201,
    body: jsonEncode({'sukses': true, 'pesan': ?pesan, 'data': ?data}),
    headers: _headers,
  );

  static Response error(String pesan, {int status = 400, dynamic detail}) =>
      Response(
        status,
        body: jsonEncode({
          'sukses': false,
          'pesan': pesan,
          if (detail != null) 'detail': detail.toString(),
        }),
        headers: _headers,
      );

  static Response unauthorized() =>
      error('Sesi tidak valid atau telah berakhir', status: 401);
  static Response forbidden() =>
      error('Anda tidak memiliki akses ke fitur ini', status: 403);
  static Response notFound(String pesan) => error(pesan, status: 404);
}
