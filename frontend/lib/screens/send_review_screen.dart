import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/contacts_controller.dart';
import '../state/send_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 2/3 alur kirim: rincian biaya transparan sebelum konfirmasi Face ID.
/// Karena `Env.feeRate == 0` di demo ini, "mereka terima" selalu sama dengan
/// "kamu kirim" — baris biaya tetap ditampilkan agar transparansi terlihat.
class SendReviewScreen extends ConsumerWidget {
  const SendReviewScreen({super.key});

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final send = ref.read(sendControllerProvider);
    final quote = send.quote;
    if (quote == null) return;

    final ok = await showBiometricConfirmSheet(
      context,
      headline: 'Kirim ${quote.amountLabel}?',
      subline: '${send.recipientName} akan menerima ${quote.receiveLabel}.',
      confirmLabel: 'Tahan untuk konfirmasi',
    );
    if (!ok || !context.mounted) return;

    await ref.read(sendControllerProvider.notifier).confirmAndSend();
    if (!context.mounted) return;

    final state = ref.read(sendControllerProvider);
    if (state.phase == SendPhase.success) {
      context.pushNamed(Routes.sendSuccess);
    } else if (state.phase == SendPhase.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Gagal mengirim.')),
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
        title: 'Tinjau',
        child: EmptyView(
          icon: Icons.receipt_long_outlined,
          title: 'Belum ada rincian kiriman',
          subtitle: 'Kembali ke layar sebelumnya untuk isi nominal dulu.',
        ),
      );
    }

    return AppScaffold(
      title: 'Tinjau',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Cukup satu Face ID',
              style: text.bodySmall?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.sm),
          PrimaryPillButton(
            label: 'Tahan untuk konfirmasi',
            icon: Icons.fingerprint,
            loading: busy,
            onPressed: busy ? null : () => _confirm(context, ref),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            child: Row(
              children: [
                MonogramAvatar(
                    initials:
                        match?.initials ?? _initialsOf(send.recipientName)),
                const SizedBox(width: KSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(send.recipientName, style: text.bodyLarge),
                      Text(match?.accountRef ?? '—',
                          style: text.bodySmall?.copyWith(color: p.inkMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            child: Column(
              children: [
                _FeeRow(label: 'Kamu kirim', value: quote.amountLabel),
                const SizedBox(height: KSpace.sm),
                _FeeRow(label: 'Biaya', value: quote.feeLabel),
                const SizedBox(height: KSpace.sm),
                _FeeRow(label: 'Mereka terima', value: quote.receiveLabel),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: KSpace.sm),
                  child: Divider(color: p.hairline, height: 1),
                ),
                _FeeRow(
                    label: 'Total bayar', value: quote.amountLabel, bold: true),
              ],
            ),
          ),
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Catatan', style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                Text('Buat kebutuhan keluarga', style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _FeeRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final labelStyle = text.bodyMedium?.copyWith(
      color: bold ? p.ink : p.inkMuted,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    final valueStyle = text.bodyMedium?.copyWith(
      color: p.ink,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
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
