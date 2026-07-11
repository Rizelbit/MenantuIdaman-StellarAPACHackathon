import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/send_amount_screen.dart';
import '../screens/send_review_screen.dart';
import '../screens/send_success_screen.dart';
import '../screens/receive_screen.dart';
import '../screens/history_screen.dart';

/// Nama rute terpusat. Screen navigasi via `context.goNamed(Routes.home)` —
/// TIDAK dengan string mentah, supaya gampang refactor & agar screen hasil agent
/// punya kontrak jelas.
abstract class Routes {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const sendAmount = 'send-amount';
  static const sendReview = 'send-review';
  static const sendSuccess = 'send-success';
  static const receive = 'receive';
  static const history = 'history';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Jembatan: setiap perubahan auth memicu router mengevaluasi ulang redirect,
  // sehingga splash otomatis berpindah begitu status sesi selesai dimuat.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      // Selama sesi masih loading, tahan di splash (jangan redirect).
      if (auth.isLoading) return null;

      final signedIn = auth.value?.isSignedIn ?? false;
      final loc = state.matchedLocation;
      final onOnboarding = loc == '/onboarding';
      final onSplash = loc == '/';

      // Belum punya akun → arahkan ke onboarding (kecuali sudah di sana).
      if (!signedIn) return onOnboarding ? null : '/onboarding';

      // Sudah punya akun → keluar dari splash/onboarding ke home.
      return (onSplash || onOnboarding) ? '/home' : null;
    },
    routes: [
      GoRoute(
          path: '/',
          name: Routes.splash,
          builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding',
          name: Routes.onboarding,
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(
          path: '/home',
          name: Routes.home,
          builder: (_, __) => const HomeScreen()),
      GoRoute(
          path: '/send',
          name: Routes.sendAmount,
          builder: (_, __) => const SendAmountScreen(),
          routes: [
            GoRoute(
                path: 'review',
                name: Routes.sendReview,
                builder: (_, __) => const SendReviewScreen()),
            GoRoute(
                path: 'success',
                name: Routes.sendSuccess,
                builder: (_, __) => const SendSuccessScreen()),
          ]),
      GoRoute(
          path: '/receive',
          name: Routes.receive,
          builder: (_, __) => const ReceiveScreen()),
      GoRoute(
          path: '/history',
          name: Routes.history,
          builder: (_, __) => const HistoryScreen()),
    ],
  );
});
