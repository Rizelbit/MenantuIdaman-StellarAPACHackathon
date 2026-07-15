import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../core/money.dart';
import '../models/models.dart';
import '../state/split_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 2/4 alur split tagihan: bagi rata atau atur nominal manual per
/// peserta, lalu validasi apakah alokasi sudah pas dengan total.
class SplitSharesScreen extends ConsumerStatefulWidget {
  const SplitSharesScreen({super.key});

  @override
  ConsumerState<SplitSharesScreen> createState() => _SplitSharesScreenState();
}

class _SplitSharesScreenState extends ConsumerState<SplitSharesScreen> {
  // Controller per peserta, key = contactId. Dipakai HANYA saat splitEvenly
  // false (input manual) — saat rata, nominal ditampilkan read-only dari
  // state langsung. Di-dispose & dibangun ulang tiap kali toggle rata/manual
  // berubah supaya teks selalu mulai dari nominal terkini (bukan sisa input
  // manual lama yang mungkin sudah basi).
  final Map<String, TextEditingController> _shareCtrls = {};
  bool? _lastSplitEvenly;

  TextEditingController _controllerFor(SplitParticipant participant) {
    return _shareCtrls.putIfAbsent(
      participant.contactId,
      () => TextEditingController(
          text: participant.shareIdr > 0
              ? participant.shareIdr.toStringAsFixed(0)
              : ''),
    );
  }

  void _resetControllersIfToggled(bool splitEvenly) {
    if (_lastSplitEvenly == splitEvenly) return;
    _lastSplitEvenly = splitEvenly;
    for (final c in _shareCtrls.values) {
      c.dispose();
    }
    _shareCtrls.clear();
  }

  @override
  void dispose() {
    for (final c in _shareCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splitControllerProvider);
    final ctrl = ref.read(splitControllerProvider.notifier);
    _resetControllersIfToggled(state.splitEvenly);

    return AppScaffold(
      title: 'Siapa bayar berapa',
      bottom: PrimaryPillButton(
        label: 'Lanjut',
        onPressed:
            state.isBalanced ? () => context.pushNamed(Routes.splitConfirm) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.md),
          _SplitEvenlyToggle(
            value: state.splitEvenly,
            onChanged: ctrl.setSplitEvenly,
          ),
          const SizedBox(height: KSpace.md),
          for (final participant in state.participants)
            Padding(
              padding: const EdgeInsets.only(bottom: KSpace.sm),
              child: _ShareRow(
                participant: participant,
                splitEvenly: state.splitEvenly,
                controller: _controllerFor(participant),
                onChanged: (value) {
                  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                  ctrl.setShare(
                      participant.contactId, digits.isEmpty ? 0 : double.parse(digits));
                },
              ),
            ),
          const SizedBox(height: KSpace.md),
          _BalanceValidator(
            assignedIdr: state.assignedIdr,
            totalIdr: state.totalIdr,
            isBalanced: state.isBalanced,
          ),
        ],
      ),
    );
  }
}

/// Toggle "Bagi rata" — saat aktif, [SplitController] menghitung ulang
/// nominal tiap peserta otomatis.
class _SplitEvenlyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SplitEvenlyToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Bagi rata', style: text.bodyLarge),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// Satu baris peserta: avatar + nama, lalu nominal read-only (rata) atau
/// [TextField] manual editable (tidak rata).
class _ShareRow extends StatelessWidget {
  final SplitParticipant participant;
  final bool splitEvenly;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ShareRow({
    required this.participant,
    required this.splitEvenly,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SurfaceCard(
      padding:
          const EdgeInsets.symmetric(horizontal: KSpace.md, vertical: KSpace.sm),
      child: Row(
        children: [
          MonogramAvatar(initials: _initialsOf(participant.name), size: KSize.avatarSm),
          const SizedBox(width: KSpace.sm),
          Expanded(child: Text(participant.name, style: text.bodyLarge)),
          if (splitEvenly)
            Text(formatMoney(participant.shareIdr, Currency.idr),
                style: text.bodyLarge)
          else
            SizedBox(
              width: 140,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.right,
                style: text.bodyLarge,
                decoration:
                    const InputDecoration(prefixText: 'Rp ', isDense: true),
                onChanged: onChanged,
              ),
            ),
        ],
      ),
    );
  }
}

/// Baris validasi: total sudah dialokasikan vs total tagihan, dengan warna
/// semantik (sukses/danger) sesuai [isBalanced].
class _BalanceValidator extends StatelessWidget {
  final double assignedIdr;
  final double totalIdr;
  final bool isBalanced;

  const _BalanceValidator({
    required this.assignedIdr,
    required this.totalIdr,
    required this.isBalanced,
  });

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final color = isBalanced ? p.success : p.danger;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(isBalanced ? Icons.check_circle : Icons.error_outline,
            size: 18, color: color),
        const SizedBox(width: KSpace.xs),
        Expanded(
          child: Text(
            '${formatMoney(assignedIdr, Currency.idr)} dari '
            '${formatMoney(totalIdr, Currency.idr)}. '
            '${isBalanced ? 'Sudah pas!' : 'Belum pas'}',
            style: text.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Dua huruf pertama nama, huruf besar — inisial avatar peserta.
String _initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
}
