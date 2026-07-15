import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../core/money.dart';
import '../core/result.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Detail satu tagihan split, dimuat dari `GET /splits/:id`. Beda dari
/// [splitControllerProvider] (draft alur create, cuma dipakai selama layar
/// 1-3) — provider ini mengambil data tagihan yang SUDAH dibuat, jadi layar
/// ini bisa dibuka langsung dari mana saja lewat `:id` di URL.
final splitByIdProvider =
    FutureProvider.family<SplitBill, String>((ref, id) async {
  switch (await ref.read(walletApiProvider).getSplit(id)) {
    case Ok(value: final s):
      return s;
    case Err(failure: final f):
      throw f; // FutureProvider surfaces this as AsyncError; screen shows retry
  }
});

/// Layar 4/4 alur split tagihan: progress terkumpul + status bayar tiap
/// peserta.
class SplitDetailScreen extends ConsumerWidget {
  final String id;
  const SplitDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(splitByIdProvider(id));

    return async.when(
      data: (bill) => AppScaffold(
        title: bill.title,
        bottom: PrimaryPillButton(
          label: 'Done',
          onPressed: () => context.goNamed(Routes.home),
        ),
        child: _SplitDetailBody(bill: bill),
      ),
      loading: () => const AppScaffold(
        title: 'Split detail',
        scrollable: false,
        child: LoadingView(),
      ),
      error: (error, stack) => AppScaffold(
        title: 'Split detail',
        scrollable: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyView(
                icon: Icons.error_outline,
                title: 'Couldn\'t load this bill',
                subtitle: 'Check your connection and try again.',
              ),
              const SizedBox(height: KSpace.md),
              SecondaryPillButton(
                label: 'Try again',
                onPressed: () => ref.invalidate(splitByIdProvider(id)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitDetailBody extends StatelessWidget {
  final SplitBill bill;
  const _SplitDetailBody({required this.bill});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: KSpace.md),
        _CollectionProgress(bill: bill),
        const SizedBox(height: KSpace.xl),
        Text('Participants', style: text.titleMedium),
        const SizedBox(height: KSpace.xs),
        for (final participant in bill.participants)
          Padding(
            padding: const EdgeInsets.only(bottom: KSpace.sm),
            child: _ParticipantStatusRow(participant: participant),
          ),
      ],
    );
  }
}

/// Nominal terkumpul vs total, plus progress bar (accent, atau sukses begitu
/// terkumpul penuh) di atas track surface.
class _CollectionProgress extends StatelessWidget {
  final SplitBill bill;
  const _CollectionProgress({required this.bill});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final ratio =
        bill.totalIdr > 0 ? (bill.collectedIdr / bill.totalIdr).clamp(0.0, 1.0) : 0.0;

    return SurfaceCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collected ${formatMoney(bill.collectedIdr, Currency.idr)} of '
            '${formatMoney(bill.totalIdr, Currency.idr)}',
            style: text.bodyLarge,
          ),
          const SizedBox(height: KSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(KRadius.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: p.surface2,
              valueColor:
                  AlwaysStoppedAnimation(ratio >= 1.0 ? p.success : p.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu peserta: avatar + nama + bagiannya + status bayar. Peserta pending
/// yang bukan diri sendiri dapat tombol "Ingatkan".
class _ParticipantStatusRow extends StatelessWidget {
  final SplitParticipant participant;
  const _ParticipantStatusRow({required this.participant});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final paid = participant.status == ParticipantStatus.paid;
    final showRemind = !paid && !participant.isSelf;

    return SurfaceCard(
      padding:
          const EdgeInsets.symmetric(horizontal: KSpace.md, vertical: KSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MonogramAvatar(initials: _initialsOf(participant.name), size: KSize.avatarSm),
              const SizedBox(width: KSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(participant.name, style: text.bodyLarge),
                    Text(formatMoney(participant.shareIdr, Currency.idr),
                        style: text.bodySmall?.copyWith(color: p.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: KSpace.sm),
              paid ? const StatusChip.success('Paid') : const StatusChip.info('Pending'),
            ],
          ),
          if (showRemind) ...[
            const SizedBox(height: KSpace.sm),
            SecondaryPillButton(
              label: 'Nudge ${participant.name}',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder sent')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dua huruf pertama nama, huruf besar — inisial avatar peserta.
String _initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
}
