import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'screens/public/public_home_page.dart';
import 'screens/workspace/workspace_page.dart';
import 'services/sesi_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SicamatApp());
}

class SicamatApp extends StatelessWidget {
  const SicamatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SICAMAT Panakkukang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const CekSesiPage(),
    );
  }
}

class CekSesiPage extends StatefulWidget {
  const CekSesiPage({super.key});

  @override
  State<CekSesiPage> createState() => _CekSesiPageState();
}

class _CekSesiPageState extends State<CekSesiPage> {
  @override
  void initState() {
    super.initState();
    _cek();
  }

  Future<void> _cek() async {
    final session = await SesiService.ambil();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => session == null
            ? const PublicHomePage()
            : WorkspacePage(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _BootSplash(),
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.82, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'SICAMAT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Menyiapkan layanan digital Kecamatan Panakkukang',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 26),
              const SizedBox(
                width: 190,
                child: LinearProgressIndicator(
                  minHeight: 4,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
