import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/models.dart';
import 'providers.dart';

class RequestState {
  final Contact? fromContact;
  final double amountIdr;
  final String note;
  final RequestStatus? status;

  const RequestState({
    this.fromContact,
    this.amountIdr = 0,
    this.note = '',
    this.status,
  });

  RequestState copyWith({
    Contact? fromContact,
    double? amountIdr,
    String? note,
    RequestStatus? status,
  }) =>
      RequestState(
        fromContact: fromContact ?? this.fromContact,
        amountIdr: amountIdr ?? this.amountIdr,
        note: note ?? this.note,
        status: status ?? this.status,
      );
}

class RequestController extends Notifier<RequestState> {
  @override
  RequestState build() => const RequestState();

  void setContact(Contact c) => state = state.copyWith(fromContact: c);

  void setAmount(double idr) => state = state.copyWith(amountIdr: idr);

  void setNote(String n) => state = state.copyWith(note: n);

  /// Returns null on success, or an [AppFailure] the screen can surface.
  Future<AppFailure?> submit() async {
    final contact = state.fromContact;
    if (contact == null) return null;

    final api = ref.read(walletApiProvider);
    switch (await api.createRequest(
      fromContactId: contact.id,
      amountIdr: state.amountIdr,
      note: state.note,
    )) {
      case Ok():
        state = state.copyWith(status: RequestStatus.pending);
        return null;
      case Err(failure: final f):
        return f;
    }
  }

  void reset() => state = const RequestState();
}

final requestControllerProvider =
    NotifierProvider<RequestController, RequestState>(RequestController.new);
