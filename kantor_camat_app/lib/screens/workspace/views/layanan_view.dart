import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class LayananView extends StatefulWidget {
  const LayananView({super.key});

  @override
  State<LayananView> createState() => _LayananViewState();
}

class _LayananViewState extends State<LayananView> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await ApiService.get('/layanan');
    if (!mounted) return;
    setState(() {
      _items = response['data'] is List ? response['data'] as List : [];
      _loading = false;
    });
  }

  Future<void> _form({Map<String, dynamic>? initial}) async {
    final nama = TextEditingController(text: '${initial?['nama'] ?? ''}');
    final sektor = TextEditingController(text: '${initial?['sektor'] ?? ''}');
    final deskripsi = TextEditingController(
      text: '${initial?['deskripsi'] ?? ''}',
    );
    final persyaratan = TextEditingController(
      text: '${initial?['persyaratan'] ?? ''}',
    );
    final estimasi = TextEditingController(
      text: '${initial?['estimasi_hari'] ?? 1}',
    );
    final biaya = TextEditingController(text: '${initial?['biaya'] ?? 0}');
    var aktif = initial?['aktif'] != false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initial == null ? 'Tambah Layanan' : 'Edit Layanan'),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nama,
                    decoration: const InputDecoration(
                      labelText: 'Nama Layanan *',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sektor,
                    decoration: const InputDecoration(
                      labelText: 'Sektor / Seksi',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deskripsi,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: persyaratan,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Persyaratan'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: estimasi,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Estimasi Hari',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: biaya,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Biaya (Rp)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktif dan tampil di halaman publik'),
                    value: aktif,
                    onChanged: (value) => setDialogState(() => aktif = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (nama.text.trim().isEmpty) return;
                final body = {
                  'nama': nama.text.trim(),
                  'sektor': sektor.text.trim(),
                  'deskripsi': deskripsi.text.trim(),
                  'persyaratan': persyaratan.text.trim(),
                  'estimasi_hari': int.tryParse(estimasi.text) ?? 1,
                  'biaya': double.tryParse(biaya.text) ?? 0,
                  'aktif': aktif,
                };
                final response = initial == null
                    ? await ApiService.post('/layanan', body)
                    : await ApiService.put('/layanan/${initial['id']}', body);
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

  Future<void> _disable(Map<String, dynamic> item) async {
    final confirmed = await Notifikasi.konfirmasi(
      context,
      judul: 'Nonaktifkan Layanan?',
      pesan:
          'Layanan ${item['nama']} tidak akan tampil untuk pengajuan baru sampai diaktifkan kembali.',
      teksYa: 'Ya, Nonaktifkan',
      berbahaya: true,
    );
    if (!confirmed) {
      return;
    }

    final response = await ApiService.delete('/layanan/${item['id']}');
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
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_items.length} jenis layanan',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => _form(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Layanan'),
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
              ? const EmptyState(text: 'Belum ada data layanan')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF3F7F5),
                    ),
                    columns: const [
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Sektor')),
                      DataColumn(label: Text('Persyaratan')),
                      DataColumn(label: Text('Estimasi')),
                      DataColumn(label: Text('Biaya')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _items.map((raw) {
                      final item = Map<String, dynamic>.from(raw as Map);
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text(
                                '${item['nama']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Text('${item['sektor'] ?? '-'}'),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 360,
                              child: Text(
                                '${item['persyaratan'] ?? '-'}',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text('${item['estimasi_hari']} hari')),
                          DataCell(Text(formatRupiah(item['biaya']))),
                          DataCell(
                            StatusBadge(
                              item['aktif'] == true ? 'aktif' : 'nonaktif',
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _form(initial: item),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit',
                                ),
                                if (item['aktif'] == true)
                                  IconButton(
                                    onPressed: () => _disable(item),
                                    icon: const Icon(
                                      Icons.block_rounded,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Nonaktifkan',
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
