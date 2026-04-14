import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/rpcs/orchestrator_wallet_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

/// Wallet reader provider backed by orchestrator's WalletManagerService.
///
/// Uses a server-streaming RPC (WatchWalletData) to receive wallet state
/// updates instead of polling.
class WalletReaderProvider extends ChangeNotifier {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorWalletRPC get _client => GetIt.I.get<OrchestratorRPC>().wallet;
  final Directory bitwindowAppDir;

  StreamSubscription<dynamic>? _watchSub;
  Timer? _reconnectTimer;

  List<WalletData> wallets = [];
  String? activeWalletId;
  String? unlockedPassword;

  WalletData? get activeWallet => wallets.where((w) => w.id == activeWalletId).firstOrNull;
  WalletData? get enforcerWallet => wallets.where((w) => w.walletType == BinaryType.enforcer).firstOrNull;

  List<WalletMetadata> get availableWallets => wallets
      .map(
        (w) => WalletMetadata(
          id: w.id,
          name: w.name,
          gradient: w.gradient,
          createdAt: w.createdAt,
          lastUsed: w.id == activeWalletId ? DateTime.now() : w.createdAt,
        ),
      )
      .toList();

  bool get isWalletUnlocked => wallets.isNotEmpty;
  bool get isWalletLocked => !isWalletUnlocked;

  WalletReaderProvider(this.bitwindowAppDir) {
    _startWatching();
  }

  void _startWatching() {
    if (Environment.isInTest) return;
    _subscribe();
  }

  void _subscribe() {
    _watchSub?.cancel();
    _reconnectTimer?.cancel();

    try {
      final stream = _client.watchWalletData();
      _watchSub = stream.listen(
        _onData,
        onError: (Object e) {
          _logger.e('WalletReaderProvider: stream error: $e');
          _scheduleReconnect();
        },
        onDone: () {
          _logger.i('WalletReaderProvider: stream closed, reconnecting');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _logger.e('WalletReaderProvider: failed to subscribe: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      _logger.i('WalletReaderProvider: reconnect attempt');
      _subscribe();
    });
  }

  void _onData(dynamic resp) {
    activeWalletId = resp.activeWalletId.isEmpty ? null : resp.activeWalletId;

    wallets = resp.wallets.map<WalletData>((protoWallet) {
      WalletGradient gradient = WalletGradient.fromWalletId(protoWallet.id);
      if (protoWallet.gradientJson.isNotEmpty) {
        try {
          gradient = WalletGradient.fromJsonString(protoWallet.gradientJson);
        } catch (_) {}
      }

      DateTime createdAt = DateTime.now();
      if (protoWallet.createdAt.isNotEmpty) {
        try {
          createdAt = DateTime.parse(protoWallet.createdAt);
        } catch (_) {}
      }

      return WalletData(
        version: 1,
        master: MasterWallet(
          mnemonic: '',
          seedHex: '',
          masterKey: '',
          chainCode: '',
          name: '',
        ),
        l1: L1Wallet(mnemonic: '', name: ''),
        sidechains: [],
        id: protoWallet.id,
        name: protoWallet.name,
        gradient: gradient,
        createdAt: createdAt,
        walletType: BinaryType.values.firstWhere(
          (t) => t.name == protoWallet.walletType,
          orElse: () => BinaryType.enforcer,
        ),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> init() async {
    // Stream will deliver initial state; nothing extra needed.
  }

  Future<bool> hasWallet() async {
    try {
      final resp = await _client.getWalletStatus();
      return resp.hasWallet;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isWalletEncrypted() async {
    try {
      final resp = await _client.getWalletStatus();
      return resp.encrypted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlockWallet(String password) async {
    try {
      await _client.unlockWallet(password);
      unlockedPassword = password;
      // Stream will push updated state automatically.
      return true;
    } catch (e) {
      _logger.e('WalletReaderProvider: unlock failed: $e');
      return false;
    }
  }

  Future<void> lockWallet() async {
    try {
      await _client.lockWallet();
      wallets = [];
      unlockedPassword = null;
      notifyListeners();
    } catch (e) {
      _logger.e('WalletReaderProvider: lock failed: $e');
    }
  }

  Future<void> encryptWallet(String password) async {
    try {
      await _client.encryptWallet(password);
      unlockedPassword = password;
      // Stream will push updated state automatically.
    } catch (e) {
      _logger.e('WalletReaderProvider: encrypt failed: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _client.changePassword(oldPassword, newPassword);
      unlockedPassword = newPassword;
    } catch (e) {
      _logger.e('WalletReaderProvider: change password failed: $e');
      rethrow;
    }
  }

  Future<void> removeEncryption(String password) async {
    try {
      await _client.removeEncryption(password);
      unlockedPassword = null;
      // Stream will push updated state automatically.
    } catch (e) {
      _logger.e('WalletReaderProvider: remove encryption failed: $e');
      rethrow;
    }
  }

  Future<void> updateWallet(WalletData wallet) async {
    // Stream will push updated state automatically.
  }

  Future<void> switchWallet(String walletId) async {
    try {
      await _client.switchWallet(walletId);
      activeWalletId = walletId;
      notifyListeners();
    } catch (e) {
      _logger.e('WalletReaderProvider: switch wallet failed: $e');
      rethrow;
    }
  }

  Future<void> removeWalletFromList(String walletId) async {
    try {
      await _client.deleteWallet(walletId);
      // Stream will push updated state automatically.
    } catch (e) {
      _logger.e('WalletReaderProvider: delete wallet failed: $e');
      rethrow;
    }
  }

  Future<void> updateWalletMetadata(
    String walletId,
    String name,
    WalletGradient gradient,
  ) async {
    try {
      await _client.updateWalletMetadata(
        walletId: walletId,
        name: name,
        gradientJson: gradient.toJsonString(),
      );
      // Stream will push updated state automatically.
    } catch (e) {
      _logger.e('WalletReaderProvider: update metadata failed: $e');
      rethrow;
    }
  }

  String? getL1Mnemonic() => activeWallet?.l1.mnemonic;

  String? getSidechainMnemonic(int slot) {
    final wallet = activeWallet;
    if (wallet == null) return null;
    return wallet.sidechains.where((sc) => sc.slot == slot).firstOrNull?.mnemonic;
  }

  Future<File> writeEnforcerL1Starter() async {
    throw UnsupportedError(
      'writeEnforcerL1Starter not needed — Go orchestrator handles starter injection',
    );
  }

  Future<File> writeSidechainStarter(int slot) async {
    throw UnsupportedError(
      'writeSidechainStarter not needed — Go orchestrator handles starter injection',
    );
  }

  Future<void> cleanupStarterFiles() async {
    // No-op — Go handles cleanup
  }

  void clearState() {
    wallets = [];
    activeWalletId = null;
    unlockedPassword = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    _reconnectTimer?.cancel();
    super.dispose();
  }
}
