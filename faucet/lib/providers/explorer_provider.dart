import 'dart:async';

import 'package:faucet/api/api_base.dart';
import 'package:faucet/env.dart';
import 'package:faucet/gen/explorer/v1/explorer.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class ExplorerProvider extends ChangeNotifier {
  API get api => GetIt.I.get<API>();

  ChainTip? mainchainTip;
  ChainTip? thunderTip;
  ChainTip? bitassetsTip;
  ChainTip? bitnamesTip;
  bool initialized = false;

  bool _isFetching = false;

  ExplorerProvider() {
    poll();
  }

  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final response = await api.clients.explorer.getChainTips(GetChainTipsRequest());

      // Always update the data and notify listeners
      if (response.mainchain.height > 0) {
        mainchainTip = response.mainchain;
      }
      if (response.thunder.height > 0) {
        thunderTip = response.thunder;
      }
      if (response.bitassets.height > 0) {
        bitassetsTip = response.bitassets;
      }
      if (response.bitnames.height > 0) {
        bitnamesTip = response.bitnames;
      }
      initialized = true;
      notifyListeners();
    } finally {
      _isFetching = false;
    }
  }

  Timer? _connectionTimer;
  void poll() {
    fetch();

    if (Environment.isInTest) {
      return;
    }

    _connectionTimer?.cancel();
    _connectionTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await fetch();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectionTimer?.cancel();
  }
}
