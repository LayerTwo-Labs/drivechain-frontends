import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/rpcs/orchestrator_wallet_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC-backed wallet reader. Calls WalletManagerService on orchestrator.
/// No file access — all wallet operations go through the backend.
class BackendWalletReaderProvider extends WalletReaderProvider {
  final Logger _logger = GetIt.I.get<Logger>();
  late OrchestratorWalletRPC _client;
  @override
  final Directory bitwindowAppDir;
  Timer? _pollTimer;

  @override
  List<WalletData> wallets = [];
  @override
  String? activeWalletId;
  @override
  String? unlockedPassword;

  @override
  WalletData? get activeWallet => wallets.where((w) => w.id == activeWalletId).firstOrNull;

  @override
  WalletData? get enforcerWallet => wallets.where((w) => w.walletType == BinaryType.enforcer).firstOrNull;

  @override
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

  @override
  bool get isWalletUnlocked => wallets.isNotEmpty;
  @override
  bool get isWalletLocked => !isWalletUnlocked;

  BackendWalletReaderProvider(this.bitwindowAppDir) {
    _initClient();
    _startPolling();
  }

  void _initClient() {
    _client = GetIt.I.get<OrchestratorWalletRPC>();
  }

  void _startPolling() {
    if (Environment.isInTest) return;
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadFromBackend(),
    );
  }

  bool _isConnectionError(Object e) {
    final msg = e.toString();
    return msg.contains('http/2 connection is finishing') ||
        msg.contains('Connection refused') ||
        msg.contains('Connection reset') ||
        msg.contains('Connection terminated');
  }

  Future<void> _loadFromBackend() async {
    try {
      final statusResp = await _client.getWalletStatus();
      final listResp = await _client.listWallets();

      activeWalletId = statusResp.activeWalletId.isEmpty ? null : statusResp.activeWalletId;

      // Convert proto WalletMetadata to lightweight WalletData.
      // Full wallet data (mnemonics, keys) stays on the backend for security.
      // The frontend only needs id, name, type, gradient for UI display +
      // wallets.isNotEmpty for isWalletUnlocked check.
      wallets = listResp.wallets.map((protoWallet) {
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
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: failed to load: $e');
      if (_isConnectionError(e)) {
        _logger.i('BackendWalletReaderProvider: recreating connection');
        _initClient();
      }
    }
  }

  @override
  Future<void> init() async => _loadFromBackend();

  @override
  File getWalletFile() => File('${bitwindowAppDir.path}/wallet.json');

  @override
  Future<bool> hasWallet() async {
    try {
      final resp = await _client.getWalletStatus();
      return resp.hasWallet;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isWalletEncrypted() async {
    try {
      final resp = await _client.getWalletStatus();
      return resp.encrypted;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unlockWallet(String password) async {
    try {
      await _client.unlockWallet(password);
      unlockedPassword = password;
      await _loadFromBackend();
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: unlock failed: $e');
      return false;
    }
  }

  @override
  Future<void> lockWallet() async {
    try {
      await _client.lockWallet();
      wallets = [];
      unlockedPassword = null;
      notifyListeners();
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: lock failed: $e');
    }
  }

  @override
  Future<void> encryptWallet(String password) async {
    try {
      await _client.encryptWallet(password);
      unlockedPassword = password;
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: encrypt failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _client.changePassword(oldPassword, newPassword);
      unlockedPassword = newPassword;
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: change password failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeEncryption(String password) async {
    try {
      await _client.removeEncryption(password);
      unlockedPassword = null;
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: remove encryption failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateWallet(WalletData wallet) async {
    // Backend handles wallet updates internally
    await _loadFromBackend();
  }

  @override
  Future<void> switchWallet(String walletId) async {
    try {
      await _client.switchWallet(walletId);
      activeWalletId = walletId;
      notifyListeners();
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: switch wallet failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeWalletFromList(String walletId) async {
    try {
      await _client.deleteWallet(walletId);
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: delete wallet failed: $e');
      rethrow;
    }
  }

  @override
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
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendWalletReaderProvider: update metadata failed: $e');
      rethrow;
    }
  }

  @override
  String? getL1Mnemonic() => activeWallet?.l1.mnemonic;

  @override
  String? getSidechainMnemonic(int slot) {
    final wallet = activeWallet;
    if (wallet == null) return null;
    return wallet.sidechains.where((sc) => sc.slot == slot).firstOrNull?.mnemonic;
  }

  @override
  Future<File> writeEnforcerL1Starter() async {
    // In backend mode, the Go orchestrator handles starter injection
    throw UnsupportedError(
      'writeEnforcerL1Starter not needed in backend mode — Go handles starter injection',
    );
  }

  @override
  Future<File> writeSidechainStarter(int slot) async {
    throw UnsupportedError(
      'writeSidechainStarter not needed in backend mode — Go handles starter injection',
    );
  }

  @override
  Future<void> cleanupStarterFiles() async {
    // No-op in backend mode — Go handles cleanup
  }

  @override
  void clearState() {
    wallets = [];
    activeWalletId = null;
    unlockedPassword = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
