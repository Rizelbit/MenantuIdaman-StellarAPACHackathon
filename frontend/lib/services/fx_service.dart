import '../app/env.dart';

/// Kurs FX MOCK (statik). Jalur real = SEP-38 (sebut di slide, jangan bangun).
/// Dipisah jadi service agar mudah diganti sumber real nanti.
class FxService {
  const FxService();

  double usdToIdr(double usd) => usd * Env.usdToIdr;
  double idrToUsd(double idr) => idr / Env.usdToIdr;
  double get rate => Env.usdToIdr;
}
