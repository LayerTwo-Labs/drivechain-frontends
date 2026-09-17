import 'package:sidechain_core/providers/network_scoped.dart';
import 'package:sidechain_core/providers/node_mode_provider.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/drivechain/v1/drivechain.pb.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/providers/bitcoin_conf_provider.dart';
import 'package:sidechain_core/providers/sync_provider.dart';
import 'package:sidechain_core/providers/wallet_reader_provider.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';

/// True when a failed fetch may run again: at most one time per [gap]. The
/// sync poll fires every 100 ms, and a retry on each would hit the backend
/// ten times a second.
bool retryIsDue({required DateTime? last, required DateTime now, required Duration gap}) {
  return last == null || now.difference(last) >= gap;
}

class SidechainProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  Logger get log => GetIt.I.get<Logger>();

  SyncProvider get _syncProvider => GetIt.I.get<SyncProvider>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  // This always has 256 slots. The fetch-method fills in the slots that
  // are actually in use.
  List<SidechainOverview?> sidechains = List.filled(256, null);

  List<SidechainProposal> sidechainProposals = [];

  bool _isFetching = false;

  String? error;

  /// A failed first fetch holds its error until the next one lands, and the
  /// synced gate below stays shut for the whole mainchain sync.
  static const _retryGap = Duration(seconds: 5);
  DateTime? _lastRetryAt;

  /// Last wallet ID we fetched for. Used to detect an actual wallet switch
  /// (vs. the stream just delivering a periodic refresh of the same wallet).
  String? _lastWalletId;

  SidechainProvider() {
    _syncProvider.addListener(_onSync);
    _walletReader.addListener(_onWalletChanged);
    _lastWalletId = _walletReader.activeWalletId;
    fetch();
  }

  void clear() {
    sidechains = List.filled(256, null);
    sidechainProposals = [];
    _lastWalletId = _walletReader.activeWalletId;
    error = null;
    _lastRetryAt = null;
    notifyListeners();
  }

  void _onSync() {
    final synced = NodeModeProvider.runsLocalBackends
        ? _syncProvider.isSynced
        : (_syncProvider.enforcerSyncInfo?.isSynced ?? false);
    if (synced) {
      fetch();
      return;
    }
    if (error == null || !_retryIsDue()) {
      return;
    }
    fetch();
  }

  bool _retryIsDue() {
    final now = DateTime.now();
    if (!retryIsDue(last: _lastRetryAt, now: now, gap: _retryGap)) {
      return false;
    }
    _lastRetryAt = now;
    return true;
  }

  void _onWalletChanged() {
    final currentId = _walletReader.activeWalletId;
    if (currentId == _lastWalletId) {
      // Same wallet, unrelated stream tick. No refetch needed.
      return;
    }
    _lastWalletId = currentId;

    // Actual wallet switch: refetch. The old data stays visible until fetch
    // completes and atomically replaces `sidechains` — no clear-to-empty
    // intermediate state.
    fetch();
  }

  // call this function from anywhere to refetch sidechain info
  Future<void> fetch() async {
    if (!GetIt.I.get<BitcoinConfProvider>().drivechainFeaturesAvailable) {
      return;
    }
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      if (_walletReader.activeWalletId == null) {
        throw Exception('No active wallet');
      }

      // Each deposit records the wallet that made it, so the history follows
      // the wallet the user is looking at.
      final historyWalletId = _walletReader.activeWalletId;

      final newSidechains = await bitwindowd.drivechain.listSidechains();
      final newSidechainProposals = await bitwindowd.drivechain.listSidechainProposals();

      // Create a new list with 256 slots
      List<SidechainOverview?> updatedSidechains = List.filled(256, null);

      // Fill in the slots with the data retrieved from the API
      for (var sidechain in newSidechains) {
        final deposits = historyWalletId == null
            ? <ListSidechainDepositsResponse_SidechainDeposit>[]
            : await bitwindowd.wallet.listSidechainDeposits(historyWalletId, sidechain.slot);
        final withdrawals = await bitwindowd.drivechain.listWithdrawals(sidechainId: sidechain.slot);
        updatedSidechains[sidechain.slot] = SidechainOverview(sidechain, deposits, withdrawals);
      }

      final changed =
          _dataHasChanged(sidechains, updatedSidechains) || _dataHasChanged(sidechainProposals, newSidechainProposals);
      if (changed) {
        sidechains = updatedSidechains;
        sidechainProposals = newSidechainProposals;
      }
      // A chain with no sidechains answers with the list the provider starts
      // from, and the error of the tick before still has to go.
      if (changed || error != null) {
        error = null;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString() != error) {
        error = e.toString();
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged<T>(List<T> oldData, List<T> newData) {
    if (!listEquals(oldData, newData)) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _syncProvider.removeListener(_onSync);
    _walletReader.removeListener(_onWalletChanged);
    super.dispose();
  }
}

class SidechainOverview {
  final ListSidechainsResponse_Sidechain info;
  final List<ListSidechainDepositsResponse_SidechainDeposit> deposits;
  final List<WithdrawalBundle> withdrawals;

  SidechainOverview(this.info, this.deposits, this.withdrawals);
}
