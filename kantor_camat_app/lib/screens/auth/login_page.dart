import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/sesi_service.dart';
import '../../widgets/notifikasi.dart';
import '../workspace/workspace_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  bool _remember = true;

  static const _demoAccounts = [
    _DemoAccount(
      label: 'Kasubag',
      email: 'kasubag@sicamat.local',
      icon: Icons.admin_panel_settings_rounded,
      color: AppColors.primary,
    ),
    _DemoAccount(
      label: 'Camat',
      email: 'camat@sicamat.local',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF7B4DA5),
    ),
    _DemoAccount(
      label: 'Seksi',
      email: 'pemerintahan@sicamat.local',
      icon: Icons.apartment_rounded,
      color: AppColors.info,
    ),
    _DemoAccount(
      label: 'Warga',
      email: 'warga@sicamat.local',
      icon: Icons.person_rounded,
      color: AppColors.warning,
    ),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(_DemoAccount account) {
    setState(() {
      _emailController.text = account.email;
      _passwordController.text = 'Sicamat123!';
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) {
        return;
      }

      if (result['sukses'] != true || result['data'] is! Map) {
        await Notifikasi.tampil(
          context,
          judul: 'Login Tidak Berhasil',
          pesan:
              '${result['pesan'] ?? 'Email atau password tidak sesuai. Periksa kembali data akun.'}',
          sukses: false,
          tombol: 'Periksa Kembali',
        );
        return;
      }

      final data = Map<String, dynamic>.from(result['data'] as Map);
      final token = '${data['token']}';
      final user = Map<String, dynamic>.from(data['user'] as Map);
      await SesiService.simpan(token: token, user: user);
      if (!mounted) {
        return;
      }

      await Notifikasi.tampil(
        context,
        judul: 'Selamat Datang',
        pesan:
            'Login berhasil sebagai ${_roleLabel('${user['role']}', user)}. Ruang kerja sedang disiapkan sesuai hak akses Anda.',
        sukses: true,
        tombol: 'Masuk ke Dashboard',
        dapatDitutup: false,
        setelahOk: () {
          if (!mounted) {
            return;
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  WorkspacePage(session: {'token': token, 'user': user}),
            ),
            (_) => false,
          );
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      await Notifikasi.tampil(
        context,
        judul: 'Server Tidak Terhubung',
        pesan:
            'SICAMAT tidak dapat terhubung ke API. Pastikan backend berjalan pada http://localhost:8081/api.',
        sukses: false,
        tombol: 'Mengerti',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _roleLabel(String role, Map<String, dynamic> user) {
    return switch (role) {
      'kasubag' => 'Kasubag Umum',
      'camat' => 'Camat',
      'seksi' => '${user['seksi'] ?? 'Seksi Kecamatan'}',
      'warga' => 'Masyarakat',
      _ => role,
    };
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 920;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      body: SafeArea(
        child: Stack(
          children: [
            if (!desktop)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.softGradient),
                ),
              ),
            Row(
              children: [
                if (desktop)
                  const Expanded(flex: 11, child: _LoginBrandPanel()),
                Expanded(
                  flex: desktop ? 9 : 1,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: desktop ? 54 : 20,
                        vertical: 28,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  tooltip: 'Kembali ke halaman publik',
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                                const Spacer(),
                                const _SecureLabel(),
                              ],
                            ),
                            const SizedBox(height: 25),
                            if (!desktop) ...[
                              const _MobileBrand(),
                              const SizedBox(height: 28),
                            ],
                            _loginCard(),
                            const SizedBox(height: 18),
                            const Text(
                              'Dengan masuk, pengguna menyetujui penggunaan sistem sesuai kewenangan dan menjaga kerahasiaan akun.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 10.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 32,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masuk ke SICAMAT',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 29,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gunakan email dan password yang telah terdaftar. Menu dashboard akan menyesuaikan role akun.',
              style: TextStyle(color: AppColors.muted, height: 1.55),
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Alamat email',
                hintText: 'nama@sicamat.local',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!text.contains('@')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  tooltip: _showPassword
                      ? 'Sembunyikan password'
                      : 'Tampilkan password',
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) =>
                  (value ?? '').isEmpty ? 'Password wajib diisi' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _remember,
                  onChanged: (value) =>
                      setState(() => _remember = value ?? true),
                ),
                const Expanded(
                  child: Text(
                    'Pertahankan sesi login di perangkat ini',
                    style: TextStyle(color: AppColors.muted, fontSize: 11.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _login,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(
                  _loading ? 'Memverifikasi akun...' : 'Masuk ke Dashboard',
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'AKUN DEMO',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 17),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: _demoAccounts.map((account) {
                return ActionChip(
                  onPressed: _loading ? null : () => _fillDemo(account),
                  avatar: Icon(account.icon, size: 16, color: account.color),
                  label: Text(account.label),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F7),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.key_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Klik salah satu role demo untuk mengisi email otomatis. Semua akun demo menggunakan password Sicamat123!',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10.8,
                        height: 1.45,
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
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 38,
            offset: const Offset(0, 17),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: -125,
            top: -140,
            child: _LoginCircle(size: 390, opacity: 0.05),
          ),
          const Positioned(
            left: -170,
            bottom: -210,
            child: _LoginCircle(size: 500, opacity: 0.045),
          ),
          Padding(
            padding: const EdgeInsets.all(58),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 37,
                  ),
                ),
                const SizedBox(height: 27),
                const Text(
                  'SICAMAT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 41,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ruang kerja digital Kecamatan Panakkukang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 560),
                  child: Text(
                    'Kelola pelayanan masyarakat, persuratan, disposisi, laporan, informasi publik, dan analisis data secara terpusat.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15.5,
                      height: 1.65,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                const _LoginFeature(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Dashboard sesuai role',
                  description:
                      'Menu dan data otomatis dibatasi untuk Kasubag, Camat, Seksi, dan Masyarakat.',
                ),
                const SizedBox(height: 17),
                const _LoginFeature(
                  icon: Icons.shield_outlined,
                  title: 'Akses terkontrol',
                  description:
                      'Hak akses tidak hanya dibatasi pada sidebar, tetapi juga divalidasi oleh API.',
                ),
                const SizedBox(height: 17),
                const _LoginFeature(
                  icon: Icons.auto_graph_rounded,
                  title: 'Data lebih terukur',
                  description:
                      'Laporan dan clustering membantu pimpinan membaca aktivitas administrasi.',
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF8BE0C7),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sistem internal • Gunakan akun resmi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFeature extends StatelessWidget {
  const _LoginFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginCircle extends StatelessWidget {
  const _LoginCircle({required this.size, required this.opacity});

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

class _SecureLabel extends StatelessWidget {
  const _SecureLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 14, color: AppColors.success),
          SizedBox(width: 5),
          Text(
            'Akses aman',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBrand extends StatelessWidget {
  const _MobileBrand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 35),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SICAMAT',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
            ),
            Text(
              'Kecamatan Panakkukang',
              style: TextStyle(color: AppColors.muted, fontSize: 10.5),
            ),
          ],
        ),
      ],
    );
  }
}

class _DemoAccount {
  const _DemoAccount({
    required this.label,
    required this.email,
    required this.icon,
    required this.color,
  });

  final String label;
  final String email;
  final IconData icon;
  final Color color;
}
