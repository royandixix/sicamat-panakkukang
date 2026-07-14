import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/print_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class SuratView extends StatefulWidget {
  final Map<String, dynamic> user;

  const SuratView({super.key, required this.user});

  @override
  State<SuratView> createState() => _SuratViewState();
}

class _SuratViewState extends State<SuratView> {
  final _searchController = TextEditingController();
  List<dynamic> _items = [];
  bool _loading = true;
  String _jenis = '';
  String _status = '';

  bool get _isKasubag => '${widget.user['role']}' == 'kasubag';
  bool get _canStatus =>
      ['kasubag', 'seksi'].contains('${widget.user['role']}');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final query = <String, String>{
      if (_jenis.isNotEmpty) 'jenis': _jenis,
      if (_status.isNotEmpty) 'status': _status,
      if (_searchController.text.trim().isNotEmpty)
        'q': _searchController.text.trim(),
    };
    final suffix = query.isEmpty ? '' : '?${Uri(queryParameters: query).query}';
    final response = await ApiService.get('/surat$suffix');
    if (!mounted) return;
    setState(() {
      _items = response['data'] is List ? response['data'] as List : [];
      _loading = false;
    });
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _form({Map<String, dynamic>? initial}) async {
    final nomor = TextEditingController(
      text: '${initial?['nomor_surat'] ?? ''}',
    );
    final perihal = TextEditingController(text: '${initial?['perihal'] ?? ''}');
    final pengirim = TextEditingController(
      text: '${initial?['pengirim'] ?? ''}',
    );
    final tujuan = TextEditingController(text: '${initial?['tujuan'] ?? ''}');
    final tanggalSurat = TextEditingController(
      text: '${initial?['tanggal_surat'] ?? _today()}'.split(' ').first,
    );
    final tanggalDiterima = TextEditingController(
      text: '${initial?['tanggal_diterima'] ?? _today()}'.split(' ').first,
    );
    final fileUrl = TextEditingController(
      text: '${initial?['file_url'] ?? ''}',
    );
    var jenis = '${initial?['jenis'] ?? 'masuk'}';
    var saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initial == null ? 'Tambah Surat' : 'Edit Surat'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nomor,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Surat *',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: jenis,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Surat *',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'masuk',
                              child: Text('Surat Masuk'),
                            ),
                            DropdownMenuItem(
                              value: 'keluar',
                              child: Text('Surat Keluar'),
                            ),
                          ],
                          onChanged: (value) =>
                              setDialogState(() => jenis = value ?? 'masuk'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: perihal,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Perihal *'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pengirim,
                          decoration: const InputDecoration(
                            labelText: 'Pengirim *',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: tujuan,
                          decoration: const InputDecoration(
                            labelText: 'Tujuan *',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tanggalSurat,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Surat (YYYY-MM-DD) *',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: tanggalDiterima,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Diterima',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fileUrl,
                    decoration: const InputDecoration(
                      labelText: 'URL Berkas (opsional)',
                    ),
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
                      if ([
                        nomor.text,
                        perihal.text,
                        pengirim.text,
                        tujuan.text,
                        tanggalSurat.text,
                      ].any((v) => v.trim().isEmpty)) {
                        Notifikasi.tampil(
                          context,
                          judul: 'Data Belum Lengkap',
                          pesan: 'Kolom bertanda * wajib diisi sebelum surat disimpan.',
                          tipe: NotifikasiTipe.peringatan,
                        );
                        return;
                      }
                      setDialogState(() => saving = true);
                      final body = {
                        'nomor_surat': nomor.text.trim(),
                        'jenis': jenis,
                        'perihal': perihal.text.trim(),
                        'pengirim': pengirim.text.trim(),
                        'tujuan': tujuan.text.trim(),
                        'tanggal_surat': tanggalSurat.text.trim(),
                        'tanggal_diterima': tanggalDiterima.text.trim(),
                        'file_url': fileUrl.text.trim(),
                      };
                      final response = initial == null
                          ? await ApiService.post('/surat', body)
                          : await ApiService.put(
                              '/surat/${initial['id']}',
                              body,
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
              icon: saving
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(saving ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ubahStatus(Map<String, dynamic> item, String status) async {
    final response = await ApiService.put('/surat/${item['id']}/status', {
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

  Future<void> _hapus(Map<String, dynamic> item) async {
    final confirmed = await Notifikasi.konfirmasi(
      context,
      judul: 'Hapus Surat?',
      pesan:
          'Surat ${item['nomor_surat']} akan dihapus. Data disposisi yang terkait juga dapat ikut terhapus.',
      teksYa: 'Ya, Hapus Surat',
      teksTidak: 'Batal',
      berbahaya: true,
    );
    if (!confirmed) {
      return;
    }
    final response = await ApiService.delete('/surat/${item['id']}');
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _load(),
                decoration: InputDecoration(
                  labelText: 'Cari nomor, perihal, pengirim...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: _jenis,
                decoration: const InputDecoration(labelText: 'Jenis'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Semua')),
                  DropdownMenuItem(value: 'masuk', child: Text('Masuk')),
                  DropdownMenuItem(value: 'keluar', child: Text('Keluar')),
                ],
                onChanged: (value) {
                  setState(() => _jenis = value ?? '');
                  _load();
                },
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Semua')),
                  DropdownMenuItem(value: 'baru', child: Text('Baru')),
                  DropdownMenuItem(
                    value: 'didisposisi',
                    child: Text('Didisposisi'),
                  ),
                  DropdownMenuItem(value: 'diproses', child: Text('Diproses')),
                  DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                  DropdownMenuItem(value: 'arsip', child: Text('Arsip')),
                ],
                onChanged: (value) {
                  setState(() => _status = value ?? '');
                  _load();
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
            ),
            if (_isKasubag)
              FilledButton.icon(
                onPressed: () => _form(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Surat'),
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
              ? const EmptyState(text: 'Data surat tidak ditemukan')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF3F7F5),
                    ),
                    columns: const [
                      DataColumn(label: Text('Nomor')),
                      DataColumn(label: Text('Jenis')),
                      DataColumn(label: Text('Perihal')),
                      DataColumn(label: Text('Pengirim')),
                      DataColumn(label: Text('Tujuan')),
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Klaster')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _items.map((raw) {
                      final item = Map<String, dynamic>.from(raw as Map);
                      return DataRow(
                        cells: [
                          DataCell(Text('${item['nomor_surat']}')),
                          DataCell(Text('${item['jenis']}')),
                          DataCell(
                            SizedBox(
                              width: 320,
                              child: Text(
                                '${item['perihal']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text('${item['pengirim']}')),
                          DataCell(Text('${item['tujuan']}')),
                          DataCell(
                            Text('${item['tanggal_surat']}'.split(' ').first),
                          ),
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                '${item['cluster_label'] ?? '-'}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(StatusBadge('${item['status']}')),
                          DataCell(
                            PopupMenuButton<String>(
                              tooltip: 'Aksi',
                              onSelected: (action) {
                                if (action == 'print') {
                                  PrintService.printSurat(item);
                                }
                                if (action == 'edit') _form(initial: item);
                                if (action == 'delete') _hapus(item);
                                if (action.startsWith('status:')) {
                                  _ubahStatus(item, action.split(':').last);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'print',
                                  child: ListTile(
                                    leading: Icon(Icons.print_outlined),
                                    title: Text('Cetak'),
                                  ),
                                ),
                                if (_isKasubag)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit_outlined),
                                      title: Text('Edit'),
                                    ),
                                  ),
                                if (_canStatus) ...[
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'status:diproses',
                                    child: Text('Tandai Diproses'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'status:selesai',
                                    child: Text('Tandai Selesai'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'status:arsip',
                                    child: Text('Arsipkan'),
                                  ),
                                ],
                                if (_isKasubag) ...[
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
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
