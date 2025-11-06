import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class ChequeProvider extends ChangeNotifier {
  final Logger log = Logger(level: Level.debug);
  final BitwindowRPC _bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  final WalletReaderProvider _walletReader = GetIt.I.get<WalletReaderProvider>();

  List<Cheque> _cheques = [];
  bool _isLoading = false;
  String? modelError;
  bool _isWalletUnlocked = false;
  String? _pendingPassword;
  StreamSubscription? _healthStreamSubscription;

  List<Cheque> get cheques => _cheques;
  bool get isLoading => _isLoading;
  bool get isWalletUnlocked => _isWalletUnlocked;

  Timer? _pollTimer;
  int? _pollingChequeId;
  Timer? _unlockCheckTimer;

  ChequeProvider() {
    _walletReader.addListener(_onWalletReaderChanged);
    _bitwindowRPC.addListener(_onBitwindowConnectionChanged);
    GetIt.I.get<BlockchainProvider>().addListener(_onNewBlock);
    _init();
  }

  Future<void> _init() async {
    await checkUnlockStatus();

    // If frontend wallet is already unlocked but backend isn't, unlock backend
    if (_walletReader.isWalletUnlocked && !_isWalletUnlocked) {
      final password = _walletReader.unlockedPassword;
      log.d('_init: password=${password != null ? "present" : "null"}');
      if (password != null) {
        log.d('_init: frontend already unlocked, unlocking backend');
        await unlockWallet(password);
      }
    }

    if (_isWalletUnlocked) {
      await fetch();
    }
    _setupHealthStreamListener();
  }

  void _onBitwindowConnectionChanged() {
    if (_bitwindowRPC.connected && _pendingPassword != null) {
      _tryUnlockBackend(_pendingPassword!);
    }
  }

  void _onNewBlock() {
    if (_isWalletUnlocked) {
      fetch();
    }
  }

  void _onWalletReaderChanged() {
    log.d(
      '_onWalletReaderChanged: frontend unlocked=${_walletReader.isWalletUnlocked}, backend unlocked=$_isWalletUnlocked',
    );

    // When wallet reader is unlocked, try to propagate to backend
    if (_walletReader.isWalletUnlocked && !_isWalletUnlocked) {
      final password = _walletReader.unlockedPassword ?? _pendingPassword;
      log.d('_onWalletReaderChanged: attempting unlock with password=${password != null ? "present" : "null"}');
      if (password != null) {
        unlockWallet(password);
      }
    } else if (!_walletReader.isWalletUnlocked && _isWalletUnlocked) {
      // Wallet was locked, propagate to backend
      log.d('_onWalletReaderChanged: locking backend');
      lockWallet();
    }
  }

  void _setupHealthStreamListener() {
    _healthStreamSubscription?.cancel();

    // Listen to bitwindow health check stream for connection status changes
    _healthStreamSubscription = _bitwindowRPC.healthStream.listen((healthResponse) {
      // When backend comes online and we have a pending password, try to unlock
      if (_pendingPassword != null && !_isWalletUnlocked) {
        _tryUnlockBackend(_pendingPassword!);
      }
    });
  }

  Future<void> checkUnlockStatus() async {
    try {
      await _bitwindowRPC.wallet.isWalletUnlocked();
      _isWalletUnlocked = true;
    } catch (e) {
      _isWalletUnlocked = false;
    }
    notifyListeners();
  }

  Future<bool> _tryUnlockBackend(String password) async {
    try {
      await _bitwindowRPC.wallet.unlockWallet(password);
      _isWalletUnlocked = true;
      modelError = null;
      await fetch();
      notifyListeners();
      return true;
    } catch (e) {
      log.w('Backend unlock attempt failed: $e');
      return false;
    }
  }

  Future<bool> unlockWallet(String password) async {
    _pendingPassword = password;
    final success = await _tryUnlockBackend(password);

    if (success) {
      _pendingPassword = null;
      _startUnlockCheckTimer();
    }

    return success;
  }

  /// Call this when the wallet reader provider unlocks with a password
  void propagateUnlock(String password) {
    _pendingPassword = password;
    // Health stream listener will automatically try unlock when backend is ready
  }

  Future<void> lockWallet() async {
    try {
      await _bitwindowRPC.wallet.lockWallet();
      _isWalletUnlocked = false;
      _cheques = [];
      stopPolling();
      _stopUnlockCheckTimer();
      notifyListeners();
    } catch (e) {
      log.e('Failed to lock wallet: $e');
    }
  }

  Future<void> fetch() async {
    if (!_isWalletUnlocked) {
      log.w('Cannot fetch cheques: wallet is locked');
      return;
    }

    _isLoading = true;
    modelError = null;
    notifyListeners();

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');
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

  Future<Cheque?> createCheque(int expectedAmountSats) async {
    if (!_isWalletUnlocked) {
      modelError = 'Wallet must be unlocked to create cheques';
      notifyListeners();
      return null;
    }

    try {
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
    } catch (e) {
      log.e('Failed to create cheque: $e');
      modelError = e.toString();

      // Check if error is wallet locked
      if (e.toString().toLowerCase().contains('wallet is locked')) {
        _isWalletUnlocked = false;
      }

      notifyListeners();
      return null;
    }
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

  Future<String?> sweepCheque(String privateKeyWif, String destinationAddress, int feeSatPerVbyte) async {
    try {
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
    } catch (e) {
      log.e('Failed to sweep cheque: $e');
      modelError = e.toString();

      // Check if error is wallet locked
      if (e.toString().toLowerCase().contains('wallet is locked')) {
        _isWalletUnlocked = false;
      }

      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteCheque(int id) async {
    try {
      // Stop polling if we're deleting the cheque being polled
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
        // Cheque might have been deleted or other error
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

  void _startUnlockCheckTimer() {
    _stopUnlockCheckTimer();
    _unlockCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkAndAutoUnlock();
    });
  }

  void _stopUnlockCheckTimer() {
    _unlockCheckTimer?.cancel();
    _unlockCheckTimer = null;
  }

  Future<void> _checkAndAutoUnlock() async {
    final password = _walletReader.unlockedPassword;
    if (password == null) {
      _stopUnlockCheckTimer();
      return;
    }

    try {
      await _bitwindowRPC.wallet.isWalletUnlocked();
      // Wallet is unlocked, all good
    } catch (e) {
      // Wallet is locked, auto-unlock it
      log.i('Backend wallet locked, auto-unlocking...');
      final success = await _tryUnlockBackend(password);
      if (!success) {
        log.w('Auto-unlock failed, will retry in 5 seconds');
      }
    }
  }

  @override
  void dispose() {
    _walletReader.removeListener(_onWalletReaderChanged);
    _bitwindowRPC.removeListener(_onBitwindowConnectionChanged);
    GetIt.I.get<BlockchainProvider>().removeListener(_onNewBlock);
    _healthStreamSubscription?.cancel();
    stopPolling();
    _stopUnlockCheckTimer();
    super.dispose();
  }
}
