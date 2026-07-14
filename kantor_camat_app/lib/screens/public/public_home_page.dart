import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/notifikasi.dart';
import '../auth/login_page.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  final _scrollController = ScrollController();
  final _berandaKey = GlobalKey();
  final _tentangKey = GlobalKey();
  final _alurKey = GlobalKey();
  final _layananKey = GlobalKey();
  final _kegiatanKey = GlobalKey();
  final _kontakKey = GlobalKey();

  Map<String, dynamic> _profil = {};
  List<dynamic> _layanan = [];
  List<dynamic> _kegiatan = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.publicGet('/public/profil'),
        ApiService.publicGet('/public/layanan'),
        ApiService.publicGet('/public/kegiatan'),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _profil = results[0]['data'] is Map
            ? Map<String, dynamic>.from(results[0]['data'] as Map)
            : {};
        _layanan = results[1]['data'] is List ? results[1]['data'] as List : [];
        _kegiatan = results[2]['data'] is List
            ? results[2]['data'] as List
            : [];
      });
    } catch (_) {
      if (mounted) {
        Notifikasi.tampil(
          context,
          judul: 'Layanan Belum Terhubung',
          pesan:
              'Data publik belum dapat dimuat. Pastikan API SICAMAT berjalan pada port 8081, lalu muat ulang halaman.',
          sukses: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _masuk() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _goTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) {
      return;
    }
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  Future<void> _lacak() async {
    final code = await Notifikasi.input(
      context,
      judul: 'Lacak Pengajuan',
      pesan:
          'Masukkan kode pelacakan yang diterima setelah pengajuan berhasil dikirim.',
      label: 'Kode pengajuan',
      hint: 'Contoh: PGJ-20260713-2250',
      tombol: 'Lacak Sekarang',
      capitalization: TextCapitalization.characters,
    );

    if (code == null || !mounted) {
      return;
    }

    try {
      final result = await ApiService.publicGet(
        '/public/pengajuan/${code.toUpperCase()}',
      );
      if (!mounted) {
        return;
      }

      if (result['sukses'] != true || result['data'] is! Map) {
        Notifikasi.tampil(
          context,
          judul: 'Pengajuan Tidak Ditemukan',
          pesan:
              '${result['pesan'] ?? 'Periksa kembali kode pelacakan yang dimasukkan.'}',
          sukses: false,
        );
        return;
      }

      final data = Map<String, dynamic>.from(result['data'] as Map);
      await Notifikasi.konten(
        context,
        judul: '${data['kode'] ?? code.toUpperCase()}',
        pesan: 'Informasi terbaru pengajuan layanan Anda.',
        tipe: NotifikasiTipe.info,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jenis layanan',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                '${data['layanan'] ?? '-'}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 13),
              const Text(
                'Keperluan',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text('${data['judul'] ?? '-'}'),
              const SizedBox(height: 15),
              StatusBadge('${data['status'] ?? 'baru'}'),
              if ('${data['catatan_petugas'] ?? ''}'.trim().isNotEmpty) ...[
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Catatan petugas: ${data['catatan_petugas']}',
                    style: const TextStyle(fontSize: 12.5, height: 1.45),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      Notifikasi.tampil(
        context,
        judul: 'Tidak Dapat Melacak',
        pesan:
            'Koneksi ke server bermasalah. Periksa API SICAMAT kemudian coba kembali.',
        sukses: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _navigationBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  key: _berandaKey,
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _hero(),
                      _trustStrip(),
                      _aboutSection(),
                      _flowSection(),
                      _servicesSection(),
                      _activitiesSection(),
                      _profileSection(),
                      _faqSection(),
                      _finalCta(),
                      _footer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigationBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 940;
        final compact = constraints.maxWidth < 560;
        return Container(
          height: desktop ? 78 : 68,
          padding: EdgeInsets.symmetric(horizontal: desktop ? 34 : 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _goTo(_berandaKey),
                    borderRadius: BorderRadius.circular(13),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 11),
                          if (!compact)
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SICAMAT',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                Text(
                                  'Kecamatan Panakkukang',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (desktop) ...[
                    const Spacer(),
                    _navButton('Tentang', () => _goTo(_tentangKey)),
                    _navButton('Alur Layanan', () => _goTo(_alurKey)),
                    _navButton('Layanan', () => _goTo(_layananKey)),
                    _navButton('Kegiatan', () => _goTo(_kegiatanKey)),
                    _navButton('Kontak', () => _goTo(_kontakKey)),
                    const SizedBox(width: 12),
                  ] else
                    const Spacer(),
                  if (compact)
                    IconButton(
                      onPressed: _lacak,
                      tooltip: 'Lacak Pengajuan',
                      icon: const Icon(Icons.manage_search_rounded),
                    )
                  else
                    TextButton.icon(
                      onPressed: _lacak,
                      icon: const Icon(Icons.manage_search_rounded, size: 19),
                      label: Text(desktop ? 'Lacak Pengajuan' : 'Lacak'),
                    ),
                  const SizedBox(width: 7),
                  FilledButton.icon(
                    onPressed: _masuk,
                    style: compact
                        ? FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 13,
                            ),
                          )
                        : null,
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: Text(desktop ? 'Masuk Sistem' : 'Masuk'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navButton(String label, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text(label));
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        children: [
          const Positioned(
            right: -120,
            top: -150,
            child: _DecorativeCircle(size: 390, opacity: 0.055),
          ),
          const Positioned(
            left: -130,
            bottom: -210,
            child: _DecorativeCircle(size: 430, opacity: 0.045),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 880;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      desktop ? 34 : 22,
                      desktop ? 82 : 58,
                      desktop ? 34 : 22,
                      desktop ? 88 : 64,
                    ),
                    child: desktop
                        ? Row(
                            children: [
                              Expanded(flex: 6, child: _heroCopy()),
                              const SizedBox(width: 62),
                              const Expanded(flex: 4, child: _HeroPreview()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heroCopy(),
                              const SizedBox(height: 40),
                              const _HeroPreview(),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, color: Color(0xFF8BE0C7), size: 17),
              SizedBox(width: 7),
              Text(
                'Pelayanan Publik Digital & Terintegrasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Layanan Kecamatan\nlebih dekat, cepat,\ndan transparan.',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.sizeOf(context).width < 600 ? 37 : 48,
            height: 1.12,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 690),
          child: Text(
            'SICAMAT menyatukan informasi layanan, pengajuan administrasi, pelacakan status, persuratan internal, disposisi, laporan, dan analisis K-Means dalam satu platform yang mudah digunakan.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.5,
              height: 1.65,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _masuk,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 17,
                ),
              ),
              icon: const Icon(Icons.assignment_turned_in_rounded),
              label: const Text('Mulai Ajukan Layanan'),
            ),
            OutlinedButton.icon(
              onPressed: _lacak,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Lacak Status'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            _HeroCheck('Tanpa biaya tersembunyi'),
            _HeroCheck('Status dapat dilacak'),
            _HeroCheck('Akses sesuai peran'),
          ],
        ),
      ],
    );
  }

  Widget _trustStrip() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F9F8),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Wrap(
            spacing: 18,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              _TrustItem(
                icon: Icons.miscellaneous_services_rounded,
                value: '${_layanan.length}',
                label: 'Layanan tersedia',
              ),
              const _TrustItem(
                icon: Icons.track_changes_rounded,
                value: '24/7',
                label: 'Pelacakan online',
              ),
              const _TrustItem(
                icon: Icons.shield_outlined,
                value: '4',
                label: 'Hak akses peran',
              ),
              _TrustItem(
                icon: Icons.event_available_rounded,
                value: '${_kegiatan.length}',
                label: 'Agenda dipublikasikan',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutSection() {
    return _PublicSection(
      key: _tentangKey,
      eyebrow: 'MENGENAL SICAMAT',
      title: 'Satu pintu pelayanan dan informasi kecamatan',
      subtitle:
          'Dirancang agar masyarakat memperoleh informasi yang jelas, sementara aparatur kecamatan dapat mengelola proses administrasi secara terstruktur dan akuntabel.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 850;
          final cards = [
            const _FeatureCard(
              icon: Icons.people_alt_outlined,
              title: 'Untuk Masyarakat',
              description:
                  'Melihat informasi layanan, mengirim pengajuan, memperoleh kode pelacakan, dan memantau status penyelesaian.',
              color: AppColors.info,
            ),
            const _FeatureCard(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Untuk Aparatur',
              description:
                  'Mengelola surat, disposisi, pengajuan, pengguna, layanan, kegiatan, profil kecamatan, dan laporan.',
              color: AppColors.primary,
            ),
            const _FeatureCard(
              icon: Icons.hub_outlined,
              title: 'Analisis K-Means',
              description:
                  'Mengelompokkan perihal surat masuk untuk membantu mengenali tema administrasi yang paling sering muncul.',
              color: Color(0xFF7C4DAB),
            ),
          ];

          if (desktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < cards.length; index++) ...[
                  Expanded(child: cards[index]),
                  if (index != cards.length - 1) const SizedBox(width: 16),
                ],
              ],
            );
          }

          return Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                cards[index],
                if (index != cards.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _flowSection() {
    return _PublicSection(
      key: _alurKey,
      background: const Color(0xFFF5F9F8),
      eyebrow: 'ALUR PELAYANAN',
      title: 'Ajukan layanan dalam empat langkah sederhana',
      subtitle:
          'Setiap tahapan dibuat ringkas dan dapat dipantau, sehingga masyarakat mengetahui posisi pengajuan tanpa harus menebak prosesnya.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 880;
          const steps = [
            _FlowStep(
              number: '01',
              icon: Icons.person_add_alt_1_rounded,
              title: 'Masuk ke akun',
              description:
                  'Gunakan akun masyarakat yang telah terdaftar untuk mengakses ruang layanan.',
            ),
            _FlowStep(
              number: '02',
              icon: Icons.fact_check_outlined,
              title: 'Pilih layanan',
              description:
                  'Baca deskripsi, persyaratan, estimasi waktu, dan lengkapi formulir pengajuan.',
            ),
            _FlowStep(
              number: '03',
              icon: Icons.mark_email_read_outlined,
              title: 'Terima kode',
              description:
                  'Sistem memberikan kode unik yang digunakan untuk pelacakan status pengajuan.',
            ),
            _FlowStep(
              number: '04',
              icon: Icons.task_alt_rounded,
              title: 'Pantau hasil',
              description:
                  'Lihat perubahan status dan catatan petugas sampai layanan selesai diproses.',
            ),
          ];

          if (desktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < steps.length; index++) ...[
                  Expanded(child: steps[index]),
                  if (index != steps.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(top: 38),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFB4CBC5),
                      ),
                    ),
                ],
              ],
            );
          }

          return Column(
            children: [
              for (var index = 0; index < steps.length; index++) ...[
                steps[index],
                if (index != steps.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _servicesSection() {
    return _PublicSection(
      key: _layananKey,
      eyebrow: 'LAYANAN ADMINISTRASI',
      title: 'Informasi layanan yang jelas sebelum mengajukan',
      subtitle:
          'Periksa persyaratan, sektor pelayanan, estimasi waktu, dan biaya agar dokumen dapat disiapkan dengan benar sejak awal.',
      trailing: OutlinedButton.icon(
        onPressed: _masuk,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Buka Ruang Layanan'),
      ),
      child: _loading
          ? const LoadingState(message: 'Memuat daftar layanan...')
          : _servicesGrid(),
    );
  }

  Widget _servicesGrid() {
    if (_layanan.isEmpty) {
      return const SectionCard(
        child: EmptyState(
          text: 'Belum ada layanan yang dipublikasikan',
          description:
              'Daftar layanan akan muncul setelah ditambahkan oleh pengelola.',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 980
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth >= 610
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _layanan.map((raw) {
            final item = Map<String, dynamic>.from(raw as Map);
            return SizedBox(
              width: cardWidth,
              child: SectionCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 47,
                                height: 47,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF5F2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _serviceIcon(item),
                                  color: AppColors.primary,
                                ),
                              ),
                              const Spacer(),
                              SoftBadge(
                                label: formatRupiah(item['biaya']),
                                icon: Icons.payments_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${item['nama'] ?? 'Layanan Kecamatan'}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item['sektor'] ?? 'Pelayanan Umum'}',
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${item['deskripsi'] ?? ''}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 17,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Estimasi ${item['estimasi_hari'] ?? '-'} hari kerja',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          18,
                        ),
                        leading: const Icon(
                          Icons.rule_folder_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text(
                          'Lihat persyaratan',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F9F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item['persyaratan'] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _activitiesSection() {
    return _PublicSection(
      key: _kegiatanKey,
      background: const Color(0xFFF5F9F8),
      eyebrow: 'INFORMASI KECAMATAN',
      title: 'Agenda dan kegiatan terbaru',
      subtitle:
          'Ikuti informasi pelayanan terpadu, koordinasi wilayah, dan aktivitas Kecamatan Panakkukang yang dipublikasikan melalui SICAMAT.',
      child: _loading
          ? const LoadingState(message: 'Memuat kegiatan...')
          : _activitiesList(),
    );
  }

  Widget _activitiesList() {
    if (_kegiatan.isEmpty) {
      return const SectionCard(
        child: EmptyState(
          text: 'Belum ada kegiatan terbaru',
          icon: Icons.event_busy_outlined,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 780;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _kegiatan.map((raw) {
            final item = Map<String, dynamic>.from(raw as Map);
            return SizedBox(
              width: desktop
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth,
              child: SectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                          SizedBox(height: 3),
                          Text(
                            'AGENDA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['judul'] ?? 'Kegiatan Kecamatan'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _MetaText(
                                icon: Icons.schedule_rounded,
                                text: _dateOnly(item['tanggal']),
                              ),
                              _MetaText(
                                icon: Icons.location_on_outlined,
                                text: '${item['lokasi'] ?? '-'}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Text(
                            '${item['isi'] ?? ''}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _profileSection() {
    return _PublicSection(
      key: _kontakKey,
      eyebrow: 'PROFIL & KONTAK',
      title: 'Komitmen pelayanan Kecamatan Panakkukang',
      subtitle:
          'Informasi instansi, visi, misi, alamat, jam pelayanan, dan kanal komunikasi resmi.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 850;
          final profile = SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SoftBadge(
                  label: 'Visi Pelayanan',
                  icon: Icons.visibility_outlined,
                ),
                const SizedBox(height: 15),
                Text(
                  '${_profil['visi'] ?? 'Mewujudkan pelayanan publik kecamatan yang profesional, transparan, dan mudah diakses.'}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 23),
                const SoftBadge(
                  label: 'Misi Pelayanan',
                  icon: Icons.flag_outlined,
                  color: AppColors.info,
                ),
                const SizedBox(height: 13),
                Text(
                  '${_profil['misi'] ?? 'Meningkatkan mutu administrasi, keterbukaan informasi, dan pemanfaatan teknologi dalam pelayanan masyarakat.'}',
                  style: const TextStyle(color: AppColors.muted, height: 1.65),
                ),
              ],
            ),
          );

          final contact = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 16),
                Text(
                  '${_profil['nama_instansi'] ?? 'Kantor Camat Panakkukang'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan menghubungi atau mengunjungi kantor pada jam pelayanan untuk bantuan administrasi lebih lanjut.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 24),
                _ContactRow(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat',
                  value: '${_profil['alamat'] ?? '-'}',
                ),
                const SizedBox(height: 15),
                _ContactRow(
                  icon: Icons.schedule_outlined,
                  title: 'Jam pelayanan',
                  value: '${_profil['jam_layanan'] ?? '-'}',
                ),
                const SizedBox(height: 15),
                _ContactRow(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: '${_profil['email'] ?? '-'}',
                ),
              ],
            ),
          );

          if (desktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: profile),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: contact),
              ],
            );
          }

          return Column(
            children: [profile, const SizedBox(height: 16), contact],
          );
        },
      ),
    );
  }

  Widget _faqSection() {
    const faqs = [
      (
        'Apakah masyarakat dapat melihat layanan tanpa login?',
        'Ya. Daftar layanan, persyaratan, estimasi waktu, kegiatan, dan profil kecamatan dapat dilihat dari halaman publik.',
      ),
      (
        'Mengapa pengajuan memerlukan akun?',
        'Akun diperlukan agar identitas pemohon, riwayat pengajuan, dan akses data tetap tercatat serta terlindungi.',
      ),
      (
        'Bagaimana mengetahui pengajuan sudah selesai?',
        'Gunakan menu Lacak Pengajuan dan masukkan kode unik. Status serta catatan petugas akan ditampilkan.',
      ),
      (
        'Siapa yang dapat mengakses fitur persuratan dan laporan?',
        'Fitur internal hanya tampil sesuai role, seperti Kasubag, Camat, atau Seksi. Backend juga memvalidasi hak akses setiap permintaan.',
      ),
    ];

    return _PublicSection(
      eyebrow: 'PERTANYAAN UMUM',
      title: 'Informasi yang sering ditanyakan',
      subtitle:
          'Penjelasan singkat mengenai akses layanan publik dan ruang kerja internal SICAMAT.',
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            for (var index = 0; index < faqs.length; index++) ...[
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 5),
                  childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),
                  title: Text(
                    faqs[index].$1,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          faqs[index].$2,
                          style: const TextStyle(
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index != faqs.length - 1) const Divider(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _finalCta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 70),
      color: const Color(0xFFF5F9F8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Container(
            padding: const EdgeInsets.all(34),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 34,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 720;
                final copy = const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siap menggunakan layanan SICAMAT?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Masuk untuk membuat pengajuan baru atau gunakan kode pelacakan untuk melihat status proses yang sedang berjalan.',
                      style: TextStyle(color: Colors.white70, height: 1.55),
                    ),
                  ],
                );

                final actions = Wrap(
                  spacing: 11,
                  runSpacing: 11,
                  children: [
                    FilledButton.icon(
                      onPressed: _masuk,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Masuk Sekarang'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _lacak,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                      ),
                      icon: const Icon(Icons.manage_search_rounded),
                      label: const Text('Lacak Pengajuan'),
                    ),
                  ],
                );

                if (desktop) {
                  return Row(
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 30),
                      actions,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 22), actions],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 700;
              final brand = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SICAMAT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                        ),
                      ),
                      Text(
                        'Sistem Informasi Kantor Camat',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              );

              final copyright = Text(
                '© 2026 ${_profil['nama_instansi'] ?? 'Kantor Camat Panakkukang'} • Pelayanan digital yang transparan dan terintegrasi.',
                textAlign: desktop ? TextAlign.right : TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11.5,
                  height: 1.5,
                ),
              );

              if (desktop) {
                return Row(
                  children: [
                    brand,
                    const Spacer(),
                    Flexible(child: copyright),
                  ],
                );
              }

              return Column(
                children: [brand, const SizedBox(height: 19), copyright],
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _serviceIcon(Map<String, dynamic> item) {
    final value = '${item['nama'] ?? ''} ${item['sektor'] ?? ''}'.toLowerCase();
    if (value.contains('usaha') || value.contains('ekonomi')) {
      return Icons.storefront_outlined;
    }
    if (value.contains('domisili') || value.contains('penduduk')) {
      return Icons.home_work_outlined;
    }
    if (value.contains('kegiatan') || value.contains('izin')) {
      return Icons.event_available_outlined;
    }
    if (value.contains('pengaduan')) {
      return Icons.support_agent_rounded;
    }
    if (value.contains('legalisasi')) {
      return Icons.verified_outlined;
    }
    return Icons.description_outlined;
  }

  String _dateOnly(dynamic value) {
    final text = '${value ?? '-'}';
    return text.split(' ').first;
  }
}

class _PublicSection extends StatelessWidget {
  const _PublicSection({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.background = Colors.white,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 720;
                  final copy = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: desktop ? 31 : 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  );

                  if (desktop && trailing != null) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: copy),
                        const SizedBox(width: 24),
                        trailing!,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copy,
                      if (trailing != null) ...[
                        const SizedBox(height: 18),
                        trailing!,
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 31),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPreview extends StatelessWidget {
  const _HeroPreview();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white54),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.17),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5F2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_rounded,
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
                          'Ruang Layanan Digital',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Ringkas, terukur, dan transparan',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _PreviewProgress(
                icon: Icons.edit_document,
                title: 'Pengajuan diterima',
                caption: 'Data dan persyaratan tercatat',
                progress: 1,
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              const _PreviewProgress(
                icon: Icons.manage_search_rounded,
                title: 'Verifikasi petugas',
                caption: 'Dokumen sedang diperiksa',
                progress: 0.72,
                color: AppColors.warning,
              ),
              const SizedBox(height: 12),
              const _PreviewProgress(
                icon: Icons.task_alt_rounded,
                title: 'Penyelesaian layanan',
                caption: 'Hasil dapat dipantau dari akun',
                progress: 0.34,
                color: AppColors.info,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Data ditampilkan sesuai hak akses pengguna.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -17,
          top: -17,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8B34D),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.13),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
                SizedBox(width: 5),
                Text(
                  'Terintegrasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewProgress extends StatelessWidget {
  const _PreviewProgress({
    required this.icon,
    required this.title,
    required this.caption,
    required this.progress,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String caption;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: const TextStyle(color: AppColors.muted, fontSize: 9.8),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCheck extends StatelessWidget {
  const _HeroCheck(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF8BE0C7),
          size: 17,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 235,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.58,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String number;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 15,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 31),
              ),
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  width: 27,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
