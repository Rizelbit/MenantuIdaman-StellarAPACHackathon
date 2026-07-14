import '../core/money.dart';
import '../core/result.dart';
import '../models/models.dart';
import 'passkey_service.dart';
import 'wallet_api.dart';

/// Layanan tiruan (mock) untuk MODE PROTOTIPE (Env.useMock).
///
/// Tujuan: menjalankan & menavigasi seluruh aplikasi TANPA backend Node dan
/// TANPA device passkey. Setiap metode mengembalikan `Ok(...)` dengan data
/// contoh, plus jeda kecil supaya loading state (spinner CTA, fase kirim) tetap
/// terlihat seperti aslinya.
///
/// Ini BUKAN pengganti backend. Untuk menyambung backend nyata, matikan mode ini
/// (`--dart-define=USE_MOCK=false`) dan implementasikan endpoint sesuai kontrak
/// di `docs/backend_handoff.md`. Setiap `Ok(...)` di sini menandai bentuk data
/// yang harus dikembalikan endpoint aslinya.

/// Jeda kecil supaya UI terasa hidup (loading terlihat sebentar).
const _mockDelay = Duration(milliseconds: 600);

/// Tiruan [WalletApi]: semua panggilan HTTP diganti data contoh di memori.
class MockWalletApi extends WalletApi {
  MockWalletApi() : super();

  /// Saldo contoh (USD). Berkurang tiap kirim supaya Home terasa hidup.
  double _balanceUsd = 250;

  /// Padanan `GET /passkey/register-options`.
  @override
  Future<Result<({String challenge, String userId})>> registerOptions(
      String userName) async {
    await Future<void>.delayed(_mockDelay);
    return const Ok((challenge: 'mock-challenge', userId: 'mock-user-1'));
  }

  /// Padanan `POST /wallet/create`. Saldo awal jadi terlihat di Home.
  @override
  Future<Result<Wallet>> createWallet({
    required String userId,
    required PasskeyAttestation attestation,
  }) async {
    await Future<void>.delayed(_mockDelay);
    return Ok(Wallet(
      userId: userId,
      contractAddress: 'CMOCK0000000000000000000000000000000000000000000000000',
      balanceUsd: _balanceUsd,
    ));
  }

  /// Padanan `POST /tx/build`.
  @override
  Future<Result<({String txId, String challenge, List<String> credentialIds})>>
      buildSendTx({
    required String userId,
    required String recipient,
    required double amountUsd,
  }) async {
    await Future<void>.delayed(_mockDelay);
    return const Ok((
      txId: 'mock-tx-1',
      challenge: 'mock-sign-payload',
      credentialIds: ['mock-cred-1'],
    ));
  }

  /// Padanan `POST /tx/submit`. Kurangi saldo sesuai nominal terkirim.
  @override
  Future<Result<AppTransaction>> submitSignedTx({
    required String txId,
    required PasskeyAssertion assertion,
    required String recipientName,
    required double receiveIdr,
  }) async {
    await Future<void>.delayed(_mockDelay);
    _balanceUsd -= idrToUsd(receiveIdr);
    if (_balanceUsd < 0) _balanceUsd = 0;
    return Ok(AppTransaction(
      id: txId,
      counterpartyName: recipientName,
      amountIdr: receiveIdr,
      createdAt: DateTime.now(),
      status: TxStatus.settled,
      direction: TxDirection.send,
    ));
  }

  /// Padanan `GET /wallet/:userId/balance`.
  @override
  Future<Result<double>> getBalanceUsd(String userId) async {
    await Future<void>.delayed(_mockDelay);
    return Ok(_balanceUsd);
  }
}

/// Tiruan [PasskeyService]: envelope WebAuthn diganti data contoh, tanpa memanggil
/// plugin native. Membuat onboarding & sign jalan di emulator/desktop.
class MockPasskeyService extends PasskeyService {
  /// Padanan `passkeys.register()` (attestation).
  @override
  Future<Result<PasskeyAttestation>> register({
    required String challengeB64Url,
    required String userId,
    required String userName,
  }) async {
    await Future<void>.delayed(_mockDelay);
    return const Ok(PasskeyAttestation(
      credentialId: 'mock-cred-1',
      clientDataJson: 'mock-clientData',
      attestationObject: 'mock-attestation',
    ));
  }

  /// Padanan `passkeys.authenticate()` (assertion).
  @override
  Future<Result<PasskeyAssertion>> authenticate({
    required String challengeB64Url,
    required List<String> allowedCredentialIds,
  }) async {
    await Future<void>.delayed(_mockDelay);
    return const Ok(PasskeyAssertion(
      credentialId: 'mock-cred-1',
      clientDataJson: 'mock-clientData',
      authenticatorData: 'mock-authData',
      signature: 'mock-signature',
    ));
  }
}
