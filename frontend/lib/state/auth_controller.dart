import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/models.dart';
import 'providers.dart';

/// State sesi: null = belum daftar/login, Wallet = sudah punya akun.
/// Router mendengarkan ini untuk redirect (lihat app/router.dart).
class AuthState {
  final Wallet? wallet;
  const AuthState({this.wallet});
  bool get isSignedIn => wallet != null;
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // MVP: mulai dari state kosong. (Nanti: baca sesi tersimpan.)
    return const AuthState();
  }

  /// Alur onboarding lengkap dalam satu aksi — inilah "daftar pakai Face ID".
  /// UI cukup panggil ini; semua langkah crypto disembunyikan.
  /// Mengembalikan null bila sukses, atau [AppFailure] agar UI tampilkan pesan.
  Future<AppFailure?> registerWithPasskey(String userName) async {
    final passkey = ref.read(passkeyServiceProvider);
    final api = ref.read(walletApiProvider);
    state = const AsyncLoading();

    // 1) minta challenge dari backend
    final String challenge;
    final String userId;
    switch (await api.registerOptions(userName)) {
      case Ok(value: final opts):
        challenge = opts.challenge;
        userId = opts.userId;
      case Err(failure: final f):
        return _fail(f);
    }

    // 2) munculkan biometrik → attestation
    final PasskeyAttestation attestation;
    switch (await passkey.register(
        challengeB64Url: challenge, userId: userId, userName: userName)) {
      case Ok(value: final a):
        attestation = a;
      case Err(failure: final f):
        return _fail(f);
    }

    // 3) backend deploy smart wallet (fee di-sponsor Launchtube)
    switch (await api.createWallet(userId: userId, attestation: attestation)) {
      case Ok(value: final wallet):
        state = AsyncData(AuthState(wallet: wallet));
        return null; // sukses
      case Err(failure: final f):
        return _fail(f);
    }
  }

  void signOut() => state = const AsyncData(AuthState());

  void updateBalance(double balanceUsd) {
    final w = state.value?.wallet;
    if (w == null) return;
    state = AsyncData(AuthState(
      wallet: Wallet(
        userId: w.userId,
        contractAddress: w.contractAddress,
        balanceUsd: balanceUsd,
      ),
    ));
  }

  AppFailure _fail(AppFailure f) {
    state = AsyncData(state.value ?? const AuthState());
    return f;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

/// Shortcut yang sering dipakai screen.
final walletProvider = Provider<Wallet?>(
  (ref) => ref.watch(authControllerProvider).value?.wallet,
);
