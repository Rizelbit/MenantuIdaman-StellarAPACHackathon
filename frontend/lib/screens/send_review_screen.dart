import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/contacts_controller.dart';
import '../state/send_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Step 2/3 of the send flow: a transparent fee breakdown before the Face ID
/// confirm. Since `Env.feeRate == 0` in this demo, "they receive" always equals
/// "you send" — the fee row still shows so the transparency is visible.
class SendReviewScreen extends ConsumerWidget {
  const SendReviewScreen({super.key});

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final send = ref.read(sendControllerProvider);
    final quote = send.quote;
    if (quote == null) return;

    final ok = await showBiometricConfirmSheet(
      context,
      headline: 'Send ${quote.amountLabel}?',
      subline: '${send.recipientName} will receive ${quote.receiveLabel}.',
      confirmLabel: 'Hold to confirm',
    );
    if (!ok || !context.mounted) return;

    await ref.read(sendControllerProvider.notifier).confirmAndSend();
    if (!context.mounted) return;

    final state = ref.read(sendControllerProvider);
    if (state.phase == SendPhase.success) {
      context.pushNamed(Routes.sendSuccess);
    } else if (state.phase == SendPhase.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Couldn\'t send.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendControllerProvider);
    final contacts = ref.watch(contactsControllerProvider);
    final match = _matchContact(contacts, send.recipientName);
    final quote = send.quote;
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final busy =
        send.phase == SendPhase.signing || send.phase == SendPhase.submitting;

    if (quote == null) {
      return const AppScaffold(
        title: 'Review',
        child: EmptyView(
          icon: Icons.receipt_long_outlined,
          title: 'Nothing to review yet',
          subtitle: 'Go back to enter an amount first.',
        ),
      );
    }

    return AppScaffold(
      title: 'Review',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('One quick Face ID and you\'re done',
              style: text.bodySmall?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.sm),
          PrimaryPillButton(
            label: 'Hold to confirm',
            icon: Icons.fingerprint,
            loading: busy,
            onPressed: busy ? null : () => _confirm(context, ref),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.lg),
          // Centered recipient block (avatar over name over masked account).
          Center(
            child: Column(
              children: [
                MonogramAvatar(
                  initials: match?.initials ?? _initialsOf(send.recipientName),
                  size: 64,
                ),
                const SizedBox(height: KSpace.sm),
                Text(send.recipientName,
                    style: text.titleMedium?.copyWith(fontSize: 18)),
                if (match?.accountRef != null)
                  Text(match!.accountRef,
                      style: text.bodySmall?.copyWith(color: p.inkMuted)),
              ],
            ),
          ),
          const SizedBox(height: KSpace.lg),
          InfoRowsCard(
            rows: [
              InfoRow('You send', quote.amountLabel),
              InfoRow('Fee', quote.feeLabel, valueColor: p.success),
              InfoRow('They receive', quote.receiveLabel),
              InfoRow('Total to pay', quote.amountLabel, emphasize: true),
            ],
          ),
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            padding:
                const EdgeInsets.symmetric(horizontal: KSpace.md, vertical: KSpace.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Note', style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                Text('For groceries this month', style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Contact? _matchContact(List<Contact> contacts, String name) {
  for (final c in contacts) {
    if (c.name == name) return c;
  }
  return null;
}

String _initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}
