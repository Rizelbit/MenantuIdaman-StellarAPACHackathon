import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum _StatusKind { success, danger, info }

/// Small pill label for a transaction/contact state (e.g. "Terkirim",
/// "Gagal", "Menunggu"). Background is always the semantic color at 14%
/// alpha with the solid semantic color as text — a tag, never a button —
/// so `.info` is the one place accent blue may color something besides a
/// border, and even then only as tinted text/background, never a fill.
class StatusChip extends StatelessWidget {
  final String label;
  final _StatusKind _kind;

  const StatusChip.success(this.label, {super.key}) : _kind = _StatusKind.success;
  const StatusChip.danger(this.label, {super.key}) : _kind = _StatusKind.danger;
  const StatusChip.info(this.label, {super.key}) : _kind = _StatusKind.info;

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final color = switch (_kind) {
      _StatusKind.success => p.success,
      _StatusKind.danger => p.danger,
      _StatusKind.info => p.accent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(KRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
