import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart' hide Result;

import '../app/env.dart';
import '../core/result.dart';
import '../models/models.dart';

/// ============================================================================
/// PASSKEY SERVICE — jahitan paling penting dari edisi mobile.
/// ----------------------------------------------------------------------------
/// Tugas HP HANYA memunculkan biometrik & mengembalikan envelope WebAuthn mentah
/// (attestation saat daftar, assertion saat sign). HP TIDAK merakit transaksi
/// Soroban — itu tugas backend (Passkey Kit). Private key tidak pernah keluar
/// dari Secure Enclave / TEE.
///
/// ⚠️ API package `passkeys` masih berkembang — nama field/type di bawah bisa
/// berbeda antar versi. PIN versi, lalu sesuaikan pemetaan di dua tempat yang
/// ditandai `// MAP:`. Verifikasi lebih dulu bahwa Associated Domains (iOS) &
/// Asset Links (Android) sudah benar, atau `register()` tidak akan memunculkan
/// biometrik sama sekali. Lihat build plan §9 poin 1.
/// ============================================================================
class PasskeyService {
  final PasskeyAuthenticator _authenticator = PasskeyAuthenticator();

  /// REGISTRASI. [challengeB64Url], [userId], [userName] datang dari backend
  /// (endpoint /passkey/register-options). Mengembalikan attestation mentah.
  Future<Result<PasskeyAttestation>> register({
    required String challengeB64Url,
    required String userId,
    required String userName,
  }) async {
    try {
      final res = await _authenticator.register(
        RegisterRequestType(
          challenge: challengeB64Url,
          relyingParty: RelyingPartyType(id: Env.rpId, name: Env.appDisplayName),
          user: UserType(
            id: userId,
            displayName: userName,
            name: userName,
          ),
          authSelectionType: AuthenticatorSelectionType(
            // platform authenticator = Face ID / Touch ID / biometrik device
            authenticatorAttachment: 'platform',
            requireResidentKey: true,
            residentKey: 'required',
            userVerification: 'required',
          ),
          pubKeyCredParams: [
            // -7 = ES256 (secp256r1) — yang diverifikasi smart wallet Stellar
            PubKeyCredParamType(type: 'public-key', alg: -7),
          ],
          excludeCredentials: const [],
          timeout: 60000,
        ),
      );

      // MAP: sesuaikan getter dengan versi package yang dipakai.
      return Ok(PasskeyAttestation(
        credentialId: res.id,
        clientDataJson: res.clientDataJSON,
        attestationObject: res.attestationObject,
      ));
    } on Object catch (e) {
      return Err(_mapError(e));
    }
  }

  /// SIGN. [challengeB64Url] = signature payload tx (base64url) dari backend.
  /// [allowedCredentialIds] = credential milik user (dari mapping backend).
  /// Mengembalikan assertion mentah untuk dirakit backend jadi auth entry.
  Future<Result<PasskeyAssertion>> authenticate({
    required String challengeB64Url,
    required List<String> allowedCredentialIds,
  }) async {
    try {
      final res = await _authenticator.authenticate(
        AuthenticateRequestType(
          relyingPartyId: Env.rpId,
          challenge: challengeB64Url,
          userVerification: 'required',
          timeout: 60000,
          allowCredentials: allowedCredentialIds
              .map((id) => CredentialType(
                    type: 'public-key',
                    id: id,
                    transports: const [],
                  ))
              .toList(),
          mediation: MediationType.Required,
          preferImmediatelyAvailableCredentials: true,
        ),
      );

      // MAP: sesuaikan getter dengan versi package yang dipakai.
      return Ok(PasskeyAssertion(
        credentialId: res.id,
        clientDataJson: res.clientDataJSON,
        authenticatorData: res.authenticatorData,
        signature: res.signature,
      ));
    } on Object catch (e) {
      return Err(_mapError(e));
    }
  }

  AppFailure _mapError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('cancel')) return AppFailure.passkeyCancelled;
    if (msg.contains('network') || msg.contains('timeout')) {
      return AppFailure.network;
    }
    return AppFailure('Face ID didn\'t work. Try again.', cause: e);
  }
}
