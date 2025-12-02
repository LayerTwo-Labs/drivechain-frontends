import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/sync_provider.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class ChequeProvider extends ChangeNotifier {
  final Logger log = Logger(level: Level.debug);
  final BitwindowRPC _bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  final WalletReaderProvider _walletReader = GetIt.I.get<WalletReaderProvider>();
  SyncProvider get _syncProvider => GetIt.I.get<SyncProvider>();

  List<Cheque> _cheques = [];
  bool _isLoading = false;
  String? modelError;

  List<Cheque> get cheques => _cheques;
  bool get isLoading => _isLoading;

  Timer? _pollTimer;
  int? _pollingChequeId;

  ChequeProvider() {
    _syncProvider.addListener(_onNewBlock);
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

  Future<void> fetch() async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      return;
    }

    _isLoading = true;
    modelError = null;
    notifyListeners();

    try {
      _cheques = await _bitwindowRPC.wallet.listCheques(walletId);
      modelError = null;
    } catch (e) {
      log.e('Failed to fetch cheques: $e');
      modelError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cheque> createCheque(int expectedAmountSats) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) throw Exception('No active wallet');
    final resp = await _bitwindowRPC.wallet.createCheque(walletId, expectedAmountSats);

    final cheque = Cheque(
      id: resp.id,
      derivationIndex: resp.derivationIndex,
      address: resp.address,
      expectedAmountSats: Int64(expectedAmountSats),
    );

    _cheques.insert(0, cheque);
    notifyListeners();
    return cheque;
  }

  Future<Cheque?> getCheque(int id) async {
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');
      return await _bitwindowRPC.wallet.getCheque(walletId, id);
    } catch (e) {
      log.e('Failed to get cheque: $e');
      return null;
    }
  }

  Future<bool> checkChequeFunding(int id) async {
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');
      final resp = await _bitwindowRPC.wallet.checkChequeFunding(walletId, id);

      if (resp.funded) {
        final index = _cheques.indexWhere((c) => c.id == id);
        if (index != -1) {
          _cheques[index] = Cheque(
            id: _cheques[index].id,
            derivationIndex: _cheques[index].derivationIndex,
            address: _cheques[index].address,
            expectedAmountSats: _cheques[index].expectedAmountSats,
            fundedTxid: resp.fundedTxid,
            actualAmountSats: resp.actualAmountSats,
            createdAt: _cheques[index].createdAt,
            fundedAt: resp.hasFundedAt() ? resp.fundedAt : null,
          );
          notifyListeners();
        }
      }

      return resp.funded;
    } catch (e) {
      log.e('Failed to check cheque funding: $e');
      return false;
    }
  }

  Future<String> sweepCheque(String privateKeyWif, String destinationAddress, int feeSatPerVbyte) async {
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

  Future<bool> deleteCheque(int id) async {
    try {
      if (_pollingChequeId == id) {
        stopPolling();
      }

      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');
      await _bitwindowRPC.wallet.deleteCheque(walletId, id);
      _cheques.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      log.e('Failed to delete cheque: $e');
      modelError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void startPolling(int chequeId, {Duration interval = const Duration(seconds: 5)}) {
    stopPolling();
    _pollingChequeId = chequeId;
    _pollTimer = Timer.periodic(interval, (_) async {
      try {
        final funded = await checkChequeFunding(chequeId);
        if (funded) {
          stopPolling();
        }
      } catch (e) {
        log.w('Error checking cheque funding (cheque may have been deleted): $e');
        stopPolling();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollingChequeId = null;
  }

  @override
  void dispose() {
    _syncProvider.removeListener(_onNewBlock);
    stopPolling();
    super.dispose();
  }
}
