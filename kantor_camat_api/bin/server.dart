import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:kantor_camat_api/config/database.dart';
import 'package:kantor_camat_api/controllers/auth_controller.dart';
import 'package:kantor_camat_api/controllers/clustering_controller.dart';
import 'package:kantor_camat_api/controllers/dashboard_controller.dart';
import 'package:kantor_camat_api/controllers/disposisi_controller.dart';
import 'package:kantor_camat_api/controllers/master_controller.dart';
import 'package:kantor_camat_api/controllers/pengajuan_controller.dart';
import 'package:kantor_camat_api/controllers/public_controller.dart';
import 'package:kantor_camat_api/controllers/surat_controller.dart';

Map<String, String> get _corsHeaders => {
      'Access-Control-Allow-Origin':
          Platform.environment['ALLOWED_ORIGIN'] ?? '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers':
          'Content-Type, Authorization, X-Requested-With',
    };

Middleware corsMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final response = await inner(request);
      return response.change(headers: {...response.headers, ..._corsHeaders});
    };
  };
}

Middleware jsonErrorMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      try {
        return await inner(request);
      } catch (e, stack) {
        stderr.writeln('Unhandled error: $e\n$stack');
        return Response.internalServerError(
          body: jsonEncode({
            'sukses': false,
            'pesan': 'Terjadi kesalahan tak terduga pada server',
          }),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      }
    };
  };
}

Future<void> main() async {
  final router = Router();

  router.get('/api/health', (Request request) async {
    final conn = await Database.getConnection();
    await conn.execute('SELECT 1');
    return Response.ok(
      jsonEncode({
        'sukses': true,
        'data': {'status': 'ok', 'aplikasi': 'SICAMAT API', 'versi': '2.0.0'},
      }),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
  });

  router.post('/api/login', AuthController.login);
  router.get('/api/me', AuthController.me);
  router.post('/api/logout', AuthController.logout);

  router.get('/api/public/profil', PublicController.profil);
  router.get('/api/public/layanan', PublicController.layanan);
  router.get('/api/public/kegiatan', PublicController.kegiatan);
  router.get('/api/public/pengajuan/<kode>', PublicController.lacakPengajuan);

  router.get('/api/dashboard', DashboardController.ringkasan);
  router.get('/api/laporan', DashboardController.laporan);

  router.get('/api/surat', SuratController.daftar);
  router.get('/api/surat/<id>', SuratController.detail);
  router.post('/api/surat', SuratController.tambah);
  router.put('/api/surat/<id>', SuratController.ubah);
  router.put('/api/surat/<id>/status', SuratController.ubahStatus);
  router.delete('/api/surat/<id>', SuratController.hapus);

  router.get('/api/disposisi', DisposisiController.daftar);
  router.post('/api/disposisi', DisposisiController.tambah);
  router.put('/api/disposisi/<id>/status', DisposisiController.ubahStatus);

  router.get('/api/pengajuan', PengajuanController.daftar);
  router.post('/api/pengajuan', PengajuanController.tambah);
  router.put('/api/pengajuan/<id>/status', PengajuanController.ubahStatus);
  router.put('/api/pengajuan/<id>/batalkan', PengajuanController.batalkan);

  router.get('/api/layanan', MasterController.daftarLayanan);
  router.post('/api/layanan', MasterController.tambahLayanan);
  router.put('/api/layanan/<id>', MasterController.ubahLayanan);
  router.delete('/api/layanan/<id>', MasterController.hapusLayanan);

  router.get('/api/kegiatan', MasterController.daftarKegiatan);
  router.post('/api/kegiatan', MasterController.tambahKegiatan);
  router.put('/api/kegiatan/<id>', MasterController.ubahKegiatan);
  router.delete('/api/kegiatan/<id>', MasterController.hapusKegiatan);

  router.get('/api/pengguna', MasterController.daftarPengguna);
  router.post('/api/pengguna', MasterController.tambahPengguna);
  router.put('/api/pengguna/<id>', MasterController.ubahPengguna);
  router.delete('/api/pengguna/<id>', MasterController.nonaktifkanPengguna);
  router.put('/api/profil', MasterController.ubahProfil);

  router.get('/api/clustering', ClusteringController.hasilTerakhir);
  router.post('/api/clustering/run', ClusteringController.jalankan);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addMiddleware(jsonErrorMiddleware())
      .addHandler(router.call);

  final host = Platform.environment['HOST'] ?? '0.0.0.0';
  final port = int.tryParse(Platform.environment['PORT'] ?? '8081') ?? 8081;
  final server = await serve(handler, host, port);
  stdout.writeln('SICAMAT API berjalan pada http://${server.address.host}:${server.port}');
}
