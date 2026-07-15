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

/// Home — showcase surface: balance, promo, quick actions, favorite contacts,
/// and recent activity, top to bottom. All data comes from [homeFeedProvider];
/// errors show a retry state that invalidates the provider.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Balance privacy toggle — pure display state, doesn't touch the data.
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
                title: 'Couldn\'t load home',
                subtitle: 'Check your connection and try again.',
              ),
              const SizedBox(height: KSpace.md),
              SecondaryPillButton(
                label: 'Try again',
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

    void goSplit() {
      ref.read(splitControllerProvider.notifier).reset();
      context.pushNamed(Routes.splitCreate);
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
        _PromoSection(promos: feed.promos, onSplit: goSplit),
        const SizedBox(height: KSpace.xl),
        _QuickActionsRow(
          onSend: goSend,
          onRequest: () => context.pushNamed(Routes.requestAmount),
          onSplit: goSplit,
          onReceive: () => context.pushNamed(Routes.receive),
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

/// Two-line greeting on the left; notification bell + initials avatar on the
/// right, matching the reference header.
class _Header extends StatelessWidget {
  final String greetingName;
  const _Header({required this.greetingName});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    final trimmed = greetingName.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good evening,',
                  style: text.bodySmall
                      ?.copyWith(color: p.inkMuted, fontWeight: FontWeight.w400)),
              const SizedBox(height: 2),
              Text(
                greetingName,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: KSpace.sm),
        _NotificationBell(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No new notifications')),
          ),
        ),
        const SizedBox(width: KSpace.xs),
        MonogramAvatar(initials: initial),
      ],
    );
  }
}

/// Surface-1 bell button with an accent notification dot.
class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    return SizedBox(
      width: KSize.iconButton,
      height: KSize.iconButton,
      child: Stack(
        children: [
          CircleIconButton(icon: Icons.notifications_none, onPressed: onTap),
          Positioned(
            top: 9,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.accent,
                border: Border.all(color: p.canvas, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large balance with a hide toggle + destination account.
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
        Text('Total balance', style: text.titleMedium?.copyWith(color: p.inkMuted)),
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
              tooltip: hidden ? 'Show balance' : 'Hide balance',
              icon: Icon(
                hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: p.inkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpace.xs),
        Text('$accountRef · Main account',
            style: text.bodySmall?.copyWith(color: p.inkMuted)),
      ],
    );
  }
}

/// The single promo card (reference shows exactly one, full width — not a
/// carousel). Renders the first promo; nothing when the feed has none.
class _PromoSection extends StatelessWidget {
  final List<PromoBanner> promos;
  final VoidCallback onSplit;
  const _PromoSection({required this.promos, required this.onSplit});

  @override
  Widget build(BuildContext context) {
    if (promos.isEmpty) return const SizedBox.shrink();
    return _PromoCard(promo: promos.first, onCta: onSplit);
  }
}

class _PromoCard extends StatelessWidget {
  final PromoBanner promo;
  final VoidCallback onCta;
  const _PromoCard({required this.promo, required this.onCta});

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
          // Read context BELOW GradientSpotlight so DefaultTextStyle.of() sees
          // the already-set text color.
          child: Builder(
            builder: (context) {
              final onColor = DefaultTextStyle.of(context).style.color ?? Colors.white;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (promo.badge != null) ...[
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
                    const SizedBox(height: KSpace.sm),
                  ],
                  Text(
                    promo.title,
                    style: text.bodyLarge?.copyWith(color: onColor, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: KSpace.xs),
                  Text(
                    promo.subtitle,
                    style: text.bodySmall?.copyWith(color: onColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: KSpace.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PrimaryPillButton(label: promo.ctaLabel, onPressed: onCta),
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

/// Row of 4 equal quick actions. "Send" is the ink-filled primary; the rest
/// stay surface1 so accent blue never fills a control.
class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onRequest;
  final VoidCallback onSplit;
  final VoidCallback onReceive;

  const _QuickActionsRow({
    required this.onSend,
    required this.onRequest,
    required this.onSplit,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: QuickAction(
                icon: Icons.arrow_upward, label: 'Send', primary: true, onPressed: onSend)),
        Expanded(child: QuickAction(icon: Icons.call_received, label: 'Request', onPressed: onRequest)),
        Expanded(child: QuickAction(icon: Icons.call_split, label: 'Split', onPressed: onSplit)),
        Expanded(child: QuickAction(icon: Icons.arrow_downward, label: 'Receive', onPressed: onReceive)),
      ],
    );
  }
}

/// "Send to family" header + horizontal scroll of favorite contact avatars,
/// ending in a circular "+ Add" button.
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
            Text('Send to family', style: text.titleMedium),
            TextButton(onPressed: onManage, child: const Text('Manage')),
          ],
        ),
        const SizedBox(height: KSpace.md),
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
            Text('Add', style: text.bodySmall?.copyWith(color: p.ink)),
          ],
        ),
      ),
    );
  }
}

/// "Recent activity" header + up to 3 latest transactions, or an empty state.
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
            Text('Recent activity', style: text.titleMedium),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        if (recent.isEmpty)
          const EmptyView(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            subtitle: 'Your first transfer will show up here.',
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

/// First two letters of the name, uppercase — avatar initials for non-split rows.
String _initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
}

String _directionLabel(TxDirection direction) {
  switch (direction) {
    case TxDirection.send:
      return 'Sent';
    case TxDirection.receive:
      return 'Received';
    case TxDirection.split:
      return 'Split';
  }
}

/// "Today HH:mm" for same-day transactions; otherwise "d MMM".
String _relativeTime(DateTime createdAt) {
  final now = DateTime.now();
  final sameDay =
      now.year == createdAt.year && now.month == createdAt.month && now.day == createdAt.day;
  if (sameDay) {
    final hh = createdAt.hour.toString().padLeft(2, '0');
    final mm = createdAt.minute.toString().padLeft(2, '0');
    return 'Today $hh:$mm';
  }
  return DateFormat('d MMM').format(createdAt);
}
