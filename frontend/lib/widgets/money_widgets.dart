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

/// ⭐ SIGNATURE ELEMENT (design system §6.5) — kartu transparansi biaya.
/// Muncul SEBELUM konfirmasi. Menjawab pain "user tak tahu biaya".
/// Tiga baris dengan urutan tetap: Kamu kirim → Keluarga terima (hero, hijau) →
/// Biaya layanan. Dipisah hairline. Angka terima adalah pusat visual kartu.
class FeeBreakdownCard extends StatelessWidget {
  final SendQuote quote;
  const FeeBreakdownCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            _row('Kamu kirim', quote.amountLabel),
            const Divider(height: 1),
            _heroRow('Keluarga terima', quote.receiveLabel),
            const Divider(height: 1),
            _row('Biaya layanan (${quote.feePercentLabel})', quote.feeLabel,
                muted: true),
          ],
        ),
      ),
    );
  }

  static TextStyle _tab(TextStyle s) =>
      s.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // Baris biasa: label kiri, nominal kanan (tabular).
  Widget _row(String label, String value, {bool muted = false}) {
    final labelStyle = muted ? AppText.bodyMuted : AppText.title;
    final valueStyle = muted ? AppText.bodyMuted : AppText.title;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: _tab(valueStyle)),
        ],
      ),
    );
  }

  // Baris hero: nominal "keluarga terima" ditonjolkan (hijau, lebih besar).
  Widget _heroRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.title),
          Text(value, style: _tab(AppText.h2.copyWith(color: AppColors.success))),
        ],
      ),
    );
  }
}
