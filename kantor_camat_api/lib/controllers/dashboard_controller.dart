import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../services/auth_service.dart';
import '../utils/api_response.dart';

class DashboardController {
  static Future<int> _count(String sql, [Map<String, dynamic>? params]) async {
    final conn = await Database.getConnection();
    final result = await conn.execute(sql, params ?? const {});
    if (result.rows.isEmpty) return 0;
    return int.tryParse('${result.rows.first.colAt(0)}') ?? 0;
  }

  static Future<Response> ringkasan(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      final role = '${user['role']}';
      final userId = user['id'];

      final suratMasuk = await _count(
        "SELECT COUNT(*) FROM surat WHERE jenis = 'masuk'",
      );
      final suratKeluar = await _count(
        "SELECT COUNT(*) FROM surat WHERE jenis = 'keluar'",
      );
      final pengajuanBaru = role == 'warga'
          ? await _count(
              "SELECT COUNT(*) FROM pengajuan WHERE user_id = :id AND status IN ('diajukan','diproses')",
              {'id': userId},
            )
          : await _count(
              "SELECT COUNT(*) FROM pengajuan WHERE status = 'diajukan'",
            );
      final disposisiAktif = role == 'seksi'
          ? await _count(
              "SELECT COUNT(*) FROM disposisi WHERE ke_user_id = :id AND status <> 'selesai'",
              {'id': userId},
            )
          : await _count(
              "SELECT COUNT(*) FROM disposisi WHERE status <> 'selesai'",
            );
      final pengguna = await _count(
        'SELECT COUNT(*) FROM users WHERE aktif = 1',
      );

      final conn = await Database.getConnection();
      final latest = await conn.execute(
        '''SELECT nomor_surat, jenis, perihal, status, created_at
           FROM surat ORDER BY id DESC LIMIT 5''',
      );

      return ApiResponse.ok(
        data: {
          'surat_masuk': suratMasuk,
          'surat_keluar': suratKeluar,
          'pengajuan_baru': pengajuanBaru,
          'disposisi_aktif': disposisiAktif,
          'total_pengguna': pengguna,
          'surat_terbaru': latest.rows
              .map(
                (r) => {
                  'nomor_surat': r.colAt(0),
                  'jenis': r.colAt(1),
                  'perihal': r.colAt(2),
                  'status': r.colAt(3),
                  'dibuat': '${r.colAt(4)}',
                },
              )
              .toList(),
        },
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal memuat dashboard',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> laporan(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag', 'camat'])) {
        return ApiResponse.forbidden();
      }
      final conn = await Database.getConnection();

      final layanan = await conn.execute('''SELECT l.nama, COUNT(p.id) total
           FROM layanan l
           LEFT JOIN pengajuan p ON p.layanan_id = l.id
           GROUP BY l.id, l.nama ORDER BY total DESC, l.nama''');
      final statusPengajuan = await conn.execute(
        '''SELECT status, COUNT(*) total
           FROM pengajuan GROUP BY status ORDER BY total DESC''',
      );
      final statusSurat = await conn.execute('''SELECT status, COUNT(*) total
           FROM surat GROUP BY status ORDER BY total DESC''');
      final bulanan = await conn.execute(
        '''SELECT DATE_FORMAT(created_at, '%Y-%m') bulan, COUNT(*) total
           FROM pengajuan
           WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 11 MONTH)
           GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY bulan''',
      );

      return ApiResponse.ok(
        data: {
          'layanan_populer': layanan.rows
              .map(
                (r) => {
                  'nama': r.colAt(0),
                  'total': int.tryParse('${r.colAt(1)}') ?? 0,
                },
              )
              .toList(),
          'status_pengajuan': statusPengajuan.rows
              .map(
                (r) => {
                  'status': r.colAt(0),
                  'total': int.tryParse('${r.colAt(1)}') ?? 0,
                },
              )
              .toList(),
          'status_surat': statusSurat.rows
              .map(
                (r) => {
                  'status': r.colAt(0),
                  'total': int.tryParse('${r.colAt(1)}') ?? 0,
                },
              )
              .toList(),
          'pengajuan_bulanan': bulanan.rows
              .map(
                (r) => {
                  'bulan': r.colAt(0),
                  'total': int.tryParse('${r.colAt(1)}') ?? 0,
                },
              )
              .toList(),
        },
      );
    } catch (e) {
      return ApiResponse.error('Gagal memuat laporan', status: 500, detail: e);
    }
  }
}
