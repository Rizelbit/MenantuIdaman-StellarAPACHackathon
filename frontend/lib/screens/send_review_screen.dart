import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../state/send_controller.dart';
import '../widgets/widgets.dart';

/// CONTOH SCREEN TER-WIRE PENUH — money-shot #2.
/// Kartu rincian biaya (signature element) muncul SEBELUM konfirmasi.
/// Tap "Kirim sekarang" → sheet Face ID → sign → submit → sukses.
class SendReviewScreen extends ConsumerWidget {
  const SendReviewScreen({super.key});

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final send = ref.read(sendControllerProvider);
    final quote = send.quote;
    if (quote == null) return;

    final ok = await showBiometricConfirmSheet(
      context,
      headline: 'Kirim ${quote.amountLabel}?',
      subline:
          '${send.recipientName} akan menerima ${quote.receiveLabel}. '
          'Sentuh Face ID untuk konfirmasi.',
    );
    if (!ok || !context.mounted) return;

    await ref.read(sendControllerProvider.notifier).confirmAndSend();
    if (!context.mounted) return;

    final phase = ref.read(sendControllerProvider).phase;
    if (phase == SendPhase.success) {
      context.goNamed(Routes.sendSuccess);
    } else if (phase == SendPhase.error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ref.read(sendControllerProvider).errorMessage ??
              'Gagal mengirim.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendControllerProvider);
    final quote = send.quote;
    final busy =
        send.phase == SendPhase.signing || send.phase == SendPhase.submitting;

    if (quote == null) {
      return const AppScaffold(
        title: 'Periksa kiriman',
        child: SizedBox.shrink(),
      );
    }

    return AppScaffold(
      title: 'Periksa kiriman',
      leading: BackButton(onPressed: () => context.goNamed(Routes.sendAmount)),
      bottom: PrimaryButton(
        label: busy ? 'Mengirim…' : 'Kirim sekarang',
        loading: busy,
        onPressed: busy ? null : () => _confirm(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Untuk ${send.recipientName}', style: AppText.h2),
          const SizedBox(height: AppSpacing.xl),
          FeeBreakdownCard(quote: quote),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Icon(Icons.schedule,
                  size: 18, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.sm),
              Text('Sampai dalam beberapa detik', style: AppText.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}
