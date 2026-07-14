import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../state/contacts_controller.dart';
import '../state/split_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 1/4 alur split tagihan: nominal total, judul, dan peserta. Nominal &
/// judul pakai [TextEditingController] lokal (pola sama seperti
/// RequestAmountScreen) — controller cuma MENULIS ke splitControllerProvider,
/// provider tidak pernah menulis balik ke controller.
class SplitCreateScreen extends ConsumerStatefulWidget {
  const SplitCreateScreen({super.key});

  @override
  ConsumerState<SplitCreateScreen> createState() => _SplitCreateScreenState();
}

class _SplitCreateScreenState extends ConsumerState<SplitCreateScreen> {
  late final TextEditingController _totalCtrl;
  late final TextEditingController _titleCtrl;

  @override
  void initState() {
    super.initState();
    final state = ref.read(splitControllerProvider);
    _totalCtrl = TextEditingController(
        text: state.totalIdr > 0 ? state.totalIdr.toStringAsFixed(0) : '');
    _titleCtrl = TextEditingController(text: state.title);
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  void _onLanjut(BuildContext context, WidgetRef ref) {
    final state = ref.read(splitControllerProvider);
    if (state.totalIdr > 0 && state.participants.length >= 2) {
      context.goNamed(Routes.splitShares);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi total dan pilih peserta dulu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(splitControllerProvider.notifier);
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Split tagihan',
      bottom: PrimaryPillButton(
        label: 'Lanjut',
        onPressed: () => _onLanjut(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.md),
          _TotalAmountField(controller: _totalCtrl, onChanged: ctrl.setTotal),
          const SizedBox(height: KSpace.lg),
          _TitleField(controller: _titleCtrl, onChanged: ctrl.setTitle),
          const SizedBox(height: KSpace.lg),
          Text('Bagi dengan', style: text.labelSmall?.copyWith(color: p.inkMuted)),
          const SizedBox(height: KSpace.xs),
          const _ParticipantPicker(),
        ],
      ),
    );
  }
}

/// Nominal total tagihan (angka mentah, prefix "Rp ").
class _TotalAmountField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double> onChanged;
  const _TotalAmountField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total tagihan', style: text.labelSmall?.copyWith(color: p.inkMuted)),
        const SizedBox(height: KSpace.xs),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: text.bodyLarge,
          decoration: const InputDecoration(prefixText: 'Rp '),
          onChanged: (value) {
            final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
            onChanged(digits.isEmpty ? 0 : double.parse(digits));
          },
        ),
      ],
    );
  }
}

/// Judul tagihan (mis. "Listrik, Juli 2026").
class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _TitleField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Untuk apa?', style: text.labelSmall?.copyWith(color: p.inkMuted)),
        const SizedBox(height: KSpace.xs),
        TextField(
          controller: controller,
          style: text.bodyLarge,
          decoration: const InputDecoration(hintText: 'Listrik, Juli 2026'),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Baris horizontal peserta yang sudah dipilih + tombol "+ Tambah" yang
/// membuka bottom sheet daftar kontak. Sheet-nya sendiri [Consumer] agar
/// selalu menonton [contactsControllerProvider] (daftar kontak dimuat async)
/// — bukan snapshot sekali-jalan — sehingga kontak yang baru dimuat tetap
/// muncul kalau sheet dibuka sebelum load selesai.
class _ParticipantPicker extends ConsumerWidget {
  const _ParticipantPicker();

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final contacts = ref.watch(contactsControllerProvider);
          final participantIds =
              ref.watch(splitControllerProvider).participants.map((p) => p.contactId).toSet();
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
                  Text('Bagi dengan', style: text.titleMedium),
                  const SizedBox(height: KSpace.md),
                  if (contacts.isEmpty)
                    const EmptyView(
                      icon: Icons.person_outline,
                      title: 'Belum ada kontak',
                      subtitle: 'Tambahkan kontak dulu untuk mengajak split.',
                    )
                  else
                    for (final c in contacts)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: MonogramAvatar(initials: c.initials),
                        title: Text(c.name, style: text.bodyLarge),
                        subtitle: Text(c.relation,
                            style: text.bodySmall?.copyWith(color: p.inkMuted)),
                        // Indikasi pilih pakai ikon centang trailing — BUKAN
                        // ring avatar yang membesar — supaya tidak ada layout
                        // jump saat toggle.
                        trailing: participantIds.contains(c.id)
                            ? Icon(Icons.check_circle, color: p.accent)
                            : null,
                        onTap: () => ref
                            .read(splitControllerProvider.notifier)
                            .toggleParticipant(c),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants =
        ref.watch(splitControllerProvider.select((s) => s.participants));
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final participant in participants)
            Padding(
              padding: const EdgeInsets.only(right: KSpace.md),
              child: SizedBox(
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MonogramAvatar(initials: _initialsOf(participant.name)),
                    const SizedBox(height: KSpace.xs),
                    Text(
                      participant.name,
                      style: text.labelSmall?.copyWith(color: p.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () => _openPicker(context),
            borderRadius: BorderRadius.circular(KRadius.md),
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: p.hairline),
                    ),
                    child: Icon(Icons.add, size: 20, color: p.ink),
                  ),
                  const SizedBox(height: KSpace.xs),
                  Text('Tambah', style: text.labelSmall?.copyWith(color: p.ink)),
                ],
              ),
            ),
          ),
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
