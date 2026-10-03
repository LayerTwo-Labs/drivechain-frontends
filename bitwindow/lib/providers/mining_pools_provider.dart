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

  /// The registered pool that serves [stratumUrl], or null.
  MiningPoolShare? shareFor(String stratumUrl) {
    if (stratumUrl.trim().isEmpty) {
      return null;
    }
    for (final share in pools) {
      if (samePoolUrl(share.pool.stratumUrl, stratumUrl)) {
        return share;
      }
    }
    return null;
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

/// Two stratum URLs name the same pool when they differ only in case,
/// whitespace, or a trailing slash.
bool samePoolUrl(String a, String b) {
  String normal(String url) {
    var out = url.trim().toLowerCase();
    while (out.endsWith('/')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  return normal(a).isNotEmpty && normal(a) == normal(b);
}

/// The short label of a window, as the Pools tab and the pool menu show it.
String miningPoolWindowLabel(MiningPoolWindow window) {
  return switch (window) {
    MiningPoolWindow.MINING_POOL_WINDOW_3D => '3 d',
    MiningPoolWindow.MINING_POOL_WINDOW_1W => '7 d',
    _ => '24 h',
  };
}
