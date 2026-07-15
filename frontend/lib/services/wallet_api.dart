import 'package:dio/dio.dart';

import '../app/env.dart';
import '../core/result.dart';
import '../models/models.dart';

/// Klien HTTP ke backend Node (Passkey Kit + Launchtube relay).
/// Endpoint di bawah adalah KONTRAK yang perlu disepakati dengan tim backend.
/// Semua kerja Soroban (rakit tx, tempel auth entry, submit) ada di backend —
/// Flutter hanya kirim envelope passkey + terima hasil.
class WalletApi {
  WalletApi([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Env.backendUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ));

  final Dio _dio;

  /// 1) Minta challenge + userId untuk registrasi passkey.
  /// GET /passkey/register-options?userName=...
  Future<Result<({String challenge, String userId})>> registerOptions(
      String userName) async {
    return _guard(() async {
      final r = await _dio.get('/passkey/register-options',
          queryParameters: {'userName': userName});
      return (
        challenge: r.data['challenge'] as String,
        userId: r.data['userId'] as String,
      );
    });
  }

  /// 2) Kirim attestation → backend deploy smart wallet via factory + Launchtube.
  /// POST /wallet/create  { userId, attestation }
  Future<Result<Wallet>> createWallet({
    required String userId,
    required PasskeyAttestation attestation,
  }) async {
    return _guard(() async {
      final r = await _dio.post('/wallet/create', data: {
        'userId': userId,
        'attestation': attestation.toJson(),
      });
      return Wallet.fromJson(r.data as Map<String, dynamic>);
    });
  }

  /// 3) Bangun tx transfer → backend balikin signature payload (challenge) untuk
  /// ditandatangani passkey, plus credentialId yang boleh dipakai.
  /// POST /tx/build  { userId, recipient, amountUsd }
  Future<Result<({String txId, String challenge, List<String> credentialIds})>>
      buildSendTx({
    required String userId,
    required String recipient,
    required double amountUsd,
  }) async {
    return _guard(() async {
      final r = await _dio.post('/tx/build', data: {
        'userId': userId,
        'recipient': recipient,
        'amountUsd': amountUsd,
      });
      return (
        txId: r.data['txId'] as String,
        challenge: r.data['challenge'] as String,
        credentialIds: (r.data['credentialIds'] as List).cast<String>(),
      );
    });
  }

  /// 4) Kirim assertion → backend tempel auth entry & submit via Launchtube.
  /// POST /tx/submit  { txId, assertion }  → settle ~5 detik
  Future<Result<AppTransaction>> submitSignedTx({
    required String txId,
    required PasskeyAssertion assertion,
    required String recipientName,
    required double receiveIdr,
  }) async {
    return _guard(() async {
      final r = await _dio.post('/tx/submit', data: {
        'txId': txId,
        'assertion': assertion.toJson(),
      });
      return AppTransaction(
        id: r.data['txId'] as String? ?? txId,
        counterpartyName: recipientName,
        amountIdr: receiveIdr,
        createdAt: DateTime.now(),
        status: TxStatus.settled,
        direction: TxDirection.send,
      );
    });
  }

  /// Ambil saldo terkini (USD/USDC di balik layar).
  /// GET /wallet/:userId/balance
  Future<Result<double>> getBalanceUsd(String userId) async {
    return _guard(() async {
      final r = await _dio.get('/wallet/$userId/balance');
      return (r.data['balanceUsd'] as num).toDouble();
    });
  }

  /// Ambil feed Home (saldo, promo, kontak favorit, transaksi terbaru).
  /// GET /home/:userId/feed
  // TODO(handoff): see docs/backend_handoff.md
  Future<Result<HomeFeed>> getHomeFeed(String userId) {
    throw UnimplementedError();
  }

  /// Daftar kontak milik user.
  /// GET /contacts/:userId
  // TODO(handoff): see docs/backend_handoff.md
  Future<Result<List<Contact>>> listContacts(String userId) {
    throw UnimplementedError();
  }

  /// Tambah kontak baru.
  /// POST /contacts  { name, relation, accountRef }
  // TODO(handoff): see docs/backend_handoff.md
  Future<Result<Contact>> addContact({
    required String name,
    required String relation,
    required String accountRef,
  }) {
    throw UnimplementedError();
  }

  /// Buat permintaan uang (request) ke kontak.
  /// POST /requests  { fromContactId, amountIdr, note }
  // TODO(handoff): see docs/backend_handoff.md
  Future<Result<MoneyRequest>> createRequest({
    required String fromContactId,
    required double amountIdr,
    String? note,
  }) {
    throw UnimplementedError();
  }

  /// Buat tagihan split baru.
  /// POST /splits  { title, totalIdr, participants }
  // TODO(handoff): see docs/backend_handoff.md
  Future<Result<SplitBill>> createSplit({
    required String title,
    required double totalIdr,
    required List<SplitParticipant> participants,
  }) {
    throw UnimplementedError();
  }

  /// Ambil detail tagihan split.
  /// GET /splits/:id
  // TODO(handoff): see docs/backend_handoff.md
  Future<Result<SplitBill>> getSplit(String id) {
    throw UnimplementedError();
  }

  /// Bungkus semua call: peta DioException → AppFailure ramah-user.
  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok(await run());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Err(AppFailure.network);
      }
      return Err(AppFailure('Couldn\'t process that. Try again.', cause: e));
    } catch (e) {
      return const Err(AppFailure.generic);
    }
  }
}
