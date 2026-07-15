import '../core/money.dart';
import '../core/result.dart';
import '../models/models.dart';
import 'mock_data.dart';
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
  /// Setara Rp 4.250.000 supaya Home menampilkan saldo sesuai spec desain.
  double _balanceUsd = idrToUsd(4250000);

  /// Kontak contoh, dimutasi di memori supaya [addContact] terlihat persisten
  /// selama sesi (bukan dibuat ulang tiap panggilan).
  final List<Contact> _contacts = seedContacts();

  /// Tagihan split yang dibuat lewat [createSplit], supaya [getSplit] bisa
  /// mengembalikannya kembali selama sesi.
  final Map<String, SplitBill> _splits = {};

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

  /// Padanan `GET /home/:userId/feed`.
  @override
  Future<Result<HomeFeed>> getHomeFeed(String userId) async {
    await Future<void>.delayed(_mockDelay);
    return Ok(HomeFeed(
      balanceIdr: usdToIdr(_balanceUsd),
      greetingName: 'Rani',
      accountRef: '•••• 4821',
      promos: seedPromos(),
      favoriteContacts: _contacts.where((c) => c.isFavorite).toList(),
      recentTransactions: seedTransactions(),
    ));
  }

  /// Padanan `GET /contacts/:userId`.
  @override
  Future<Result<List<Contact>>> listContacts(String userId) async {
    await Future<void>.delayed(_mockDelay);
    return Ok(List.of(_contacts));
  }

  /// Padanan `POST /contacts`. Ditambahkan ke daftar kontak di memori.
  @override
  Future<Result<Contact>> addContact({
    required String name,
    required String relation,
    required String accountRef,
  }) async {
    await Future<void>.delayed(_mockDelay);
    final upper = name.trim().toUpperCase();
    final initials =
        upper.length >= 2 ? upper.substring(0, 2) : upper.padRight(2);
    final contact = Contact(
      id: 'c${_contacts.length + 1}',
      name: name,
      relation: relation,
      initials: initials,
      accountRef: accountRef,
    );
    _contacts.add(contact);
    return Ok(contact);
  }

  /// Padanan `POST /requests`.
  @override
  Future<Result<MoneyRequest>> createRequest({
    required String fromContactId,
    required double amountIdr,
    String? note,
  }) async {
    await Future<void>.delayed(_mockDelay);
    return Ok(MoneyRequest(
      id: 'req${DateTime.now().millisecondsSinceEpoch}',
      fromContactId: fromContactId,
      amountIdr: amountIdr,
      note: note,
      createdAt: DateTime.now(),
    ));
  }

  /// Padanan `POST /splits`. Disimpan di memori supaya [getSplit] bisa
  /// mengembalikannya kembali.
  @override
  Future<Result<SplitBill>> createSplit({
    required String title,
    required double totalIdr,
    required List<SplitParticipant> participants,
  }) async {
    await Future<void>.delayed(_mockDelay);
    final split = SplitBill(
      id: 'split${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      totalIdr: totalIdr,
      createdAt: DateTime.now(),
      participants: participants,
    );
    _splits[split.id] = split;
    return Ok(split);
  }

  /// Padanan `GET /splits/:id`. Kembalikan split yang dibuat sesi ini jika ada,
  /// jika tidak jatuh balik ke split contoh.
  @override
  Future<Result<SplitBill>> getSplit(String id) async {
    await Future<void>.delayed(_mockDelay);
    return Ok(_splits[id] ?? seedSplit());
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
