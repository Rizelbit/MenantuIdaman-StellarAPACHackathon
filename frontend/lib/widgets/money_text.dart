import 'package:flutter/material.dart';
import '../core/money.dart';
import '../theme/text_theme.dart';
import '../theme/tokens.dart';

/// Renders an IDR amount with the shared tabular-figure money type. Pass
/// `hidden: true` (privacy toggle on balances) to mask the digits without
/// touching layout — the masked string keeps the same "Rp " lead-in.
class MoneyText extends StatelessWidget {
  final double amountIdr;
  final double size;
  final bool hidden;
  final FontWeight weight;
  final Color? color;

  const MoneyText({
    required this.amountIdr,
    required this.size,
    this.hidden = false,
    this.weight = FontWeight.w700,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = hidden ? 'Rp ••••••' : formatMoney(amountIdr, Currency.idr);
    return Text(
      text,
      style: moneyStyle(size: size, color: color ?? p.ink, weight: weight),
    );
  }
}
