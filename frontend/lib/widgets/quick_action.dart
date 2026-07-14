import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Circle-plus-caption shortcut (e.g. Kirim, Terima, Riwayat) grouped below
/// the balance/hero area. `primary` marks the single most likely action with
/// an ink-filled circle; the rest stay surface1 so accent blue never fills.
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  const QuickAction(
      {required this.icon,
      required this.label,
      this.onPressed,
      this.primary = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(KRadius.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary ? p.ink : p.surface1,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary ? p.canvas : p.ink),
          ),
          const SizedBox(height: KSpace.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: p.ink),
          ),
        ],
      ),
    );
  }
}
