/// Konfigurasi lingkungan. Untuk hackathon cukup hardcode di sini + override
/// via --dart-define saat build. JANGAN taruh secret produksi di sini.
class Env {
  Env._();

  /// Base URL backend Node (PasskeyServer + relay Launchtube).
  /// Override: flutter run --dart-define=BACKEND_URL=https://xxxx.ngrok.app
  static const backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://localhost:8787',
  );

  /// RP ID passkey = domain yang meng-host /.well-known/ (HARUS sama dengan
  /// domain backend). Salah = passkey tidak muncul. Lihat build plan §9.
  static const rpId = String.fromEnvironment(
    'RP_ID',
    defaultValue: 'localhost',
  );

  /// Nama yang ditampilkan OS saat prompt passkey.
  static const appDisplayName = 'Kirimin';

  /// Mode prototipe: pakai layanan tiruan (mock) sehingga seluruh aplikasi bisa
  /// dijalankan dan dinavigasi TANPA backend dan TANPA device passkey. Default
  /// `true` supaya `flutter run` langsung jalan untuk demo UI. Untuk sambung ke
  /// backend nyata: `--dart-define=USE_MOCK=false` bersama BACKEND_URL & RP_ID.
  /// Lihat `docs/backend_handoff.md`.
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  /// Kurs statik (MOCK). Sumber real: SEP-38. 1 USD = Rp berikut.
  static const usdToIdr = 16350.0;

  /// Biaya layanan (MOCK) — ditampilkan sebagai "biaya", bukan "network fee".
  /// Demo: nol biaya, jadi "mereka terima" == "kamu kirim" di seluruh alur kirim.
  static const feeRate = 0.0;

  /// Kirim ke testnet, bukan mainnet.
  static const stellarNetwork = 'testnet';
}
