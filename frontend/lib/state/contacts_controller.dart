import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/models.dart';
import 'auth_controller.dart';
import 'providers.dart';

/// Daftar kontak milik user. Mulai kosong lalu dimuat async dari [build] —
/// state tetap sinkron ([Notifier]) supaya UI baca `.state` langsung, sementara
/// pemuatan awal & aksi lain jalan di latar belakang lewat `ref.read`.
class ContactsController extends Notifier<List<Contact>> {
  @override
  List<Contact> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final api = ref.read(walletApiProvider);
    final userId = ref.read(walletProvider)?.userId ?? 'me';
    switch (await api.listContacts(userId)) {
      case Ok(value: final list):
        state = list;
      case Err():
        break;
    }
  }

  List<Contact> get favoriteContacts =>
      state.where((c) => c.isFavorite).toList();

  void toggleFavorite(String id) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(isFavorite: !c.isFavorite) else c
    ];
  }

  Future<void> addContact({
    required String name,
    required String relation,
    required String accountRef,
  }) async {
    final api = ref.read(walletApiProvider);
    switch (await api.addContact(
        name: name, relation: relation, accountRef: accountRef)) {
      case Ok(value: final c):
        state = [...state, c];
      case Err():
        break;
    }
  }
}

final contactsControllerProvider =
    NotifierProvider<ContactsController, List<Contact>>(
        ContactsController.new);
