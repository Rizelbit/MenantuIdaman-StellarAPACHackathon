/// Dataset contoh (seed) untuk MODE PROTOTIPE (Env.useMock).
///
/// Setiap fungsi mengembalikan koleksi/objek BARU (bukan konstanta bersama)
/// supaya nilai `DateTime` selalu relatif ke `DateTime.now()` saat dipanggil,
/// dan supaya pemanggil bebas memutasi hasilnya tanpa mempengaruhi seed lain.
library;

import '../models/models.dart';

/// Kontak contoh: 2 favorit (Ibu, Ayu) + 1 non-favorit (Pak Slamet).
List<Contact> seedContacts() => [
      const Contact(
        id: 'c1',
        name: 'Ibu',
        relation: 'Mother',
        initials: 'IB',
        accountRef: '•••• 3092',
        isFavorite: true,
      ),
      const Contact(
        id: 'c2',
        name: 'Ayu (Adik)',
        relation: 'Sister',
        initials: 'AY',
        accountRef: '•••• 7741',
        isFavorite: true,
      ),
      const Contact(
        id: 'c3',
        name: 'Pak Slamet',
        relation: 'Father',
        initials: 'PS',
        accountRef: '•••• 5510',
        isFavorite: false,
      ),
    ];

/// Kartu promo contoh untuk carousel Home.
List<PromoBanner> seedPromos() => [
      const PromoBanner(
        id: 'promo-split-bill-launch',
        title: 'Split the bill!',
        subtitle:
            'Electricity, rent, groceries, and dinner bills done much faster.',
        ctaLabel: "Let's split it",
        deepLink: '/split',
        badge: 'New',
        spotlight: SpotlightVariant.aurora,
      ),
    ];

/// Transaksi terbaru contoh, dengan timestamp RELATIF terhadap `DateTime.now()`
/// supaya pengelompokan hari (Hari ini / Minggu ini / lebih lama) terlihat wajar.
List<AppTransaction> seedTransactions() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 9, 20);

  return [
    AppTransaction(
      id: 'tx1',
      counterpartyName: 'Ibu',
      amountIdr: 995000,
      createdAt: today,
      status: TxStatus.settled,
      direction: TxDirection.send,
      reference: 'KRM-8F2A091',
      note: 'Groceries this month',
    ),
    AppTransaction(
      id: 'tx2',
      counterpartyName: 'Electricity bill',
      amountIdr: 150000,
      createdAt: now.subtract(const Duration(days: 2, hours: 3)),
      status: TxStatus.pending,
      direction: TxDirection.split,
    ),
    AppTransaction(
      id: 'tx3',
      counterpartyName: 'Ayu (Adik)',
      amountIdr: 200000,
      createdAt: now.subtract(const Duration(days: 5, hours: 1)),
      status: TxStatus.settled,
      direction: TxDirection.receive,
    ),
    AppTransaction(
      id: 'tx4',
      counterpartyName: 'Pak Slamet',
      amountIdr: 500000,
      createdAt: now.subtract(const Duration(days: 6, hours: 4)),
      status: TxStatus.settled,
      direction: TxDirection.send,
    ),
    AppTransaction(
      id: 'tx5',
      counterpartyName: 'Ibu',
      amountIdr: 1000000,
      createdAt: now.subtract(const Duration(days: 8, hours: 2)),
      status: TxStatus.settled,
      direction: TxDirection.send,
    ),
  ];
}

/// Tagihan split contoh: Listrik Juli 2026, dibagi rata 3 orang.
SplitBill seedSplit() {
  final now = DateTime.now();
  return SplitBill(
    id: 'split1',
    title: 'Electricity, July 2026',
    totalIdr: 450000,
    createdAt: now.subtract(const Duration(days: 3, hours: 6)),
    participants: const [
      SplitParticipant(
        contactId: 'c1',
        name: 'Ibu',
        shareIdr: 150000,
        status: ParticipantStatus.paid,
      ),
      SplitParticipant(
        contactId: 'c2',
        name: 'Ayu (Adik)',
        shareIdr: 150000,
        status: ParticipantStatus.pending,
      ),
      SplitParticipant(
        contactId: 'self',
        name: 'You',
        shareIdr: 150000,
        isSelf: true,
        status: ParticipantStatus.paid,
      ),
    ],
  );
}
