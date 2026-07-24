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
  Duration unlockStateWait = Environment.isInTest ? const Duration(milliseconds: 10) : const Duration(seconds: 3);

  /// Mirrors `has_wallet` from the WatchWalletData stream. Distinct from
  /// `isWalletUnlocked` — a locked/encrypted wallet has `hasWalletOnDisk=true`
  /// with an empty `wallets` list.
  bool hasWalletOnDisk = false;

  WalletData? get activeWallet => wallets.where((w) => w.id == activeWalletId).firstOrNull;
  WalletData? get enforcerWallet => wallets.where((w) => w.walletType == BinaryType.BINARY_TYPE_ENFORCER).firstOrNull;

  /// False when the active wallet is electrum — it serves chain data remotely
  /// and runs no local Bitcoin Core or enforcer. Used to skip the L1 backend
  /// boot/wait. Defaults to true when no wallet is loaded yet so a fresh
  /// install still boots the backends.
  bool get activeWalletNeedsBitcoinBackends => !(activeWallet?.isElectrum ?? false);

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

  WalletReaderProvider(this.bitwindowAppDir);

  void _ensureSupervisor() {
    if (Environment.isInTest) return;
    if (_supervisor != null) return;
    _supervisor = StreamSupervisor<wmpb.WatchWalletDataResponse>(
      subscribe: () => _client.watchWalletData(),
      onEvent: _onResponse,
      onTransportDeath: () => GetIt.I.get<OrchestratorRPC>().recreateConnection(),
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
    _logger.i(
      'WalletReaderProvider: frame wallets=${protoWallets.length} '
      'active=$newActiveId hasWallet=$newHasWalletOnDisk (current=${wallets.length})',
    );
    // Reconnecting stream can send an empty initial frame; keep a populated
    // list (a real delete arrives with hasWallet=false).
    if (protoWallets.isEmpty && wallets.isNotEmpty && newHasWalletOnDisk) {
      return;
    }
    final previousActiveId = activeWalletId;
    // A transient stream frame can arrive with an empty active id while wallets
    // still exist; keep the known-good selection instead of blanking it.
    var effectiveActiveId = newActiveId;
    if (effectiveActiveId == null && previousActiveId != null && protoWallets.isNotEmpty) {
      effectiveActiveId = previousActiveId;
    }
    if (previousActiveId != effectiveActiveId) {
      _logger.i(
        'WalletReaderProvider: activeWalletId $previousActiveId -> $effectiveActiveId '
        '(wallets=${protoWallets.length})',
      );
    }
    activeWalletId = effectiveActiveId;

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
        walletType: switch (protoWallet.walletType) {
          wmpb.WalletType.WALLET_TYPE_ENFORCER => BinaryType.BINARY_TYPE_ENFORCER,
          // Electrum runs no local backend binary.
          wmpb.WalletType.WALLET_TYPE_ELECTRUM => BinaryType.BINARY_TYPE_UNSPECIFIED,
          _ => BinaryType.BINARY_TYPE_BITCOIND,
        },
        isElectrum: protoWallet.walletType == wmpb.WalletType.WALLET_TYPE_ELECTRUM,
        isWatchOnly: protoWallet.watchOnly,
        bip47PaymentCode: protoWallet.bip47PaymentCode,
        multisig: protoWallet.hasMultisig() ? protoWallet.multisig : null,
        hardwareDeviceType: protoWallet.hardwareDeviceType,
        hardwareFingerprint: protoWallet.hardwareFingerprint,
      );
    }).toList();

    notifyListeners();
  }

  Future<void> init() async {
    if (Environment.isInTest) return;
    if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
      // bootBackendManagedSidechain calls back into init() once the
      // orchestrator is registered + ready; bail without crashing.
      _logger.d('WalletReaderProvider: OrchestratorRPC not registered yet, skipping seed');
      return;
    }
    _ensureSupervisor();
    // Seed state synchronously instead of waiting for the WatchWalletData
    // stream. The stream races UI mount on cold start, and a slow/broken
    // stream leaves the wallet dropdown, BIP47 card and starters tab empty
    // even when the orchestrator already has the wallet on disk.
    // listWallets + getWalletStatus return the same fields the stream
    // would push, so we can populate the provider directly.
    if (wallets.isNotEmpty) return;
    await _seedWalletsIfEmpty('init');
  }

  Future<List<dynamic>?> _fetchWalletSeed(String phase) async {
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
            _logger.w('WalletReaderProvider: $phase seed retry failed: $e2');
          }
          return null;
        }
      } else {
        if (!isExpectedBootError(e)) {
          _logger.w('WalletReaderProvider: $phase seed failed: $e');
        }
        return null;
      }
    }
    return results;
  }

  Future<bool> _seedWalletsIfEmpty(String phase) async {
    if (wallets.isNotEmpty) return true;
    final results = await _fetchWalletSeed(phase);
    if (results == null || wallets.isNotEmpty) return wallets.isNotEmpty;

    // Stream may have delivered while we awaited — let it win.
    final list = results[0] as dynamic;
    final status = results[1] as dynamic;
    if (list.wallets.isEmpty) return false;
    _applyState(
      protoWallets: list.wallets,
      newActiveId: list.activeWalletId.isEmpty ? null : list.activeWalletId as String,
      newHasWalletOnDisk: status.hasWallet as bool,
    );
    return wallets.isNotEmpty;
  }

  Future<bool> _waitForWalletState(Duration timeout) async {
    if (wallets.isNotEmpty) return true;

    final completer = Completer<bool>();
    late VoidCallback listener;
    Timer? timer;

    listener = () {
      if (wallets.isNotEmpty && !completer.isCompleted) {
        completer.complete(true);
      }
    };

    addListener(listener);
    timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    try {
      return await completer.future;
    } finally {
      timer.cancel();
      removeListener(listener);
    }
  }

  /// Returns true once the orchestrator confirms a wallet exists on disk.
  ///
  /// Polled with backoff so the WalletGuard doesn't race the orchestrator's
  /// boot: on cold start, getWalletStatus() can throw "connection refused"
  /// for a few seconds while orchestratord finishes coming up. Returning
  /// false on that error silently misroutes existing users to the
  /// "Set up your wallet" screen, so we keep retrying for ~5s before giving
  /// up. Any non-transport error (e.g. a successful RPC with hasWallet=false)
  /// short-circuits immediately.
  Future<bool> hasWallet() async {
    // Trust the streamed state when we have one.
    if (hasWalletOnDisk) return true;

    const maxAttempts = 10;
    const delay = Duration(milliseconds: 500);
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final resp = await _client.getWalletStatus();
        return resp.hasWallet;
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          _logger.w('WalletReaderProvider.hasWallet: giving up after $maxAttempts attempts: $e');
          return false;
        }
        await Future.delayed(delay);
      }
    }
    return false;
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
      // isWalletUnlocked is wallets.isNotEmpty; the watch stream lags on cold
      // boot, so without an eager seed PasswordGuard reads stale-empty state
      // when UnlockWalletRoute pops and rejects the resume navigation —
      // user lands on a blank route. Mirror the init() seed pattern.
      if (wallets.isEmpty && GetIt.I.isRegistered<OrchestratorRPC>()) {
        await _seedWalletsIfEmpty('unlock');
      }
      if (wallets.isEmpty && !await _waitForWalletState(unlockStateWait)) {
        _logger.w('WalletReaderProvider: unlock succeeded but wallet state did not load');
        return false;
      }
      unlockedPassword = password;
      notifyListeners();
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

  // Clear then immediately re-fetch, instead of waiting for the next stream frame.
  Future<void> reloadForNetworkChange() async {
    clearState();
    await _seedWalletsIfEmpty('network-change');
  }

  @override
  void dispose() {
    _supervisor?.dispose();
    _supervisor = null;
    super.dispose();
  }
}
