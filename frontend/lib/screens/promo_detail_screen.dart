import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../models/models.dart';
import '../state/home_feed.dart';
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

/// Detail satu promo, dibuka dari kartu promo Home lewat `/promo/:id`.
/// Datanya diambil dari [homeFeedProvider] yang sudah termuat (bukan fetch
/// terpisah) — kalau feed belum siap (deep-link dingin) atau id tidak
/// ketemu, tampil state tidak ditemukan alih-alih layar kosong.
class PromoDetailScreen extends ConsumerWidget {
  final String id;
  const PromoDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider).value;
    final promo = feed == null ? null : _firstById(feed.promos, id, (p) => p.id);

    if (promo == null) {
      return const AppScaffold(
        title: 'Promo',
        child: EmptyView(
          icon: Icons.error_outline,
          title: 'Promo tidak ditemukan',
          subtitle: 'Coba buka dari beranda.',
        ),
      );
    }

    return AppScaffold(
      title: 'Promo',
      bottom: PrimaryPillButton(
        label: promo.ctaLabel,
        onPressed: () => promo.deepLink.startsWith('/split')
            ? context.goNamed(Routes.splitCreate)
            : context.goNamed(Routes.home),
      ),
      child: _PromoDetailBody(promo: promo),
    );
  }
}

class _PromoDetailBody extends StatelessWidget {
  final PromoBanner promo;
  const _PromoDetailBody({required this.promo});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isSplit = promo.deepLink.contains('split');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: KSpace.md),
        _PromoHero(promo: promo),
        const SizedBox(height: KSpace.xl),
        Text('Yang kamu dapat', style: text.titleMedium),
        const SizedBox(height: KSpace.sm),
        if (isSplit) ...[
          const _FeatureRow(
            icon: Icons.balance,
            title: 'Bagi rata atau custom',
            desc: 'Bagi sama rata atau atur nominal tiap orang.',
          ),
          const _FeatureRow(
            icon: Icons.check_circle_outline,
            title: 'Lihat siapa sudah bayar',
            desc: 'Pantau status bayar tiap peserta sekilas.',
          ),
          const _FeatureRow(
            icon: Icons.notifications_outlined,
            title: 'Pengingat halus',
            desc: 'Kirim pengingat lembut buat yang belum bayar.',
          ),
        ] else
          _FeatureRow(
            icon: Icons.info_outline,
            title: 'Info promo',
            desc: promo.subtitle,
          ),
      ],
    );
  }
}

/// Panel gradien hero: badge opsional, judul, dan subjudul promo — satu
/// gradien per layar, sesuai kontrak [GradientSpotlight].
class _PromoHero extends StatelessWidget {
  final PromoBanner promo;
  const _PromoHero({required this.promo});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GradientSpotlight(
      sunset: promo.spotlight == SpotlightVariant.sunset,
      // Builder ambil context DI BAWAH GradientSpotlight supaya
      // DefaultTextStyle.of() melihat warna teks yang sudah di-set.
      child: Builder(
        builder: (context) {
          final onColor = DefaultTextStyle.of(context).style.color ?? Colors.white;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (promo.badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: KSpace.xs, vertical: 4),
                  decoration: BoxDecoration(
                    color: onColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(KRadius.pill),
                  ),
                  child: Text(promo.badge!, style: text.labelSmall?.copyWith(color: onColor)),
                ),
                const SizedBox(height: KSpace.sm),
              ],
              Text(promo.title, style: text.headlineMedium?.copyWith(color: onColor)),
              const SizedBox(height: KSpace.xs),
              Text(promo.subtitle, style: text.bodyMedium?.copyWith(color: onColor)),
            ],
          );
        },
      ),
    );
  }
}

/// Satu baris fitur: ikon (accent, dalam lingkaran surface) + judul + deskripsi.
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: KSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surface1, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: p.accent),
          ),
          const SizedBox(width: KSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.bodyLarge?.copyWith(color: p.ink)),
                const SizedBox(height: 2),
                Text(desc, style: text.bodySmall?.copyWith(color: p.inkMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
