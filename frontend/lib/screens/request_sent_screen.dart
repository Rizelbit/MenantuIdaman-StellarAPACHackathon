import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../core/money.dart';
import '../state/request_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 3/3 alur minta: konfirmasi bahwa permintaan sudah terkirim ke
/// kontak, plus status "menunggu dibayar" — tidak ada dana yang berpindah
/// di layar ini, cuma catatan bahwa permintaan sudah dikirim.
class RequestSentScreen extends ConsumerWidget {
  const RequestSentScreen({super.key});

  void _done(BuildContext context, WidgetRef ref) {
    ref.read(requestControllerProvider.notifier).reset();
    context.goNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(requestControllerProvider);
    final contact = state.fromContact;
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    if (contact == null) {
      // Layar dibuka tanpa permintaan aktif (mis. deep-link langsung) —
      // kembali ke home setelah frame pertama alih-alih menampilkan status
      // kosong.
      WidgetsBinding.instance.addPostFrameCallback((_) => _done(context, ref));
      return const AppScaffold(scrollable: false, child: SizedBox.shrink());
    }

    return AppScaffold(
      title: 'Minta',
      bottom: PrimaryPillButton(
        label: 'Selesai',
        onPressed: () => _done(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.xl),
          Center(
            child: Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
              child: Icon(Icons.mark_email_read_outlined, size: 40, color: p.ink),
            ),
          ),
          const SizedBox(height: KSpace.lg),
          Text('Permintaan terkirim',
              style: text.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: KSpace.xs),
          Text(
            'Kami akan ingatkan ${contact.name} untuk bayar '
            '${formatMoney(state.amountIdr, Currency.idr)}',
            style: text.bodyMedium?.copyWith(color: p.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSpace.xl),
          const Center(child: StatusChip.info('Menunggu dibayar')),
          const SizedBox(height: KSpace.lg),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TimelineStep(
                  filled: true,
                  label: 'Permintaan terkirim · Baru saja',
                ),
                const SizedBox(height: KSpace.sm),
                const _TimelineStep(
                  filled: false,
                  label: 'Menunggu dibayar',
                ),
                const SizedBox(height: KSpace.sm),
                Text('Kami kabari begitu ${contact.name} bayar',
                    style: text.bodySmall?.copyWith(color: p.inkMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final bool filled;
  final String label;
  const _TimelineStep({required this.filled, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? p.ink : Colors.transparent,
            border: filled ? null : Border.all(color: p.inkMuted, width: 1.5),
          ),
        ),
        const SizedBox(width: KSpace.sm),
        Expanded(
          child: Text(
            label,
            style: text.bodyMedium?.copyWith(
              color: filled ? p.ink : p.inkMuted,
              fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
