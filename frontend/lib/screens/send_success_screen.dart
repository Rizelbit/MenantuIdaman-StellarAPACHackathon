import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../core/money.dart';
import '../state/send_controller.dart';
import '../widgets/widgets.dart';

/// CONTOH SCREEN TER-WIRE PENUH. Konfirmasi lega, bukan teknis.
class SendSuccessScreen extends ConsumerWidget {
  const SendSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(sendControllerProvider).result;

    return AppScaffold(
      scrollable: false,
      bottom: PrimaryButton(
        label: 'Selesai',
        onPressed: () {
          ref.read(sendControllerProvider.notifier).reset();
          context.goNamed(Routes.home);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            height: 88,
            width: 88,
            decoration: const BoxDecoration(
                color: AppColors.successSoft, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                size: 48, color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Uang terkirim', style: AppText.h1),
          const SizedBox(height: AppSpacing.sm),
          if (result != null)
            Text(
              '${result.recipientName} menerima '
              '${formatMoney(result.amountIdr, Currency.idr)}.',
              style: AppText.bodyMuted,
              textAlign: TextAlign.center,
            ),
          const Spacer(),
        ],
      ),
    );
  }
}
