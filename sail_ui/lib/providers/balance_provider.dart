import 'package:sail_ui/providers/network_scoped.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';

class BalanceProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  final log = GetIt.I.get<Logger>();
  final List<RPCConnection> connections;

  final Map<RPCConnection, (double confirmed, double pending)> _balances = {};
  String? error;

  bool initialized = false;
  bool _isFetching = false;
  Timer? _fetchTimer;

  // A recreated transport abandons in-flight requests without ever completing
  // their futures, which would latch _isFetching for the rest of the session.
  static const _fetchTimeout = Duration(seconds: 30);

  final WalletReaderProvider? _walletReader = GetIt.I.isRegistered<WalletReaderProvider>()
      ? GetIt.I.get<WalletReaderProvider>()
      : null;
  String? _lastWalletId;

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
    _walletReader?.addListener(_onWalletChanged);
    _lastWalletId = _walletReader?.activeWalletId;
    _startFetchTimer();
    fetch();
  }

  void _onConnectionChange() {
    fetch();
  }

  // A balance belongs to one wallet, so drop it the moment another becomes
  // active instead of showing the previous wallet's coins until a poll lands.
  void _onWalletChanged() {
    final currentId = _walletReader?.activeWalletId;
    if (currentId == _lastWalletId) {
      return;
    }
    _lastWalletId = currentId;
    clear();
    unawaited(fetch());
  }

  // Write a balance fetched elsewhere in the same batch as utxos/transactions,
  // so the displayed number can't drift from the list it belongs to.
  void setBalance(RPCConnection rpc, double confirmed, double pending) {
    final changed = _balances[rpc] != (confirmed, pending) || !initialized;
    _balances[rpc] = (confirmed, pending);
    initialized = true;
    if (changed) {
      error = null;
      notifyListeners();
    }
  }

  void clear() {
    for (final rpc in connections) {
      _balances[rpc] = (0.0, 0.0);
    }
    initialized = false;
    _lastWalletId = _walletReader?.activeWalletId;
    error = null;
    notifyListeners();
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
        final (double confirmed, double pending) balances;
        try {
          balances = await rpc.balance().timeout(_fetchTimeout);
        } catch (err) {
          // One unreachable chain must not stop the others from reporting.
          if (!isExpectedBootError(err)) {
            log.w('BalanceProvider: ${rpc.binaryType.name} balance failed: $err');
          }
          error = err.toString();
          continue;
        }
        final (confirmed, pending) = balances;
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
      log.w('BalanceProvider: fetch failed: $err');
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
    _walletReader?.removeListener(_onWalletChanged);
    for (final rpc in connections) {
      rpc.removeListener(_onConnectionChange);
    }
    super.dispose();
  }
}
