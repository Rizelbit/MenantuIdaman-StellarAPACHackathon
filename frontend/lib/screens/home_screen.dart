import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../core/money.dart';
import '../state/auth_controller.dart';
import '../state/send_controller.dart';
import '../widgets/widgets.dart';

/// CONTOH SCREEN TER-WIRE PENUH.
/// Saldo tampil dalam Rupiah (dikonversi dari USD di balik layar). Dua aksi
/// besar: Kirim & Terima. Riwayat sebagai secondary.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final balanceIdr = usdToIdr(wallet?.balanceUsd ?? 0);

    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Text('Saldo kamu', style: AppText.label),
          const SizedBox(height: AppSpacing.xs),
          Text(formatMoney(balanceIdr, Currency.idr),
              style: AppText.displayMoney),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Kirim',
                  icon: Icons.arrow_upward,
                  onPressed: () {
                    ref.read(sendControllerProvider.notifier).reset();
                    context.goNamed(Routes.sendAmount);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.goNamed(Routes.receive),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Terima'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
                    textStyle: AppText.title,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat', style: AppText.h2),
              TextButton(
                onPressed: () => context.goNamed(Routes.history),
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // MVP: riwayat kosong sampai ada transaksi nyata di sesi.
          const EmptyView(
            icon: Icons.history,
            title: 'Belum ada transaksi',
            subtitle: 'Kiriman pertamamu akan muncul di sini.',
          ),
        ],
      ),
    );
  }
}
