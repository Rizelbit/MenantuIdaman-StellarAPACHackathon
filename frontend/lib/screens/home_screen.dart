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
/// Saldo tampil dalam Rupiah (dikonversi dari USD di balik layar). Kirim adalah
/// satu-satunya CTA kuning; Terima subordinat (ghost). Riwayat sebagai secondary.
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
          _BalanceHero(balanceIdr: balanceIdr),
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
                child: GhostButton(
                  label: 'Terima',
                  icon: Icons.arrow_downward,
                  onPressed: () => context.goNamed(Routes.receive),
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

/// Balance hero (design system §6.4): eyebrow label, angka besar tabular, tombol
/// mata untuk sembunyikan/tampilkan, dan glow kuning sangat samar di belakang
/// angka — jangkar emosional layar Home.
class _BalanceHero extends StatefulWidget {
  final double balanceIdr;
  const _BalanceHero({required this.balanceIdr});

  @override
  State<_BalanceHero> createState() => _BalanceHeroState();
}

class _BalanceHeroState extends State<_BalanceHero> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Total saldo', style: AppText.label),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                // Glow kuning ~6% di belakang angka (§2.1) — satu-satunya di layar.
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.4, 0),
                    radius: 1.2,
                    colors: [Color(0x0FF5B301), Color(0x00F5B301)],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _hidden
                        ? 'Rp ••••••'
                        : formatMoney(widget.balanceIdr, Currency.idr),
                    style: AppText.displayMoneyLg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: () => setState(() => _hidden = !_hidden),
              tooltip: _hidden ? 'Tampilkan saldo' : 'Sembunyikan saldo',
              icon: Icon(
                _hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: AppIconSize.lg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
