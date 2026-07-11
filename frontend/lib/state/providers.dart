import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/fx_service.dart';
import '../services/passkey_service.dart';
import '../services/wallet_api.dart';

/// Provider service — titik injeksi tunggal. Screen & controller mengambil
/// dependency dari sini (bukan `new` langsung) supaya gampang di-mock saat test.
final passkeyServiceProvider = Provider((_) => PasskeyService());
final walletApiProvider = Provider((_) => WalletApi());
final fxServiceProvider = Provider((_) => const FxService());
