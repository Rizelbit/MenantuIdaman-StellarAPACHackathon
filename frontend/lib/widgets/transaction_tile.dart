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
          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
                color: AppColors.surfaceAlt, shape: BoxShape.circle),
            child: const Icon(Icons.north_east, color: AppColors.primary),
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
          Text(formatMoney(tx.amountIdr, Currency.idr),
              style: AppText.title),
        ],
      ),
    );
  }
}
