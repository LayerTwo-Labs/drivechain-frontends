import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';

class AddressProvider extends ChangeNotifier {
  SidechainRPC get rpc => GetIt.I.get<SidechainRPC>();

  String? receiveAddress;
  String? depositAddress;
  bool initialized = false;
  String? _error;
  String? _depositError;

  String? get error => rpc.connected ? _error : null;
  String? get depositError => rpc.connected ? _depositError : null;

  bool _isFetching = false;
  Timer? _retryTimer;

  AddressProvider() {
    // fetching on each rpc update makes sure
    // we fetch an address immediately after the rpc
    // is connected
    rpc.addListener(fetch);
    // fetch immediately in case rpc is connected
    fetch();
    _startRetryTimer();
  }

  void _startRetryTimer() {
    if (Environment.isInTest) {
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (receiveAddress != null && depositAddress != null) {
        timer.cancel();
        _retryTimer = null;
        return;
      }
      fetch();
    });
  }

  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    _error = null;
    _depositError = null;

    if (receiveAddress == null) {
      try {
        receiveAddress = await rpc.getSideAddress();
        initialized = true;
      } catch (e) {
        _error = e.toString();
      } finally {
        notifyListeners();
      }
    }

    if (depositAddress == null) {
      try {
        depositAddress = await rpc.getDepositAddress();
        initialized = true;
      } catch (e) {
        _depositError = e.toString();
      } finally {
        notifyListeners();
      }
    }

    _isFetching = false;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    rpc.removeListener(fetch);
    super.dispose();
  }
}
