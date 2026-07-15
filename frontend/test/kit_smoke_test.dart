import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Kirimin/models/models.dart';
import 'package:Kirimin/theme/app_theme.dart';
import 'package:Kirimin/widgets/widgets.dart';

/// Smoke test untuk seluruh kit UI: tiap widget di-pump lewat barrel export
/// `widgets.dart` di atas tema gelap dan dipastikan render tanpa error/overflow.
void main() {
  Widget harness(Widget child) => MaterialApp(
        theme: buildTheme(dark: true),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('PrimaryPillButton renders', (tester) async {
    await tester.pumpWidget(harness(
      PrimaryPillButton(label: 'Kirim', onPressed: () {}),
    ));

    expect(find.byType(PrimaryPillButton), findsOneWidget);
  });

  testWidgets('SurfaceCard renders', (tester) async {
    await tester.pumpWidget(harness(
      const SurfaceCard(child: Text('Konten')),
    ));

    expect(find.byType(SurfaceCard), findsOneWidget);
  });

  testWidgets('GradientSpotlight renders', (tester) async {
    await tester.pumpWidget(harness(
      const GradientSpotlight(child: Text('Saldo')),
    ));

    expect(find.byType(GradientSpotlight), findsOneWidget);
  });

  testWidgets('MonogramAvatar renders', (tester) async {
    await tester.pumpWidget(harness(
      const MonogramAvatar(initials: 'IB'),
    ));

    expect(find.byType(MonogramAvatar), findsOneWidget);
  });

  testWidgets('StatusChip renders', (tester) async {
    await tester.pumpWidget(harness(
      const StatusChip.success('Lunas'),
    ));

    expect(find.byType(StatusChip), findsOneWidget);
  });

  testWidgets('TransactionRow renders', (tester) async {
    await tester.pumpWidget(harness(
      const TransactionRow(
        title: 'Ibu',
        subtitle: 'Terkirim · Hari ini',
        amountIdr: 995000,
        direction: TxDirection.send,
      ),
    ));

    expect(find.byType(TransactionRow), findsOneWidget);
  });

  testWidgets('MoneyText renders', (tester) async {
    await tester.pumpWidget(harness(
      const MoneyText(amountIdr: 4250000, size: 40),
    ));

    expect(find.byType(MoneyText), findsOneWidget);
  });

  testWidgets('AmountKeypad renders', (tester) async {
    await tester.pumpWidget(harness(
      AmountKeypad(onKey: (_) {}, onBackspace: () {}),
    ));

    expect(find.byType(AmountKeypad), findsOneWidget);
  });
}
