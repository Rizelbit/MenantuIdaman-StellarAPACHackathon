import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/request_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Step 2/3 of the request flow: a summary before the request goes out. No
/// Face ID here — unlike the send flow — because requesting moves no funds.
class RequestConfirmScreen extends ConsumerWidget {
  const RequestConfirmScreen({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final failure = await ref.read(requestControllerProvider.notifier).submit();
    if (!context.mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
      return;
    }
    context.pushNamed(Routes.requestSent);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(requestControllerProvider);
    final contact = state.fromContact;
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    if (contact == null) {
      return const AppScaffold(
        title: 'Confirm request',
        child: EmptyView(
          icon: Icons.request_page_outlined,
          title: 'Nothing to request yet',
          subtitle: 'Go back to pick a contact and amount first.',
        ),
      );
    }

    return AppScaffold(
      title: 'Confirm request',
      scrollable: false,
      bottom: PrimaryPillButton(
        label: 'Send request',
        onPressed: () => _submit(context, ref),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You're requesting",
                style: text.bodyMedium?.copyWith(color: p.inkMuted)),
            const SizedBox(height: KSpace.sm),
            MoneyText(amountIdr: state.amountIdr, size: 44),
            const SizedBox(height: KSpace.lg),
            _FromPill(contact: contact),
            if (state.note.trim().isNotEmpty) ...[
              const SizedBox(height: KSpace.lg),
              _NoteBubble(note: state.note),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rounded "from [avatar] Name" pill under the amount.
class _FromPill extends StatelessWidget {
  final Contact contact;
  const _FromPill({required this.contact});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: BorderRadius.circular(KRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('from', style: text.bodySmall?.copyWith(color: p.inkMuted)),
          const SizedBox(width: KSpace.xs),
          MonogramAvatar(initials: contact.initials, size: 32),
          const SizedBox(width: KSpace.xs),
          Text(contact.name,
              style: text.bodySmall?.copyWith(color: p.ink)),
        ],
      ),
    );
  }
}

/// Quoted note bubble.
class _NoteBubble extends StatelessWidget {
  final String note;
  const _NoteBubble({required this.note});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('"$note"',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: p.ink)),
    );
  }
}
