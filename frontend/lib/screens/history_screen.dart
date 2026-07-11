import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// POLA SIAP-ISI. MVP menampilkan daftar dari state sesi. Ganti sumber data ke
/// endpoint /wallet/:id/history bila backend menyediakannya (opsional/indexing).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MVP: kosong sampai ada indexing/riwayat backend.
    const List<AppTransaction> items = [];

    return AppScaffold(
      title: 'Riwayat',
      leading: BackButton(onPressed: () => context.goNamed(Routes.home)),
      scrollable: false,
      child: items.isEmpty
          ? const EmptyView(
              icon: Icons.history,
              title: 'Belum ada transaksi',
              subtitle: 'Kiriman pertamamu akan muncul di sini.',
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) => TransactionTile(tx: items[i]),
            ),
    );
  }
}
