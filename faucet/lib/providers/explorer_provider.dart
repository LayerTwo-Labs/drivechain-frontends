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
  ChainTip? zsideTip;

  bool isFetching = false;

  ExplorerProvider() {
    poll();
  }

  Future<void> fetch() async {
    if (isFetching) {
      return;
    }
    isFetching = true;

    try {
      final response = await api.clients.explorer.getChainTips(GetChainTipsRequest());

      // Track if any data actually changed
      bool hasChanges = false;

      // Only update and mark as changed if the data actually differs
      if (mainchainTip != response.mainchain) {
        mainchainTip = response.mainchain;
        hasChanges = true;
      }

      if (thunderTip != response.thunder) {
        thunderTip = response.thunder;
        hasChanges = true;
      }

      if (bitassetsTip != response.bitassets) {
        bitassetsTip = response.bitassets;
        hasChanges = true;
      }

      if (bitnamesTip != response.bitnames) {
        bitnamesTip = response.bitnames;
        hasChanges = true;
      }

      if (zsideTip != response.zside) {
        zsideTip = response.zside;
        hasChanges = true;
      }

      // Only notify if data actually changed or if this is the first initialization
      if (hasChanges) {
        notifyListeners();
      }
    } finally {
      isFetching = false;
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
