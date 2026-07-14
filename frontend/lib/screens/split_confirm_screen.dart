import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../core/money.dart';
import '../models/models.dart';
import '../state/split_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 3/4 alur split tagihan: ringkasan sebelum permintaan bagian dikirim
/// ke tiap peserta.
class SplitConfirmScreen extends ConsumerWidget {
  const SplitConfirmScreen({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    await ref.read(splitControllerProvider.notifier).submit();
    if (!context.mounted) return;
    // Demo: detail intentionally shows the canonical sample split ('split1',
    // mid-progress) so the "Ingatkan" nudge state is visible. With a real
    // backend, navigate to the id returned by submit().
    context.pushNamed(Routes.splitDetail, pathParameters: {'id': 'split1'});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(splitControllerProvider);

    // Dibuka tanpa draft split yang lengkap (mis. deep-link langsung) —
    // arahkan balik ke layar sebelumnya, sama seperti pola guard di
    // RequestConfirmScreen/SendReviewScreen.
    if (state.totalIdr <= 0 || state.participants.length < 2) {
      return const AppScaffold(
        title: 'Konfirmasi split',
        child: EmptyView(
          icon: Icons.call_split,
          title: 'Belum ada tagihan',
          subtitle: 'Kembali ke layar sebelumnya untuk isi total dan peserta dulu.',
        ),
      );
    }

    return AppScaffold(
      title: 'Konfirmasi split',
      bottom: PrimaryPillButton(
        label: 'Kirim permintaan',
        onPressed: () => _submit(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.md),
          _SplitSummaryCard(
            title: state.title,
            totalIdr: state.totalIdr,
            participants: state.participants,
          ),
          const SizedBox(height: KSpace.md),
          const _SendRequestsHint(),
        ],
      ),
    );
  }
}

/// Kartu ringkasan: judul, nominal total besar, jumlah peserta, lalu rincian
/// bagian tiap peserta.
class _SplitSummaryCard extends StatelessWidget {
  final String title;
  final double totalIdr;
  final List<SplitParticipant> participants;

  const _SplitSummaryCard({
    required this.title,
    required this.totalIdr,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return SurfaceCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: KSpace.xs),
          MoneyText(amountIdr: totalIdr, size: 36),
          const SizedBox(height: KSpace.xs),
          Text('Dibagi ke ${participants.length} orang',
              style: text.bodyMedium?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.lg),
          Divider(color: p.hairline, height: 1),
          const SizedBox(height: KSpace.md),
          for (final participant in participants)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: KSpace.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      participant.isSelf ? 'Kamu · Bagianmu' : participant.name,
                      style: text.bodyMedium,
                    ),
                  ),
                  Text(formatMoney(participant.shareIdr, Currency.idr),
                      style: text.bodyMedium),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SendRequestsHint extends StatelessWidget {
  const _SendRequestsHint();

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: p.inkMuted),
        const SizedBox(width: KSpace.xs),
        Expanded(
          child: Text(
            'Tiap orang dapat permintaan untuk bagiannya',
            style: text.bodySmall?.copyWith(color: p.inkMuted),
          ),
        ),
      ],
    );
  }
}
