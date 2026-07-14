import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/print_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class PengajuanView extends StatefulWidget {
  final Map<String, dynamic> user;

  const PengajuanView({super.key, required this.user});

  @override
  State<PengajuanView> createState() => _PengajuanViewState();
}

class _PengajuanViewState extends State<PengajuanView> {
  List<dynamic> _items = [];
  List<dynamic> _layanan = [];
  bool _loading = true;
  String _statusFilter = '';

  bool get _isWarga => '${widget.user['role']}' == 'warga';
  bool get _canProcess =>
      ['kasubag', 'seksi'].contains('${widget.user['role']}');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final query = _statusFilter.isEmpty ? '' : '?status=$_statusFilter';
    final results = await Future.wait([
      ApiService.get('/pengajuan$query'),
      ApiService.get('/layanan'),
    ]);
    if (!mounted) return;
    setState(() {
      _items = results[0]['data'] is List ? results[0]['data'] as List : [];
      _layanan = results[1]['data'] is List ? results[1]['data'] as List : [];
      _loading = false;
    });
  }

  String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _create() async {
    int? layananId;
    final judul = TextEditingController();
    final deskripsi = TextEditingController();
    final lokasi = TextEditingController();
    final mulai = TextEditingController(text: _date(DateTime.now()));
    final selesai = TextEditingController(text: _date(DateTime.now()));
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pengajuan Layanan Baru'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: layananId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Layanan *',
                    ),
                    items: _layanan
                        .where(
                          (raw) =>
                              Map<String, dynamic>.from(raw as Map)['aktif'] !=
                              false,
                        )
                        .map((raw) {
                          final item = Map<String, dynamic>.from(raw as Map);
                          return DropdownMenuItem<int>(
                            value: int.tryParse('${item['id']}'),
                            child: Text('${item['nama']}'),
                          );
                        })
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => layananId = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: judul,
                    decoration: const InputDecoration(
                      labelText: 'Judul / Keperluan *',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deskripsi,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Pengajuan *',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lokasi,
                    decoration: const InputDecoration(labelText: 'Lokasi'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: mulai,
                          decoration: const InputDecoration(
                            labelText: 'Mulai (YYYY-MM-DD)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: selesai,
                          decoration: const InputDecoration(
                            labelText: 'Selesai (YYYY-MM-DD)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                      if (layananId == null ||
                          judul.text.trim().isEmpty ||
                          deskripsi.text.trim().isEmpty) {
                        Notifikasi.tampil(
                          context,
                          judul: 'Data Belum Lengkap',
                          pesan: 'Layanan, judul, dan deskripsi wajib diisi.',
                          tipe: NotifikasiTipe.peringatan,
                        );
                        return;
                      }
                      setDialogState(() => saving = true);
                      final response = await ApiService.post('/pengajuan', {
                        'layanan_id': layananId,
                        'judul': judul.text.trim(),
                        'deskripsi': deskripsi.text.trim(),
                        'lokasi': lokasi.text.trim(),
                        'tanggal_mulai': mulai.text.trim(),
                        'tanggal_selesai': selesai.text.trim(),
                      });
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      final kode = response['data'] is Map
                          ? (response['data'] as Map)['kode']
                          : null;
                      Notifikasi.tampil(
                        context,
                        judul: response['sukses'] == true
                            ? 'Pengajuan Terkirim'
                            : 'Gagal',
                        pesan: response['sukses'] == true
                            ? '${response['pesan']}\nKode pelacakan: $kode'
                            : '${response['pesan'] ?? ''}',
                        sukses: response['sukses'] == true,
                        setelahOk: response['sukses'] == true ? _load : null,
                      );
                    },
              icon: const Icon(Icons.send_rounded),
              label: Text(saving ? 'Mengirim...' : 'Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _process(Map<String, dynamic> item) async {
    var status = '${item['status']}';
    final catatan = TextEditingController(
      text: '${item['catatan_petugas'] ?? ''}',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Proses ${item['kode']}'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'diajukan',
                      child: Text('Diajukan'),
                    ),
                    DropdownMenuItem(
                      value: 'diverifikasi',
                      child: Text('Diverifikasi'),
                    ),
                    DropdownMenuItem(
                      value: 'diproses',
                      child: Text('Diproses'),
                    ),
                    DropdownMenuItem(
                      value: 'disetujui',
                      child: Text('Disetujui'),
                    ),
                    DropdownMenuItem(value: 'ditolak', child: Text('Ditolak')),
                    DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => status = value ?? status),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catatan,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Petugas',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final response = await ApiService.put(
                  '/pengajuan/${item['id']}/status',
                  {'status': status, 'catatan_petugas': catatan.text.trim()},
                );
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
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel(Map<String, dynamic> item) async {
    final confirmed = await Notifikasi.konfirmasi(
      context,
      judul: 'Batalkan Pengajuan?',
      pesan:
          'Pengajuan ${item['kode'] ?? ''} akan dibatalkan dan tidak dapat dilanjutkan oleh petugas.',
      teksYa: 'Ya, Batalkan',
      berbahaya: true,
    );
    if (!confirmed) {
      return;
    }

    final response = await ApiService.put(
      '/pengajuan/${item['id']}/batalkan',
      {},
    );
    if (!mounted) {
      return;
    }
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 210,
              child: DropdownButtonFormField<String>(
                initialValue: _statusFilter,
                decoration: const InputDecoration(labelText: 'Filter Status'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Semua')),
                  DropdownMenuItem(value: 'diajukan', child: Text('Diajukan')),
                  DropdownMenuItem(
                    value: 'diverifikasi',
                    child: Text('Diverifikasi'),
                  ),
                  DropdownMenuItem(value: 'diproses', child: Text('Diproses')),
                  DropdownMenuItem(
                    value: 'disetujui',
                    child: Text('Disetujui'),
                  ),
                  DropdownMenuItem(value: 'ditolak', child: Text('Ditolak')),
                  DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                ],
                onChanged: (value) {
                  setState(() => _statusFilter = value ?? '');
                  _load();
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
            ),
            FilledButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Pengajuan Baru'),
            ),
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
              ? const EmptyState(text: 'Belum ada pengajuan layanan')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF3F7F5),
                    ),
                    columns: const [
                      DataColumn(label: Text('Kode')),
                      DataColumn(label: Text('Pemohon')),
                      DataColumn(label: Text('Layanan')),
                      DataColumn(label: Text('Keperluan')),
                      DataColumn(label: Text('Periode')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Catatan')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _items.map((raw) {
                      final item = Map<String, dynamic>.from(raw as Map);
                      final canCancel =
                          _isWarga &&
                          [
                            'diajukan',
                            'diverifikasi',
                          ].contains('${item['status']}');
                      return DataRow(
                        cells: [
                          DataCell(SelectableText('${item['kode']}')),
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                '${item['nama_warga']}\n${item['kelurahan'] ?? ''}',
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text('${item['layanan']}'),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 280,
                              child: Text(
                                '${item['judul']}\n${item['deskripsi']}',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${'${item['tanggal_mulai']}'.split(' ').first}\ns.d. ${'${item['tanggal_selesai']}'.split(' ').first}',
                            ),
                          ),
                          DataCell(StatusBadge('${item['status']}')),
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text('${item['catatan_petugas'] ?? '-'}'),
                            ),
                          ),
                          DataCell(
                            Wrap(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      PrintService.printPengajuan(item),
                                  icon: const Icon(Icons.print_outlined),
                                  tooltip: 'Cetak',
                                ),
                                if (_canProcess)
                                  IconButton(
                                    onPressed: () => _process(item),
                                    icon: const Icon(Icons.edit_note_rounded),
                                    tooltip: 'Proses',
                                  ),
                                if (canCancel)
                                  IconButton(
                                    onPressed: () => _cancel(item),
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Batalkan',
                                  ),
                              ],
                            ),
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
