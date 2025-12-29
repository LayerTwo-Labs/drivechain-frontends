import 'package:bitwindow/utils/coin_selection.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart' as pb;
import 'package:sail_ui/rpcs/bitwindow_api.dart';

/// Provider for UTXO metadata and coin selection strategy state.
/// Read-only state holder - mutations go through BitwindowRPC.wallet.
class CoinSelectionProvider extends ChangeNotifier {
  BitwindowRPC get _rpc => GetIt.I.get<BitwindowRPC>();
  Logger get _log => GetIt.I.get<Logger>();

  Map<String, pb.UTXOMetadata> _metadata = {};
  CoinSelectionStrategy _strategy = CoinSelectionStrategy.largestFirst;
  String? error;
  bool _isFetching = false;

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

  /// Fetches all UTXO metadata and coin selection strategy from backend
  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;

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
      if (changed) notifyListeners();
    } catch (e) {
      if (e.toString() != error) {
        error = e.toString();
        _log.w('Failed to fetch coin selection data: $e');
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  CoinSelectionStrategy _fromProto(pb.CoinSelectionStrategy proto) {
    switch (proto) {
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_SMALLEST_FIRST:
        return CoinSelectionStrategy.smallestFirst;
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_RANDOM:
        return CoinSelectionStrategy.random;
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_LARGEST_FIRST:
      case pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_UNSPECIFIED:
      default:
        return CoinSelectionStrategy.largestFirst;
    }
  }
}
