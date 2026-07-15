import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/text_theme.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Static receive surface — the user's own QR + Kirimin ID, shown so others can
/// scan or type to send money. Values here are static (mock) until a profile
/// endpoint exists; swap them in once available.
class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Terima',
      bottom: PrimaryPillButton(
        label: 'Bagikan detail',
        icon: Icons.ios_share,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Detail disalin')),
          );
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.lg),
          Center(
            child: Container(
              width: 220,
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(KRadius.xl),
              ),
              child: const Icon(Icons.qr_code_2, size: 168, color: Color(0xFF0A0A0A)),
            ),
          ),
          const SizedBox(height: KSpace.lg),
          Center(
            child: Column(
              children: [
                Text('Rani Putri', style: text.titleMedium?.copyWith(color: p.ink)),
                const SizedBox(height: KSpace.xxs),
                Text('Pindai untuk kirim uang ke saya',
                    style: text.bodySmall?.copyWith(color: p.inkMuted)),
              ],
            ),
          ),
          const SizedBox(height: KSpace.lg),
          Container(
            decoration: BoxDecoration(
              color: p.surface1,
              borderRadius: BorderRadius.circular(KRadius.xl),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                const _CopyRow(label: 'Kirimin ID', value: 'rani.putri'),
                Divider(height: 1, color: p.hairline),
                const _CopyRow(label: 'Rekening tujuan', value: 'BCA •••• 4821'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One "label over value" row with a trailing copy affordance (copies the value
/// to the clipboard).
class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  const _CopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: microStyle(p.inkMuted)),
                const SizedBox(height: 2),
                Text(value,
                    style: text.bodyMedium?.copyWith(
                        color: p.ink, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label disalin')),
              );
            },
            icon: Icon(Icons.copy_outlined, size: 18, color: p.accent),
          ),
        ],
      ),
    );
  }
}
