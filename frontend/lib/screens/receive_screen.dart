import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar terima statis — QR + ID Kirimin milik pengguna sendiri, ditampilkan
/// agar orang lain bisa memindai/mengetik untuk mengirim uang. Nilai di sini
/// statik (mock) karena belum ada endpoint profil; ganti begitu tersedia.
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
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            elevated: true,
            child: Column(
              children: [
                Icon(Icons.qr_code_2, size: 160, color: p.ink),
                const SizedBox(height: KSpace.md),
                Text('Rani Putri', style: text.titleMedium?.copyWith(color: p.ink)),
                const SizedBox(height: KSpace.xxs),
                Text('Pindai untuk mengirimiku uang',
                    style: text.bodySmall?.copyWith(color: p.inkMuted)),
                const SizedBox(height: KSpace.sm),
                Text.rich(
                  TextSpan(
                    style: text.bodyMedium?.copyWith(color: p.inkMuted),
                    children: [
                      const TextSpan(text: 'Kirimin ID: '),
                      TextSpan(
                        text: 'rani.putri',
                        style: text.bodyMedium?.copyWith(
                          color: p.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            child: Row(
              children: [
                Icon(Icons.account_balance_outlined, size: 20, color: p.inkMuted),
                const SizedBox(width: KSpace.sm),
                Text('Rekening', style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                const Spacer(),
                Text('•••• 4821', style: text.bodyMedium?.copyWith(color: p.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
