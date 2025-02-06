import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class AddressBookProvider extends ChangeNotifier {
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();

  List<AddressBookEntry> _entries = [];
  List<AddressBookEntry> get sendEntries =>
      _entries.where((entry) => entry.direction == Direction.DIRECTION_SEND).toList();
  List<AddressBookEntry> get receiveEntries =>
      _entries.where((entry) => entry.direction == Direction.DIRECTION_RECEIVE).toList();

  String? error;
  bool _isFetching = false;

  // CRUD operations
  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final response = await api.bitwindowd.listAddressBook();
      _entries = response;
    } catch (e) {
      error = e.toString();
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> createEntry(String label, String address, Direction direction) async {
    try {
      await api.bitwindowd.createAddressBookEntry(label, address, direction);
      await fetch();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLabel(Int64 id, String newLabel) async {
    try {
      await api.bitwindowd.updateAddressBookEntry(id, newLabel);
      await fetch();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEntry(Int64 id) async {
    try {
      await api.bitwindowd.deleteAddressBookEntry(id);
      await fetch();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
