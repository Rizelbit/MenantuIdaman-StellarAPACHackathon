/// Result minimal untuk membedakan sukses vs gagal tanpa lempar exception ke UI.
/// UI menampilkan [AppFailure.message] apa adanya — jadi pesan ditulis dari sisi
/// user ("Koneksi terputus, coba lagi"), bukan sisi sistem ("SocketException").
sealed class Result<T> {
  const Result();
  R when<R>({
    required R Function(T value) ok,
    required R Function(AppFailure failure) err,
  }) {
    final self = this;
    if (self is Ok<T>) return ok(self.value);
    return err((self as Err<T>).failure);
  }
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final AppFailure failure;
  const Err(this.failure);
}

class AppFailure {
  final String message; // ditulis untuk user
  final Object? cause; // untuk log/debug, tidak ditampilkan
  const AppFailure(this.message, {this.cause});

  static const network =
      AppFailure('Koneksi terputus. Cek internet lalu coba lagi.');
  static const passkeyCancelled =
      AppFailure('Verifikasi dibatalkan. Coba lagi ketika siap.');
  static const generic =
      AppFailure('Ada yang tidak beres. Coba lagi sebentar lagi.');
}
