import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/sync_provider.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class CheckProvider extends ChangeNotifier {
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

  CheckProvider() {
    _syncProvider.addListener(_onNewBlock);
    _walletReader.addListener(_onWalletChanged);
    _init();
  }

  Future<void> _init() async {
    await fetch();
  }

  void _onNewBlock() {
    if (_syncProvider.isSynced) {
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

    _isLoading = true;
    modelError = null;
    notifyListeners();

    try {
      _checks = await _bitwindowRPC.wallet.listCheques(walletId);
      modelError = null;
    } catch (e) {
      log.e('Failed to fetch checks: $e');
      modelError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cheque> createCheck(int expectedAmountSats) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) throw Exception('No active wallet');
    final resp = await _bitwindowRPC.wallet.createCheque(walletId, expectedAmountSats);

    final check = Cheque(
      id: resp.id,
      derivationIndex: resp.derivationIndex,
      address: resp.address,
      expectedAmountSats: Int64(expectedAmountSats),
    );

    _checks.insert(0, check);
    notifyListeners();
    return check;
  }

  Future<Cheque?> getCheck(int id) async {
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');
      return await _bitwindowRPC.wallet.getCheque(walletId, id);
    } catch (e) {
      log.e('Failed to get check: $e');
      return null;
    }
  }

  Future<bool> checkCheckFunding(int id) async {
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');
      final resp = await _bitwindowRPC.wallet.checkChequeFunding(walletId, id);

      if (resp.funded) {
        final index = _checks.indexWhere((c) => c.id == id);
        if (index != -1) {
          _checks[index] = Cheque(
            id: _checks[index].id,
            derivationIndex: _checks[index].derivationIndex,
            address: _checks[index].address,
            expectedAmountSats: _checks[index].expectedAmountSats,
            fundedTxid: resp.fundedTxid,
            actualAmountSats: resp.actualAmountSats,
            createdAt: _checks[index].createdAt,
            fundedAt: resp.hasFundedAt() ? resp.fundedAt : null,
          );
          notifyListeners();
        }
      }

      return resp.funded;
    } catch (e) {
      log.e('Failed to check check funding: $e');
      return false;
    }
  }

  Future<String> sweepCheck(String privateKeyWif, String destinationAddress, int feeSatPerVbyte) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) throw Exception('No active wallet');
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
      if (walletId == null) throw Exception('No active wallet');
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
    super.dispose();
  }
}
