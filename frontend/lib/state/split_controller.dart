import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/models.dart';
import 'providers.dart';

/// State layar buat tagihan split. Diri sendiri ("Kamu") selalu jadi peserta
/// pertama dan tidak bisa dihapus.
class SplitState {
  final String title;
  final double totalIdr;
  final List<SplitParticipant> participants;
  final bool splitEvenly;

  const SplitState({
    this.title = '',
    this.totalIdr = 0,
    this.participants = const [],
    this.splitEvenly = true,
  });

  SplitState copyWith({
    String? title,
    double? totalIdr,
    List<SplitParticipant>? participants,
    bool? splitEvenly,
  }) =>
      SplitState(
        title: title ?? this.title,
        totalIdr: totalIdr ?? this.totalIdr,
        participants: participants ?? this.participants,
        splitEvenly: splitEvenly ?? this.splitEvenly,
      );

  /// Total yang sudah dialokasikan ke semua peserta.
  double get assignedIdr =>
      participants.fold(0.0, (sum, p) => sum + p.shareIdr);

  /// Apakah alokasi peserta pas dengan nominal tagihan.
  bool get isBalanced => assignedIdr == totalIdr;
}

const _selfParticipant = SplitParticipant(
  contactId: 'self',
  name: 'Kamu',
  shareIdr: 0,
  isSelf: true,
  status: ParticipantStatus.pending,
);

const _initialSplitState = SplitState(
  totalIdr: 0,
  splitEvenly: true,
  participants: [_selfParticipant],
);

class SplitController extends Notifier<SplitState> {
  @override
  SplitState build() => _initialSplitState;

  void setTitle(String t) => state = state.copyWith(title: t);

  void setTotal(double idr) {
    state = state.copyWith(totalIdr: idr);
    if (state.splitEvenly) _recomputeEvenShares();
  }

  /// Tambah/hapus peserta lewat kontak. Diri sendiri tidak pernah dihapus
  /// lewat jalur ini karena contactId-nya selalu 'self'.
  void toggleParticipant(Contact c) {
    final exists = state.participants.any((p) => p.contactId == c.id);
    final updated = exists
        ? state.participants.where((p) => p.contactId != c.id).toList()
        : [
            ...state.participants,
            SplitParticipant(
              contactId: c.id,
              name: c.name,
              shareIdr: 0,
              isSelf: false,
              status: ParticipantStatus.pending,
            ),
          ];
    state = state.copyWith(participants: updated);
    if (state.splitEvenly) _recomputeEvenShares();
  }

  void setSplitEvenly(bool v) {
    state = state.copyWith(splitEvenly: v);
    if (v) _recomputeEvenShares();
  }

  /// Set nominal manual untuk satu peserta (dipakai saat splitEvenly false).
  void setShare(String contactId, double idr) {
    state = state.copyWith(
      participants: [
        for (final p in state.participants)
          if (p.contactId == contactId) p.copyWith(shareIdr: idr) else p,
      ],
    );
  }

  /// Returns null on success, or an [AppFailure] the screen can surface.
  Future<AppFailure?> submit() async {
    final api = ref.read(walletApiProvider);
    switch (await api.createSplit(
      title: state.title,
      totalIdr: state.totalIdr,
      participants: state.participants,
    )) {
      case Ok():
        return null; // created bill surfaced by split detail via getSplit
      case Err(failure: final f):
        return f;
    }
  }

  void reset() => state = _initialSplitState;

  /// Bagi rata dalam rupiah bulat: sisa pembagian integer ditumpuk ke peserta
  /// pertama supaya Σ share == total persis (tidak ada sen yang hilang).
  void _recomputeEvenShares() {
    final n = state.participants.length;
    if (n == 0) return;
    final base = (state.totalIdr / n).floorToDouble();
    final remainder = state.totalIdr - base * n;
    state = state.copyWith(
      participants: [
        for (var i = 0; i < n; i++)
          state.participants[i]
              .copyWith(shareIdr: i == 0 ? base + remainder : base),
      ],
    );
  }
}

final splitControllerProvider =
    NotifierProvider<SplitController, SplitState>(SplitController.new);
