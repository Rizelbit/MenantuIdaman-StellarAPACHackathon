import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/contacts_controller.dart';
import '../state/request_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 1/3 alur minta: pilih siapa yang diminta, nominal, dan catatan
/// opsional. Nominal & catatan pakai [TextEditingController] lokal — bukan
/// dibaca balik dari `requestControllerProvider` — supaya user bebas mengetik
/// tanpa perang kursor dengan reformat state. Controller cuma MENULIS ke
/// provider; provider tidak pernah menulis balik ke controller.
class RequestAmountScreen extends ConsumerStatefulWidget {
  const RequestAmountScreen({super.key});

  @override
  ConsumerState<RequestAmountScreen> createState() =>
      _RequestAmountScreenState();
}

class _RequestAmountScreenState extends ConsumerState<RequestAmountScreen> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final state = ref.read(requestControllerProvider);
    _amountCtrl = TextEditingController(
        text: state.amountIdr > 0 ? state.amountIdr.toStringAsFixed(0) : '');
    _noteCtrl = TextEditingController(text: state.note);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickContact(BuildContext context, WidgetRef ref) async {
    final favorites =
        ref.read(contactsControllerProvider.notifier).favoriteContacts;
    final chosen = await showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final p = KColors.of(Theme.of(ctx).brightness);
        final text = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                KSpace.lg, KSpace.lg, KSpace.lg, KSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose contact', style: text.titleMedium),
                const SizedBox(height: KSpace.md),
                if (favorites.isEmpty)
                  const EmptyView(
                    icon: Icons.person_outline,
                    title: 'No favorites yet',
                    subtitle: 'Add a favorite contact for quick requests.',
                  )
                else
                  for (final c in favorites)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: MonogramAvatar(initials: c.initials),
                      title: Text(c.name, style: text.bodyLarge),
                      subtitle: Text('${c.relation} · ${c.accountRef}',
                          style: text.bodySmall?.copyWith(color: p.inkMuted)),
                      onTap: () => Navigator.pop(ctx, c),
                    ),
              ],
            ),
          ),
        );
      },
    );
    if (chosen != null) {
      ref.read(requestControllerProvider.notifier).setContact(chosen);
    }
  }

  void _onLanjut(BuildContext context, WidgetRef ref) {
    final state = ref.read(requestControllerProvider);
    if (state.fromContact != null && state.amountIdr > 0) {
      context.pushNamed(Routes.requestConfirm);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a contact and amount first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestControllerProvider);
    final ctrl = ref.read(requestControllerProvider.notifier);
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final contact = state.fromContact;

    return AppScaffold(
      title: 'Request',
      bottom: PrimaryPillButton(
        label: 'Continue',
        onPressed: () => _onLanjut(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.md),
          Text('From', style: text.titleMedium?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.xs),
          SurfaceCard(
            onTap: () => _pickContact(context, ref),
            child: Row(
              children: [
                MonogramAvatar(initials: contact?.initials ?? '?'),
                const SizedBox(width: KSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact?.name ?? 'Choose contact',
                          style: text.bodyLarge),
                      Text(
                        contact != null
                            ? contact.accountRef
                            : 'Tap to pick a favorite',
                        style: text.bodySmall?.copyWith(color: p.inkMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _pickContact(context, ref),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpace.lg),
          Text('Amount', style: text.titleMedium?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.xs),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: text.bodyLarge,
            decoration: const InputDecoration(prefixText: 'Rp '),
            onChanged: (value) {
              final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
              ctrl.setAmount(digits.isEmpty ? 0 : double.parse(digits));
            },
          ),
          const SizedBox(height: KSpace.lg),
          Text('Note', style: text.titleMedium?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.xs),
          TextField(
            controller: _noteCtrl,
            style: text.bodyLarge,
            decoration: const InputDecoration(hintText: 'For school books'),
            onChanged: ctrl.setNote,
          ),
        ],
      ),
    );
  }
}
