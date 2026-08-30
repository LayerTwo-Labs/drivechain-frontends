import 'package:bitwindow/utils/coin_selection.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as pb;
import 'package:sidechain_core/rpcs/bitwindow_api.dart';

/// Provider for UTXO metadata and coin selection strategy state.
/// Read-only state holder - mutations go through BitwindowRPC.wallet.
class CoinSelectionProvider extends ChangeNotifier {
  BitwindowRPC get _rpc => GetIt.I.get<BitwindowRPC>();
  Logger get _log => GetIt.I.get<Logger>();

  Map<String, pb.UTXOMetadata> _metadata = {};
  CoinSelectionStrategy _strategy = CoinSelectionStrategy.largestFirst;
  String? error;
  Future<void>? _inFlight;

  // Getters
  Map<String, pb.UTXOMetadata> get metadata => _metadata;
  CoinSelectionStrategy get strategy => _strategy;
  bool isFrozen(String outpoint) => _metadata[outpoint]?.isFrozen_2 ?? false;
  String getLabel(String outpoint) => _metadata[outpoint]?.label ?? '';
  Set<String> get frozenOutpoints => _metadata.entries.where((e) => e.value.isFrozen_2).map((e) => e.key).toSet();

  CoinSelectionProvider() {
    _rpc.addListener(fetch);
    fetch();
  }

  /// Fetches all UTXO metadata and coin selection strategy from backend.
  /// A caller that arrives during a read joins that read.
  Future<void> fetch() async {
    await (_inFlight ?? _read());
  }

  /// Reads metadata the backend holds now. A read already in flight may have
  /// started before the caller's own write, so this waits for it and reads
  /// again. Use it after a write that the UI must see at once.
  ///
  /// It throws when the read fails, because a caller that treats this as a
  /// barrier must not go on with a cache it could not update.
  Future<void> refresh() async {
    final inFlight = _inFlight;
    if (inFlight != null) {
      await inFlight;
    }
    final failure = await _read();
    if (failure != null) {
      throw failure;
    }
  }

  /// Runs one read and reports its failure instead of throwing, so a plain
  /// [fetch] stays quiet.
  Future<Object?> _read() {
    final future = _fetchOnce();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
  }

  Future<Object?> _fetchOnce() async {
    try {
      final results = await Future.wait([
        _rpc.wallet.getUTXOMetadata([]),
        _rpc.wallet.getCoinSelectionStrategy(),
      ]);

      final newMetadata = results[0] as Map<String, pb.UTXOMetadata>;
      final newStrategy = _fromProto(results[1] as pb.CoinSelectionStrategy);

      bool changed = false;
      if (!mapEquals(_metadata, newMetadata)) {
        _metadata = newMetadata;
        changed = true;
      }
      if (_strategy != newStrategy) {
        _strategy = newStrategy;
        changed = true;
      }
      if (changed) {
        notifyListeners();
      }
      return null;
    } catch (e) {
      if (e.toString() != error) {
        error = e.toString();
        if (!isExpectedBootError(e)) {
          _log.w('Failed to fetch coin selection data: $e');
        }
        notifyListeners();
      }
      return e;
    }
  }

  CoinSelectionStrategy _fromProto(pb.CoinSelectionStrategy proto) {
    switch (proto) {
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_SMALLEST_FIRST:
        return CoinSelectionStrategy.smallestFirst;
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_RANDOM:
        return CoinSelectionStrategy.random;
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND:
        return CoinSelectionStrategy.branchAndBound;
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_LARGEST_FIRST:
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_UNSPECIFIED:
      default:
        return CoinSelectionStrategy.largestFirst;
    }
  }
}
