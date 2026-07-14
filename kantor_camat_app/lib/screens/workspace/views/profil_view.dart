import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/notifikasi.dart';

class ProfilView extends StatefulWidget {
  const ProfilView({super.key});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  final _nama = TextEditingController();
  final _alamat = TextEditingController();
  final _telepon = TextEditingController();
  final _email = TextEditingController();
  final _jam = TextEditingController();
  final _visi = TextEditingController();
  final _misi = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _nama,
      _alamat,
      _telepon,
      _email,
      _jam,
      _visi,
      _misi,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await ApiService.publicGet('/public/profil');
      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : <String, dynamic>{};
      _nama.text = '${data['nama_instansi'] ?? ''}';
      _alamat.text = '${data['alamat'] ?? ''}';
      _telepon.text = '${data['telepon'] ?? ''}';
      _email.text = '${data['email'] ?? ''}';
      _jam.text = '${data['jam_layanan'] ?? ''}';
      _visi.text = '${data['visi'] ?? ''}';
      _misi.text = '${data['misi'] ?? ''}';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_nama.text.trim().isEmpty || _alamat.text.trim().isEmpty) {
      Notifikasi.tampil(
        context,
        pesan: 'Nama instansi dan alamat wajib diisi.',
        sukses: false,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final response = await ApiService.put('/profil', {
        'nama_instansi': _nama.text.trim(),
        'alamat': _alamat.text.trim(),
        'telepon': _telepon.text.trim(),
        'email': _email.text.trim(),
        'jam_layanan': _jam.text.trim(),
        'visi': _visi.text.trim(),
        'misi': _misi.text.trim(),
      });
      if (!mounted) return;
      Notifikasi.tampil(
        context,
        pesan: '${response['pesan'] ?? ''}',
        sukses: response['sukses'] == true,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Publik Kecamatan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Data berikut ditampilkan pada halaman publik SICAMAT.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _nama,
            decoration: const InputDecoration(labelText: 'Nama Instansi *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _alamat,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Alamat *'),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final fields = [
                Expanded(
                  child: TextField(
                    controller: _telepon,
                    decoration: const InputDecoration(labelText: 'Telepon'),
                  ),
                ),
                const SizedBox(width: 12, height: 12),
                Expanded(
                  child: TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ),
              ];
              return compact
                  ? Column(
                      children: [
                        TextField(
                          controller: _telepon,
                          decoration: const InputDecoration(
                            labelText: 'Telepon',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                      ],
                    )
                  : Row(children: fields);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jam,
            decoration: const InputDecoration(labelText: 'Jam Layanan'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _visi,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Visi'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _misi,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Misi'),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Menyimpan...' : 'Simpan Profil'),
            ),
          ),
        ],
      ),
    );
  }
}
