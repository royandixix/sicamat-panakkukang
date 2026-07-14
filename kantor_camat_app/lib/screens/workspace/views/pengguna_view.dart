import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class PenggunaView extends StatefulWidget {
  final Map<String, dynamic> user;

  const PenggunaView({super.key, required this.user});

  @override
  State<PenggunaView> createState() => _PenggunaViewState();
}

class _PenggunaViewState extends State<PenggunaView> {
  List<dynamic> _items = [];
  bool _loading = true;
  String _roleFilter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final query = _roleFilter.isEmpty ? '' : '?role=$_roleFilter';
    final response = await ApiService.get('/pengguna$query');
    if (!mounted) return;
    setState(() {
      _items = response['data'] is List ? response['data'] as List : [];
      _loading = false;
    });
  }

  Future<void> _form({Map<String, dynamic>? initial}) async {
    final nama = TextEditingController(text: '${initial?['nama'] ?? ''}');
    final email = TextEditingController(text: '${initial?['email'] ?? ''}');
    final password = TextEditingController();
    final kelurahan = TextEditingController(
      text: '${initial?['kelurahan'] ?? ''}',
    );
    final seksi = TextEditingController(text: '${initial?['seksi'] ?? ''}');
    final noHp = TextEditingController(text: '${initial?['no_hp'] ?? ''}');
    var role = '${initial?['role'] ?? 'warga'}';
    var aktif = initial?['aktif'] != false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initial == null ? 'Tambah Pengguna' : 'Edit Pengguna'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nama,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap *',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: initial == null
                          ? 'Password minimal 8 karakter *'
                          : 'Password baru (kosongkan jika tidak diubah)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Peran *'),
                    items: const [
                      DropdownMenuItem(
                        value: 'kasubag',
                        child: Text('Kasubag Umum'),
                      ),
                      DropdownMenuItem(value: 'camat', child: Text('Camat')),
                      DropdownMenuItem(value: 'seksi', child: Text('Seksi')),
                      DropdownMenuItem(
                        value: 'warga',
                        child: Text('Masyarakat'),
                      ),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => role = value ?? 'warga'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: kelurahan,
                          decoration: const InputDecoration(
                            labelText: 'Kelurahan',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: noHp,
                          decoration: const InputDecoration(
                            labelText: 'Nomor HP',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: seksi,
                    decoration: const InputDecoration(
                      labelText: 'Nama Seksi / Unit Kerja',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Akun aktif'),
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
                if (nama.text.trim().isEmpty ||
                    email.text.trim().isEmpty ||
                    (initial == null && password.text.length < 8)) {
                  Notifikasi.tampil(
                    context,
                    judul: 'Data Belum Lengkap',
                    pesan:
                        'Lengkapi nama, email, dan password minimal 8 karakter.',
                    tipe: NotifikasiTipe.peringatan,
                  );
                  return;
                }
                final body = {
                  'nama': nama.text.trim(),
                  'email': email.text.trim(),
                  'password': password.text,
                  'role': role,
                  'kelurahan': kelurahan.text.trim(),
                  'seksi': seksi.text.trim(),
                  'no_hp': noHp.text.trim(),
                  'aktif': aktif,
                };
                final response = initial == null
                    ? await ApiService.post('/pengguna', body)
                    : await ApiService.put('/pengguna/${initial['id']}', body);
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
      judul: 'Nonaktifkan Pengguna?',
      pesan:
          'Akun ${item['nama']} tidak dapat login setelah dinonaktifkan.',
      teksYa: 'Ya, Nonaktifkan',
      berbahaya: true,
    );
    if (!confirmed) {
      return;
    }

    final response = await ApiService.delete('/pengguna/${item['id']}');
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                initialValue: _roleFilter,
                decoration: const InputDecoration(labelText: 'Filter Peran'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Semua')),
                  DropdownMenuItem(value: 'kasubag', child: Text('Kasubag')),
                  DropdownMenuItem(value: 'camat', child: Text('Camat')),
                  DropdownMenuItem(value: 'seksi', child: Text('Seksi')),
                  DropdownMenuItem(value: 'warga', child: Text('Masyarakat')),
                ],
                onChanged: (value) {
                  setState(() => _roleFilter = value ?? '');
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
              onPressed: () => _form(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Tambah Pengguna'),
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
              ? const EmptyState(text: 'Belum ada pengguna')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF3F7F5),
                    ),
                    columns: const [
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Peran')),
                      DataColumn(label: Text('Kelurahan')),
                      DataColumn(label: Text('Seksi')),
                      DataColumn(label: Text('No. HP')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _items.map((raw) {
                      final item = Map<String, dynamic>.from(raw as Map);
                      final isSelf = '${item['id']}' == '${widget.user['id']}';
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item['nama']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(SelectableText('${item['email']}')),
                          DataCell(Text('${item['role']}')),
                          DataCell(Text('${item['kelurahan'] ?? '-'}')),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text('${item['seksi'] ?? '-'}'),
                            ),
                          ),
                          DataCell(Text('${item['no_hp'] ?? '-'}')),
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
                                if (item['aktif'] == true && !isSelf)
                                  IconButton(
                                    onPressed: () => _disable(item),
                                    icon: const Icon(
                                      Icons.person_off_outlined,
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
