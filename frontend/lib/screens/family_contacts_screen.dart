import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/contacts_controller.dart';
import '../state/send_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Kontak keluarga: favorit di atas, sisanya di bawah. Ketuk kartu untuk
/// prefill alur kirim; bintang trailing toggle favorit tanpa membuka
/// apa pun. "Tambah kontak" membuka sheet form singkat.
class FamilyContactsScreen extends ConsumerWidget {
  const FamilyContactsScreen({super.key});

  void _sendTo(BuildContext context, WidgetRef ref, Contact contact) {
    final n = ref.read(sendControllerProvider.notifier);
    n.reset();
    n.setRecipient(contact.name);
    context.goNamed(Routes.sendAmount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsControllerProvider);
    final favorites = contacts.where((c) => c.isFavorite).toList();
    final others = contacts.where((c) => !c.isFavorite).toList();
    final text = Theme.of(context).textTheme;
    final p = KColors.of(Theme.of(context).brightness);

    return AppScaffold(
      title: 'Keluarga',
      bottom: PrimaryPillButton(
        label: 'Tambah kontak',
        onPressed: () => _showAddContactSheet(context, ref),
      ),
      child: contacts.isEmpty
          ? const EmptyView(
              icon: Icons.group_outlined,
              title: 'Belum ada kontak',
              subtitle: 'Tambahkan keluarga yang sering kamu kirimi.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: KSpace.md),
                if (favorites.isNotEmpty) ...[
                  Text('FAVORIT',
                      style: text.labelSmall?.copyWith(color: p.inkMuted)),
                  const SizedBox(height: KSpace.xs),
                  for (final c in favorites)
                    _ContactListTile(
                      contact: c,
                      onTap: () => _sendTo(context, ref, c),
                    ),
                  const SizedBox(height: KSpace.lg),
                ],
                if (others.isNotEmpty) ...[
                  Text('SEMUA KONTAK',
                      style: text.labelSmall?.copyWith(color: p.inkMuted)),
                  const SizedBox(height: KSpace.xs),
                  for (final c in others)
                    _ContactListTile(
                      contact: c,
                      onTap: () => _sendTo(context, ref, c),
                    ),
                ],
              ],
            ),
    );
  }
}

/// Satu baris kontak: avatar + nama/relasi tappable ke kirim, bintang
/// trailing toggle favorit secara independen dari tap baris.
class _ContactListTile extends ConsumerWidget {
  final Contact contact;
  final VoidCallback onTap;
  const _ContactListTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: MonogramAvatar(initials: contact.initials),
      title: Text(contact.name, style: text.bodyLarge),
      subtitle: Text('${contact.relation} · ${contact.accountRef}',
          style: text.bodySmall?.copyWith(color: p.inkMuted)),
      onTap: onTap,
      trailing: IconButton(
        onPressed: () => ref
            .read(contactsControllerProvider.notifier)
            .toggleFavorite(contact.id),
        icon: Icon(
          contact.isFavorite ? Icons.star : Icons.star_border,
          color: contact.isFavorite ? p.accent : p.inkMuted,
        ),
      ),
    );
  }
}

Future<void> _showAddContactSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _AddContactSheet(),
  );
}

/// Form tambah kontak: nama, hubungan, nomor rekening. State lokal murni
/// controller teks — disimpan lewat [contactsControllerProvider] hanya saat
/// "Simpan" ditekan.
class _AddContactSheet extends ConsumerStatefulWidget {
  const _AddContactSheet();

  @override
  ConsumerState<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends ConsumerState<_AddContactSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _relationCtrl;
  late final TextEditingController _accountCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _relationCtrl = TextEditingController();
    _accountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    ref.read(contactsControllerProvider.notifier).addContact(
          name: name,
          relation: _relationCtrl.text.trim(),
          accountRef: _accountCtrl.text.trim(),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          KSpace.lg,
          KSpace.lg,
          KSpace.lg,
          KSpace.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah kontak', style: text.titleMedium),
            const SizedBox(height: KSpace.md),
            Text('Nama', style: text.labelSmall?.copyWith(color: p.inkMuted)),
            const SizedBox(height: KSpace.xs),
            TextField(controller: _nameCtrl, style: text.bodyLarge),
            const SizedBox(height: KSpace.sm),
            Text('Hubungan', style: text.labelSmall?.copyWith(color: p.inkMuted)),
            const SizedBox(height: KSpace.xs),
            TextField(
              controller: _relationCtrl,
              style: text.bodyLarge,
              decoration: const InputDecoration(hintText: 'Ibu/Adik/Ayah'),
            ),
            const SizedBox(height: KSpace.sm),
            Text('Nomor rekening', style: text.labelSmall?.copyWith(color: p.inkMuted)),
            const SizedBox(height: KSpace.xs),
            TextField(
              controller: _accountCtrl,
              style: text.bodyLarge,
              decoration: const InputDecoration(hintText: '•••• 1234'),
            ),
            const SizedBox(height: KSpace.lg),
            PrimaryPillButton(label: 'Simpan', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
