import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/result.dart';
import '../models/models.dart';
import 'auth_controller.dart';
import 'providers.dart';

/// Tahapan alur kirim. Screen membaca [phase] untuk memutuskan tampilan.
enum SendPhase { input, review, signing, submitting, success, error }

class SendState {
  final SendPhase phase;
  final String recipientName;
  final double amountIdr;
  final SendQuote? quote;
  final AppTransaction? result;
  final String? errorMessage;

  const SendState({
    this.phase = SendPhase.input,
    this.recipientName = '',
    this.amountIdr = 0,
    this.quote,
    this.result,
    this.errorMessage,
  });

  SendState copyWith({
    SendPhase? phase,
    String? recipientName,
    double? amountIdr,
    SendQuote? quote,
    AppTransaction? result,
    String? errorMessage,
  }) =>
      SendState(
        phase: phase ?? this.phase,
        recipientName: recipientName ?? this.recipientName,
        amountIdr: amountIdr ?? this.amountIdr,
        quote: quote ?? this.quote,
        result: result ?? this.result,
        errorMessage: errorMessage,
      );
}

class SendController extends Notifier<SendState> {
  @override
  SendState build() => const SendState();

  void setRecipient(String name) =>
      state = state.copyWith(recipientName: name);

  /// Dipanggil tiap ketikan nominal → memperbarui kartu transparansi live.
  void setAmount(double idr) => state = state.copyWith(
        amountIdr: idr,
        quote: idr > 0 ? SendQuote.fromAmount(idr) : null,
      );

  void goToReview() {
    if (state.quote == null || state.recipientName.trim().isEmpty) return;
    state = state.copyWith(phase: SendPhase.review);
  }

  void backToInput() => state = state.copyWith(phase: SendPhase.input);

  /// Konfirmasi: sign dengan Face ID lalu submit. Semua langkah crypto internal.
  Future<void> confirmAndSend() async {
    final wallet = ref.read(walletProvider);
    final quote = state.quote;
    if (wallet == null || quote == null) return;

    final api = ref.read(walletApiProvider);
    final passkey = ref.read(passkeyServiceProvider);
    final amountUsd = idrToUsd(quote.amountIdr);

    // 1) backend bangun tx → balikin challenge (signature payload)
    final String txId;
    final String challenge;
    final List<String> credentialIds;
    switch (await api.buildSendTx(
        userId: wallet.userId,
        recipient: state.recipientName,
        amountUsd: amountUsd)) {
      case Ok(value: final b):
        txId = b.txId;
        challenge = b.challenge;
        credentialIds = b.credentialIds;
      case Err(failure: final f):
        return _error(f.message);
    }

    // 2) Face ID → assertion
    state = state.copyWith(phase: SendPhase.signing);
    final PasskeyAssertion assertion;
    switch (await passkey.authenticate(
        challengeB64Url: challenge, allowedCredentialIds: credentialIds)) {
      case Ok(value: final a):
        assertion = a;
      case Err(failure: final f):
        return _error(f.message);
    }

    // 3) submit via Launchtube → settle ~5 detik
    state = state.copyWith(phase: SendPhase.submitting);
    final AppTransaction tx;
    switch (await api.submitSignedTx(
        txId: txId,
        assertion: assertion,
        recipientName: state.recipientName,
        receiveIdr: quote.receiveIdr)) {
      case Ok(value: final t):
        tx = t;
      case Err(failure: final f):
        return _error(f.message);
    }

    // refresh saldo di background (kegagalan di sini tidak membatalkan sukses)
    switch (await api.getBalanceUsd(wallet.userId)) {
      case Ok(value: final bal):
        ref.read(authControllerProvider.notifier).updateBalance(bal);
      case Err():
        break;
    }

    state = state.copyWith(phase: SendPhase.success, result: tx);
  }

  void reset() => state = const SendState();

  void _error(String message) =>
      state = state.copyWith(phase: SendPhase.error, errorMessage: message);
}

final sendControllerProvider =
    NotifierProvider<SendController, SendState>(SendController.new);
