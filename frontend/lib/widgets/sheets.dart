import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'pill_button.dart';

/// Face ID / biometric confirm sheet used before a sensitive action (sending
/// money, revealing a secret). Resolves `true` only when the user taps the
/// primary confirm button; a swipe-to-dismiss or the "Batal" text button both
/// resolve `false`.
Future<bool> showBiometricConfirmSheet(
  BuildContext context, {
  required String headline,
  required String subline,
  String confirmLabel = 'Konfirmasi dengan Face ID',
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final p = KColors.of(Theme.of(ctx).brightness);
      final text = Theme.of(ctx).textTheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          KSpace.lg,
          KSpace.lg,
          KSpace.lg,
          KSpace.lg + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
              child: Icon(Icons.fingerprint, size: 36, color: p.ink),
            ),
            const SizedBox(height: KSpace.lg),
            Text(headline, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: KSpace.xs),
            Text(
              subline,
              style: text.bodyMedium?.copyWith(color: p.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KSpace.xl),
            PrimaryPillButton(
              label: confirmLabel,
              icon: Icons.face,
              onPressed: () => Navigator.pop(ctx, true),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}
