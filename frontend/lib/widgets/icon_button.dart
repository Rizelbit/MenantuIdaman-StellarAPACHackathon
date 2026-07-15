import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// 40px circular tap target for a single icon action (app-bar controls, list
/// affordances). Accent blue is signal-only, so `filled` uses ink/canvas —
/// never a colored fill — to mark the one emphasized icon in a group.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  const CircleIconButton(
      {required this.icon, this.onPressed, this.filled = false, super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(KRadius.full));
    return Material(
      color: filled ? p.ink : p.surface1,
      shape: shape,
      child: InkWell(
        onTap: onPressed,
        customBorder: shape,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(icon, size: 20, color: filled ? p.canvas : p.ink),
          ),
        ),
      ),
    );
  }
}
