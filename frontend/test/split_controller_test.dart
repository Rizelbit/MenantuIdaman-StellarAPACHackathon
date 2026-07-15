import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Kirimin/state/split_controller.dart';
import 'package:Kirimin/models/models.dart';

void main() {
  ProviderContainer make() => ProviderContainer();
  const ibu = Contact(id: 'c1', name: 'Ibu', relation: 'Ibu', initials: 'IB', accountRef: '•••• 3092', isFavorite: true);
  const ayu = Contact(id: 'c2', name: 'Ayu', relation: 'Adik', initials: 'AY', accountRef: '•••• 7741', isFavorite: true);

  test('even split of 450000 across 3 (incl. self) => 150000 each, balanced', () {
    final c = make();
    final ctrl = c.read(splitControllerProvider.notifier);
    ctrl.setTotal(450000);
    ctrl.toggleParticipant(ibu);
    ctrl.toggleParticipant(ayu); // + self is always a participant
    final s = c.read(splitControllerProvider);
    expect(s.participants.length, 3);
    expect(s.participants.every((p) => p.shareIdr == 150000), isTrue);
    expect(s.isBalanced, isTrue);
  });

  test('even split with remainder puts leftover on first participant, stays balanced', () {
    final c = make();
    final ctrl = c.read(splitControllerProvider.notifier);
    ctrl.setTotal(100000);
    ctrl.toggleParticipant(ibu);
    ctrl.toggleParticipant(ayu); // 3-way of 100000 => 33334/33333/33333
    final s = c.read(splitControllerProvider);
    expect(s.assignedIdr, 100000);
    expect(s.isBalanced, isTrue);
  });

  test('manual override that breaks total is not balanced', () {
    final c = make();
    final ctrl = c.read(splitControllerProvider.notifier);
    ctrl.setTotal(450000);
    ctrl.toggleParticipant(ibu);
    ctrl.setSplitEvenly(false);
    ctrl.setShare('c1', 999999);
    expect(c.read(splitControllerProvider).isBalanced, isFalse);
  });
}
