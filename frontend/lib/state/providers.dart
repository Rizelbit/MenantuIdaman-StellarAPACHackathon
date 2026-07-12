import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/env.dart';
import '../services/fx_service.dart';
import '../services/mock_services.dart';
import '../services/passkey_service.dart';
import '../services/wallet_api.dart';

/// Provider service — titik injeksi tunggal. Screen & controller mengambil
/// dependency dari sini (bukan `new` langsung) supaya gampang di-mock saat test.
///
/// Mode prototipe (Env.useMock, default true) memakai implementasi tiruan supaya
/// aplikasi jalan tanpa backend & tanpa device passkey. Set `USE_MOCK=false`
/// untuk memakai backend nyata. Lihat `docs/backend_handoff.md`.
final passkeyServiceProvider = Provider<PasskeyService>(
    (_) => Env.useMock ? MockPasskeyService() : PasskeyService());
final walletApiProvider = Provider<WalletApi>(
    (_) => Env.useMock ? MockWalletApi() : WalletApi());
final fxServiceProvider = Provider((_) => const FxService());
