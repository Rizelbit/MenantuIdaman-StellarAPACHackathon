import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../core/money.dart';
import '../state/send_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 3/3 alur kirim: konfirmasi visual lega + ringkasan bukti transaksi.
/// Dibaca dari `sendController.result` (bukan `.recipientName` lama — field
/// itu sudah diganti `AppTransaction.counterpartyName`).
class SendSuccessScreen extends ConsumerWidget {
  const SendSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(sendControllerProvider).result;
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    void done() {
      ref.read(sendControllerProvider.notifier).reset();
      context.goNamed(Routes.home);
    }

    if (result == null) {
      // Layar dibuka tanpa hasil kiriman (mis. deep-link langsung) — kembali
      // ke home setelah frame pertama alih-alih menampilkan bukti kosong.
      WidgetsBinding.instance.addPostFrameCallback((_) => done());
      return const AppScaffold(scrollable: false, child: SizedBox.shrink());
    }

    return AppScaffold(
      scrollable: false,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryPillButton(label: 'Selesai', onPressed: done),
          const SizedBox(height: KSpace.sm),
          SecondaryPillButton(
            label: 'Bagikan bukti',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bukti kiriman disalin.')),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(child: Icon(Icons.check_circle, size: 88, color: p.success)),
          const SizedBox(height: KSpace.lg),
          Text('Uang sedang dikirim',
              style: text.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: KSpace.xs),
          Text(
            '${formatMoney(result.amountIdr, Currency.idr)} sedang menuju '
            '${result.counterpartyName}',
            style: text.bodyMedium?.copyWith(color: p.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSpace.xl),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ke ${result.counterpartyName}', style: text.bodyLarge),
                const SizedBox(height: KSpace.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nominal',
                        style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                    Text(formatMoney(result.amountIdr, Currency.idr),
                        style: text.bodyMedium),
                  ],
                ),
                const SizedBox(height: KSpace.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Referensi',
                        style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                    Text(result.reference ?? 'KRM-8F2A091',
                        style: text.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
