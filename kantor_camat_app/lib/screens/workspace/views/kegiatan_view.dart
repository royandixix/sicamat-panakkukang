import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class KegiatanView extends StatefulWidget {
  const KegiatanView({super.key});

  @override
  State<KegiatanView> createState() => _KegiatanViewState();
}

class _KegiatanViewState extends State<KegiatanView> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await ApiService.get('/kegiatan');
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
    final judul = TextEditingController(text: '${initial?['judul'] ?? ''}');
    final isi = TextEditingController(text: '${initial?['isi'] ?? ''}');
    final tanggal = TextEditingController(
      text: '${initial?['tanggal'] ?? _today()}'.split(' ').first,
    );
    final lokasi = TextEditingController(text: '${initial?['lokasi'] ?? ''}');
    var publikasi = initial?['publikasi'] != false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initial == null ? 'Tambah Kegiatan' : 'Edit Kegiatan'),
          content: SizedBox(
            width: 620,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judul,
                  decoration: const InputDecoration(
                    labelText: 'Judul Kegiatan *',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: isi,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tanggal,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal (YYYY-MM-DD) *',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lokasi,
                        decoration: const InputDecoration(labelText: 'Lokasi'),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tampilkan di halaman publik'),
                  value: publikasi,
                  onChanged: (value) => setDialogState(() => publikasi = value),
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
                if (judul.text.trim().isEmpty || tanggal.text.trim().isEmpty) {
                  return;
                }
                final body = {
                  'judul': judul.text.trim(),
                  'isi': isi.text.trim(),
                  'tanggal': tanggal.text.trim(),
                  'lokasi': lokasi.text.trim(),
                  'publikasi': publikasi,
                };
                final response = initial == null
                    ? await ApiService.post('/kegiatan', body)
                    : await ApiService.put('/kegiatan/${initial['id']}', body);
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

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await Notifikasi.konfirmasi(
      context,
      judul: 'Hapus Kegiatan?',
      pesan:
          'Kegiatan ${item['judul']} akan dihapus dari sistem dan halaman informasi publik.',
      teksYa: 'Ya, Hapus',
      berbahaya: true,
    );
    if (!confirmed) {
      return;
    }

    final response = await ApiService.delete('/kegiatan/${item['id']}');
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
                '${_items.length} kegiatan',
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
              label: const Text('Tambah Kegiatan'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_items.isEmpty)
          const SectionCard(child: EmptyState(text: 'Belum ada kegiatan'))
        else
          ..._items.map((raw) {
            final item = Map<String, dynamic>.from(raw as Map);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5F2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.event_note_rounded,
                        color: Color(0xFF075E54),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['judul']}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['tanggal']} • ${item['lokasi'] ?? '-'}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 10),
                          Text('${item['isi'] ?? ''}'),
                          const SizedBox(height: 12),
                          StatusBadge(
                            item['publikasi'] == true
                                ? 'dipublikasikan'
                                : 'draft',
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _form(initial: item),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _delete(item),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
