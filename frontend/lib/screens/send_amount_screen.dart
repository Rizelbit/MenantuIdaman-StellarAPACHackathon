import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../state/send_controller.dart';
import '../widgets/widgets.dart';

/// CONTOH SCREEN TER-WIRE PENUH.
/// Input nominal + nama penerima. Preview "keluarga terima" muncul LIVE saat
/// mengetik — transparansi sebelum lanjut.
class SendAmountScreen extends ConsumerWidget {
  const SendAmountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendControllerProvider);
    final ctrl = ref.read(sendControllerProvider.notifier);
    final canContinue =
        send.quote != null && send.recipientName.trim().isNotEmpty;

    return AppScaffold(
      title: 'Kirim uang',
      leading: BackButton(onPressed: () => context.goNamed(Routes.home)),
      bottom: PrimaryButton(
        label: 'Lanjut',
        onPressed: canContinue
            ? () {
                ctrl.goToReview();
                context.goNamed(Routes.sendReview);
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const Text('Untuk siapa?', style: AppText.label),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            decoration: const InputDecoration(hintText: 'Nama keluarga'),
            textCapitalization: TextCapitalization.words,
            onChanged: ctrl.setRecipient,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Center(child: Text('Nominal kiriman', style: AppText.label)),
          const SizedBox(height: AppSpacing.sm),
          MoneyInput(onChanged: ctrl.setAmount),
          const SizedBox(height: AppSpacing.xl),
          if (send.quote != null)
            Center(
              child: Text(
                'Keluarga terima ${send.quote!.receiveLabel}',
                style: AppText.title.copyWith(color: AppColors.success),
              ),
            ),
        ],
      ),
    );
  }
}
