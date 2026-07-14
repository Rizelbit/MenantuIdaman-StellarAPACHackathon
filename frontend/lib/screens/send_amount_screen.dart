import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/contacts_controller.dart';
import '../state/send_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 1/3 alur kirim: pilih penerima dari kontak favorit lalu ketik
/// nominal lewat keypad numerik. String digit yang tampil diturunkan
/// langsung dari `send.amountIdr` (bukan state lokal terpisah), sehingga
/// tidak ada dua sumber kebenaran untuk nominal yang sedang diketik.
class SendAmountScreen extends ConsumerWidget {
  const SendAmountScreen({super.key});

  Future<void> _pickRecipient(BuildContext context, WidgetRef ref) async {
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
                Text('Pilih penerima', style: text.titleMedium),
                const SizedBox(height: KSpace.md),
                if (favorites.isEmpty)
                  const EmptyView(
                    icon: Icons.person_outline,
                    title: 'Belum ada kontak favorit',
                    subtitle:
                        'Tambahkan kontak favorit dulu untuk kirim cepat.',
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
      ref.read(sendControllerProvider.notifier).setRecipient(chosen.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.watch(sendControllerProvider);
    final ctrl = ref.read(sendControllerProvider.notifier);
    final contacts = ref.watch(contactsControllerProvider);
    final match = _matchContact(contacts, send.recipientName);
    final hasRecipient = send.recipientName.trim().isNotEmpty;
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    void onKey(String digit) =>
        ctrl.setAmount(double.parse(_digitsOf(send.amountIdr) + digit));

    void onBackspace() {
      final current = _digitsOf(send.amountIdr);
      if (current.isEmpty) return;
      final next = current.substring(0, current.length - 1);
      ctrl.setAmount(next.isEmpty ? 0 : double.parse(next));
    }

    void onReview() {
      ctrl.goToReview();
      if (ref.read(sendControllerProvider).phase == SendPhase.review) {
        context.pushNamed(Routes.sendReview);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih penerima dan nominal dulu')),
        );
      }
    }

    return AppScaffold(
      title: 'Kirim',
      bottom: PrimaryPillButton(label: 'Tinjau', onPressed: onReview),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            onTap: () => _pickRecipient(context, ref),
            child: Row(
              children: [
                MonogramAvatar(
                    initials: hasRecipient
                        ? (match?.initials ?? _initialsOf(send.recipientName))
                        : '?'),
                const SizedBox(width: KSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          hasRecipient
                              ? send.recipientName
                              : 'Pilih penerima',
                          style: text.bodyLarge),
                      Text(
                        hasRecipient
                            ? 'Kirimin · ${match?.accountRef ?? '—'}'
                            : 'Ketuk untuk pilih dari kontak favorit',
                        style: text.bodySmall?.copyWith(color: p.inkMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _pickRecipient(context, ref),
                  child: const Text('Ubah'),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpace.xl),
          Text('Nominal kirim',
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.xs),
          Center(child: MoneyText(amountIdr: send.amountIdr, size: 44)),
          const SizedBox(height: KSpace.xs),
          Center(
            child: Text('Tanpa biaya admin',
                style: text.bodySmall?.copyWith(color: p.inkMuted)),
          ),
          const SizedBox(height: KSpace.xl),
          AmountKeypad(onKey: onKey, onBackspace: onBackspace),
        ],
      ),
    );
  }
}

/// Turunkan string digit nominal dari [amountIdr] tanpa state lokal terpisah
/// — nominal selalu bilangan bulat rupiah sehingga konversi ini reversibel.
String _digitsOf(double amountIdr) =>
    amountIdr <= 0 ? '' : amountIdr.toStringAsFixed(0);

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
