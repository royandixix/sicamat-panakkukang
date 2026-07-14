import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../services/auth_service.dart';
import '../utils/api_response.dart';

class MasterController {
  static Future<Map<String, dynamic>> _body(Request request) async {
    final raw = await request.readAsString();
    return raw.trim().isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static Future<Map<String, dynamic>?> _admin(Request request) async {
    final user = await AuthService.userFromRequest(request);
    if (user == null || '${user['role']}' != 'kasubag') return null;
    return user;
  }

  static Future<Response> daftarLayanan(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT id, nama, sektor, deskripsi, persyaratan,
                  estimasi_hari, biaya, aktif
           FROM layanan ORDER BY nama''',
      );
      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'nama': r.colAt(1),
                'sektor': r.colAt(2),
                'deskripsi': r.colAt(3),
                'persyaratan': r.colAt(4),
                'estimasi_hari': int.tryParse('${r.colAt(5)}') ?? 0,
                'biaya': double.tryParse('${r.colAt(6)}') ?? 0,
                'aktif': '${r.colAt(7)}' == '1',
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Gagal memuat layanan', status: 500, detail: e);
    }
  }

  static Future<Response> tambahLayanan(Request request) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final body = await _body(request);
      if ('${body['nama'] ?? ''}'.trim().isEmpty)
        return ApiResponse.error('Nama layanan wajib diisi');
      final conn = await Database.getConnection();
      await conn.execute(
        '''INSERT INTO layanan
           (nama, sektor, deskripsi, persyaratan, estimasi_hari, biaya, aktif)
           VALUES (:nama, :sektor, :deskripsi, :persyaratan, :estimasi, :biaya, :aktif)''',
        {
          'nama': '${body['nama']}'.trim(),
          'sektor': '${body['sektor'] ?? ''}'.trim(),
          'deskripsi': '${body['deskripsi'] ?? ''}'.trim(),
          'persyaratan': '${body['persyaratan'] ?? ''}'.trim(),
          'estimasi': int.tryParse('${body['estimasi_hari'] ?? 0}') ?? 0,
          'biaya': double.tryParse('${body['biaya'] ?? 0}') ?? 0,
          'aktif': body['aktif'] == false ? 0 : 1,
        },
      );
      return ApiResponse.created(pesan: 'Layanan berhasil ditambahkan');
    } catch (e) {
      return ApiResponse.error(
        'Gagal menambahkan layanan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> ubahLayanan(Request request, String id) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final body = await _body(request);
      if ('${body['nama'] ?? ''}'.trim().isEmpty)
        return ApiResponse.error('Nama layanan wajib diisi');
      final conn = await Database.getConnection();
      await conn.execute(
        '''UPDATE layanan SET nama = :nama, sektor = :sektor,
           deskripsi = :deskripsi, persyaratan = :persyaratan,
           estimasi_hari = :estimasi, biaya = :biaya, aktif = :aktif
           WHERE id = :id''',
        {
          'id': id,
          'nama': '${body['nama']}'.trim(),
          'sektor': '${body['sektor'] ?? ''}'.trim(),
          'deskripsi': '${body['deskripsi'] ?? ''}'.trim(),
          'persyaratan': '${body['persyaratan'] ?? ''}'.trim(),
          'estimasi': int.tryParse('${body['estimasi_hari'] ?? 0}') ?? 0,
          'biaya': double.tryParse('${body['biaya'] ?? 0}') ?? 0,
          'aktif': body['aktif'] == false ? 0 : 1,
        },
      );
      return ApiResponse.ok(pesan: 'Layanan berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui layanan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> hapusLayanan(Request request, String id) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final conn = await Database.getConnection();
      await conn.execute('UPDATE layanan SET aktif = 0 WHERE id = :id', {
        'id': id,
      });
      return ApiResponse.ok(pesan: 'Layanan dinonaktifkan');
    } catch (e) {
      return ApiResponse.error(
        'Gagal menonaktifkan layanan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> daftarKegiatan(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT id, judul, isi, tanggal, lokasi, publikasi
           FROM kegiatan ORDER BY tanggal DESC, id DESC''',
      );
      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'judul': r.colAt(1),
                'isi': r.colAt(2),
                'tanggal': '${r.colAt(3)}',
                'lokasi': r.colAt(4),
                'publikasi': '${r.colAt(5)}' == '1',
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Gagal memuat kegiatan', status: 500, detail: e);
    }
  }

  static Future<Response> tambahKegiatan(Request request) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final body = await _body(request);
      if ('${body['judul'] ?? ''}'.trim().isEmpty ||
          '${body['tanggal'] ?? ''}'.isEmpty) {
        return ApiResponse.error('Judul dan tanggal kegiatan wajib diisi');
      }
      final conn = await Database.getConnection();
      await conn.execute(
        '''INSERT INTO kegiatan (judul, isi, tanggal, lokasi, publikasi)
           VALUES (:judul, :isi, :tanggal, :lokasi, :publikasi)''',
        {
          'judul': '${body['judul']}'.trim(),
          'isi': '${body['isi'] ?? ''}'.trim(),
          'tanggal': body['tanggal'],
          'lokasi': '${body['lokasi'] ?? ''}'.trim(),
          'publikasi': body['publikasi'] == false ? 0 : 1,
        },
      );
      return ApiResponse.created(pesan: 'Kegiatan berhasil ditambahkan');
    } catch (e) {
      return ApiResponse.error(
        'Gagal menambahkan kegiatan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> ubahKegiatan(Request request, String id) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final body = await _body(request);
      final conn = await Database.getConnection();
      await conn.execute(
        '''UPDATE kegiatan SET judul = :judul, isi = :isi,
           tanggal = :tanggal, lokasi = :lokasi, publikasi = :publikasi
           WHERE id = :id''',
        {
          'id': id,
          'judul': '${body['judul'] ?? ''}'.trim(),
          'isi': '${body['isi'] ?? ''}'.trim(),
          'tanggal': body['tanggal'],
          'lokasi': '${body['lokasi'] ?? ''}'.trim(),
          'publikasi': body['publikasi'] == false ? 0 : 1,
        },
      );
      return ApiResponse.ok(pesan: 'Kegiatan berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui kegiatan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> hapusKegiatan(Request request, String id) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final conn = await Database.getConnection();
      await conn.execute('DELETE FROM kegiatan WHERE id = :id', {'id': id});
      return ApiResponse.ok(pesan: 'Kegiatan berhasil dihapus');
    } catch (e) {
      return ApiResponse.error(
        'Gagal menghapus kegiatan',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> daftarPengguna(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag', 'camat']))
        return ApiResponse.forbidden();
      final role = request.url.queryParameters['role'] ?? '';
      final conn = await Database.getConnection();
      final result = await conn.execute(
        '''SELECT id, nama, email, role, kelurahan, seksi, no_hp, aktif, created_at
           FROM users WHERE (:role = '' OR role = :role)
           ORDER BY nama''',
        {'role': role},
      );
      return ApiResponse.ok(
        data: result.rows
            .map(
              (r) => {
                'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
                'nama': r.colAt(1),
                'email': r.colAt(2),
                'role': r.colAt(3),
                'kelurahan': r.colAt(4),
                'seksi': r.colAt(5),
                'no_hp': r.colAt(6),
                'aktif': '${r.colAt(7)}' == '1',
                'dibuat': '${r.colAt(8)}',
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error('Gagal memuat pengguna', status: 500, detail: e);
    }
  }

  static Future<Response> tambahPengguna(Request request) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final body = await _body(request);
      final nama = '${body['nama'] ?? ''}'.trim();
      final email = '${body['email'] ?? ''}'.trim().toLowerCase();
      final password = '${body['password'] ?? ''}';
      final role = '${body['role'] ?? ''}';
      if (nama.isEmpty || email.isEmpty || password.length < 8) {
        return ApiResponse.error(
          'Nama, email, dan password minimal 8 karakter wajib diisi',
        );
      }
      if (!['kasubag', 'camat', 'seksi', 'warga'].contains(role)) {
        return ApiResponse.error('Peran pengguna tidak valid');
      }
      final conn = await Database.getConnection();
      await conn.execute(
        '''INSERT INTO users
           (nama, email, password_hash, role, kelurahan, seksi, no_hp, aktif)
           VALUES (:nama, :email, SHA2(:password, 256), :role,
                   :kelurahan, :seksi, :no_hp, :aktif)''',
        {
          'nama': nama,
          'email': email,
          'password': password,
          'role': role,
          'kelurahan': '${body['kelurahan'] ?? ''}'.trim(),
          'seksi': '${body['seksi'] ?? ''}'.trim(),
          'no_hp': '${body['no_hp'] ?? ''}'.trim(),
          'aktif': body['aktif'] == false ? 0 : 1,
        },
      );
      return ApiResponse.created(pesan: 'Pengguna berhasil ditambahkan');
    } catch (e) {
      if (e.toString().toLowerCase().contains('duplicate')) {
        return ApiResponse.error('Email sudah digunakan');
      }
      return ApiResponse.error(
        'Gagal menambahkan pengguna',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> ubahPengguna(Request request, String id) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final body = await _body(request);
      final password = '${body['password'] ?? ''}';
      final conn = await Database.getConnection();
      if (password.isEmpty) {
        await conn.execute(
          '''UPDATE users SET nama = :nama, email = :email, role = :role,
             kelurahan = :kelurahan, seksi = :seksi, no_hp = :no_hp,
             aktif = :aktif WHERE id = :id''',
          {
            'id': id,
            'nama': '${body['nama'] ?? ''}'.trim(),
            'email': '${body['email'] ?? ''}'.trim().toLowerCase(),
            'role': body['role'],
            'kelurahan': '${body['kelurahan'] ?? ''}'.trim(),
            'seksi': '${body['seksi'] ?? ''}'.trim(),
            'no_hp': '${body['no_hp'] ?? ''}'.trim(),
            'aktif': body['aktif'] == false ? 0 : 1,
          },
        );
      } else {
        if (password.length < 8)
          return ApiResponse.error('Password minimal 8 karakter');
        await conn.execute(
          '''UPDATE users SET nama = :nama, email = :email,
             password_hash = SHA2(:password, 256), role = :role,
             kelurahan = :kelurahan, seksi = :seksi, no_hp = :no_hp,
             aktif = :aktif WHERE id = :id''',
          {
            'id': id,
            'nama': '${body['nama'] ?? ''}'.trim(),
            'email': '${body['email'] ?? ''}'.trim().toLowerCase(),
            'password': password,
            'role': body['role'],
            'kelurahan': '${body['kelurahan'] ?? ''}'.trim(),
            'seksi': '${body['seksi'] ?? ''}'.trim(),
            'no_hp': '${body['no_hp'] ?? ''}'.trim(),
            'aktif': body['aktif'] == false ? 0 : 1,
          },
        );
      }
      return ApiResponse.ok(pesan: 'Pengguna berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui pengguna',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> nonaktifkanPengguna(
    Request request,
    String id,
  ) async {
    try {
      final admin = await _admin(request);
      if (admin == null) return ApiResponse.forbidden();
      if ('${admin['id']}' == id)
        return ApiResponse.error(
          'Akun yang sedang digunakan tidak dapat dinonaktifkan',
        );
      final conn = await Database.getConnection();
      await conn.execute('UPDATE users SET aktif = 0 WHERE id = :id', {
        'id': id,
      });
      await conn.execute('DELETE FROM sessions WHERE user_id = :id', {
        'id': id,
      });
      return ApiResponse.ok(pesan: 'Pengguna dinonaktifkan');
    } catch (e) {
      return ApiResponse.error(
        'Gagal menonaktifkan pengguna',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> ubahProfil(Request request) async {
    try {
      if (await _admin(request) == null) return ApiResponse.forbidden();
      final body = await _body(request);
      final conn = await Database.getConnection();
      await conn.execute(
        '''UPDATE profil_kecamatan SET nama_instansi = :nama, alamat = :alamat,
           telepon = :telepon, email = :email, jam_layanan = :jam,
           visi = :visi, misi = :misi WHERE id = 1''',
        {
          'nama': '${body['nama_instansi'] ?? ''}'.trim(),
          'alamat': '${body['alamat'] ?? ''}'.trim(),
          'telepon': '${body['telepon'] ?? ''}'.trim(),
          'email': '${body['email'] ?? ''}'.trim(),
          'jam': '${body['jam_layanan'] ?? ''}'.trim(),
          'visi': '${body['visi'] ?? ''}'.trim(),
          'misi': '${body['misi'] ?? ''}'.trim(),
        },
      );
      return ApiResponse.ok(pesan: 'Profil kecamatan berhasil diperbarui');
    } catch (e) {
      return ApiResponse.error(
        'Gagal memperbarui profil',
        status: 500,
        detail: e,
      );
    }
  }
}
