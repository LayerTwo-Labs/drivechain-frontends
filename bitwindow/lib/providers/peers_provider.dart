import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// The peer list of Bitcoin Core. It polls while a widget listens.
class PeersProvider extends ChangeNotifier implements NetworkScoped {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  static const _fetchInterval = Duration(seconds: 5);

  List<Peer> peers = [];
  bool _isFetching = false;
  Timer? _fetchTimer;
  String? _loggedError;

  PeersProvider() {
    bitwindowd.addListener(_onConnection);
    unawaited(fetch());
  }

  bool _connected = false;

  /// A tooltip opens with the list of the last read, so the list is read
  /// when bitwindowd connects, before the first open.
  void _onConnection() {
    final connected = bitwindowd.connected;
    if (connected == _connected) {
      return;
    }
    _connected = connected;
    unawaited(fetch());
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    if (_fetchTimer != null) {
      return;
    }
    unawaited(fetch());
    if (Environment.isInTest) {
      return;
    }
    _fetchTimer = Timer.periodic(_fetchInterval, (_) => fetch());
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _fetchTimer?.cancel();
      _fetchTimer = null;
    }
  }

  @override
  Future<void> onNetworkChanged() async {
    peers = [];
    notifyListeners();
  }

  Future<void> fetch() async {
    if (!NodeModeProvider.runsLocalBackends) {
      if (peers.isNotEmpty) {
        peers = [];
        notifyListeners();
      }
      return;
    }
    if (!bitwindowd.connected || _isFetching) {
      return;
    }
    _isFetching = true;
    try {
      final response = await _orchestrator.bitcoind.getPeerInfo(GetPeerInfoRequest());
      _loggedError = null;
      if (!listEquals(peers, response.peers)) {
        peers = List.of(response.peers);
        notifyListeners();
      }
    } catch (e) {
      if (!isExpectedBootError(e) && _loggedError != e.toString()) {
        _loggedError = e.toString();
        log.e('fetch peers: $e');
      }
    } finally {
      _isFetching = false;
    }
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    bitwindowd.removeListener(_onConnection);
    super.dispose();
  }
}
