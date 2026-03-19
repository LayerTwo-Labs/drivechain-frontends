import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC-backed wallet reader that delegates to the Go wallet service via ThunderRPC.
/// Used by Thunder instead of the filesystem-based WalletReaderProvider.
class RpcWalletReaderProvider extends ChangeNotifier {
  final ThunderdRPC _thunderRPC;
  final Directory bitwindowAppDir;
  final _logger = GetIt.I.get<Logger>();

  List<WalletData> wallets = [];
  String? activeWalletId;
  String? unlockedPassword;
  Timer? _pollTimer;

  bool _hasWallet = false;
  bool _encrypted = false;
  bool _unlocked = false;

  WalletData? get activeWallet => wallets.firstWhereOrNull(
    (w) => w.id == activeWalletId,
  );

  WalletData? get enforcerWallet => wallets.firstWhereOrNull(
    (w) => w.walletType == BinaryType.enforcer,
  );

  bool get isWalletUnlocked => _unlocked && wallets.isNotEmpty;
  bool get isWalletLocked => !isWalletUnlocked;

  List<WalletMetadata> get availableWallets {
    return wallets
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
  }

  RpcWalletReaderProvider(this._thunderRPC, this.bitwindowAppDir);

  Future<void> init() async {
    await _refreshStatus();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void clearState() {
    wallets = [];
    activeWalletId = null;
    unlockedPassword = null;
    _hasWallet = false;
    _encrypted = false;
    _unlocked = false;
    notifyListeners();
  }

  File getWalletFile() {
    return File('${bitwindowAppDir.path}/wallet.json');
  }

  Future<bool> isWalletEncrypted() async {
    await _refreshStatus();
    return _encrypted;
  }

  Future<bool> unlockWallet(String password) async {
    try {
      await _thunderRPC.walletUnlock(password);
      unlockedPassword = password;
      await _refreshStatus();
      notifyListeners();
      return true;
    } catch (e) {
      _logger.w('RpcWalletReaderProvider.unlockWallet failed: $e');
      return false;
    }
  }

  Future<void> lockWallet() async {
    try {
      await _thunderRPC.walletLock();
    } catch (e) {
      _logger.w('RpcWalletReaderProvider.lockWallet failed: $e');
    }
    wallets = [];
    unlockedPassword = null;
    _unlocked = false;
    notifyListeners();
  }

  Future<void> encryptWallet(String password) async {
    await _thunderRPC.walletEncrypt(password);
    unlockedPassword = password;
    await _refreshStatus();
    notifyListeners();
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _thunderRPC.walletChangePassword(oldPassword, newPassword);
    unlockedPassword = newPassword;
    notifyListeners();
  }

  Future<void> removeEncryption(String password) async {
    await _thunderRPC.walletRemoveEncryption(password);
    unlockedPassword = null;
    await _refreshStatus();
    notifyListeners();
  }

  Future<void> switchWallet(String walletId) async {
    await _thunderRPC.walletSwitch(walletId);
    activeWalletId = walletId;
    notifyListeners();
  }

  Future<void> updateWalletMetadata(String walletId, String name, WalletGradient gradient) async {
    await _thunderRPC.walletUpdateMetadata(walletId, name, gradient.toJsonString());
    await _refreshStatus();
    notifyListeners();
  }

  Future<void> removeWalletFromList(String walletId) async {
    await _thunderRPC.walletDelete(walletId);
    await _refreshStatus();
    notifyListeners();
  }

  Future<void> updateWallet(WalletData wallet) async {
    // For RPC mode, wallet updates are done through generate/update metadata
    // This is a compatibility shim - the Go server manages the actual file
    _logger.d('RpcWalletReaderProvider.updateWallet called (no-op for RPC mode)');
  }

  String? getL1Mnemonic() => activeWallet?.l1.mnemonic;

  String? getSidechainMnemonic(int slot) {
    final wallet = activeWallet;
    if (wallet == null) return null;
    final sidechain = wallet.sidechains.firstWhereOrNull((sc) => sc.slot == slot);
    return sidechain?.mnemonic;
  }

  // Starter file operations are handled by the Go server now,
  // but we keep these for compatibility with guards that check them.
  Future<File> writeEnforcerL1Starter() async {
    throw UnsupportedError('Starter files are managed by the Go server in RPC mode');
  }

  Future<File> writeSidechainStarter(int slot) async {
    throw UnsupportedError('Starter files are managed by the Go server in RPC mode');
  }

  Future<void> cleanupStarterFiles() async {
    // No-op: Go server handles cleanup
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        await _refreshStatus();
      } catch (e) {
        // Server may not be ready yet
      }
    });
  }

  Future<void> _refreshStatus() async {
    try {
      final status = await _thunderRPC.getWalletStatus();
      final previousHasWallet = _hasWallet;
      final previousUnlocked = _unlocked;

      _hasWallet = status.hasWallet;
      _encrypted = status.encrypted;
      _unlocked = status.unlocked;
      activeWalletId = status.activeWalletId.isNotEmpty ? status.activeWalletId : null;

      // If wallet status changed, refresh wallet list
      if (_unlocked && (_hasWallet != previousHasWallet || _unlocked != previousUnlocked)) {
        await _refreshWalletList();
      }

      if (!_unlocked && !_encrypted && _hasWallet) {
        // Unencrypted wallet - load wallet list
        await _refreshWalletList();
      }

      notifyListeners();
    } catch (e) {
      // Server not ready - ignore
    }
  }

  Future<void> _refreshWalletList() async {
    try {
      final response = await _thunderRPC.walletList();
      activeWalletId = response.activeWalletId.isNotEmpty ? response.activeWalletId : null;

      // We only get metadata from the RPC, not full wallet data with mnemonics.
      // For Thunder, the Go server handles starter injection, so we don't need mnemonics in Flutter.
      // Create minimal WalletData objects for the UI.
      wallets = response.wallets.map((meta) {
        return WalletData(
          version: 1,
          master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: '', name: 'Master'),
          l1: L1Wallet(mnemonic: ''),
          sidechains: [],
          id: meta.id,
          name: meta.name,
          gradient: meta.gradientJson.isNotEmpty
              ? WalletGradient.fromJson(Map<String, dynamic>.from(_parseJson(meta.gradientJson)))
              : WalletGradient.fromWalletId(meta.id),
          createdAt: meta.createdAt.isNotEmpty ? DateTime.parse(meta.createdAt) : DateTime.now(),
          walletType: BinaryType.values.firstWhere(
            (e) => e.name == meta.walletType,
            orElse: () => BinaryType.bitcoinCore,
          ),
        );
      }).toList();
    } catch (e) {
      _logger.w('Failed to refresh wallet list: $e');
    }
  }

  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
