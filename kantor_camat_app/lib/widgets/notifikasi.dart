import 'package:flutter/material.dart';

import '../config/app_theme.dart';

enum NotifikasiTipe { sukses, gagal, peringatan, info }

class Notifikasi {
  static Future<void> tampil(
    BuildContext context, {
    required String pesan,
    String? judul,
    bool sukses = true,
    NotifikasiTipe? tipe,
    String tombol = 'Mengerti',
    VoidCallback? setelahOk,
    bool dapatDitutup = true,
  }) async {
    final resolvedType = tipe ??
        (sukses ? NotifikasiTipe.sukses : NotifikasiTipe.gagal);

    await _show<void>(
      context,
      dismissible: dapatDitutup,
      child: _AlertPanel(
        type: resolvedType,
        title: judul ?? _defaultTitle(resolvedType),
        message: pesan,
        primaryLabel: tombol,
        onPrimary: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );

    setelahOk?.call();
  }

  static Future<bool> konfirmasi(
    BuildContext context, {
    required String judul,
    required String pesan,
    String teksYa = 'Ya, lanjutkan',
    String teksTidak = 'Batal',
    bool berbahaya = false,
    NotifikasiTipe tipe = NotifikasiTipe.peringatan,
  }) async {
    final result = await _show<bool>(
      context,
      dismissible: true,
      child: _AlertPanel(
        type: tipe,
        title: judul,
        message: pesan,
        primaryLabel: teksYa,
        secondaryLabel: teksTidak,
        destructive: berbahaya,
        onPrimary: () => Navigator.of(
          context,
          rootNavigator: true,
        ).pop(true),
        onSecondary: () => Navigator.of(
          context,
          rootNavigator: true,
        ).pop(false),
      ),
    );

    return result ?? false;
  }

  static Future<String?> input(
    BuildContext context, {
    required String judul,
    required String pesan,
    required String label,
    String? hint,
    String tombol = 'Cari',
    String teksAwal = '',
    TextCapitalization capitalization = TextCapitalization.none,
  }) async {
    final controller = TextEditingController(text: teksAwal);
    String? error;

    final result = await _show<String>(
      context,
      dismissible: true,
      child: StatefulBuilder(
        builder: (dialogContext, setState) => _AlertPanel(
          type: NotifikasiTipe.info,
          title: judul,
          message: pesan,
          primaryLabel: tombol,
          secondaryLabel: 'Batal',
          onPrimary: () {
            final value = controller.text.trim();
            if (value.isEmpty) {
              setState(() => error = '$label wajib diisi');
              return;
            }
            Navigator.of(dialogContext, rootNavigator: true).pop(value);
          },
          onSecondary: () => Navigator.of(
            dialogContext,
            rootNavigator: true,
          ).pop(),
          content: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: capitalization,
              onSubmitted: (value) {
                final cleanValue = value.trim();
                if (cleanValue.isEmpty) {
                  setState(() => error = '$label wajib diisi');
                  return;
                }
                Navigator.of(
                  dialogContext,
                  rootNavigator: true,
                ).pop(cleanValue);
              },
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                errorText: error,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
      ),
    );

    controller.dispose();
    return result;
  }

  static Future<void> konten(
    BuildContext context, {
    required String judul,
    required Widget child,
    String? pesan,
    String tombol = 'Tutup',
    NotifikasiTipe tipe = NotifikasiTipe.info,
  }) {
    return _show<void>(
      context,
      dismissible: true,
      child: _AlertPanel(
        type: tipe,
        title: judul,
        message: pesan,
        primaryLabel: tombol,
        onPrimary: () => Navigator.of(context, rootNavigator: true).pop(),
        content: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: child,
        ),
      ),
    );
  }

  static Future<T?> _show<T>(
    BuildContext context, {
    required Widget child,
    required bool dismissible,
  }) {
    return showGeneralDialog<T>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: dismissible,
      barrierLabel: 'notifikasi',
      barrierColor: const Color(0xB31B2926),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static String _defaultTitle(NotifikasiTipe type) {
    return switch (type) {
      NotifikasiTipe.sukses => 'Berhasil',
      NotifikasiTipe.gagal => 'Terjadi Kesalahan',
      NotifikasiTipe.peringatan => 'Perlu Perhatian',
      NotifikasiTipe.info => 'Informasi',
    };
  }
}

class _AlertPanel extends StatelessWidget {
  const _AlertPanel({
    required this.type,
    required this.title,
    required this.primaryLabel,
    required this.onPrimary,
    this.message,
    this.secondaryLabel,
    this.onSecondary,
    this.content,
    this.destructive = false,
  });

  final NotifikasiTipe type;
  final String title;
  final String? message;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final Widget? content;
  final bool destructive;

  Color get _color => switch (type) {
    NotifikasiTipe.sukses => AppColors.success,
    NotifikasiTipe.gagal => AppColors.danger,
    NotifikasiTipe.peringatan => AppColors.warning,
    NotifikasiTipe.info => AppColors.info,
  };

  IconData get _icon => switch (type) {
    NotifikasiTipe.sukses => Icons.check_rounded,
    NotifikasiTipe.gagal => Icons.close_rounded,
    NotifikasiTipe.peringatan => Icons.priority_high_rounded,
    NotifikasiTipe.info => Icons.info_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final actionColor = destructive ? AppColors.danger : _color;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 430,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width - 32,
            maxHeight: MediaQuery.sizeOf(context).height - 40,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 50,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_color.withValues(alpha: 0.70), _color],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color.withValues(alpha: 0.18),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: _color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _color.withValues(alpha: 0.28),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Icon(_icon, color: Colors.white, size: 31),
                          ),
                        ),
                      ),
                      const SizedBox(height: 21),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (message != null && message!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14.5,
                            height: 1.55,
                          ),
                        ),
                      ],
                      if (content != null) content!,
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          if (secondaryLabel != null) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onSecondary,
                                child: Text(secondaryLabel!),
                              ),
                            ),
                            const SizedBox(width: 11),
                          ],
                          Expanded(
                            child: FilledButton(
                              onPressed: onPrimary,
                              style: FilledButton.styleFrom(
                                backgroundColor: actionColor,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: Text(primaryLabel),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
