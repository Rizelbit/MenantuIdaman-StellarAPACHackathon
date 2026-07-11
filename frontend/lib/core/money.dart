import 'package:intl/intl.dart';
import '../app/env.dart';

/// Semua uang di UI selalu dalam Rp atau $ — TIDAK pernah "jumlah token mentah".
/// File ini satu-satunya sumber kebenaran untuk format & konversi. Screen tidak
/// boleh memformat angka sendiri.

enum Currency { idr, usd }

final _rpFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final _usdFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: '\$',
  decimalDigits: 2,
);

/// Format sebuah nilai jadi string yang siap tampil.
String formatMoney(double amount, Currency currency) {
  switch (currency) {
    case Currency.idr:
      return _rpFormat.format(amount);
    case Currency.usd:
      return _usdFormat.format(amount);
  }
}

double usdToIdr(double usd) => usd * Env.usdToIdr;
double idrToUsd(double idr) => idr / Env.usdToIdr;

/// Hasil perhitungan biaya untuk kartu transparansi & konfirmasi.
/// Semua nilai dalam IDR (mata uang yang dilihat user Indonesia).
class SendQuote {
  final double amountIdr; // yang user KIRIM
  final double feeIdr; // biaya layanan
  final double receiveIdr; // yang keluarga TERIMA
  final double feeRate;

  const SendQuote({
    required this.amountIdr,
    required this.feeIdr,
    required this.receiveIdr,
    required this.feeRate,
  });

  /// Bangun quote dari nominal kirim (IDR). Biaya potong dari nominal.
  factory SendQuote.fromAmount(double amountIdr) {
    final fee = (amountIdr * Env.feeRate).roundToDouble();
    return SendQuote(
      amountIdr: amountIdr,
      feeIdr: fee,
      receiveIdr: amountIdr - fee,
      feeRate: Env.feeRate,
    );
  }

  String get amountLabel => formatMoney(amountIdr, Currency.idr);
  String get feeLabel => formatMoney(feeIdr, Currency.idr);
  String get receiveLabel => formatMoney(receiveIdr, Currency.idr);
  String get feePercentLabel =>
      '${(feeRate * 100).toStringAsFixed(feeRate * 100 % 1 == 0 ? 0 : 1)}%';
}
