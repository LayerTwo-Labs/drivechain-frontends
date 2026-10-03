import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sidechain_core/providers/network_scoped.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';

/// Polls which pools mined the recent blocks while a page is listening.
class MiningPoolsProvider extends ChangeNotifier implements NetworkScoped {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();

  MiningPoolWindow window = MiningPoolWindow.MINING_POOL_WINDOW_24H;
  List<MiningPoolShare> pools = [];
  int blockCount = 0;
  int fromHeight = 0;
  int toHeight = 0;
  double networkHashrate = 0;
  bool registryAvailable = false;
  String registrySource = '';
  String? error;

  bool isFetching = false;
  Timer? _timer;

  MiningPoolsProvider() {
    if (!Environment.isInTest) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => fetch());
    }
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    unawaited(fetch());
  }

  @override
  Future<void> onNetworkChanged() async {
    pools = [];
    blockCount = 0;
    fromHeight = 0;
    toHeight = 0;
    networkHashrate = 0;
    registryAvailable = false;
    registrySource = '';
    error = null;
    notifyListeners();
  }

  Future<void> fetch() async {
    if (!hasListeners || !api.connected || isFetching) {
      return;
    }
    isFetching = true;
    try {
      final response = await api.bitwindowd.listMiningPools(window);
      pools = response.pools;
      blockCount = response.blockCount;
      fromHeight = response.fromHeight;
      toHeight = response.toHeight;
      networkHashrate = response.networkHashrate;
      registryAvailable = response.registryAvailable;
      registrySource = response.registrySource;
      error = null;
    } catch (e) {
      error = e.toString();
      log.e('mining pools fetch: $e');
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  void setWindow(MiningPoolWindow value) {
    window = value;
    notifyListeners();
    unawaited(fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
