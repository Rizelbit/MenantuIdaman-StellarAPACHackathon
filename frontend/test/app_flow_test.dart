import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kirimin/main.dart';

/// Full-app smoke: pumps the real KiriminApp (mock mode) and drives
/// welcome -> home -> history -> back. Verifies the app renders without
/// runtime/layout errors and that forward navigation (pushNamed) yields a
/// working AppBar back button.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The Welcome screen gates on local_auth (native Face ID). There's no
  // biometric channel under `flutter test`, so stub it to report a supported
  // device and a successful authentication — this drives the happy path.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (call) async {
        switch (call.method) {
          case 'isDeviceSupported':
          case 'authenticate':
            return true;
          case 'getAvailableBiometrics':
          case 'getEnrolledBiometrics':
            return <String>['face'];
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      null,
    );
  });

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  // Tap the Welcome screen's "Log in with Face ID" pill; the stubbed channel
  // above reports success, so the gate opens and sign-in proceeds.
  final faceIdButton = find.widgetWithText(TextButton, 'Log in with Face ID');

  // Advance fake time past the mock service delays (600ms each) without
  // pumpAndSettle (which would hang on the loading spinner's animation).
  Future<void> advance(WidgetTester tester, {int steps = 6}) async {
    for (var i = 0; i < steps; i++) {
      await tester.pump(const Duration(milliseconds: 700));
    }
  }

  testWidgets('welcome -> home -> history -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KiriminApp()));
    await advance(tester); // splash redirect -> welcome

    // Welcome renders.
    expect(find.text('Kirimin'), findsOneWidget);
    expect(faceIdButton, findsOneWidget);
    await tester.tap(faceIdButton);
    await advance(tester, steps: 8); // register (3x600ms) + redirect + feed load

    // Home rendered.
    expect(find.text('Total saldo'), findsOneWidget);
    expect(find.text('Kirim'), findsWidgets);

    // Navigate to History via "Lihat semua".
    final seeAll = find.text('Lihat semua');
    await tester.scrollUntilVisible(seeAll, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(seeAll);
    await advance(tester);

    // History screen + a working back button (proves pushNamed, not go).
    expect(find.text('Riwayat'), findsWidgets);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await advance(tester);
    expect(find.text('Total saldo'), findsOneWidget); // back on Home
  });

  testWidgets('home quick action Kirim pushes send with a back button',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KiriminApp()));
    await advance(tester);
    await tester.tap(faceIdButton);
    await advance(tester, steps: 8);

    expect(find.text('Total saldo'), findsOneWidget);
    await tester.tap(find.text('Kirim').first);
    await advance(tester);

    // Send Amount screen title + back button present.
    expect(find.text('Kirim'), findsWidgets);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
