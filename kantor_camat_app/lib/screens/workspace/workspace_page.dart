import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/sesi_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/notifikasi.dart';
import '../public/public_home_page.dart';
import 'views/clustering_view.dart';
import 'views/dashboard_view.dart';
import 'views/disposisi_view.dart';
import 'views/kegiatan_view.dart';
import 'views/layanan_view.dart';
import 'views/laporan_view.dart';
import 'views/pengajuan_view.dart';
import 'views/pengguna_view.dart';
import 'views/profil_view.dart';
import 'views/surat_view.dart';

class WorkspaceMenu {
  const WorkspaceMenu({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.roles,
    required this.group,
  });

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final List<String> roles;
  final String group;
}

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key, required this.session});

  final Map<String, dynamic> session;

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  static const _allMenus = [
    WorkspaceMenu(
      id: 'dashboard',
      label: 'Dashboard',
      subtitle: 'Ringkasan aktivitas dan informasi penting sistem.',
      icon: Icons.space_dashboard_rounded,
      roles: ['kasubag', 'camat', 'seksi', 'warga'],
      group: 'UTAMA',
    ),
    WorkspaceMenu(
      id: 'surat',
      label: 'Surat Masuk & Keluar',
      subtitle: 'Kelola registrasi, status, arsip, dan pencetakan data surat.',
      icon: Icons.mark_email_read_rounded,
      roles: ['kasubag', 'camat', 'seksi'],
      group: 'OPERASIONAL',
    ),
    WorkspaceMenu(
      id: 'disposisi',
      label: 'Distribusi Surat',
      subtitle: 'Arahkan surat kepada pejabat atau seksi yang bertanggung jawab.',
      icon: Icons.forward_to_inbox_rounded,
      roles: ['kasubag', 'camat', 'seksi'],
      group: 'OPERASIONAL',
    ),
    WorkspaceMenu(
      id: 'pengajuan',
      label: 'Pengajuan Layanan',
      subtitle: 'Kelola permohonan masyarakat dan pantau tahapan penyelesaian.',
      icon: Icons.assignment_rounded,
      roles: ['kasubag', 'camat', 'seksi', 'warga'],
      group: 'OPERASIONAL',
    ),
    WorkspaceMenu(
      id: 'clustering',
      label: 'Clustering K-Means',
      subtitle: 'Kelompokkan perihal surat masuk berdasarkan kemiripan kata.',
      icon: Icons.hub_rounded,
      roles: ['kasubag', 'camat'],
      group: 'ANALISIS',
    ),
    WorkspaceMenu(
      id: 'laporan',
      label: 'Laporan Camat',
      subtitle: 'Tinjau ringkasan manajemen dan cetak laporan untuk pimpinan.',
      icon: Icons.analytics_rounded,
      roles: ['kasubag', 'camat'],
      group: 'ANALISIS',
    ),
    WorkspaceMenu(
      id: 'layanan',
      label: 'Data Layanan',
      subtitle: 'Atur jenis layanan, persyaratan, biaya, dan estimasi proses.',
      icon: Icons.miscellaneous_services_rounded,
      roles: ['kasubag'],
      group: 'MASTER DATA',
    ),
    WorkspaceMenu(
      id: 'kegiatan',
      label: 'Informasi Kegiatan',
      subtitle: 'Kelola agenda dan informasi kegiatan yang tampil pada halaman publik.',
      icon: Icons.event_note_rounded,
      roles: ['kasubag'],
      group: 'MASTER DATA',
    ),
    WorkspaceMenu(
      id: 'pengguna',
      label: 'Data Pengguna',
      subtitle: 'Kelola akun, role, status aktif, kelurahan, dan seksi pengguna.',
      icon: Icons.people_alt_rounded,
      roles: ['kasubag'],
      group: 'MASTER DATA',
    ),
    WorkspaceMenu(
      id: 'profil',
      label: 'Profil Kecamatan',
      subtitle: 'Perbarui informasi instansi, visi, misi, alamat, dan kontak publik.',
      icon: Icons.account_balance_rounded,
      roles: ['kasubag'],
      group: 'MASTER DATA',
    ),
  ];

  late final Map<String, dynamic> _user;
  String _active = 'dashboard';

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.session['user'] as Map);
  }

  String get _role => '${_user['role'] ?? ''}';

  List<WorkspaceMenu> get _menus =>
      _allMenus.where((menu) => menu.roles.contains(_role)).toList();

  WorkspaceMenu get _activeMenu => _menus.firstWhere(
    (menu) => menu.id == _active,
    orElse: () => _menus.first,
  );

  String get _roleLabel => switch (_role) {
    'kasubag' => 'Kasubag Umum',
    'camat' => 'Camat',
    'seksi' => '${_user['seksi'] ?? 'Seksi Kecamatan'}',
    'warga' => 'Masyarakat',
    _ => _role,
  };

  Widget _content() {
    return switch (_active) {
      'surat' => SuratView(user: _user),
      'disposisi' => DisposisiView(user: _user),
      'pengajuan' => PengajuanView(user: _user),
      'clustering' => ClusteringView(user: _user),
      'laporan' => const LaporanView(),
      'layanan' => const LayananView(),
      'kegiatan' => const KegiatanView(),
      'pengguna' => PenggunaView(user: _user),
      'profil' => const ProfilView(),
      _ => DashboardView(user: _user),
    };
  }

  Future<void> _logout() async {
    final confirmed = await Notifikasi.konfirmasi(
      context,
      judul: 'Keluar dari SICAMAT?',
      pesan:
          'Sesi akun ${_user['nama'] ?? ''} akan diakhiri. Anda perlu login kembali untuk membuka ruang kerja.',
      teksYa: 'Ya, Keluar',
      teksTidak: 'Tetap Masuk',
      berbahaya: true,
    );

    if (!confirmed) {
      return;
    }

    try {
      await ApiService.logout();
    } catch (_) {}
    await SesiService.hapus();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PublicHomePage()),
      (_) => false,
    );
  }

  Future<void> _showAccessInfo() {
    return Notifikasi.konten(
      context,
      judul: 'Hak Akses $_roleLabel',
      pesan:
          'Sidebar dan aksi di dalam sistem disesuaikan dengan role akun. API tetap memvalidasi setiap permintaan agar akses tidak dapat dilewati.',
      tipe: NotifikasiTipe.info,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8F7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu yang tersedia:',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _menus
                  .map(
                    (menu) => SoftBadge(
                      label: menu.label,
                      icon: menu.icon,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 960;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      drawer: mobile
          ? Drawer(
              width: 286,
              backgroundColor: AppColors.primaryDark,
              child: _sidebar(context, closeDrawer: true),
            )
          : null,
      body: Row(
        children: [
          if (!mobile) SizedBox(width: 286, child: _sidebar(context)),
          Expanded(
            child: Column(
              children: [
                _header(context, mobile: mobile),
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        mobile ? 15 : 27,
                        mobile ? 16 : 24,
                        mobile ? 15 : 27,
                        35,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1500),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0.015, 0.01),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              key: ValueKey(_active),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_active != 'dashboard')
                                  PageIntro(
                                    title: _activeMenu.label,
                                    subtitle: _activeMenu.subtitle,
                                    icon: _activeMenu.icon,
                                    trailing: SoftBadge(
                                      label: _roleLabel,
                                      icon: Icons.verified_user_outlined,
                                    ),
                                  ),
                                _content(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebar(BuildContext context, {bool closeDrawer = false}) {
    final grouped = <String, List<WorkspaceMenu>>{};
    for (final menu in _menus) {
      grouped.putIfAbsent(menu.group, () => []).add(menu);
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 17),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SICAMAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: 2.2,
                          ),
                        ),
                        Text(
                          'Kecamatan Panakkukang',
                          style: TextStyle(color: Colors.white54, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                  if (closeDrawer)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      child: Text(
                        _initials('${_user['nama'] ?? 'U'}'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_user['nama'] ?? '-'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _roleLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9EDBCB),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF8BE0C7),
                      size: 17,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(11, 13, 11, 7),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.35,
                        ),
                      ),
                    ),
                    ...entry.value.map((menu) => _menuTile(menu, closeDrawer)),
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.white12),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _sidebarAction(
                    icon: Icons.language_rounded,
                    label: 'Halaman Publik',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PublicHomePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  _sidebarAction(
                    icon: Icons.logout_rounded,
                    label: 'Keluar dari Akun',
                    onTap: _logout,
                    danger: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(WorkspaceMenu menu, bool closeDrawer) {
    final active = menu.id == _active;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: active ? Colors.white.withValues(alpha: 0.13) : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () {
            setState(() => _active = menu.id);
            if (closeDrawer) {
              Navigator.pop(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: active ? Border.all(color: Colors.white12) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    menu.icon,
                    size: 20,
                    color: active ? Colors.white : Colors.white54,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    menu.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white60,
                      fontSize: 12.3,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (active)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8BE0C7),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: danger ? const Color(0xFFFFA9A9) : Colors.white54,
              ),
              const SizedBox(width: 11),
              Text(
                label,
                style: TextStyle(
                  color: danger ? const Color(0xFFFFB5B5) : Colors.white60,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, {required bool mobile}) {
    return Container(
      height: 78,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 9 : 25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (mobile)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          if (mobile) const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      _activeMenu.label,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: mobile ? 17 : 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (!mobile) ...[
                      const SizedBox(width: 9),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFB0BDB9),
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        _roleLabel,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!mobile) ...[
                  const SizedBox(height: 3),
                  Text(
                    _todayLabel(),
                    style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                  ),
                ],
              ],
            ),
          ),
          if (!mobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F7),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Sistem aktif',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 7),
          IconButton(
            onPressed: _showAccessInfo,
            tooltip: 'Informasi hak akses',
            icon: const Icon(Icons.help_outline_rounded),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Menu akun',
            onSelected: (value) {
              if (value == 'access') {
                _showAccessInfo();
              } else if (value == 'public') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PublicHomePage()),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'access',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Hak Akses Saya'),
                ),
              ),
              PopupMenuItem(
                value: 'public',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.language_rounded),
                  title: Text('Halaman Publik'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded, color: AppColors.danger),
                  title: Text(
                    'Keluar',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Text(
                      _initials('${_user['nama'] ?? 'U'}'),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (!mobile) ...[
                    const SizedBox(width: 9),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 115,
                          child: Text(
                            '${_user['nama'] ?? '-'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          _roleLabel,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 9.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.isEmpty) {
      return 'U';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String _todayLabel() {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
