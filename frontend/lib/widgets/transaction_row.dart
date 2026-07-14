import 'package:flutter/material.dart';
import '../core/money.dart';
import '../models/models.dart';
import '../theme/text_theme.dart';
import '../theme/tokens.dart';
import 'avatar.dart';

/// One row in a transaction/activity list: leading avatar (or icon) circle,
/// title over subtitle, and a signed, colored amount. `direction` sets the
/// sign (`+` for receive, `−` for send/split) and default color (success for
/// receive, ink otherwise); `failed` always wins and paints danger. A hairline
/// divider is drawn under the row so lists can just stack `TransactionRow`s.
class TransactionRow extends StatelessWidget {
  final String? avatarInitials;
  final IconData? icon;
  final String title;
  final String subtitle;
  final double amountIdr;
  final TxDirection direction;
  final bool failed;
  final VoidCallback? onTap;

  const TransactionRow({
    this.avatarInitials,
    this.icon,
    required this.title,
    required this.subtitle,
    required this.amountIdr,
    required this.direction,
    this.failed = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final isReceive = direction == TxDirection.receive;
    final sign = isReceive ? '+ ' : '− ';
    final amountColor = failed ? p.danger : (isReceive ? p.success : p.ink);

    final leading = avatarInitials != null
        ? MonogramAvatar(initials: avatarInitials!)
        : Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surface1, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: p.ink),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 64,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                leading,
                const SizedBox(width: KSpace.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: text.bodySmall?.copyWith(color: p.inkMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: KSpace.sm),
                Text(
                  '$sign${formatMoney(amountIdr, Currency.idr)}',
                  style: moneyStyle(size: 15, color: amountColor, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const Divider(), // picks up DividerThemeData: hairlineSoft, 1px
      ],
    );
  }
}
