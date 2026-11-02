import 'package:sail_ui/sail_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class HDWalletProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    await reinitialize();
  }

  Logger get log => GetIt.I.get<Logger>();

  String? _error;
  bool _initialized = false;
  final bool _isProcessing = false;
  String? _mnemonic;

  String? get error => _error;
  bool get isInitialized => _initialized;
  bool get isProcessing => _isProcessing;
  String? get mnemonic => _mnemonic;

  /// BIP47 v3 payment code — computed server-side by the orchestrator and
  /// delivered on the WatchWalletData stream. No local crypto involved.
  String get bip47PaymentCode => GetIt.I.get<WalletReaderProvider>().activeWallet?.bip47PaymentCode ?? '';

  HDWalletProvider() {
    GetIt.I.get<WalletReaderProvider>().addListener(_onWalletStream);
  }

  @override
  void dispose() {
    GetIt.I.get<WalletReaderProvider>().removeListener(_onWalletStream);
    super.dispose();
  }

  // Auto-load when the enforcer wallet finally arrives on the stream. First
  // paint races the stream subscription, so init() can fire before any
  // mnemonic is available — without this, the "Couldn't load wallet" error
  // would stick until the user reloaded the page.
  void _onWalletStream() {
    final reader = GetIt.I.get<WalletReaderProvider>();
    final mnemonic = reader.getL1Mnemonic();
    if (!_initialized && mnemonic != null && mnemonic.isNotEmpty) {
      _loadMnemonic().then((_) => notifyListeners());
      return;
    }
    if (_initialized && (mnemonic == null || mnemonic.isEmpty)) {
      _mnemonic = null;
      _initialized = false;
    }
    notifyListeners();
  }

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      await _loadMnemonic();
      notifyListeners();
    } catch (e) {
      _error = "Couldn't sync to wallet for HD Explorer";
      notifyListeners();
    }
  }

  Future<bool> loadMnemonic() async {
    try {
      await _loadMnemonic();
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Couldn't load wallet mnemonic: $e";
      notifyListeners();
      return false;
    }
  }

  /// Force reinitialize the HD wallet provider
  Future<void> reinitialize() async {
    _initialized = false;
    _mnemonic = null;
    _error = null;
    await init();
  }

  Future<void> _loadMnemonic() async {
    try {
      // Use WalletWriterProvider to load L1 mnemonic (supports both old and new structure)
      final walletProvider = GetIt.I.get<WalletWriterProvider>();
      final l1Mnemonic = await walletProvider.getL1Starter();

      if (l1Mnemonic == null || l1Mnemonic.isEmpty) {
        // Electrum wallets have no L1 (enforcer) seed, so the HD Explorer has
        // nothing to derive — leave it uninitialized without surfacing an error.
        _mnemonic = null;
        _initialized = false;
        _error = null;
        return;
      }

      _mnemonic = l1Mnemonic.trim();

      _error = null;
      _initialized = true;
    } catch (e, st) {
      log.e('HDWalletProvider: _loadMnemonic failed', error: e, stackTrace: st);
      _error = "Couldn't load wallet for HD Explorer";
      _mnemonic = null;
      _initialized = false;
    }
  }

  /// Reset the provider state to allow re-initialization with new wallet data
  Future<void> reset() async {
    _initialized = false;
    _mnemonic = null;
    _error = null;
    notifyListeners();
  }

  Future<Map<String, String>> generateWalletXpub(
    int accountIndex, [
    bool isMainnet = false,
  ]) async {
    final coinType = isMainnet ? "0'" : "1'";
    final path = "m/84'/$coinType/$accountIndex'";
    final derived = await deriveAccountXpub(path);

    return {
      'xpub': derived.xpub,
      'fingerprint': derived.fingerprint,
      'xpub_with_origin': '[${derived.fingerprint}/${derived.originPath}]${derived.xpub}',
      'derivation_path': path,
    };
  }

  /// The account xpub at [path] for the loaded L1 seed, from the orchestrator.
  Future<wmpb.DeriveKeystoreResponse> deriveAccountXpub(String path) {
    final mnemonic = _mnemonic;
    if (mnemonic == null || mnemonic.isEmpty) {
      throw StateError('no L1 wallet seed is loaded');
    }
    return GetIt.I.get<OrchestratorRPC>().wallet.deriveKeystore(
      mnemonic: mnemonic,
      scriptType: 'wsh',
      multisig: true,
      derivationPath: path,
    );
  }

  Future<int> getNextAccountIndex([Set<int>? additionalUsedIndices]) async {
    final api = GetIt.I.get<BitwindowRPC>().multisig;
    return await api.getNextAccountIndex(
      additionalUsedIndices: additionalUsedIndices?.toList(),
    );
  }
}
