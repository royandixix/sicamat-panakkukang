import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class ClusteringView extends StatefulWidget {
  final Map<String, dynamic> user;

  const ClusteringView({super.key, required this.user});

  @override
  State<ClusteringView> createState() => _ClusteringViewState();
}

class _ClusteringViewState extends State<ClusteringView> {
  Map<String, dynamic>? _result;
  bool _loading = true;
  bool _running = false;
  int _k = 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await ApiService.get('/clustering');
    if (!mounted) return;
    setState(() {
      _result = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : null;
      _loading = false;
    });
  }

  Future<void> _run() async {
    setState(() => _running = true);
    final response = await ApiService.post('/clustering/run', {'k': _k});
    if (!mounted) return;
    setState(() => _running = false);
    Notifikasi.tampil(
      context,
      pesan: '${response['pesan'] ?? ''}',
      sukses: response['sukses'] == true,
      setelahOk: response['sukses'] == true ? _load : null,
    );
  }

  String _quality(double score) {
    if (score >= 0.7) return 'Struktur klaster kuat';
    if (score >= 0.5) return 'Struktur klaster cukup baik';
    if (score >= 0.25) return 'Struktur klaster masih tumpang tindih';
    return 'Klaster perlu dievaluasi kembali';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(),
        ),
      );
    }
    final canRun = '${widget.user['role']}' == 'kasubag';
    final clusters = _result?['clusters'] is List
        ? _result!['clusters'] as List
        : <dynamic>[];
    final score = double.tryParse('${_result?['silhouette'] ?? 0}') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pengelompokan Perihal Surat Masuk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Sistem mengubah perihal surat menjadi vektor TF-IDF, lalu mengelompokkan surat menggunakan algoritma K-Means. Nama klaster diambil dari kata dominan pada centroid.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
              if (canRun) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Jumlah klaster (K):'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _k,
                      items: [2, 3, 4, 5, 6]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value'),
                            ),
                          )
                          .toList(),
                      onChanged: _running
                          ? null
                          : (value) => setState(() => _k = value ?? 3),
                    ),
                    const SizedBox(width: 18),
                    FilledButton.icon(
                      onPressed: _running ? null : _run,
                      icon: _running
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        _running ? 'Memproses...' : 'Jalankan K-Means',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_result == null)
          const SectionCard(
            child: EmptyState(text: 'Belum ada hasil clustering'),
          )
        else ...[
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _InfoCard('K', '${_result!['k']}', Icons.category_outlined),
              _InfoCard(
                'Jumlah Data',
                '${_result!['jumlah_data']}',
                Icons.description_outlined,
              ),
              _InfoCard(
                'Silhouette Score',
                score.toStringAsFixed(4),
                Icons.insights_rounded,
              ),
              _InfoCard(
                'Interpretasi',
                _quality(score),
                Icons.fact_check_outlined,
                width: 280,
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...clusters.map((item) {
            final cluster = Map<String, dynamic>.from(item as Map);
            final members = cluster['members'] is List
                ? cluster['members'] as List
                : <dynamic>[];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEAF5F2),
                          foregroundColor: const Color(0xFF075E54),
                          child: Text(
                            '${cluster['cluster_no']}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${cluster['label']}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${members.length} surat',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (members.isEmpty)
                      const EmptyState(
                        text: 'Tidak ada anggota dalam klaster ini',
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Nomor Surat')),
                            DataColumn(label: Text('Perihal')),
                            DataColumn(label: Text('Jarak')),
                          ],
                          rows: members.map((member) {
                            final row = Map<String, dynamic>.from(
                              member as Map,
                            );
                            final distance =
                                double.tryParse('${row['distance'] ?? 0}') ?? 0;
                            return DataRow(
                              cells: [
                                DataCell(Text('${row['nomor_surat']}')),
                                DataCell(
                                  SizedBox(
                                    width: 520,
                                    child: Text('${row['perihal']}'),
                                  ),
                                ),
                                DataCell(Text(distance.toStringAsFixed(4))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double width;

  const _InfoCard(this.label, this.value, this.icon, {this.width = 210});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3EBE8)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF075E54)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
