import 'package:sidechain_core/providers/network_scoped.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/providers/wallet_reader_provider.dart';

class BalanceProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  final log = GetIt.I.get<Logger>();
  final List<RPCConnection> connections;

  /// The wallet the Send page spends. Its balance is the headline figure, and
  /// every other connection counts as a sidechain. Defaults to the first
  /// connection.
  late final RPCConnection mainConnection;

  final Map<RPCConnection, (double confirmed, double pending)> _balances = {};
  final Map<RPCConnection, double> _maturing = {};
  String? error;

  final Set<RPCConnection> _reported = {};

  /// Last error text printed per connection. A failure that stands, such as a
  /// wallet the network serves no chain source for, prints one time.
  final Map<RPCConnection, String> _loggedError = {};

  /// True once the headline connection answered. A sidechain answer must not
  /// clear the loading state, or the bar shows an unread zero as the balance.
  bool get initialized => _reported.contains(mainConnection);

  bool _isFetching = false;
  Timer? _fetchTimer;

  /// When [setBalance] last wrote each connection.
  final Map<RPCConnection, DateTime> _setAt = {};

  /// A poll skips a connection that [setBalance] wrote this recently.
  static const _setBalanceFresh = Duration(seconds: 6);

  /// When a poll last read each connection. [setBalance] holds no maturing
  /// balance, so a skipped connection still gets a read this often.
  final Map<RPCConnection, DateTime> _readAt = {};
  static const _maturingMaxAge = Duration(seconds: 30);

  // A recreated transport abandons in-flight requests without ever completing
  // their futures, which would latch _isFetching for the rest of the session.
  static const _fetchTimeout = Duration(seconds: 30);

  final WalletReaderProvider? _walletReader = GetIt.I.isRegistered<WalletReaderProvider>()
      ? GetIt.I.get<WalletReaderProvider>()
      : null;
  String? _lastWalletId;

  double get balance => balanceFor(mainConnection).$1;
  double get pendingBalance => balanceFor(mainConnection).$2;

  /// Coinbase coins of the headline wallet that cannot be spent yet.
  double get maturingBalance => _maturing[mainConnection] ?? 0.0;

  double get sidechainBalance => _otherConnections.fold(0.0, (sum, rpc) => sum + balanceFor(rpc).$1);
  double get sidechainPendingBalance => _otherConnections.fold(0.0, (sum, rpc) => sum + balanceFor(rpc).$2);

  Iterable<RPCConnection> get _otherConnections => connections.where((rpc) => rpc != mainConnection);

  // Get balance for specific RPC
  (double confirmed, double pending) balanceFor(RPCConnection rpc) => _balances[rpc] ?? (0.0, 0.0);

  BalanceProvider({required this.connections, RPCConnection? mainConnection}) {
    this.mainConnection = mainConnection ?? connections.first;
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

  BalanceProvider._mirror({required this.connections}) {
    mainConnection = connections.first;
    for (final rpc in connections) {
      _balances[rpc] = (0.0, 0.0);
    }
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
    final changed = _balances[rpc] != (confirmed, pending) || !_reported.contains(rpc);
    _setAt[rpc] = DateTime.now();
    _balances[rpc] = (confirmed, pending);
    _reported.add(rpc);
    if (changed) {
      error = null;
      notifyListeners();
    }
  }

  void clear() {
    for (final rpc in connections) {
      _balances[rpc] = (0.0, 0.0);
    }
    _maturing.clear();
    _setAt.clear();
    _readAt.clear();
    _reported.clear();
    _loggedError.clear();
    _lastWalletId = _walletReader?.activeWalletId;
    error = null;
    notifyListeners();
  }

  Future<void> fetch() => _fetch(skipFresh: false);

  /// The timer poll. It skips a connection whose balance another provider
  /// wrote with [setBalance] in the last [_setBalanceFresh], unless its last
  /// read is older than [_maturingMaxAge].
  @visibleForTesting
  Future<void> poll() => _fetch(skipFresh: true);

  Future<void> _fetch({required bool skipFresh}) async {
    if (_isFetching) {
      return;
    }
    final now = DateTime.now();

    try {
      _isFetching = true;

      var changed = false;

      // Fetch balances from all connections
      for (final rpc in connections) {
        if (!rpc.connected) {
          // dont bother fetching balance if connection is down
          continue;
        }
        final setAt = _setAt[rpc];
        final readAt = _readAt[rpc];
        if (skipFresh &&
            setAt != null &&
            now.difference(setAt) < _setBalanceFresh &&
            readAt != null &&
            now.difference(readAt) < _maturingMaxAge) {
          continue;
        }
        _readAt[rpc] = now;
        final (double confirmed, double pending, double maturing) balances;
        try {
          balances = await rpc.balances().timeout(_fetchTimeout);
        } catch (err) {
          // One unreachable chain must not stop the others from reporting.
          final text = err.toString();
          if (!isExpectedBootError(err) && _loggedError[rpc] != text) {
            log.w('BalanceProvider: ${rpc.binaryType.name} balance failed: $err');
            _loggedError[rpc] = text;
          }
          error = text;
          continue;
        }
        _loggedError.remove(rpc);
        final (confirmed, pending, maturing) = balances;
        if (_reported.add(rpc)) {
          // wen't from not initialized to initialized, make sure to notify
          changed = true;
        }

        if (_balances[rpc] != (confirmed, pending) || _maturing[rpc] != maturing) {
          _balances[rpc] = (confirmed, pending);
          _maturing[rpc] = maturing;
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
    _fetchTimer = Timer.periodic(const Duration(seconds: 1), (_) => poll());
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

/// The balance of one sidechain wallet, for the pages of that chain.
class SidechainBalanceProvider extends BalanceProvider {
  final BalanceProvider? _source;

  SidechainBalanceProvider({required RPCConnection sidechain}) : _source = null, super(connections: [sidechain]);

  /// Shows the balance that [source] reads for [sidechain], with no poll of its own.
  SidechainBalanceProvider.mirror({required RPCConnection sidechain, required BalanceProvider source})
    : assert(source.connections.contains(sidechain)),
      _source = source,
      super._mirror(connections: [sidechain]) {
    source.addListener(_copy);
    _copy();
  }

  void _copy() {
    final source = _source!;
    final rpc = mainConnection;
    if (!source._reported.contains(rpc)) {
      if (_reported.isNotEmpty) {
        clear();
      }
      return;
    }
    final (confirmed, pending) = source.balanceFor(rpc);
    setBalance(rpc, confirmed, pending);
  }

  @override
  Future<void> fetch() => _source?.fetch() ?? super.fetch();

  @override
  void dispose() {
    _source?.removeListener(_copy);
    super.dispose();
  }
}
