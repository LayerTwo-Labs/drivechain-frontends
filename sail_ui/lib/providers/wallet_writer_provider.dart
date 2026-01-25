import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

class WalletWriterProvider extends ChangeNotifier {
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();
  final Directory bitwindowAppDir;

  WalletWriterProvider({
    required this.bitwindowAppDir,
  });

  final _logger = GetIt.I.get<Logger>();
  static const String defaultBip32Path = "m/44'/0'/0'";

  // Thread-safe access lock
  final Lock _walletLock = Lock();

  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  Future<void> init() async {
    _logger.i('init: Wallet writer provider initialized');

    // Listen to WalletReaderProvider changes and propagate to our listeners
    _walletReader.addListener(notifyListeners);
  }

  Future<bool> hasExistingWallet() async {
    final fileExists = await _walletReader.getWalletFile().exists();
    return fileExists;
  }

  /// Load wallet - reads from WalletReaderProvider cache (thread-safe)
  Future<WalletData?> loadWallet() async {
    return await _walletLock.synchronized(() async {
      return _walletReader.activeWallet;
    });
  }

  /// Save wallet to new wallet.json structure using WalletReaderProvider
  Future<void> saveWallet(WalletData wallet) async {
    await _walletLock.synchronized(() async {
      try {
        _logger.i('saveWallet: Saving wallet to wallet.json via WalletReaderProvider');

        // Ensure bitwindowAppDir exists
        if (!await bitwindowAppDir.exists()) {
          await bitwindowAppDir.create(recursive: true);
        }

        // Use WalletReaderProvider to update wallet (handles encryption/decryption)
        await _walletReader.updateWallet(wallet);
        _logger.i('saveWallet: Wallet saved successfully via WalletReaderProvider');
      } catch (e, stack) {
        _logger.e('saveWallet: Error saving wallet: $e\n$stack');
        rethrow;
      }
    });
  }

  Future<Map<String, dynamic>> generateWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
  }) async {
    _logger.i('generateWallet: Starting wallet generation');

    final walletData = await _genWallet(name: name, customMnemonic: customMnemonic, passphrase: passphrase);

    _logger.i('generateWallet: Wallet data generated, restarting enforcer');

    // Restart enforcer to pick up the new wallet
    unawaited(restartEnforcer());

    // Reset HD wallet provider to pick up new wallet data (if registered - BitWindow only)
    await _resetHDWalletProviderIfRegistered();

    _logger.i('generateWallet: Complete');
    return walletData;
  }

  /// Reset HD wallet provider if it's registered (BitWindow only)
  Future<void> _resetHDWalletProviderIfRegistered() async {
    // HDWalletProvider is only registered in BitWindow, not sidechains
    // Use dynamic lookup to avoid import dependency
    try {
      if (GetIt.I.isRegistered(instanceName: 'HDWalletProvider')) {
        final hdWalletProvider = GetIt.I.get(instanceName: 'HDWalletProvider');
        await (hdWalletProvider as dynamic).reset();
        await (hdWalletProvider as dynamic).init();
        _logger.i('generateWallet: HD wallet provider reset and re-initialized');
      }
    } catch (e) {
      // HDWalletProvider not available or reset failed - that's OK for sidechains
      _logger.d('generateWallet: HD wallet provider not available or reset failed: $e');
    }
  }

  Future<void> restartEnforcer() async {
    try {
      final enforcerBinary = binaryProvider.binaries.whereType<Enforcer>().firstOrNull;
      if (enforcerBinary != null) {
        // Stop the enforcer
        await binaryProvider.stop(enforcerBinary);
        // Wait for 3 seconds to ensure enforcer is fully stopped
        await Future.delayed(const Duration(seconds: 3));

        // Restart the enforcer with the new wallet
        await binaryProvider.start(enforcerBinary);

        _logger.i('Restarted enforcer after wallet generation');
      }
    } catch (e) {
      _logger.e('Failed to restart enforcer after wallet generation: $e');
    }
  }

  /// Create a new Bitcoin Core wallet (subsequent wallet, not first enforcer wallet)
  Future<void> createBitcoinCoreWallet({
    required String name,
    required WalletGradient gradient,
  }) async {
    _logger.i('createBitcoinCoreWallet: Creating Bitcoin Core wallet named "$name"');

    // Generate a new wallet with random mnemonic
    // This will save the wallet via saveMasterWallet with auto-generated gradient
    await _genWallet(name: name, customMnemonic: null, passphrase: null);

    // Get the newly created wallet ID (it's now the active wallet)
    final walletId = _walletReader.activeWalletId;
    if (walletId != null) {
      // Update with user-selected gradient
      await updateWalletMetadata(walletId, name, gradient);
    }

    _logger.i('createBitcoinCoreWallet: Complete - created wallet $walletId');
  }

  /// Create a watch-only wallet from xpub or descriptor
  Future<void> createWatchOnlyWallet({
    required String name,
    required String xpubOrDescriptor,
    required WalletGradient gradient,
  }) async {
    _logger.i('createWatchOnlyWallet: Creating watch-only wallet named "$name"');

    await _walletLock.synchronized(() async {
      final walletId = _generateWalletId();
      final isDescriptor = xpubOrDescriptor.contains('(') && xpubOrDescriptor.contains(')');

      // Create watch-only wallet structure matching backend's WalletInfo format
      final walletJson = {
        'id': walletId,
        'name': name,
        'wallet_type': 'watchOnly',
        'gradient': gradient.toJson(),
        'created_at': DateTime.now().toIso8601String(),
        'version': 1,
        // Watch-only wallets don't have master/l1/sidechains
        'master': {'seed_hex': ''},
        'l1': {'mnemonic': ''},
        'sidechains': <Map<String, dynamic>>[],
        'watch_only': {
          if (isDescriptor) 'descriptor': xpubOrDescriptor else 'xpub': xpubOrDescriptor,
        },
      };

      // Load existing wallet.json structure
      final walletFile = _walletReader.getWalletFile();
      Map<String, dynamic> walletFileData;

      if (await walletFile.exists()) {
        // Read and decrypt if needed
        final content = await walletFile.readAsString();
        walletFileData = jsonDecode(content) as Map<String, dynamic>;
      } else {
        // Create new structure
        walletFileData = {
          'version': 1,
          'wallets': [],
        };
      }

      // Add new wallet to wallets array
      final wallets = walletFileData['wallets'] as List<dynamic>? ?? [];
      wallets.add(walletJson);
      walletFileData['wallets'] = wallets;
      walletFileData['activeWalletId'] = walletId;

      // Save to file
      await walletFile.writeAsString(jsonEncode(walletFileData));

      // Reload wallet reader to pick up the new wallet
      await _walletReader.init();

      _logger.i('createWatchOnlyWallet: Successfully created watch-only wallet $walletId');
    });
  }

  Future<Map<String, dynamic>> _genWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
  }) async {
    _logger.i('_genWallet: Starting');

    // Run heavy crypto operations in isolate to prevent UI blocking
    final walletData = await compute(_generateWalletInIsolate, {
      'customMnemonic': customMnemonic,
      'passphrase': passphrase,
    });

    _logger.i('_genWallet: Wallet data generated from isolate');

    _logger.i('_genWallet: About to save master wallet (includes all chains)');
    await saveMasterWallet(walletData, name: name);

    _logger.i('_genWallet: Notifying listeners once after all wallets generated');
    notifyListeners();

    _logger.i('_genWallet: Complete');
    return walletData;
  }

  Future<Map<String, dynamic>> generateWalletFromEntropy(
    List<int> entropy, {
    String? passphrase,
    bool doNotSave = false,
  }) async {
    // Create mnemonic from entropy
    final mnemonic = Mnemonic(entropy, Language.english);

    // Generate seed using PBKDF2-HMAC-SHA512
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128));
    final params = Pbkdf2Parameters(utf8.encode('Bitcoin seed'), 2048, 64);
    pbkdf2.init(params);

    // Use mnemonic sentence as the input key material
    final seedBytes = pbkdf2.process(utf8.encode(mnemonic.sentence + (passphrase ?? '')));
    final seedHex = hex.encode(seedBytes);

    // Create master key from seed
    final chain = Chain.seed(seedHex);
    final masterKey = chain.forPath('m') as ExtendedPrivateKey;

    final wallet = {
      'mnemonic': mnemonic.sentence,
      'seed_hex': seedHex,
      'bip39_binary': _bytesToBinary(mnemonic.entropy),
      'bip39_checksum': _calculateChecksumBits(mnemonic.entropy),
      'bip39_checksum_hex': hex.encode([int.parse(_calculateChecksumBits(mnemonic.entropy), radix: 2)]),
      'master_key': masterKey.privateKeyHex(),
      'chain_code': hex.encode(masterKey.chainCode!),
    };

    if (!doNotSave) {
      await saveMasterWallet(wallet, name: 'Enforcer Wallet');

      // Reset HD wallet provider if registered (BitWindow only)
      await _resetHDWalletProviderIfRegistered();
    }

    return wallet;
  }

  static String _bytesToBinary(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
  }

  static String _calculateChecksumBits(List<int> entropy) {
    final entropyBits = entropy.length * 8;
    final checksumSize = entropyBits ~/ 32;

    final hash = sha256.convert(entropy);
    final hashBits = _bytesToBinary(hash.bytes);
    return hashBits.substring(0, checksumSize);
  }

  // Static method to run in isolate
  static Map<String, dynamic> _generateWalletInIsolate(Map<String, dynamic> params) {
    final customMnemonic = params['customMnemonic'] as String?;
    final passphrase = params['passphrase'] as String?;

    final Mnemonic mnemonicObj = customMnemonic != null
        ? Mnemonic.fromSentence(customMnemonic, Language.english, passphrase: passphrase ?? '')
        : Mnemonic.generate(Language.english, length: MnemonicLength.words12, passphrase: passphrase ?? '');

    final seedHex = hex.encode(mnemonicObj.seed);

    // Create chain from seed
    final chain = Chain.seed(seedHex);
    final masterKey = chain.forPath('m') as ExtendedPrivateKey;

    return {
      'mnemonic': mnemonicObj.sentence,
      'seed_hex': seedHex,
      'master_key': masterKey.privateKeyHex(),
      'chain_code': hex.encode(masterKey.chainCode!),
      'bip39_binary': _bytesToBinary(mnemonicObj.entropy),
      'bip39_checksum': _calculateChecksumBits(mnemonicObj.entropy),
      'bip39_checksum_hex': hex.encode([int.parse(_calculateChecksumBits(mnemonicObj.entropy), radix: 2)]),
    };
  }

  String _generateWalletId() {
    return const Uuid().v4().replaceAll('-', '').toUpperCase();
  }

  // Static method to derive starter in isolate
  static Map<String, dynamic> _deriveStarter(Map<String, dynamic> params) {
    final seedHex = params['seedHex'] as String;
    final derivationPath = params['derivationPath'] as String;
    final name = params['name'] as String?;

    // Create chain from seed hex and derive key
    final chain = Chain.seed(seedHex);
    final derivedKey = chain.forPath(derivationPath) as ExtendedPrivateKey;

    // Generate new entropy from derived key
    final privateKeyBytes = hex.decode(derivedKey.privateKeyHex());
    final hashedKey = sha256.convert(privateKeyBytes).bytes;
    final entropy = hashedKey.sublist(0, 16);

    // Create new mnemonic from entropy
    final mnemonic = Mnemonic(entropy, Language.english);
    final seedHexResult = hex.encode(mnemonic.seed);

    return {
      'mnemonic': mnemonic.sentence,
      'seed_hex': seedHexResult,
      'master_key': derivedKey.privateKeyHex(),
      'chain_code': hex.encode(derivedKey.chainCode!),
      'derivation_path': derivationPath,
      if (name != null) 'name': name,
    };
  }

  Future<void> saveMasterWallet(Map<String, dynamic> walletData, {required String name}) async {
    _logger.i('saveMasterWallet: Starting (will save to new wallet.json structure)');

    walletData['name'] = 'Master';

    final requiredFields = ['mnemonic', 'seed_hex', 'master_key'];
    for (final field in requiredFields) {
      if (!walletData.containsKey(field) || walletData[field] == null) {
        throw Exception('Missing required wallet field: $field');
      }
    }

    // Create MasterWallet from the map
    final masterWallet = MasterWallet(
      mnemonic: walletData['mnemonic'] as String,
      seedHex: walletData['seed_hex'] as String,
      masterKey: walletData['master_key'] as String,
      chainCode: walletData['chain_code'] as String,
      bip39Binary: walletData['bip39_binary'] as String?,
      bip39Checksum: walletData['bip39_checksum'] as String?,
      bip39ChecksumHex: walletData['bip39_checksum_hex'] as String?,
      name: walletData['name'] as String,
    );

    // Derive L1 starter
    _logger.i('saveMasterWallet: Deriving L1 starter');
    final l1StarterData = await compute(_deriveStarter, {
      'seedHex': walletData['seed_hex'],
      'derivationPath': "m/44'/0'/256'",
      'name': 'Bitcoin Core (Patched)',
    });
    final l1Wallet = L1Wallet(
      mnemonic: l1StarterData['mnemonic'] as String,
      name: 'Bitcoin Core (Patched)',
    );

    // Derive sidechain starters
    _logger.i('saveMasterWallet: Deriving sidechain starters');
    final sidechainWallets = <SidechainWallet>[];
    final l2Chains = binaryProvider.binaries.where((b) => b.chainLayer == 2).whereType<Sidechain>();

    for (final chain in l2Chains) {
      try {
        final starterData = await compute(_deriveStarter, {
          'seedHex': walletData['seed_hex'],
          'derivationPath': "m/44'/0'/${chain.slot}'",
          'name': chain.name,
        });
        sidechainWallets.add(
          SidechainWallet(
            slot: chain.slot,
            name: chain.name,
            mnemonic: starterData['mnemonic'] as String,
          ),
        );
        _logger.i('saveMasterWallet: Derived sidechain starter for ${chain.name}');
      } catch (e) {
        _logger.e('saveMasterWallet: Could not derive starter for ${chain.name}: $e');
      }
    }

    // Create complete WalletData structure
    // Always generate a new wallet ID for new wallets
    final walletId = _generateWalletId();

    // THE FIRST WALLET MUST ALWAYS BE AN ENFORCER WALLET
    // Check if there are any existing wallets
    final existingWallets = _walletReader.wallets;
    final isFirstWallet = existingWallets.isEmpty;

    // First wallet is enforcer, subsequent wallets are bitcoinCore
    final walletType = isFirstWallet ? BinaryType.enforcer : BinaryType.bitcoinCore;

    _logger.i(
      'saveMasterWallet: Creating wallet with type=$walletType (isFirstWallet=$isFirstWallet, existingCount=${existingWallets.length})',
    );

    final completeWallet = WalletData(
      version: 1,
      master: masterWallet,
      l1: l1Wallet,
      sidechains: sidechainWallets,
      id: walletId,
      name: name,
      gradient: WalletGradient.fromWalletId(walletId),
      createdAt: DateTime.now(),
      walletType: walletType,
    );

    // Save to wallets/wallet_*.json
    // First set the active wallet ID so saveWallet knows where to save
    _walletReader.activeWalletId = walletId;
    await saveWallet(completeWallet);

    // Reload wallet list and switch to the newly created wallet
    await _walletReader.init();

    _logger.i('saveMasterWallet: Complete - created wallet $walletId named "$name"');
  }

  Future<Map<String, dynamic>?> loadMasterStarter() async {
    final wallet = await loadWallet();
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
    final wallet = await loadWallet();
    return wallet?.l1.mnemonic;
  }

  Future<String?> getSidechainStarter(int sidechainSlot) async {
    final wallet = await loadWallet();
    if (wallet == null) return null;

    // Check if sidechain wallet already exists
    final existingSidechain = wallet.sidechains.where((s) => s.slot == sidechainSlot).firstOrNull;
    if (existingSidechain != null) {
      return existingSidechain.mnemonic;
    }

    // Sidechain doesn't exist yet - generate it
    _logger.i('getSidechainStarter: Sidechain for slot $sidechainSlot not found, generating...');

    // Find the sidechain binary configuration
    final sidechainBinary = binaryProvider.binaries
        .whereType<Sidechain>()
        .where((s) => s.slot == sidechainSlot)
        .firstOrNull;
    if (sidechainBinary == null) {
      _logger.w('getSidechainStarter: No sidechain binary configured for slot $sidechainSlot');
      return null;
    }

    // Derive the new sidechain starter from master wallet
    final starterData = await compute(_deriveStarter, {
      'seedHex': wallet.master.seedHex,
      'derivationPath': "m/44'/0'/$sidechainSlot'",
      'name': sidechainBinary.name,
    });

    // Create the new sidechain wallet
    final newSidechain = SidechainWallet(
      slot: sidechainSlot,
      name: sidechainBinary.name,
      mnemonic: starterData['mnemonic'] as String,
    );

    // Update wallet with the new sidechain
    final updatedWallet = WalletData(
      version: wallet.version,
      master: wallet.master,
      l1: wallet.l1,
      sidechains: [...wallet.sidechains, newSidechain],
      id: wallet.id,
      name: wallet.name,
      gradient: wallet.gradient,
      createdAt: wallet.createdAt,
      walletType: wallet.walletType,
    );

    // Save updated wallet
    await saveWallet(updatedWallet);
    _logger.i('getSidechainStarter: Generated and saved sidechain wallet for slot $sidechainSlot');

    return newSidechain.mnemonic;
  }

  // Delete Bitcoin Core wallet directories in network-specific datadir
  Future<void> _deleteCoreMultisigWallets(Logger logger) async {
    try {
      final coreDataDir = Directory(BitcoinCore().datadirNetwork());
      final entities = await coreDataDir.list(recursive: false).toList();

      for (final maybeMusigWallet in entities) {
        if (maybeMusigWallet is Directory && path.basename(maybeMusigWallet.path).startsWith('multisig_')) {
          try {
            await maybeMusigWallet.delete(recursive: true);
            logger.i('Deleted multisig wallet: ${maybeMusigWallet.path}');
          } catch (e) {
            logger.w('Could not delete multisig wallet ${maybeMusigWallet.path}: $e');
          }
        }
      }
    } catch (e) {
      logger.e('Error cleaning multisig wallets in core data dir: $e');
    }
  }

  Future<void> deleteAllWallets({
    Future<void> Function()? beforeBoot,
    void Function(String status)? onStatusUpdate,
  }) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    onStatusUpdate?.call('Stopping binaries');

    final alwaysStop = [BitcoinCore(), Enforcer(), BitWindow()];
    // regardless of whether bitwindow started these, we need to stop them
    for (final binary in alwaysStop) {
      await binaryProvider.stop(binary);
    }

    try {
      for (final binary in binaryProvider.binaries) {
        // stop absolutely all binaries, to avoid corruption/file overwriting
        await binaryProvider.stop(binary);
      }
    } catch (e) {
      _logger.e('could not stop individual binaries: $e');
    }

    onStatusUpdate?.call('Waiting for processes to stop');
    await Future.delayed(const Duration(seconds: 5));

    onStatusUpdate?.call('Deleting wallet files');

    try {
      for (final binary in binaryProvider.binaries) {
        // wipe all wallets, for the enforcer, bitnames, bitassets, thunder etc..
        await binary.deleteWallet();
      }
    } catch (e) {
      _logger.e('could not wipe wallets: $e');
    }

    onStatusUpdate?.call('Cleaning multisig wallets');

    // Clean BitDrive data if provider is registered (BitWindow only)
    try {
      if (GetIt.I.isRegistered(instanceName: 'BitDriveProvider')) {
        final bitDriveProvider = GetIt.I.get(instanceName: 'BitDriveProvider');
        await (bitDriveProvider as dynamic).wipeData(bitwindowAppDir);
      }
      await _deleteCoreMultisigWallets(_logger);
    } catch (e) {
      _logger.e('could not delete multisig wallets: $e');
    }

    onStatusUpdate?.call('Clearing wallet state');

    // Clear in-memory wallet state
    _walletReader.clearState();

    // Reset HD wallet provider if registered (BitWindow only)
    await _resetHDWalletProviderIfRegistered();

    // Clear balance and transaction providers if registered
    try {
      if (GetIt.I.isRegistered(instanceName: 'TransactionProvider')) {
        final txProvider = GetIt.I.get(instanceName: 'TransactionProvider');
        (txProvider as dynamic).clear();
      }
      GetIt.I.get<BalanceProvider>().clear();
    } catch (e) {
      _logger.e('could not clear balance/transaction providers: $e');
    }

    try {
      if (beforeBoot != null) {
        await beforeBoot();
      }
    } catch (e) {
      _logger.e('could not run beforeBoot: $e');
    }

    onStatusUpdate?.call('Reset complete');

    // Caller is responsible for booting binaries and navigating to wallet creation
  }

  /// Update wallet metadata (name and gradient)
  Future<void> updateWalletMetadata(String walletId, String name, WalletGradient gradient) async {
    return await _walletLock.synchronized(() async {
      try {
        await _walletReader.updateWalletMetadata(walletId, name, gradient);
        _logger.i('updateWalletMetadata: Updated wallet $walletId');
      } catch (e, stack) {
        _logger.e('updateWalletMetadata: Failed to update wallet metadata: $e\n$stack');
        rethrow;
      }
    });
  }

  @override
  void dispose() {
    _walletReader.removeListener(notifyListeners);
    super.dispose();
  }
}
