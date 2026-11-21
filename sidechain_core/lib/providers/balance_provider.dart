import 'package:sidechain_core/providers/network_scoped.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/bitcoin.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/providers/wallet_reader_provider.dart';
import 'package:sidechain_core/rpcs/stream_supervisor.dart';

class BalanceProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    // A wallet ID can hold another balance on the new network.
    _frames.clear();
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

  // A recreated transport abandons in-flight requests without ever completing
  // their futures, which would latch _isFetching for the rest of the session.
  static const _fetchTimeout = Duration(seconds: 30);

  final Map<RPCConnection, StreamSupervisor<wmpb.WatchBalanceResponse>> _watches = {};

  /// The last balance frame of each streamed connection, for any wallet.
  final Map<RPCConnection, wmpb.WatchBalanceResponse> _frames = {};

  /// The transactions that a send made in the active wallet, from the last balance
  /// frame of [mainConnection] that carried any.
  final newestTransactions = ValueNotifier<List<wmpb.TransactionEntry>?>(null);

  /// True while [rpc] gets its balance from a stream and not from the poll.
  bool streams(RPCConnection rpc) => (_watches[rpc]?.isHealthy ?? false) && _frames.containsKey(rpc);

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
      final listener = _connectionListeners[rpc] = () => _onConnectionChange(rpc);
      rpc.addListener(listener);
      _balances[rpc] = (0.0, 0.0);
      if (rpc.connected) {
        _wasConnected.add(rpc);
      }
    }
    _walletReader?.addListener(_onWalletChanged);
    _lastWalletId = _walletReader?.activeWalletId;
    _startWatches();
    _startFetchTimer();
    fetch();
  }

  BalanceProvider._mirror({required this.connections}) {
    mainConnection = connections.first;
    for (final rpc in connections) {
      _balances[rpc] = (0.0, 0.0);
    }
  }

  void _startWatches() {
    for (final rpc in connections) {
      _startWatch(rpc);
    }
  }

  void _startWatch(RPCConnection rpc) {
    final stream = rpc.balanceStream;
    if (stream == null) {
      return;
    }
    _watches[rpc] = StreamSupervisor<wmpb.WatchBalanceResponse>(
      subscribe: stream.subscribe,
      onEvent: (frame) => _onFrame(rpc, frame),
      onTransportDeath: stream.onTransportDeath,
      logger: log,
      tag: 'BalanceProvider(${rpc.binaryType.name})',
    )..start();
  }

  final Map<RPCConnection, VoidCallback> _connectionListeners = {};
  final Set<RPCConnection> _wasConnected = {};

  /// Subscribes again at once to the stream of a chain that came up. The
  /// attempts before it met no server, and their backoff can wait 5 s.
  void _resubscribeOnConnect(RPCConnection rpc) {
    if (!rpc.connected) {
      _wasConnected.remove(rpc);
      return;
    }
    if (!_wasConnected.add(rpc)) {
      return;
    }
    final watch = _watches[rpc];
    if (watch == null || watch.isHealthy) {
      return;
    }
    unawaited(watch.dispose());
    _startWatch(rpc);
  }

  void _onFrame(RPCConnection rpc, wmpb.WatchBalanceResponse frame) {
    if (frame.heartbeat) {
      return;
    }
    // No wallet is active, so the poll reports the error as before.
    if (frame.walletId.isEmpty) {
      _frames.remove(rpc);
      return;
    }
    _frames[rpc] = frame;
    final activeId = _walletReader?.activeWalletId;
    if (rpc == mainConnection && frame.transactions.isNotEmpty && (activeId == null || frame.walletId == activeId)) {
      newestTransactions.value = frame.transactions;
    }
    if (_applyFrame(rpc)) {
      error = null;
      notifyListeners();
    }
  }

  /// Shows the last frame of [rpc] if it holds the balance of the active
  /// wallet. Returns true if the balance changed.
  bool _applyFrame(RPCConnection rpc) {
    final frame = _frames[rpc];
    final activeId = _walletReader?.activeWalletId;
    if (frame == null || (activeId != null && frame.walletId != activeId)) {
      return false;
    }
    _loggedError.remove(rpc);
    return _store(
      rpc,
      satoshiToBTC(frame.balance.confirmedSats.round()),
      satoshiToBTC(frame.balance.unconfirmedSats.round()),
      satoshiToBTC(frame.balance.immatureSats.round()),
    );
  }

  /// Returns true if the balance of [rpc] changed or was not read before.
  bool _store(RPCConnection rpc, double confirmed, double pending, double maturing) {
    var changed = _reported.add(rpc);
    if (_balances[rpc] != (confirmed, pending) || _maturing[rpc] != maturing) {
      _balances[rpc] = (confirmed, pending);
      _maturing[rpc] = maturing;
      changed = true;
    }
    return changed;
  }

  void _onConnectionChange(RPCConnection rpc) {
    _resubscribeOnConnect(rpc);
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
    _balances[rpc] = (confirmed, pending);
    _reported.add(rpc);
    if (changed) {
      error = null;
      notifyListeners();
    }
  }

  void clear() {
    newestTransactions.value = null;
    for (final rpc in connections) {
      _balances[rpc] = (0.0, 0.0);
    }
    _maturing.clear();
    _reported.clear();
    _loggedError.clear();
    _lastWalletId = _walletReader?.activeWalletId;
    error = null;
    notifyListeners();
  }

  /// The timer poll.
  @visibleForTesting
  Future<void> poll() => fetch();

  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }

    try {
      _isFetching = true;

      var changed = false;

      // Fetch balances from all connections
      for (final rpc in connections) {
        if (streams(rpc)) {
          if (_applyFrame(rpc)) {
            changed = true;
          }
          continue;
        }
        if (!rpc.connected) {
          // dont bother fetching balance if connection is down
          continue;
        }
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
        // A frame that came during the read is newer.
        if (streams(rpc)) {
          continue;
        }
        _loggedError.remove(rpc);
        final (confirmed, pending, maturing) = balances;
        if (_store(rpc, confirmed, pending, maturing)) {
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
    newestTransactions.dispose();
    for (final watch in _watches.values) {
      unawaited(watch.dispose());
    }
    _walletReader?.removeListener(_onWalletChanged);
    _connectionListeners.forEach((rpc, listener) => rpc.removeListener(listener));
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
