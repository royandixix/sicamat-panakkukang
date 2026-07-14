import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common_widgets.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<String, dynamic> _data = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApiService.get('/dashboard');
      if (!mounted) {
        return;
      }
      if (result['sukses'] == true && result['data'] is Map) {
        setState(
          () => _data = Map<String, dynamic>.from(result['data'] as Map),
        );
      } else {
        setState(
          () => _error = '${result['pesan'] ?? 'Gagal memuat dashboard'}',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Tidak dapat terhubung ke server');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String get _role => '${widget.user['role'] ?? ''}';

  String get _roleLabel => switch (_role) {
    'kasubag' => 'Kasubag Umum',
    'camat' => 'Camat',
    'seksi' => '${widget.user['seksi'] ?? 'Seksi Kecamatan'}',
    'warga' => 'Masyarakat',
    _ => _role,
  };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SectionCard(
        child: LoadingState(message: 'Menyiapkan ringkasan dashboard...'),
      );
    }

    if (_error != null) {
      return SectionCard(
        child: EmptyState(
          text: 'Dashboard belum dapat dimuat',
          description: _error,
          icon: Icons.cloud_off_rounded,
          action: FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ),
      );
    }

    final latest = _data['surat_terbaru'] is List
        ? _data['surat_terbaru'] as List
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _welcomeBanner(),
        const SizedBox(height: 20),
        _metrics(),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 980;
            if (desktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _latestLetters(latest)),
                  const SizedBox(width: 18),
                  Expanded(flex: 3, child: _rolePanel()),
                ],
              );
            }
            return Column(
              children: [
                _latestLetters(latest),
                const SizedBox(height: 18),
                _rolePanel(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _welcomeBanner() {
    final firstName = '${widget.user['nama'] ?? 'Pengguna'}'.trim().split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.17),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -52,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 760;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF8BE0C7),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _roleLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    'Selamat datang, $firstName 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      _welcomeMessage(),
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              );

              if (!desktop) {
                return copy;
              }

              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 25),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Hari Ini',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Data diperbarui dari server',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metrics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1260
            ? (constraints.maxWidth - 56) / 5
            : constraints.maxWidth >= 900
            ? (constraints.maxWidth - 42) / 4
            : constraints.maxWidth >= 560
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;

        final cards = <Widget>[
          MetricCard(
            width: width,
            label: 'Surat Masuk',
            value: '${_data['surat_masuk'] ?? 0}',
            icon: Icons.mark_email_unread_rounded,
            color: AppColors.info,
            caption: 'Dokumen tercatat',
          ),
          MetricCard(
            width: width,
            label: 'Surat Keluar',
            value: '${_data['surat_keluar'] ?? 0}',
            icon: Icons.outgoing_mail,
            color: AppColors.success,
            caption: 'Dokumen diterbitkan',
          ),
          MetricCard(
            width: width,
            label: 'Pengajuan Aktif',
            value: '${_data['pengajuan_baru'] ?? 0}',
            icon: Icons.assignment_late_rounded,
            color: AppColors.warning,
            caption: 'Perlu ditindaklanjuti',
          ),
          MetricCard(
            width: width,
            label: 'Disposisi Aktif',
            value: '${_data['disposisi_aktif'] ?? 0}',
            icon: Icons.forward_to_inbox_rounded,
            color: const Color(0xFF7B4DA5),
            caption: 'Sedang dikerjakan',
          ),
          if (_role != 'warga')
            MetricCard(
              width: width,
              label: 'Total Pengguna',
              value: '${_data['total_pengguna'] ?? 0}',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF556C74),
              caption: 'Akun sistem',
            ),
        ];

        return Wrap(spacing: 14, runSpacing: 14, children: cards);
      },
    );
  }

  Widget _latestLetters(List<dynamic> latest) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 19, 13, 14),
            child: Row(
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Surat Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Aktivitas persuratan yang terakhir tercatat',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Muat ulang dashboard',
                ),
              ],
            ),
          ),
          const Divider(),
          if (latest.isEmpty)
            const EmptyState(
              text: 'Belum ada surat terbaru',
              description: 'Data surat terbaru akan tampil pada bagian ini.',
            )
          else
            ...latest.asMap().entries.map((entry) {
              final row = Map<String, dynamic>.from(entry.value as Map);
              final last = entry.key == latest.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: last
                      ? null
                      : const Border(
                          bottom: BorderSide(color: Color(0xFFEDF2F0)),
                        ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _letterColor('${row['jenis']}').withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        '${row['jenis']}' == 'keluar'
                            ? Icons.north_east_rounded
                            : Icons.south_west_rounded,
                        color: _letterColor('${row['jenis']}'),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${row['perihal'] ?? '-'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 7,
                            runSpacing: 4,
                            children: [
                              Text(
                                '${row['nomor_surat'] ?? '-'}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10.5,
                                ),
                              ),
                              Text(
                                '• ${row['jenis'] ?? '-'}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatusBadge('${row['status'] ?? 'baru'}'),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _rolePanel() {
    final features = _roleFeatures();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Akses Akun',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      _roleLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Fokus aktivitas Anda',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feature.icon,
                      color: AppColors.primary,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      feature.label,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9F8),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Menu dan data yang tidak menjadi kewenangan role ini otomatis disembunyikan dan ditolak oleh API.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10.3,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _welcomeMessage() {
    return switch (_role) {
      'kasubag' =>
        'Pantau operasional sistem, kelola data master, administrasi surat, pengajuan, pengguna, serta laporan dari satu dashboard.',
      'camat' =>
        'Tinjau ringkasan administrasi, disposisi, hasil clustering, dan laporan sebagai bahan pengambilan keputusan.',
      'seksi' =>
        'Periksa surat dan disposisi yang ditugaskan, kemudian perbarui proses pelayanan sesuai bidang kerja Anda.',
      'warga' =>
        'Buat pengajuan layanan, simpan kode pelacakan, dan pantau status penyelesaian secara transparan.',
      _ => 'Berikut ringkasan aktivitas terbaru dalam sistem SICAMAT.',
    };
  }

  List<_RoleFeature> _roleFeatures() {
    return switch (_role) {
      'kasubag' => const [
          _RoleFeature(Icons.settings_suggest_outlined, 'Mengelola seluruh data operasional dan master.'),
          _RoleFeature(Icons.mark_email_read_outlined, 'Mencatat surat dan mengatur status proses.'),
          _RoleFeature(Icons.hub_outlined, 'Menjalankan clustering K-Means.'),
          _RoleFeature(Icons.people_alt_outlined, 'Mengelola akun dan hak akses pengguna.'),
        ],
      'camat' => const [
          _RoleFeature(Icons.forward_to_inbox_outlined, 'Meninjau surat dan disposisi kecamatan.'),
          _RoleFeature(Icons.analytics_outlined, 'Melihat laporan ringkas manajemen.'),
          _RoleFeature(Icons.hub_outlined, 'Meninjau hasil clustering K-Means.'),
        ],
      'seksi' => const [
          _RoleFeature(Icons.assignment_ind_outlined, 'Menerima disposisi sesuai seksi.'),
          _RoleFeature(Icons.update_rounded, 'Memperbarui status pekerjaan dan layanan.'),
          _RoleFeature(Icons.mark_email_read_outlined, 'Melihat surat terkait bidang kerja.'),
        ],
      'warga' => const [
          _RoleFeature(Icons.add_task_rounded, 'Membuat pengajuan layanan baru.'),
          _RoleFeature(Icons.track_changes_rounded, 'Melacak status dan catatan petugas.'),
          _RoleFeature(Icons.history_rounded, 'Melihat riwayat pengajuan pribadi.'),
        ],
      _ => const [
          _RoleFeature(Icons.dashboard_outlined, 'Mengakses fitur sesuai hak akun.'),
        ],
    };
  }

  Color _letterColor(String type) {
    return type == 'keluar' ? AppColors.success : AppColors.info;
  }
}

class _RoleFeature {
  const _RoleFeature(this.icon, this.label);

  final IconData icon;
  final String label;
}
