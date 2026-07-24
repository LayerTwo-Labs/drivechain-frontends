import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:convert/convert.dart' show hex;
import 'package:crypto/crypto.dart' show sha256;
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

/// Wallet writer provider backed by orchestrator's WalletManagerService.
class WalletWriterProvider extends ChangeNotifier {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorWalletRPC get _client => GetIt.I.get<OrchestratorRPC>().wallet;
  final Directory bitwindowAppDir;

  WalletWriterProvider({required this.bitwindowAppDir});

  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  Future<void> init() async {
    _logger.i('init: Wallet writer provider initialized');
    _walletReader.addListener(notifyListeners);
  }

  Future<bool> hasExistingWallet() async {
    return _walletReader.hasWallet();
  }

  Future<WalletData?> loadWallet() async {
    return _walletReader.activeWallet;
  }

  Future<void> saveWallet(WalletData wallet) async {
    await _walletReader.updateWallet(wallet);
  }

  Future<Map<String, dynamic>> generateWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
    int account = 0,
    String? derivationPath,
  }) async {
    try {
      final resp = await _client.generateWallet(
        name: name,
        customMnemonic: customMnemonic,
        passphrase: passphrase,
        account: account,
        derivationPath: derivationPath,
      );

      _logger.i(
        'generateWallet: wallet generated via backend, id=${resp.walletId}',
      );

      await _walletReader.init();
      notifyListeners();

      return {'wallet_id': resp.walletId, 'mnemonic': resp.mnemonic};
    } catch (e) {
      _logger.e('generateWallet: failed: $e');
      rethrow;
    }
  }

  /// Creates a Bitcoin Core wallet. With no [customMnemonic] the backend
  /// generates a fresh seed; [customMnemonic] imports an existing one.
  /// [passphrase] is the optional BIP39 passphrase applied to the seed.
  Future<void> createBitcoinCoreWallet({
    required String name,
    required WalletGradient gradient,
    String? customMnemonic,
    String? passphrase,
    int account = 0,
    String? derivationPath,
  }) async {
    final result = await generateWallet(
      name: name,
      customMnemonic: customMnemonic,
      passphrase: passphrase,
      account: account,
      derivationPath: derivationPath,
    );
    final walletId = result['wallet_id'] as String?;
    if (walletId != null) {
      await updateWalletMetadata(walletId, name, gradient);
    }
  }

  /// Creates an electrum wallet. With no [customMnemonic] or
  /// [xpubOrDescriptor] a new seed is generated. [customMnemonic] imports an
  /// existing seed; [xpubOrDescriptor] instead creates a watch-only wallet
  /// (no private keys). The two import inputs are mutually exclusive.
  Future<void> createElectrumWallet({
    required String name,
    required WalletGradient gradient,
    String? customMnemonic,
    String? passphrase,
    String? xpubOrDescriptor,
    String? scriptType,
    int account = 0,
    String? derivationPath,
    String? hardwareDeviceType,
    String? hardwareFingerprint,
  }) async {
    try {
      final resp = await _client.createElectrumWallet(
        name: name,
        gradientJson: gradient.toJsonString(),
        customMnemonic: customMnemonic,
        passphrase: passphrase,
        xpubOrDescriptor: xpubOrDescriptor,
        scriptType: scriptType,
        account: account,
        derivationPath: derivationPath,
        hardwareDeviceType: hardwareDeviceType,
        hardwareFingerprint: hardwareFingerprint,
      );

      _logger.i('createElectrumWallet: created via backend, id=${resp.walletId}');

      await _walletReader.init();
      notifyListeners();
    } catch (e) {
      _logger.e('createElectrumWallet: failed: $e');
      rethrow;
    }
  }

  /// Creates an m-of-n multisig electrum wallet. Cosigners carrying a mnemonic
  /// or xprv are held on disk and can sign; the rest are watch-only legs.
  Future<void> createMultisigWallet({
    required String name,
    required WalletGradient gradient,
    required int m,
    required int n,
    required String scriptType,
    required List<wmpb.MultisigCosignerInput> cosigners,
  }) async {
    try {
      final resp = await _client.createMultisigWallet(
        name: name,
        gradientJson: gradient.toJsonString(),
        m: m,
        n: n,
        scriptType: scriptType,
        cosigners: cosigners,
      );

      _logger.i('createMultisigWallet: created via backend, id=${resp.walletId}');

      await _walletReader.init();
      notifyListeners();
    } catch (e) {
      _logger.e('createMultisigWallet: failed: $e');
      rethrow;
    }
  }

  Future<void> createWatchOnlyWallet({
    required String name,
    required String xpubOrDescriptor,
    required WalletGradient gradient,
  }) async {
    try {
      final resp = await _client.createWatchOnlyWallet(
        name: name,
        xpubOrDescriptor: xpubOrDescriptor,
        gradientJson: gradient.toJsonString(),
      );

      _logger.i(
        'createWatchOnlyWallet: created via backend, id=${resp.walletId}',
      );

      await _walletReader.init();
      notifyListeners();
    } catch (e) {
      _logger.e('createWatchOnlyWallet: failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateWalletFromEntropy(
    List<int> entropy, {
    String? name,
    String? passphrase,
    bool doNotSave = false,
  }) async {
    final walletData = _walletDataFromEntropy(entropy, passphrase: passphrase);

    if (doNotSave) {
      return walletData;
    }

    final walletName = name?.trim().isNotEmpty == true ? name!.trim() : 'Enforcer Wallet';
    final result = await generateWallet(
      name: walletName,
      customMnemonic: walletData['mnemonic'] as String,
      passphrase: passphrase,
    );

    return {
      ...walletData,
      ...result,
    };
  }

  Map<String, dynamic> _walletDataFromEntropy(
    List<int> entropy, {
    String? passphrase,
  }) {
    final mnemonic = Mnemonic(
      entropy,
      Language.english,
      passphrase: passphrase ?? '',
    );
    final seedHex = hex.encode(mnemonic.seed);
    final masterKey = Chain.seed(seedHex).forPath('m') as ExtendedPrivateKey;
    final bip39Checksum = _bip39Checksum(entropy);

    return {
      'mnemonic': mnemonic.sentence,
      'seed_hex': seedHex,
      'master_key': masterKey.privateKeyHex(),
      'chain_code': hex.encode(masterKey.chainCode!),
      'bip39_binary': _bytesToBinary(entropy),
      'bip39_checksum': bip39Checksum,
      'bip39_checksum_hex': _checksumHex(bip39Checksum),
    };
  }

  String _bytesToBinary(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join();
  }

  String _bip39Checksum(List<int> entropy) {
    final checksumSize = (entropy.length * 8) ~/ 32;
    return _bytesToBinary(sha256.convert(entropy).bytes).substring(0, checksumSize);
  }

  String _checksumHex(String checksumBits) {
    var checksumByte = 0;
    for (final bit in checksumBits.codeUnits) {
      checksumByte = (checksumByte << 1) | (bit == 49 ? 1 : 0);
    }
    return hex.encode([checksumByte]);
  }

  Future<void> saveMasterWallet(
    Map<String, dynamic> walletData, {
    required String name,
  }) async {
    // Handled internally by backend generateWallet
    _logger.w('saveMasterWallet: handled internally by backend generateWallet');
  }

  Future<Map<String, dynamic>?> loadMasterStarter() async {
    // Master/L1/sidechain starters are derived from the enforcer wallet's
    // seed (the backend stamps them onto that wallet's metadata only). When
    // the active wallet is a separate Bitcoin Core or watch-only wallet,
    // reading from `activeWallet` would return blank data and the Starters
    // tab would render empty — fall back to the active wallet only when no
    // enforcer is loaded yet, so a fresh post-wipe install still gets
    // something on screen.
    final wallet = _walletReader.enforcerWallet ?? _walletReader.activeWallet;
    if (wallet != null) {
      return {
        'mnemonic': wallet.master.mnemonic,
        'seed_hex': wallet.master.seedHex,
        'master_key': wallet.master.masterKey,
        'chain_code': wallet.master.chainCode,
        'bip39_binary': wallet.master.bip39Binary,
        'bip39_checksum': wallet.master.bip39Checksum,
        'bip39_checksum_hex': wallet.master.bip39ChecksumHex,
        'name': wallet.master.name,
      };
    }
    return null;
  }

  Future<String?> getL1Starter() async {
    return _walletReader.getL1Mnemonic();
  }

  Future<String?> getSidechainStarter(int sidechainSlot) async {
    return _walletReader.getSidechainMnemonic(sidechainSlot);
  }

  Future<void> deleteAllWallets({
    Future<void> Function()? beforeBoot,
    void Function(String status)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('Deleting wallets via backend');
      await _client.deleteAllWallets();
      _walletReader.clearState();
      onStatusUpdate?.call('Reset complete');

      if (beforeBoot != null) {
        await beforeBoot();
      }
    } catch (e) {
      _logger.e('deleteAllWallets: failed: $e');
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
      await _walletReader.init();
    } catch (e) {
      _logger.e('updateWalletMetadata: failed: $e');
      rethrow;
    }
  }

  Future<void> restartEnforcer() async {
    // The Go orchestrator handles binary lifecycle.
    _logger.i('restartEnforcer: handled by Go orchestrator');
  }

  @override
  void dispose() {
    _walletReader.removeListener(notifyListeners);
    super.dispose();
  }
}
