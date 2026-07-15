import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Empty state for a list/screen with nothing to show yet: centered icon,
/// title, and an explanatory subtitle — no CTA, callers compose one below if
/// needed.
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyView({required this.icon, required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: p.inkMuted),
            const SizedBox(height: KSpace.lg),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: KSpace.xs),
            Text(
              subtitle,
              style: text.bodyMedium?.copyWith(color: p.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered spinner for a screen/section awaiting data.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
