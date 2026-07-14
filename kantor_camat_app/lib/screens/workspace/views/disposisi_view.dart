import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class DisposisiView extends StatefulWidget {
  final Map<String, dynamic> user;

  const DisposisiView({super.key, required this.user});

  @override
  State<DisposisiView> createState() => _DisposisiViewState();
}

class _DisposisiViewState extends State<DisposisiView> {
  List<dynamic> _items = [];
  List<dynamic> _surat = [];
  List<dynamic> _seksi = [];
  bool _loading = true;

  bool get _isKasubag => '${widget.user['role']}' == 'kasubag';
  bool get _canStatus =>
      ['kasubag', 'seksi'].contains('${widget.user['role']}');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final futures = <Future<Map<String, dynamic>>>[
      ApiService.get('/disposisi'),
      if (_isKasubag) ApiService.get('/surat?jenis=masuk'),
      if (_isKasubag) ApiService.get('/pengguna?role=seksi'),
    ];
    final result = await Future.wait(futures);
    if (!mounted) return;
    setState(() {
      _items = result[0]['data'] is List ? result[0]['data'] as List : [];
      if (_isKasubag) {
        _surat = result[1]['data'] is List ? result[1]['data'] as List : [];
        _seksi = result[2]['data'] is List ? result[2]['data'] as List : [];
      }
      _loading = false;
    });
  }

  String _todayPlus(int days) {
    final date = DateTime.now().add(Duration(days: days));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _create() async {
    int? suratId;
    int? userId;
    final catatan = TextEditingController();
    final batas = TextEditingController(text: _todayPlus(3));
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Buat Disposisi Surat'),
          content: SizedBox(
            width: 620,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: suratId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Surat Masuk *',
                  ),
                  items: _surat.map((raw) {
                    final item = Map<String, dynamic>.from(raw as Map);
                    return DropdownMenuItem<int>(
                      value: int.tryParse('${item['id']}'),
                      child: Text(
                        '${item['nomor_surat']} — ${item['perihal']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => suratId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: userId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Penerima / Seksi *',
                  ),
                  items: _seksi.map((raw) {
                    final item = Map<String, dynamic>.from(raw as Map);
                    return DropdownMenuItem<int>(
                      value: int.tryParse('${item['id']}'),
                      child: Text('${item['nama']} — ${item['seksi'] ?? '-'}'),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => userId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catatan,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Instruksi / Catatan',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: batas,
                  decoration: const InputDecoration(
                    labelText: 'Batas Waktu (YYYY-MM-DD)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: saving
                  ? null
                  : () async {
                      if (suratId == null || userId == null) {
                        Notifikasi.tampil(
                          context,
                          judul: 'Data Belum Lengkap',
                          pesan: 'Surat dan penerima disposisi wajib dipilih.',
                          tipe: NotifikasiTipe.peringatan,
                        );
                        return;
                      }
                      setDialogState(() => saving = true);
                      final response = await ApiService.post('/disposisi', {
                        'surat_id': suratId,
                        'ke_user_id': userId,
                        'catatan': catatan.text.trim(),
                        'batas_waktu': batas.text.trim(),
                      });
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      Notifikasi.tampil(
                        context,
                        pesan: '${response['pesan'] ?? ''}',
                        sukses: response['sukses'] == true,
                        setelahOk: response['sukses'] == true ? _load : null,
                      );
                    },
              icon: const Icon(Icons.send_rounded),
              label: Text(saving ? 'Mengirim...' : 'Kirim Disposisi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _status(Map<String, dynamic> item, String status) async {
    final response = await ApiService.put('/disposisi/${item['id']}/status', {
      'status': status,
    });
    if (!mounted) return;
    Notifikasi.tampil(
      context,
      pesan: '${response['pesan'] ?? ''}',
      sukses: response['sukses'] == true,
      setelahOk: response['sukses'] == true ? _load : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_items.length} disposisi',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
            ),
            if (_isKasubag) ...[
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Buat Disposisi'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        SectionCard(
          padding: EdgeInsets.zero,
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _items.isEmpty
              ? const EmptyState(text: 'Belum ada disposisi surat')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF3F7F5),
                    ),
                    columns: const [
                      DataColumn(label: Text('Nomor Surat')),
                      DataColumn(label: Text('Perihal')),
                      DataColumn(label: Text('Dari')),
                      DataColumn(label: Text('Kepada')),
                      DataColumn(label: Text('Instruksi')),
                      DataColumn(label: Text('Batas Waktu')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _items.map((raw) {
                      final item = Map<String, dynamic>.from(raw as Map);
                      return DataRow(
                        cells: [
                          DataCell(Text('${item['nomor_surat']}')),
                          DataCell(
                            SizedBox(
                              width: 300,
                              child: Text(
                                '${item['perihal']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text('${item['dari']}')),
                          DataCell(
                            SizedBox(
                              width: 210,
                              child: Text(
                                '${item['kepada']}\n${item['seksi'] ?? ''}',
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 250,
                              child: Text('${item['catatan'] ?? '-'}'),
                            ),
                          ),
                          DataCell(
                            Text('${item['batas_waktu']}'.split(' ').first),
                          ),
                          DataCell(StatusBadge('${item['status']}')),
                          DataCell(
                            _canStatus
                                ? PopupMenuButton<String>(
                                    onSelected: (value) => _status(item, value),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'diterima',
                                        child: Text('Diterima'),
                                      ),
                                      PopupMenuItem(
                                        value: 'diproses',
                                        child: Text('Diproses'),
                                      ),
                                      PopupMenuItem(
                                        value: 'selesai',
                                        child: Text('Selesai'),
                                      ),
                                    ],
                                  )
                                : const Text('-'),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
