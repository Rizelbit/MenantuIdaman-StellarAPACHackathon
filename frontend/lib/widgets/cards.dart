import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Generic content container. Plain surface1 + [KRadius.xl] for regular
/// content; `elevated` steps up to surface2 + the slightly larger
/// [KRadius.xxl] for cards that need to read as sitting above the page
/// (e.g. a summary panel over a list). Pass [onTap] to make the whole card
/// tappable with a ripple clipped to the card's own radius.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final bool elevated;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const SurfaceCard({
    required this.child,
    this.elevated = false,
    this.padding = const EdgeInsets.all(22),
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final radius = BorderRadius.circular(elevated ? KRadius.xxl : KRadius.xl);
    final content = Padding(padding: padding, child: child);

    return Material(
      color: elevated ? p.surface2 : p.surface1,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, borderRadius: radius, child: content),
    );
  }
}

/// Full-bleed gradient panel — the one hero surface a screen is allowed to
/// spend its accent gradient on (aurora blue by default; `sunset` swaps in
/// the warm gradient for a celebratory/success moment — never both on one
/// screen). Wraps [child] in a [DefaultTextStyle] so text drops in legible
/// without every caller having to set its own color.
class GradientSpotlight extends StatelessWidget {
  final Widget child;
  final bool sunset;
  final EdgeInsetsGeometry padding;
  const GradientSpotlight({
    required this.child,
    this.sunset = false,
    this.padding = const EdgeInsets.all(22),
    super.key,
  });

  // Sunset's warm gradient reads best against near-black text; this is the
  // documented on-sunset text color from the design spec, not a stray hex.
  static const _onSunset = Color(0xFF1A1207);

  @override
  Widget build(BuildContext context) {
    final textColor = sunset ? _onSunset : Colors.white;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: sunset ? KColors.sunsetGradient : KColors.auroraGradient,
        borderRadius: KRadius.spotlight,
      ),
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(color: textColor),
        child: child,
      ),
    );
  }
}
