import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../core/money.dart';
import '../widgets/widgets.dart';

/// CONTOH SCREEN (MOCK OFF-RAMP) — sisi penerima.
/// Untuk demo, ini "layar keluarga": Rp sudah masuk ke rekening. Tidak ada satu
/// pun istilah crypto. Nilai & rekening di sini statik (mock) — ganti sesuai
/// skenario demo. Jalur real = anchor/SEP (future work).
class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK: nilai contoh untuk demo panggung.
    const receivedIdr = 995000.0;
    const bankLabel = 'BCA ****1234';

    return AppScaffold(
      title: 'Terima',
      leading: BackButton(onPressed: () => context.goNamed(Routes.home)),
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            height: 88,
            width: 88,
            decoration: const BoxDecoration(
                color: AppColors.accentSoft, shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 44, color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('${formatMoney(receivedIdr, Currency.idr)} masuk',
              style: AppText.h1),
          const SizedBox(height: AppSpacing.sm),
          const Text('ke rekening $bankLabel',
              style: AppText.bodyMuted, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: AppColors.success, size: 22),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text('Dana tersedia untuk ditarik sekarang.',
                        style: AppText.body),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
      bottom: PrimaryButton(
        label: 'Kembali ke beranda',
        onPressed: () => context.goNamed(Routes.home),
      ),
    );
  }
}
