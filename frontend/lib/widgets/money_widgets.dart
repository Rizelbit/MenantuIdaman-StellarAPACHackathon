import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../core/money.dart';

/// Input nominal Rupiah dengan pemisah ribuan otomatis. Mengembalikan nilai
/// double lewat [onChanged]. Prefix "Rp" agar user tak pernah lihat token.
class MoneyInput extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final String hint;
  const MoneyInput({
    super.key,
    required this.onChanged,
    this.hint = '0',
  });

  @override
  State<MoneyInput> createState() => _MoneyInputState();
}

class _MoneyInputState extends State<MoneyInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      style: AppText.displayMoney,
      textAlign: TextAlign.center,
      cursorColor: AppColors.primary,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        prefixText: 'Rp ',
        prefixStyle: AppText.displayMoney.copyWith(color: AppColors.textSecondary),
        hintText: widget.hint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
      ),
      onChanged: (raw) {
        final value = double.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        widget.onChanged(value);
      },
    );
  }
}

/// Angka saldo/nominal besar. Selalu Rp/$ — pusat visual di Home & konfirmasi.
class AmountDisplay extends StatelessWidget {
  final double amount;
  final Currency currency;
  final String? caption;
  const AmountDisplay({
    super.key,
    required this.amount,
    this.currency = Currency.idr,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (caption != null) ...[
          Text(caption!, style: AppText.label),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(formatMoney(amount, currency), style: AppText.displayMoney),
      ],
    );
  }
}

/// ⭐ SIGNATURE ELEMENT — kartu transparansi biaya.
/// Muncul SEBELUM konfirmasi. Menjawab pain "user tak tahu biaya".
/// Baris "Keluarga terima" sengaja ditonjolkan (warna + weight).
class FeeBreakdownCard extends StatelessWidget {
  final SendQuote quote;
  const FeeBreakdownCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _row('Kamu kirim', quote.amountLabel),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            _row('Biaya layanan (${quote.feePercentLabel})', '- ${quote.feeLabel}',
                muted: true),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: AppRadii.card,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Keluarga terima',
                      style: AppText.title.copyWith(color: AppColors.success)),
                  Text(quote.receiveLabel,
                      style: AppText.h2.copyWith(color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool muted = false}) {
    final style = muted ? AppText.bodyMuted : AppText.body;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
