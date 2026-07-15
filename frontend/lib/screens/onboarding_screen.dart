import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../state/auth_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// CONTOH SCREEN TER-WIRE PENUH — pola untuk screen lain.
/// Money-shot #1: "daftar pakai Face ID". Satu tap → biometrik → akun siap.
/// Tidak ada seed phrase, tidak ada kata wallet.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _register(BuildContext context, WidgetRef ref) async {
    // MVP: nama user statik. (Nanti: field nama sederhana.)
    final failure = await ref
        .read(authControllerProvider.notifier)
        .registerWithPasskey('Kirimin User');

    if (!context.mounted) return;
    if (failure == null) {
      context.goNamed(Routes.home);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authControllerProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;
    final p = KColors.of(Theme.of(context).brightness);

    return AppScaffold(
      scrollable: false,
      bottom: PrimaryPillButton(
        label: 'Create account with Face ID',
        icon: Icons.face,
        loading: loading,
        onPressed: () => _register(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text('Send money to family,\nwith just Face ID.',
              style: textTheme.headlineLarge),
          const SizedBox(height: KSpace.md),
          Text(
            'No complicated passwords, no cards. Create an account with one '
            'touch — money reaches family in seconds.',
            style: textTheme.bodyMedium?.copyWith(color: p.inkMuted),
          ),
          const Spacer(flex: 2),
          const _AssurancePoint(
              icon: Icons.verified_user_outlined,
              text: 'Secured by your fingerprint or face'),
          const _AssurancePoint(
              icon: Icons.bolt_outlined, text: 'Arrives in seconds'),
          const _AssurancePoint(
              icon: Icons.receipt_long_outlined,
              text: 'Clear fees before you send'),
          const Spacer(),
        ],
      ),
    );
  }
}

class _AssurancePoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AssurancePoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(bottom: KSpace.lg),
      child: Row(
        children: [
          Icon(icon, color: p.accent, size: 22),
          const SizedBox(width: KSpace.md),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
