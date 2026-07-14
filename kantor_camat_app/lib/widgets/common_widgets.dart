import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class SectionCard extends StatefulWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.border,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final bool showShadow;

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;

    return MouseRegion(
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: widget.showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _hovered ? 0.075 : 0.035,
                    ),
                    blurRadius: _hovered ? 24 : 16,
                    offset: Offset(0, _hovered ? 10 : 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: widget.backgroundColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: widget.borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: EdgeInsets.all(narrow ? 18 : 22),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E9E4)),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageIntroContent(title: title, subtitle: subtitle, icon: icon),
                if (trailing != null) ...[
                  const SizedBox(height: 16),
                  trailing!,
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _PageIntroContent(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 18),
                  trailing!,
                ],
              ],
            ),
    );
  }
}

class _PageIntroContent extends StatelessWidget {
  const _PageIntroContent({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 25),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.text,
    this.icon = Icons.inbox_outlined,
    this.description,
    this.action,
  });

  final String text;
  final IconData icon;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF6F3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 17),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 7),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 18),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Memuat data...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(52),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final config = switch (normalized) {
      'selesai' || 'disetujui' || 'aktif' => const _BadgeConfig(
          AppColors.success,
          Icons.check_circle_rounded,
        ),
      'ditolak' || 'dibatalkan' || 'nonaktif' => const _BadgeConfig(
          AppColors.danger,
          Icons.cancel_rounded,
        ),
      'diproses' || 'didisposisi' || 'diverifikasi' => const _BadgeConfig(
          AppColors.warning,
          Icons.schedule_rounded,
        ),
      'arsip' => const _BadgeConfig(Color(0xFF66716E), Icons.archive_rounded),
      'baru' => const _BadgeConfig(AppColors.info, Icons.fiber_new_rounded),
      _ => const _BadgeConfig(AppColors.info, Icons.info_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: config.color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 5),
          Text(
            status.replaceAll('_', ' '),
            style: TextStyle(
              color: config.color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeConfig {
  const _BadgeConfig(this.color, this.icon);

  final Color color;
  final IconData icon;
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.caption,
    this.width = 235,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? caption;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SectionCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (caption != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftBadge extends StatelessWidget {
  const SoftBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

String formatRupiah(dynamic value) {
  final number = double.tryParse('$value') ?? 0;

  if (number == 0) {
    return 'Gratis';
  }

  final digits = number.toStringAsFixed(0);
  final characters = digits.split('').reversed.toList();
  final groups = <String>[];

  for (var index = 0; index < characters.length; index += 3) {
    final group = characters.skip(index).take(3).toList().reversed.join();
    groups.add(group);
  }

  return 'Rp${groups.reversed.join('.')}';
}
