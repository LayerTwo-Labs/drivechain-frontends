import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class AddressBookProvider extends ChangeNotifier {
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();

  List<AddressBookEntry> _entries = [];
  List<AddressBookEntry> get entries => _entries;
  List<AddressBookEntry> get sendEntries =>
      _entries.where((entry) => entry.direction == Direction.DIRECTION_SEND).toList();
  List<AddressBookEntry> get receiveEntries =>
      _entries.where((entry) => entry.direction == Direction.DIRECTION_RECEIVE).toList();

  String? error;
  bool _isFetching = false;

  AddressBookProvider() {
    bitwindowd.addListener(fetch);
  }

  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final response = await bitwindowd.bitwindowd.listAddressBook();

      if (_dataHasChanged(response)) {
        _entries = response;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString() != error) {
        error = e.toString();
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(List<AddressBookEntry> newEntries) {
    return !listEquals(entries, newEntries);
  }

  Future<void> createEntry(String label, String address, Direction direction) async {
    await bitwindowd.bitwindowd.createAddressBookEntry(label, address, direction);
    await fetch();
    notifyListeners();
  }

  Future<void> updateLabel(Int64 id, String newLabel) async {
    await bitwindowd.bitwindowd.updateAddressBookEntry(id, newLabel);
    await fetch();
  }

  Future<void> deleteEntry(Int64 id) async {
    await bitwindowd.bitwindowd.deleteAddressBookEntry(id);
    await fetch();
  }
}
