import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/home_feed.dart';
import '../state/send_controller.dart';
import '../state/split_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Home — layar showcase: saldo, promo, aksi cepat, kontak favorit, dan
/// aktivitas terbaru, top ke bawah. Semua data dari [homeFeedProvider]; error
/// tampil sebagai state dengan tombol coba lagi yang meng-invalidate provider.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Toggle privasi saldo — state lokal murni tampilan, tidak memengaruhi data.
  bool _hiddenBalance = false;

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);

    return feed.when(
      data: (data) => AppScaffold(child: _buildContent(context, data)),
      loading: () => const AppScaffold(scrollable: false, child: LoadingView()),
      error: (error, stack) => AppScaffold(
        scrollable: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyView(
                icon: Icons.error_outline,
                title: 'Gagal memuat beranda',
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

  Widget _buildContent(BuildContext context, HomeFeed feed) {
    void goSend() {
      ref.read(sendControllerProvider.notifier).reset();
      context.pushNamed(Routes.sendAmount);
    }

    void sendTo(Contact contact) {
      final notifier = ref.read(sendControllerProvider.notifier);
      notifier.reset();
      notifier.setRecipient(contact.name);
      context.pushNamed(Routes.sendAmount);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: KSpace.lg),
        _Header(greetingName: feed.greetingName),
        const SizedBox(height: KSpace.xl),
        _BalanceHero(
          balanceIdr: feed.balanceIdr,
          accountRef: feed.accountRef,
          hidden: _hiddenBalance,
          onToggle: () => setState(() => _hiddenBalance = !_hiddenBalance),
        ),
        const SizedBox(height: KSpace.xl),
        _PromoCarousel(promos: feed.promos),
        const SizedBox(height: KSpace.xl),
        _QuickActionsRow(
          onKirim: goSend,
          onMinta: () => context.pushNamed(Routes.requestAmount),
          onSplit: () {
            ref.read(splitControllerProvider.notifier).reset();
            context.pushNamed(Routes.splitCreate);
          },
          onTerima: () => context.pushNamed(Routes.receive),
        ),
        const SizedBox(height: KSpace.xl),
        _FamilyShortcuts(
          contacts: feed.favoriteContacts,
          onContactTap: sendTo,
          onManage: () => context.pushNamed(Routes.contacts),
        ),
        const SizedBox(height: KSpace.xl),
        _RecentTransactions(
          transactions: feed.recentTransactions,
          onSeeAll: () => context.pushNamed(Routes.history),
          onTxTap: (tx) =>
              context.pushNamed(Routes.txDetail, pathParameters: {'id': tx.id}),
        ),
      ],
    );
  }
}

/// Sapaan + avatar inisial di kanan.
class _Header extends StatelessWidget {
  final String greetingName;
  const _Header({required this.greetingName});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final trimmed = greetingName.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Text('Selamat malam, $greetingName', style: text.headlineMedium),
        ),
        const SizedBox(width: KSpace.sm),
        MonogramAvatar(initials: initial),
      ],
    );
  }
}

/// Saldo besar dengan toggle sembunyikan + rekening tujuan.
class _BalanceHero extends StatelessWidget {
  final double balanceIdr;
  final String accountRef;
  final bool hidden;
  final VoidCallback onToggle;

  const _BalanceHero({
    required this.balanceIdr,
    required this.accountRef,
    required this.hidden,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total saldo', style: text.titleMedium?.copyWith(color: p.inkMuted)),
        const SizedBox(height: KSpace.xs),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: MoneyText(amountIdr: balanceIdr, size: 52, hidden: hidden),
              ),
            ),
            IconButton(
              onPressed: onToggle,
              tooltip: hidden ? 'Tampilkan saldo' : 'Sembunyikan saldo',
              icon: Icon(
                hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: p.inkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpace.xs),
        Text('$accountRef · Rekening utama',
            style: text.bodySmall?.copyWith(color: p.inkMuted)),
      ],
    );
  }
}

/// Scroll horizontal kartu promo — satu penuh terlihat + intip kartu
/// berikutnya lewat lebar kartu yang lebih sempit dari area konten.
class _PromoCarousel extends StatelessWidget {
  final List<PromoBanner> promos;
  const _PromoCarousel({required this.promos});

  @override
  Widget build(BuildContext context) {
    if (promos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 176,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth - KSpace.xxl;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: promos.length,
            separatorBuilder: (_, __) => const SizedBox(width: KSpace.sm),
            itemBuilder: (context, i) =>
                SizedBox(width: cardWidth, child: _PromoCard(promo: promos[i])),
          );
        },
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromoBanner promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = KRadius.spotlight;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        onTap: () =>
            context.pushNamed(Routes.promoDetail, pathParameters: {'id': promo.id}),
        child: GradientSpotlight(
          sunset: promo.spotlight == SpotlightVariant.sunset,
          // Builder ambil context DI BAWAH GradientSpotlight supaya
          // DefaultTextStyle.of() melihat warna teks yang sudah di-set.
          child: Builder(
            builder: (context) {
              final onColor = DefaultTextStyle.of(context).style.color ?? Colors.white;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (promo.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: KSpace.xs, vertical: 4),
                      decoration: BoxDecoration(
                        color: onColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(KRadius.pill),
                      ),
                      child: Text(
                        promo.badge!,
                        style: text.bodySmall?.copyWith(color: onColor),
                      ),
                    ),
                  Text(
                    promo.title,
                    style: text.bodyLarge?.copyWith(color: onColor, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    promo.subtitle,
                    style: text.bodySmall?.copyWith(color: onColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    promo.ctaLabel,
                    style: text.labelMedium?.copyWith(
                      color: onColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Baris 4 aksi cepat setara — tanpa hierarki, semua ink/surface.
class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onKirim;
  final VoidCallback onMinta;
  final VoidCallback onSplit;
  final VoidCallback onTerima;

  const _QuickActionsRow({
    required this.onKirim,
    required this.onMinta,
    required this.onSplit,
    required this.onTerima,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: QuickAction(icon: Icons.arrow_upward, label: 'Kirim', onPressed: onKirim)),
        Expanded(child: QuickAction(icon: Icons.call_received, label: 'Minta', onPressed: onMinta)),
        Expanded(child: QuickAction(icon: Icons.call_split, label: 'Split', onPressed: onSplit)),
        Expanded(child: QuickAction(icon: Icons.arrow_downward, label: 'Terima', onPressed: onTerima)),
      ],
    );
  }
}

/// Header "Kirim ke keluarga" + scroll horizontal avatar kontak favorit,
/// diakhiri tombol lingkaran "+ Tambah".
class _FamilyShortcuts extends StatelessWidget {
  final List<Contact> contacts;
  final ValueChanged<Contact> onContactTap;
  final VoidCallback onManage;

  const _FamilyShortcuts({
    required this.contacts,
    required this.onContactTap,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kirim ke keluarga', style: text.titleMedium),
            TextButton(onPressed: onManage, child: const Text('Kelola')),
          ],
        ),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final contact in contacts)
                Padding(
                  padding: const EdgeInsets.only(right: KSpace.md),
                  child: _ContactShortcut(
                    contact: contact,
                    onTap: () => onContactTap(contact),
                  ),
                ),
              _AddContactShortcut(onTap: onManage),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactShortcut extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  const _ContactShortcut({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KRadius.md),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MonogramAvatar(initials: contact.initials, size: KSize.avatarMd),
            const SizedBox(height: KSpace.xs),
            Text(
              contact.name,
              style: text.bodySmall?.copyWith(color: p.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddContactShortcut extends StatelessWidget {
  final VoidCallback onTap;
  const _AddContactShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
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
            Text('Tambah', style: text.bodySmall?.copyWith(color: p.ink)),
          ],
        ),
      ),
    );
  }
}

/// Header "Aktivitas terbaru" + hingga 3 transaksi terakhir, atau empty state.
class _RecentTransactions extends StatelessWidget {
  final List<AppTransaction> transactions;
  final VoidCallback onSeeAll;
  final ValueChanged<AppTransaction> onTxTap;

  const _RecentTransactions({
    required this.transactions,
    required this.onSeeAll,
    required this.onTxTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final recent = transactions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aktivitas terbaru', style: text.titleMedium),
            TextButton(onPressed: onSeeAll, child: const Text('Lihat semua')),
          ],
        ),
        if (recent.isEmpty)
          const EmptyView(
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada transaksi',
            subtitle: 'Kiriman pertamamu akan muncul di sini.',
          )
        else
          for (final tx in recent)
            TransactionRow(
              avatarInitials: tx.direction == TxDirection.split ? null : _initialsOf(tx.counterpartyName),
              icon: tx.direction == TxDirection.split ? Icons.call_split : null,
              title: tx.counterpartyName,
              subtitle: '${_directionLabel(tx.direction)} · ${_relativeTime(tx.createdAt)}',
              amountIdr: tx.amountIdr,
              direction: tx.direction,
              failed: tx.status == TxStatus.failed,
              onTap: () => onTxTap(tx),
            ),
      ],
    );
  }
}

/// Dua huruf pertama nama, huruf besar — inisial avatar transaksi non-split.
String _initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
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

/// "Hari ini HH:mm" untuk transaksi hari yang sama; selain itu "d MMM" lokal id.
String _relativeTime(DateTime createdAt) {
  final now = DateTime.now();
  final sameDay =
      now.year == createdAt.year && now.month == createdAt.month && now.day == createdAt.day;
  if (sameDay) {
    final hh = createdAt.hour.toString().padLeft(2, '0');
    final mm = createdAt.minute.toString().padLeft(2, '0');
    return 'Hari ini $hh:$mm';
  }
  return DateFormat('d MMM', 'id').format(createdAt);
}
