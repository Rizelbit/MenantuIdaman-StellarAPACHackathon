import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Circular initials avatar for a contact/recipient in a list or picker.
/// `selected` draws a 2px accent ring in an outer [Container] so the ring
/// sits cleanly outside the fill — accent blue stays signal-only here, never
/// a filled background.
class MonogramAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final bool selected;
  const MonogramAvatar({
    required this.initials,
    this.size = KSize.avatarSm,
    this.selected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);

    final fill = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          color: p.ink,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (!selected) return fill;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: p.accent, width: 2),
      ),
      child: fill,
    );
  }
}
