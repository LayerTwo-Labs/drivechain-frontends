import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/env.dart';

class BalanceProvider extends ChangeNotifier {
  final log = GetIt.I.get<Logger>();
  final List<RPCConnection> connections;

  final Map<RPCConnection, (double confirmed, double pending)> _balances = {};
  String? error;

  bool initialized = false;
  bool _isFetching = false;
  Timer? _fetchTimer;

  // Utility getters for total balances
  double get balance => _balances.values.fold(0.0, (sum, b) => sum + b.$1);
  double get pendingBalance => _balances.values.fold(0.0, (sum, b) => sum + b.$2);

  // Get balance for specific RPC
  (double confirmed, double pending) balanceFor(RPCConnection rpc) => _balances[rpc] ?? (0.0, 0.0);

  BalanceProvider({required this.connections}) {
    // Add listeners for connection changes
    for (final rpc in connections) {
      rpc.addListener(_onConnectionChange);
      _balances[rpc] = (0.0, 0.0);
    }
    _startFetchTimer();
    fetch();
  }

  void _onConnectionChange() {
    fetch();
  }

  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }

    try {
      _isFetching = true;

      var changed = false;

      // Fetch balances from all connections
      for (final rpc in connections) {
        if (!rpc.connected) {
          // dont bother fetching balance if connection is down
          continue;
        }
        final (confirmed, pending) = await rpc.balance();
        if (!initialized) {
          // wen't from not initialized to initialized, make sure to notify
          changed = true;
          initialized = true;
        }

        if (_balances[rpc] != (confirmed, pending)) {
          _balances[rpc] = (confirmed, pending);
          changed = true;
        }
      }

      if (changed) {
        error = null;
        notifyListeners();
      }
    } catch (err) {
      error = err.toString();
    } finally {
      _isFetching = false;
    }
  }

  void _startFetchTimer() {
    if (Environment.isInTest) {
      return;
    }

    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(const Duration(seconds: 1), (_) => fetch());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    for (final rpc in connections) {
      rpc.removeListener(_onConnectionChange);
    }
    super.dispose();
  }
}
