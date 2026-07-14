import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../services/auth_service.dart';
import '../services/kmeans_service.dart';
import '../utils/api_response.dart';

class ClusteringController {
  static Future<Response> jalankan(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag']))
        return ApiResponse.forbidden();
      final raw = await request.readAsString();
      final body = raw.trim().isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final requestedK = int.tryParse('${body['k'] ?? 3}') ?? 3;
      if (requestedK < 2 || requestedK > 8) {
        return ApiResponse.error('Nilai K harus berada antara 2 sampai 8');
      }

      final conn = await Database.getConnection();
      final source = await conn.execute(
        '''SELECT id, nomor_surat, perihal FROM surat
           WHERE jenis = 'masuk' AND perihal IS NOT NULL AND perihal <> ''
           ORDER BY id''',
      );
      final documents = source.rows
          .map(
            (r) => {
              'id': int.tryParse('${r.colAt(0)}') ?? r.colAt(0),
              'nomor_surat': r.colAt(1),
              'perihal': r.colAt(2),
            },
          )
          .toList();

      final result = KMeansService.run(documents, requestedK: requestedK);
      final insertRun = await conn.execute(
        '''INSERT INTO cluster_runs (k_value, jumlah_data, silhouette, created_by)
           VALUES (:k, :jumlah, :silhouette, :created_by)''',
        {
          'k': result.k,
          'jumlah': documents.length,
          'silhouette': result.silhouette,
          'created_by': user['id'],
        },
      );
      final runId = insertRun.lastInsertID.toInt();

      for (final cluster in result.clusters) {
        final clusterNo = cluster['cluster_no'];
        final label = cluster['label'];
        for (final member in cluster['members'] as List) {
          await conn.execute(
            '''INSERT INTO cluster_members
               (run_id, surat_id, cluster_no, cluster_label, distance)
               VALUES (:run_id, :surat_id, :cluster_no, :label, :distance)''',
            {
              'run_id': runId,
              'surat_id': member['surat_id'],
              'cluster_no': clusterNo,
              'label': label,
              'distance': member['distance'],
            },
          );
          await conn.execute(
            '''UPDATE surat SET cluster_no = :cluster_no,
               cluster_label = :label WHERE id = :surat_id''',
            {
              'cluster_no': clusterNo,
              'label': label,
              'surat_id': member['surat_id'],
            },
          );
        }
      }

      return ApiResponse.created(
        pesan: 'Clustering K-Means berhasil dijalankan',
        data: {
          'run_id': runId,
          'k': result.k,
          'jumlah_data': documents.length,
          'silhouette': result.silhouette,
          'clusters': result.clusters,
        },
      );
    } on ArgumentError catch (e) {
      return ApiResponse.error(
        e.message?.toString() ?? 'Data clustering tidak valid',
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal menjalankan clustering',
        status: 500,
        detail: e,
      );
    }
  }

  static Future<Response> hasilTerakhir(Request request) async {
    try {
      final user = await AuthService.userFromRequest(request);
      if (user == null) return ApiResponse.unauthorized();
      if (!AuthService.hasRole(user, const ['kasubag', 'camat']))
        return ApiResponse.forbidden();
      final conn = await Database.getConnection();
      final run = await conn.execute(
        '''SELECT cr.id, cr.k_value, cr.jumlah_data, cr.silhouette,
                  cr.created_at, u.nama
           FROM cluster_runs cr JOIN users u ON u.id = cr.created_by
           ORDER BY cr.id DESC LIMIT 1''',
      );
      if (run.rows.isEmpty)
        return ApiResponse.ok(data: null, pesan: 'Belum ada hasil clustering');
      final r = run.rows.first;
      final runId = int.tryParse('${r.colAt(0)}') ?? 0;
      final members = await conn.execute(
        '''SELECT cm.cluster_no, cm.cluster_label, cm.distance,
                  s.id, s.nomor_surat, s.perihal
           FROM cluster_members cm
           JOIN surat s ON s.id = cm.surat_id
           WHERE cm.run_id = :run_id
           ORDER BY cm.cluster_no, cm.distance''',
        {'run_id': runId},
      );
      final grouped = <int, Map<String, dynamic>>{};
      for (final row in members.rows) {
        final clusterNo = int.tryParse('${row.colAt(0)}') ?? 0;
        grouped.putIfAbsent(
          clusterNo,
          () => {
            'cluster_no': clusterNo,
            'label': row.colAt(1),
            'members': <Map<String, dynamic>>[],
          },
        );
        (grouped[clusterNo]!['members'] as List<Map<String, dynamic>>).add({
          'distance': double.tryParse('${row.colAt(2)}') ?? 0,
          'surat_id': int.tryParse('${row.colAt(3)}') ?? row.colAt(3),
          'nomor_surat': row.colAt(4),
          'perihal': row.colAt(5),
        });
      }
      final clusters = grouped.values.toList()
        ..sort(
          (a, b) => (a['cluster_no'] as int).compareTo(b['cluster_no'] as int),
        );
      for (final cluster in clusters) {
        cluster['jumlah'] = (cluster['members'] as List).length;
      }
      return ApiResponse.ok(
        data: {
          'run_id': runId,
          'k': int.tryParse('${r.colAt(1)}') ?? 0,
          'jumlah_data': int.tryParse('${r.colAt(2)}') ?? 0,
          'silhouette': double.tryParse('${r.colAt(3)}') ?? 0,
          'dibuat': '${r.colAt(4)}',
          'dibuat_oleh': r.colAt(5),
          'clusters': clusters,
        },
      );
    } catch (e) {
      return ApiResponse.error(
        'Gagal memuat hasil clustering',
        status: 500,
        detail: e,
      );
    }
  }
}
