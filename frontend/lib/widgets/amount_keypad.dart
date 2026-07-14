import 'package:flutter/material.dart';
import '../theme/text_theme.dart';
import '../theme/tokens.dart';

/// Numeric entry pad for amount screens: `1`-`9`, then `000`, `0`, backspace.
/// Borderless — no fill, no border — so it reads as part of the canvas; each
/// key gets a tall tap target rather than a visible chip.
class AmountKeypad extends StatelessWidget {
  final void Function(String digit) onKey;
  final VoidCallback onBackspace;

  const AmountKeypad({required this.onKey, required this.onBackspace, super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final rows = <List<Widget>>[
      for (final row in const [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
      ])
        [
          for (final digit in row)
            _KeypadKey(
              onTap: () => onKey(digit),
              child: Text(digit, style: moneyStyle(size: 26, color: p.ink)),
            ),
        ],
      [
        _KeypadKey(
          onTap: () => onKey('000'),
          child: Text('000', style: moneyStyle(size: 26, color: p.ink)),
        ),
        _KeypadKey(
          onTap: () => onKey('0'),
          child: Text('0', style: moneyStyle(size: 26, color: p.ink)),
        ),
        _KeypadKey(
          onTap: onBackspace,
          child: Icon(Icons.backspace_outlined, color: p.ink, size: 24),
        ),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(children: [for (final key in row) Expanded(child: key)]),
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _KeypadKey({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Center(child: child),
        ),
      ),
    );
  }
}
