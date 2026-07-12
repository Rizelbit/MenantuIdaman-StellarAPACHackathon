import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../core/money.dart';
import '../models/models.dart';

/// Baris satu transaksi di riwayat. Bahasa: "Terkirim ke Ibu", bukan hash tx.
class TransactionTile extends StatelessWidget {
  final AppTransaction tx;
  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM, HH:mm', 'id_ID');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          // Leading: ikon persegi membulat di surface2 dengan garis hairline (§6.9).
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.hairline),
            ),
            child: const Icon(Icons.north_east,
                color: AppColors.primary, size: AppIconSize.lg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terkirim ke ${tx.recipientName}', style: AppText.title),
                const SizedBox(height: 2),
                Text(df.format(tx.createdAt), style: AppText.bodyMuted),
              ],
            ),
          ),
          // Nominal keluar: teks terang, angka tabular agar tidak bergeser (§6.9, §4).
          Text(
            '- ${formatMoney(tx.amountIdr, Currency.idr)}',
            style: AppText.title.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}
