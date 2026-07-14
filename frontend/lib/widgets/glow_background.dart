import 'package:flutter/material.dart';

/// Full-screen background: canvas + a barely-there off-center radial glow so the
/// dark is never flat. Light mode uses a warm off-white glow.
class GlowBackground extends StatelessWidget {
  final Widget child;
  const GlowBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.9),
          radius: 1.3,
          colors: dark
              ? const [Color(0xFF1A160F), Color(0xFF0E0C0A), Color(0xFF090909)]
              : const [Color(0xFFFDFBF7), Color(0xFFF7F4EF), Color(0xFFFFFFFF)],
          stops: const [0.0, 0.45, 0.8],
        ),
      ),
      child: child,
    );
  }
}
