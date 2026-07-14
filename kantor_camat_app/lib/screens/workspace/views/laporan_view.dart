import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/print_service.dart';
import '../../../widgets/common_widgets.dart';

class LaporanView extends StatefulWidget {
  const LaporanView({super.key});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await ApiService.get('/laporan');
    if (!mounted) return;
    setState(() {
      _data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : {};
      _loading = false;
    });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Ringkasan Laporan Manajemen',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: PrintService.supported
                  ? () => PrintService.printLaporan(_data)
                  : null,
              icon: const Icon(Icons.print_outlined),
              label: const Text('Cetak Laporan'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            final width = wide
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: width,
                  child: _tableCard(
                    'Status Pengajuan',
                    _data['status_pengajuan'],
                    'status',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _tableCard(
                    'Status Surat',
                    _data['status_surat'],
                    'status',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _tableCard(
                    'Layanan Paling Banyak Diajukan',
                    _data['layanan_populer'],
                    'nama',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _tableCard(
                    'Tren Pengajuan Bulanan',
                    _data['pengajuan_bulanan'],
                    'bulan',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _tableCard(String title, dynamic raw, String labelKey) {
    final rows = raw is List ? raw : <dynamic>[];
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            const EmptyState(text: 'Belum ada data')
          else
            ...rows.map((item) {
              final row = Map<String, dynamic>.from(item as Map);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text('${row[labelKey] ?? '-'}')),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${row['total'] ?? 0}',
                        style: const TextStyle(
                          color: Color(0xFF075E54),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
