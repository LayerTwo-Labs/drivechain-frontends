import 'package:sidechain_core/providers/network_scoped.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/providers/sync_provider.dart';
import 'package:sidechain_core/providers/wallet_reader_provider.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';

/// Apply a CheckChequeFundingResponse to the in-memory cheque list. Returns
/// true when [checks] was mutated and listeners should be notified.
///
/// Extracted as a pure function so the polling state machine can be unit
/// tested without bringing up GetIt, the WalletReader, or the RPC client.
bool applyFundingResponse(
  List<Cheque> checks,
  int id,
  CheckChequeFundingResponse resp,
) {
  if (resp.fundedTxids.isEmpty) {
    return false;
  }
  final index = checks.indexWhere((c) => c.id == id);
  if (index == -1) {
    return false;
  }
  checks[index] = Cheque(
    id: checks[index].id,
    derivationIndex: checks[index].derivationIndex,
    address: checks[index].address,
    expectedAmountSats: checks[index].expectedAmountSats,
    funded: resp.funded,
    fundedTxids: resp.fundedTxids,
    actualAmountSats: resp.actualAmountSats,
    createdAt: checks[index].createdAt,
    fundedAt: resp.hasFundedAt() ? resp.fundedAt : null,
  );
  return true;
}

class CheckProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  final Logger log = Logger(level: Level.debug);
  final BitwindowRPC _bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  final WalletReaderProvider _walletReader = GetIt.I.get<WalletReaderProvider>();
  SyncProvider get _syncProvider => GetIt.I.get<SyncProvider>();

  List<Cheque> _checks = [];
  bool _isLoading = false;
  String? modelError;

  List<Cheque> get checks => _checks;
  bool get isLoading => _isLoading;

  Timer? _pollTimer;
  int? _pollingCheckId;
  Timer? _unfundedPollTimer;
  final SyncedTipWatch _tip = SyncedTipWatch();

  CheckProvider() {
    _syncProvider.addListener(_onNewBlock);
    _walletReader.addListener(_onWalletChanged);
    _init();
  }

  Future<void> _init() async {
    await fetch();
    _startUnfundedPolling();
  }

  void _startUnfundedPolling() {
    _unfundedPollTimer?.cancel();
    _unfundedPollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_checks.isEmpty) {
        if (modelError != null) {
          await fetch();
        }
        return;
      }
      final hasUnfunded = _checks.any((c) => !c.funded);
      if (!hasUnfunded) {
        return;
      }
      await _checkUnfundedChecks();
    });
  }

  Future<void> _checkUnfundedChecks() async {
    final unfunded = _checks.where((c) => !c.funded).toList();
    await Future.wait(unfunded.map((check) => checkCheckFunding(check.id.toInt())));
  }

  void _onNewBlock() {
    if (_tip.moved(_syncProvider, synced: _syncProvider.isSynced)) {
      fetch();
    }
  }

  void _onWalletChanged() {
    clear();
    fetch();
  }

  void clear() {
    _checks = [];
    notifyListeners();
  }

  Future<void> fetch() async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      return;
    }

    final (shownChecks, shownError) = (_checks, modelError);
    _isLoading = true;

    try {
      _checks = await _bitwindowRPC.wallet.listCheques(walletId);
      modelError = null;
      // Also check funding for unfunded checks (detects mempool txs)
      await _checkUnfundedChecks();
    } catch (e) {
      if (!isExpectedBootError(e)) {
        log.e('Failed to fetch checks: $e');
      }
      modelError = e.toString();
    } finally {
      _isLoading = false;
      if (shownError != modelError || !listEquals(shownChecks, _checks)) {
        notifyListeners();
      }
    }
  }

  Future<Cheque> createCheck(int expectedAmountSats) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      throw Exception('No active wallet');
    }
    final resp = await _bitwindowRPC.wallet.createCheque(walletId, expectedAmountSats);
    final check = await _bitwindowRPC.wallet.getCheque(walletId, resp.id.toInt());

    _checks.insert(0, check);
    notifyListeners();
    return check;
  }

  Future<Cheque?> getCheck(int id) async {
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) {
        throw Exception('No active wallet');
      }
      return await _bitwindowRPC.wallet.getCheque(walletId, id);
    } catch (e) {
      log.e('Failed to get check: $e');
      return null;
    }
  }

  Future<bool> checkCheckFunding(int id) async {
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) {
        throw Exception('No active wallet');
      }
      final resp = await _bitwindowRPC.wallet.checkChequeFunding(walletId, id);

      if (applyFundingResponse(_checks, id, resp)) {
        notifyListeners();
      }

      return resp.funded;
    } catch (e) {
      log.e('Failed to check check funding: $e');
      return false;
    }
  }

  Future<String> sweepCheck(String privateKeyWif, String destinationAddress, int feeSatPerVbyte) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      throw Exception('No active wallet');
    }
    final result = await _bitwindowRPC.wallet.sweepCheque(
      walletId,
      privateKeyWif,
      destinationAddress,
      feeSatPerVbyte,
    );
    await fetch();
    return result.txid;
  }

  Future<bool> deleteCheck(int id) async {
    try {
      if (_pollingCheckId == id) {
        stopPolling();
      }

      final walletId = _walletReader.activeWalletId;
      if (walletId == null) {
        throw Exception('No active wallet');
      }
      await _bitwindowRPC.wallet.deleteCheque(walletId, id);
      _checks.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      log.e('Failed to delete check: $e');
      modelError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void startPolling(int checkId, {Duration interval = const Duration(seconds: 5)}) {
    stopPolling();
    _pollingCheckId = checkId;
    _pollTimer = Timer.periodic(interval, (_) async {
      try {
        final funded = await checkCheckFunding(checkId);
        if (funded) {
          stopPolling();
        }
      } catch (e) {
        log.w('Error checking check funding (check may have been deleted): $e');
        stopPolling();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollingCheckId = null;
  }

  @override
  void dispose() {
    _syncProvider.removeListener(_onNewBlock);
    _walletReader.removeListener(_onWalletChanged);
    stopPolling();
    _unfundedPollTimer?.cancel();
    super.dispose();
  }
}
