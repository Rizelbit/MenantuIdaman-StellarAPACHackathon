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
import '../screens/request_amount_screen.dart';
import '../screens/request_confirm_screen.dart';
import '../screens/request_sent_screen.dart';
import '../screens/split_create_screen.dart';
import '../screens/split_shares_screen.dart';
import '../screens/split_confirm_screen.dart';
import '../screens/split_detail_screen.dart';

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
  static const requestAmount = 'request-amount';
  static const requestConfirm = 'request-confirm';
  static const requestSent = 'request-sent';
  static const splitCreate = 'split-create';
  static const splitShares = 'split-shares';
  static const splitConfirm = 'split-confirm';
  static const splitDetail = 'split-detail';
  static const contacts = 'contacts';
  static const txDetail = 'tx-detail';
  static const promoDetail = 'promo-detail';
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
          path: '/request',
          name: Routes.requestAmount,
          builder: (_, __) => const RequestAmountScreen(),
          routes: [
            GoRoute(
                path: 'confirm',
                name: Routes.requestConfirm,
                builder: (_, __) => const RequestConfirmScreen()),
            GoRoute(
                path: 'sent',
                name: Routes.requestSent,
                builder: (_, __) => const RequestSentScreen()),
          ]),
      GoRoute(
          path: '/split',
          name: Routes.splitCreate,
          builder: (_, __) => const SplitCreateScreen(),
          routes: [
            GoRoute(
                path: 'shares',
                name: Routes.splitShares,
                builder: (_, __) => const SplitSharesScreen()),
            GoRoute(
                path: 'confirm',
                name: Routes.splitConfirm,
                builder: (_, __) => const SplitConfirmScreen()),
          ]),
      GoRoute(
          path: '/split/detail/:id',
          name: Routes.splitDetail,
          builder: (_, state) =>
              SplitDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(
          path: '/contacts',
          name: Routes.contacts,
          builder: (_, __) => _stub('Kontak')),
      GoRoute(
          path: '/tx/:id',
          name: Routes.txDetail,
          builder: (_, __) => _stub('Transaksi')),
      GoRoute(
          path: '/promo/:id',
          name: Routes.promoDetail,
          builder: (_, __) => _stub('Promo')),
      GoRoute(
          path: '/history',
          name: Routes.history,
          builder: (_, __) => _stub('Riwayat')),
    ],
  );
});

/// Placeholder screen untuk rute yang belum dibangun — diganti oleh task
/// masing-masing (mis. Task 14 menukar `/home` dengan `HomeScreen` asli).
Widget _stub(String name) => Scaffold(
      body: Center(child: Text('$name — coming soon')),
    );
