import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../state/auth_controller.dart';
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
        .registerWithPasskey('Pengguna Kirimin');

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

    return AppScaffold(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Text('Kirim uang ke keluarga,\ncukup pakai Face ID.',
              style: AppText.h1),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tanpa kata sandi rumit, tanpa kartu. Buat akun sekali sentuh — '
            'uang sampai ke rekening keluarga dalam hitungan detik.',
            style: AppText.bodyMuted,
          ),
          const Spacer(flex: 2),
          _AssurancePoint(
              icon: Icons.verified_user_outlined,
              text: 'Aman dengan sidik jari / wajahmu'),
          _AssurancePoint(
              icon: Icons.bolt_outlined, text: 'Sampai dalam hitungan detik'),
          _AssurancePoint(
              icon: Icons.receipt_long_outlined,
              text: 'Biaya jelas sebelum kamu kirim'),
          const Spacer(),
        ],
      ),
      bottom: PrimaryButton(
        label: 'Buat akun dengan Face ID',
        icon: Icons.face_retouching_natural,
        loading: loading,
        onPressed: () => _register(context, ref),
      ),
    );
  }
}

class _AssurancePoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AssurancePoint({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: AppText.body)),
          ],
        ),
      );
}
