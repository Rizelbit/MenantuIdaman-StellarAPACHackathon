import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/router.dart';
import '../core/money.dart';
import '../models/models.dart';
import '../state/home_feed.dart';
import '../state/send_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Cari elemen list berdasarkan id — pengganti ringan untuk lookup satuan
/// pada data [HomeFeed] yang sudah termuat (tanpa `package:collection`).
T? _firstById<T>(List<T> list, String id, String Function(T) idOf) {
  for (final e in list) {
    if (idOf(e) == id) return e;
  }
  return null;
}

/// Detail satu transaksi, dibuka dari Home/History lewat `/tx/:id`. Datanya
/// diambil dari [homeFeedProvider] yang sudah termuat (bukan fetch terpisah)
/// — kalau feed belum siap (deep-link dingin) atau id tidak ketemu, tampil
/// state tidak ditemukan alih-alih layar kosong.
class TransactionDetailScreen extends ConsumerWidget {
  final String id;
  const TransactionDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider).value;
    final tx =
        feed == null ? null : _firstById(feed.recentTransactions, id, (t) => t.id);

    if (tx == null) {
      return const AppScaffold(
        title: 'Transaksi',
        child: EmptyView(
          icon: Icons.error_outline,
          title: 'Transaksi tidak ditemukan',
          subtitle: 'Coba buka dari daftar riwayat.',
        ),
      );
    }

    return AppScaffold(
      title: 'Transaksi',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryPillButton(
            label: 'Kirim lagi',
            onPressed: () {
              final n = ref.read(sendControllerProvider.notifier);
              n.reset();
              n.setRecipient(tx.counterpartyName);
              context.pushNamed(Routes.sendAmount);
            },
          ),
          const SizedBox(height: KSpace.sm),
          SecondaryPillButton(
            label: 'Bagikan bukti',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bukti disalin')),
            ),
          ),
        ],
      ),
      child: _TransactionDetailBody(tx: tx),
    );
  }
}

class _TransactionDetailBody extends StatelessWidget {
  final AppTransaction tx;
  const _TransactionDetailBody({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: KSpace.lg),
        _AmountHeader(tx: tx),
        const SizedBox(height: KSpace.sm),
        Center(child: _statusChipFor(tx)),
        const SizedBox(height: KSpace.xl),
        _DetailRows(tx: tx),
      ],
    );
  }
}

/// Avatar (atau lingkaran ikon split) + nominal bertanda besar di tengah.
class _AmountHeader extends StatelessWidget {
  final AppTransaction tx;
  const _AmountHeader({required this.tx});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final isReceive = tx.direction == TxDirection.receive;
    final sign = isReceive ? '+ ' : '− ';
    final amountColor = tx.status == TxStatus.failed
        ? p.danger
        : (isReceive ? p.success : p.ink);

    return Column(
      children: [
        tx.direction == TxDirection.split
            ? Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: p.surface1, shape: BoxShape.circle),
                child: Icon(Icons.call_split, size: 24, color: p.ink),
              )
            : MonogramAvatar(initials: _initialsOf(tx.counterpartyName), size: 56),
        const SizedBox(height: KSpace.md),
        Text(
          '$sign${formatMoney(tx.amountIdr, Currency.idr)}',
          style: text.headlineLarge?.copyWith(color: amountColor),
        ),
      ],
    );
  }
}

StatusChip _statusChipFor(AppTransaction tx) {
  switch (tx.status) {
    case TxStatus.settled:
      final label = tx.direction == TxDirection.receive
          ? 'Diterima'
          : tx.direction == TxDirection.split
              ? 'Split'
              : 'Terkirim';
      return StatusChip.success(label);
    case TxStatus.pending:
      return const StatusChip.info('Menunggu');
    case TxStatus.failed:
      return const StatusChip.danger('Gagal');
  }
}

/// Kartu rincian: lawan transaksi, tanggal, biaya, referensi, dan catatan
/// (kalau ada) — label inkMuted di kiri, nilai ink di kanan.
class _DetailRows extends StatelessWidget {
  final AppTransaction tx;
  const _DetailRows({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isReceive = tx.direction == TxDirection.receive;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailRow(label: isReceive ? 'Dari' : 'Ke', value: tx.counterpartyName),
          const SizedBox(height: KSpace.sm),
          _DetailRow(
            label: 'Tanggal',
            value: DateFormat('d MMM yyyy · HH:mm', 'id').format(tx.createdAt),
          ),
          const SizedBox(height: KSpace.sm),
          const _DetailRow(label: 'Biaya', value: 'Rp 0'),
          const SizedBox(height: KSpace.sm),
          _DetailRow(label: 'Referensi', value: tx.reference ?? 'KRM-8F2A091'),
          if (tx.note != null) ...[
            const SizedBox(height: KSpace.sm),
            _DetailRow(label: 'Catatan', value: tx.note!),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: text.bodyMedium?.copyWith(color: p.inkMuted)),
        const SizedBox(width: KSpace.md),
        Expanded(
          child: Text(
            value,
            style: text.bodyMedium?.copyWith(color: p.ink),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Dua huruf pertama nama, huruf besar — inisial avatar lawan transaksi.
String _initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
}
