import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';

class AddressProvider extends ChangeNotifier {
  ThunderRPC get rpc => GetIt.I.get<ThunderRPC>();

  String? receiveAddress;
  String? depositAddress;
  bool initialized = false;
  String? error;
  String? depositError;

  bool _isFetching = false;

  AddressProvider() {
    // fetching on each rpc update makes sure
    // we fetch an address immediately after the rpc
    // is connected
    rpc.addListener(fetch);
    // fetch immediately in case rpc is connected
    fetch();
  }

  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    error = null;
    depositError = null;

    if (receiveAddress == null) {
      try {
        receiveAddress = await rpc.getSideAddress();
        initialized = true;
      } catch (e) {
        log.e('Failed to generate addresses: $e');
        error = e.toString();
      } finally {
        notifyListeners();
      }
    }

    if (depositAddress == null) {
      try {
        depositAddress = await rpc.getDepositAddress();
        initialized = true;
      } catch (e) {
        log.e('Failed to generate addresses: $e');
        depositError = e.toString();
      } finally {
        notifyListeners();
      }
    }

    _isFetching = false;
  }

  @override
  void dispose() {
    rpc.removeListener(fetch);
    super.dispose();
  }
}
