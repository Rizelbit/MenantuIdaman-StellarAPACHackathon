import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/models.dart';
import 'auth_controller.dart';
import 'providers.dart';

/// Feed Home (saldo, promo, kontak favorit, transaksi terbaru).
/// Kegagalan diteruskan sebagai [AsyncError] lewat `throw` — screen Home
/// menampilkan tombol retry dari situ (lihat pola `ref.watch(...).when`).
final homeFeedProvider = FutureProvider<HomeFeed>((ref) async {
  final api = ref.watch(walletApiProvider);
  final userId = ref.watch(walletProvider)?.userId ?? 'me';
  switch (await api.getHomeFeed(userId)) {
    case Ok(value: final feed):
      return feed;
    case Err(failure: final f):
      throw f; // FutureProvider surfaces this as AsyncError; screens show retry
  }
});
