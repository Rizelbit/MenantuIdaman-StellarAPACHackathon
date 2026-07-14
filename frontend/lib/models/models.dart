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
  final String counterpartyName;
  final double amountIdr; // yang diterima keluarga
  final DateTime createdAt;
  final TxStatus status;
  final TxDirection direction;
  final String? reference; // mis. KRM-8F2A091
  final String? note;

  const AppTransaction({
    required this.id,
    required this.counterpartyName,
    required this.amountIdr,
    required this.createdAt,
    required this.status,
    this.direction = TxDirection.send,
    this.reference,
    this.note,
  });
}

enum TxStatus { pending, settled, failed }

enum TxDirection { send, receive, split }

/// Varian latar dekoratif untuk kartu promo di Home.
enum SpotlightVariant { aurora, sunset }

class Contact {
  final String id;
  final String name;
  final String relation;
  final String initials;
  final String accountRef;
  final bool isFavorite;
  final DateTime? lastSentAt;

  const Contact({
    required this.id,
    required this.name,
    required this.relation,
    required this.initials,
    required this.accountRef,
    this.isFavorite = false,
    this.lastSentAt,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? relation,
    String? initials,
    String? accountRef,
    bool? isFavorite,
    DateTime? lastSentAt,
  }) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        relation: relation ?? this.relation,
        initials: initials ?? this.initials,
        accountRef: accountRef ?? this.accountRef,
        isFavorite: isFavorite ?? this.isFavorite,
        lastSentAt: lastSentAt ?? this.lastSentAt,
      );
}

class PromoBanner {
  final String id;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String deepLink;
  final String? badge;
  final SpotlightVariant spotlight;

  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.deepLink,
    this.badge,
    this.spotlight = SpotlightVariant.aurora,
  });
}

enum RequestStatus { pending, paid, declined, expired }

class MoneyRequest {
  final String id;
  final String fromContactId;
  final double amountIdr;
  final String? note;
  final RequestStatus status;
  final DateTime createdAt;

  const MoneyRequest({
    required this.id,
    required this.fromContactId,
    required this.amountIdr,
    this.note,
    this.status = RequestStatus.pending,
    required this.createdAt,
  });

  MoneyRequest copyWith({
    String? id,
    String? fromContactId,
    double? amountIdr,
    String? note,
    RequestStatus? status,
    DateTime? createdAt,
  }) =>
      MoneyRequest(
        id: id ?? this.id,
        fromContactId: fromContactId ?? this.fromContactId,
        amountIdr: amountIdr ?? this.amountIdr,
        note: note ?? this.note,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
}

enum ParticipantStatus { pending, paid }

class SplitParticipant {
  final String contactId;
  final String name;
  final double shareIdr;
  final bool isSelf;
  final ParticipantStatus status;

  const SplitParticipant({
    required this.contactId,
    required this.name,
    required this.shareIdr,
    this.isSelf = false,
    this.status = ParticipantStatus.pending,
  });

  SplitParticipant copyWith({
    String? contactId,
    String? name,
    double? shareIdr,
    bool? isSelf,
    ParticipantStatus? status,
  }) =>
      SplitParticipant(
        contactId: contactId ?? this.contactId,
        name: name ?? this.name,
        shareIdr: shareIdr ?? this.shareIdr,
        isSelf: isSelf ?? this.isSelf,
        status: status ?? this.status,
      );
}

class SplitBill {
  final String id;
  final String title;
  final double totalIdr;
  final DateTime createdAt;
  final List<SplitParticipant> participants;

  const SplitBill({
    required this.id,
    required this.title,
    required this.totalIdr,
    required this.createdAt,
    required this.participants,
  });

  /// Total yang sudah terkumpul dari peserta yang sudah bayar.
  double get collectedIdr => participants
      .where((p) => p.status == ParticipantStatus.paid)
      .fold(0.0, (sum, p) => sum + p.shareIdr);

  /// Apakah total pembagian pas dengan nominal tagihan.
  bool get isBalanced =>
      participants.fold(0.0, (sum, p) => sum + p.shareIdr) == totalIdr;
}

class HomeFeed {
  final double balanceIdr;
  final String greetingName;
  final String accountRef;
  final List<PromoBanner> promos;
  final List<Contact> favoriteContacts;
  final List<AppTransaction> recentTransactions;

  const HomeFeed({
    required this.balanceIdr,
    required this.greetingName,
    required this.accountRef,
    required this.promos,
    required this.favoriteContacts,
    required this.recentTransactions,
  });
}

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
