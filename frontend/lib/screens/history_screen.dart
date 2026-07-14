import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/home_feed.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Riwayat — seluruh [HomeFeed.recentTransactions], dikelompokkan per hari:
/// "Hari ini", "Minggu ini" (7 hari terakhir, bukan hari ini), lalu
/// "Sebelumnya". Grup tanpa transaksi tidak ditampilkan (tanpa header
/// kosong). Data & error state mengikuti pola `homeFeedProvider` yang sama
/// dengan Home — gagal muat tampil dengan tombol coba lagi yang
/// meng-invalidate provider.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider);

    return feed.when(
      data: (data) => AppScaffold(
        title: 'Riwayat',
        scrollable: false,
        child: _HistoryList(transactions: data.recentTransactions),
      ),
      loading: () => const AppScaffold(
        title: 'Riwayat',
        scrollable: false,
        child: LoadingView(),
      ),
      error: (error, stack) => AppScaffold(
        title: 'Riwayat',
        scrollable: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyView(
                icon: Icons.error_outline,
                title: 'Gagal memuat riwayat',
                subtitle: 'Periksa koneksi lalu coba lagi.',
              ),
              const SizedBox(height: KSpace.md),
              SecondaryPillButton(
                label: 'Coba lagi',
                onPressed: () => ref.invalidate(homeFeedProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daftar transaksi dikelompokkan per hari, atau [EmptyView] bila kosong.
class _HistoryList extends StatelessWidget {
  final List<AppTransaction> transactions;
  const _HistoryList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyView(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada transaksi',
        subtitle: 'Riwayat kirimanmu akan muncul di sini.',
      );
    }

    final groups = _groupByDay(transactions);

    return ListView(
      children: [
        for (final group in groups) ...[
          _SectionHeader(label: group.label),
          for (final tx in group.transactions)
            TransactionRow(
              avatarInitials:
                  tx.direction == TxDirection.split ? null : _initialsOf(tx.counterpartyName),
              icon: tx.direction == TxDirection.split ? Icons.call_split : null,
              title: tx.counterpartyName,
              subtitle: '${_directionLabel(tx.direction)} · ${_relativeTime(tx.createdAt)}',
              amountIdr: tx.amountIdr,
              direction: tx.direction,
              failed: tx.status == TxStatus.failed,
              onTap: () =>
                  context.goNamed(Routes.txDetail, pathParameters: {'id': tx.id}),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: KSpace.lg, bottom: KSpace.xs),
      child: Text(label, style: text.labelSmall?.copyWith(color: p.inkMuted)),
    );
  }
}

class _DayGroup {
  final String label;
  final List<AppTransaction> transactions;
  const _DayGroup(this.label, this.transactions);
}

/// Mengelompokkan [transactions] ke "Hari ini" / "Minggu ini" / "Sebelumnya"
/// berdasarkan tanggal kalender `createdAt` (bukan jarak 24 jam), lalu
/// mengurutkan tiap grup terbaru-lebih-dulu. Grup kosong dibuang dari hasil.
List<_DayGroup> _groupByDay(List<AppTransaction> transactions) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekAgo = today.subtract(const Duration(days: 7));

  final todayTx = <AppTransaction>[];
  final weekTx = <AppTransaction>[];
  final olderTx = <AppTransaction>[];

  for (final tx in transactions) {
    final day = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
    if (day == today) {
      todayTx.add(tx);
    } else if (!day.isBefore(weekAgo)) {
      weekTx.add(tx);
    } else {
      olderTx.add(tx);
    }
  }

  int byNewest(AppTransaction a, AppTransaction b) => b.createdAt.compareTo(a.createdAt);
  todayTx.sort(byNewest);
  weekTx.sort(byNewest);
  olderTx.sort(byNewest);

  return [
    if (todayTx.isNotEmpty) _DayGroup('Hari ini', todayTx),
    if (weekTx.isNotEmpty) _DayGroup('Minggu ini', weekTx),
    if (olderTx.isNotEmpty) _DayGroup('Sebelumnya', olderTx),
  ];
}

String _directionLabel(TxDirection direction) {
  switch (direction) {
    case TxDirection.send:
      return 'Terkirim';
    case TxDirection.receive:
      return 'Diterima';
    case TxDirection.split:
      return 'Split';
  }
}

/// "HH:mm" untuk transaksi hari ini; selain itu "d MMM" lokal id.
String _relativeTime(DateTime createdAt) {
  final now = DateTime.now();
  final sameDay =
      now.year == createdAt.year && now.month == createdAt.month && now.day == createdAt.day;
  return sameDay
      ? DateFormat('HH:mm', 'id').format(createdAt)
      : DateFormat('d MMM', 'id').format(createdAt);
}

/// Dua huruf pertama nama, huruf besar — inisial avatar lawan transaksi.
String _initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
}
