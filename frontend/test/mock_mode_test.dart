import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Kirimin/app/env.dart';
import 'package:Kirimin/state/auth_controller.dart';
import 'package:Kirimin/state/send_controller.dart';

/// Regresi untuk bug "stuck di onboarding, network failure": dengan mode mock
/// (Env.useMock, default true) seluruh alur backend selesai TANPA backend.
void main() {
  test('prototype defaults to mock mode', () {
    expect(Env.useMock, isTrue);
  });

  test('onboarding completes with no backend (the fixed bug)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final failure = await container
        .read(authControllerProvider.notifier)
        .registerWithPasskey('Pengguna Kirimin');

    // Sebelum fix: gagal dengan AppFailure.network dan wallet tetap null.
    expect(failure, isNull);
    final wallet = container.read(walletProvider);
    expect(wallet, isNotNull);
    expect(wallet!.balanceUsd, greaterThan(0));
  });

  test('send flow reaches success with no backend', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Punya wallet dulu (onboarding).
    await container
        .read(authControllerProvider.notifier)
        .registerWithPasskey('Pengirim');

    final send = container.read(sendControllerProvider.notifier);
    send.setRecipient('Ibu');
    send.setAmount(1000000);
    send.goToReview();
    await send.confirmAndSend();

    final state = container.read(sendControllerProvider);
    expect(state.phase, SendPhase.success);
    expect(state.result, isNotNull);
    expect(state.result!.counterpartyName, 'Ibu');

    // Saldo berkurang setelah kirim (mock stateful; saldo awal 250 USD).
    expect(container.read(walletProvider)!.balanceUsd, lessThan(250));
  });
}
