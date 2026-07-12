/// Model data ringan untuk MVP. Tidak ada satu pun istilah crypto yang bocor ke
/// UI dari sini — field on-chain (contractAddress) hanya dipakai internal.
library;

class Wallet {
  final String userId;
  final String contractAddress; // internal saja, JANGAN ditampilkan ke user
  final double balanceUsd; // saldo mentah dalam USD/USDC

  const Wallet({
    required this.userId,
    required this.contractAddress,
    required this.balanceUsd,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        userId: json['userId'] as String,
        contractAddress: json['contractAddress'] as String,
        balanceUsd: (json['balanceUsd'] as num).toDouble(),
      );
}

class AppTransaction {
  final String id;
  final String recipientName;
  final double amountIdr; // yang diterima keluarga
  final DateTime createdAt;
  final TxStatus status;

  const AppTransaction({
    required this.id,
    required this.recipientName,
    required this.amountIdr,
    required this.createdAt,
    required this.status,
  });
}

enum TxStatus { pending, settled, failed }

/// Envelope attestation WebAuthn hasil `passkeys.register()` (registrasi).
/// Diteruskan mentah ke backend; backend (Passkey Kit) yang mem-parsing pubkey.
class PasskeyAttestation {
  final String credentialId; // rawId (base64url)
  final String clientDataJson; // base64url
  final String attestationObject; // base64url

  const PasskeyAttestation({
    required this.credentialId,
    required this.clientDataJson,
    required this.attestationObject,
  });

  Map<String, dynamic> toJson() => {
        'credentialId': credentialId,
        'clientDataJSON': clientDataJson,
        'attestationObject': attestationObject,
      };
}

/// Envelope assertion WebAuthn hasil `passkeys.authenticate()` (sign tx).
/// Diteruskan mentah ke backend; backend merakit auth entry Soroban dari ini.
class PasskeyAssertion {
  final String credentialId;
  final String clientDataJson;
  final String authenticatorData;
  final String signature;

  const PasskeyAssertion({
    required this.credentialId,
    required this.clientDataJson,
    required this.authenticatorData,
    required this.signature,
  });

  Map<String, dynamic> toJson() => {
        'credentialId': credentialId,
        'clientDataJSON': clientDataJson,
        'authenticatorData': authenticatorData,
        'signature': signature,
      };
}
