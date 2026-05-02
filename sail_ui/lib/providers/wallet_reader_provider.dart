import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/rpcs/stream_supervisor.dart';
import 'package:sail_ui/sail_ui.dart';

/// Wallet reader provider backed by orchestrator's WalletManagerService.
///
/// Uses the WatchWalletData server-streaming RPC, wrapped in a
/// [StreamSupervisor] that owns reconnect, transport recreation, and
/// heartbeat detection.
class WalletReaderProvider extends ChangeNotifier {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorWalletRPC get _client => GetIt.I.get<OrchestratorRPC>().wallet;
  final Directory bitwindowAppDir;

  StreamSupervisor<wmpb.WatchWalletDataResponse>? _supervisor;

  List<WalletData> wallets = [];
  String? activeWalletId;
  String? unlockedPassword;

  /// Mirrors `has_wallet` from the WatchWalletData stream. Distinct from
  /// `isWalletUnlocked` — a locked/encrypted wallet has `hasWalletOnDisk=true`
  /// with an empty `wallets` list.
  bool hasWalletOnDisk = false;

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
    if (Environment.isInTest) return;
    _supervisor = StreamSupervisor<wmpb.WatchWalletDataResponse>(
      subscribe: () => _client.watchWalletData(),
      onEvent: _onResponse,
      onTransportDeath: GetIt.I.get<OrchestratorRPC>().recreateConnection,
      logger: _logger,
      tag: 'WalletReaderProvider',
    )..start();
  }

  void _onResponse(wmpb.WatchWalletDataResponse resp) {
    // Heartbeat frames carry no payload — supervisor uses them only for
    // liveness detection, no state to apply here.
    if (resp.heartbeat) return;
    _applyState(
      protoWallets: resp.wallets,
      newActiveId: resp.activeWalletId.isEmpty ? null : resp.activeWalletId,
      newHasWalletOnDisk: resp.hasWallet,
    );
  }

  void _applyState({
    required Iterable<dynamic> protoWallets,
    required String? newActiveId,
    required bool newHasWalletOnDisk,
  }) {
    final previousActiveId = activeWalletId;
    if (previousActiveId != newActiveId) {
      _logger.i(
        'WalletReaderProvider: activeWalletId $previousActiveId -> $newActiveId '
        '(wallets=${protoWallets.length})',
      );
    }
    activeWalletId = newActiveId;

    final previousHasWallet = hasWalletOnDisk;
    hasWalletOnDisk = newHasWalletOnDisk;
    if (previousHasWallet != hasWalletOnDisk) {
      _logger.i('WalletReaderProvider: hasWalletOnDisk $previousHasWallet -> $hasWalletOnDisk');
    }

    wallets = protoWallets.map<WalletData>((protoWallet) {
      WalletGradient gradient = WalletGradient.fromWalletId(protoWallet.id);
      if (protoWallet.gradientJson.isNotEmpty) {
        try {
          final parsed = WalletGradient.fromJsonString(protoWallet.gradientJson);
          // Legacy default {"background_svg":""} parses cleanly but would
          // render an empty avatar; keep the deterministic fallback in that
          // case.
          if ((parsed.backgroundSvg ?? '').isNotEmpty) {
            gradient = parsed;
          }
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
          mnemonic: protoWallet.masterMnemonic,
          seedHex: '',
          masterKey: '',
          chainCode: '',
          name: 'Master',
        ),
        l1: L1Wallet(mnemonic: protoWallet.l1Mnemonic),
        sidechains: protoWallet.sidechains
            .map<SidechainWallet>(
              (sc) => SidechainWallet(
                slot: sc.slot,
                name: sc.name,
                mnemonic: sc.mnemonic,
              ),
            )
            .toList(),
        id: protoWallet.id,
        name: protoWallet.name,
        gradient: gradient,
        createdAt: createdAt,
        walletType: BinaryType.values.firstWhere(
          (t) => t.name == protoWallet.walletType,
          orElse: () => BinaryType.enforcer,
        ),
        walletTypeRaw: protoWallet.walletType,
        bip47PaymentCode: protoWallet.bip47PaymentCode,
      );
    }).toList();

    notifyListeners();
  }

  Future<void> init() async {
    if (Environment.isInTest) return;
    // Seed state synchronously instead of waiting for the WatchWalletData
    // stream. The stream races UI mount on cold start, and a slow/broken
    // stream leaves the wallet dropdown, BIP47 card and starters tab empty
    // even when the orchestrator already has the wallet on disk.
    // listWallets + getWalletStatus return the same fields the stream
    // would push, so we can populate the provider directly.
    if (wallets.isNotEmpty) return;
    if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
      // bootBackendManagedSidechain calls back into init() once the
      // orchestrator is registered + ready; bail without crashing.
      _logger.d('WalletReaderProvider: OrchestratorRPC not registered yet, skipping seed');
      return;
    }
    final orchestrator = GetIt.I.get<OrchestratorRPC>();
    Future<List<dynamic>> seed() => Future.wait([
      orchestrator.wallet.listWallets(),
      orchestrator.wallet.getWalletStatus(),
    ]).timeout(const Duration(seconds: 3));

    List<dynamic> results;
    try {
      results = await seed();
    } catch (e) {
      // The orchestrator's HTTP/2 connection sometimes returns
      // "Connection is being forcefully terminated" mid-handshake; rebuild
      // the transport and try once more before giving up.
      if (orchestrator.recreateIfHttp2Error(e)) {
        try {
          results = await seed();
        } catch (e2) {
          if (!isExpectedBootError(e2)) {
            _logger.w('WalletReaderProvider: init seed retry failed: $e2');
          }
          return;
        }
      } else {
        if (!isExpectedBootError(e)) {
          _logger.w('WalletReaderProvider: init seed failed: $e');
        }
        return;
      }
    }
    // Stream may have delivered while we awaited — let it win.
    if (wallets.isNotEmpty) return;
    final list = results[0] as dynamic;
    final status = results[1] as dynamic;
    if (list.wallets.isEmpty) return;
    _applyState(
      protoWallets: list.wallets,
      newActiveId: list.activeWalletId.isEmpty ? null : list.activeWalletId as String,
      newHasWalletOnDisk: status.hasWallet as bool,
    );
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

  // L1 + sidechain starters are always derived from the enforcer wallet, even
  // if the active wallet is a separate Bitcoin Core wallet.
  String? getL1Mnemonic() => enforcerWallet?.l1.mnemonic;

  String? getSidechainMnemonic(int slot) {
    final wallet = enforcerWallet;
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
    _supervisor?.dispose();
    _supervisor = null;
    super.dispose();
  }
}
