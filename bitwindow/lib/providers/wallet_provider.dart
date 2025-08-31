import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
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
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';

class WalletProvider extends ChangeNotifier {
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();
  final Directory bitwindowAppDir;

  WalletProvider({
    required this.bitwindowAppDir,
  });

  final _logger = GetIt.I.get<Logger>();
  static const String defaultBip32Path = "m/44'/0'/0'";

  Future<bool> hasExistingWallet() async {
    return (await getMasterStarter()) != null;
  }

  Future<bool> hasLauncherModeDir() async {
    var walletDir = path.join(bitwindowAppDir.path, 'wallet_starters');
    return Directory(walletDir).existsSync();
  }

  Future<File?> getMasterStarter() async {
    final walletFile = await _getWalletFile('master_starter.json');
    if (walletFile == null || !await walletFile.exists()) return null;

    final walletJson = await walletFile.readAsString();
    final walletData = jsonDecode(walletJson) as Map<String, dynamic>;

    if (!walletData.containsKey('mnemonic') || !walletData.containsKey('seed_hex')) {
      throw Exception('Invalid wallet data format');
    }

    return walletFile;
  }

  Future<void> moveMasterWalletDir() async {
    final hasLauncherDir = await hasLauncherModeDir();
    if (!hasLauncherDir) {
      return;
    }

    final newName = await _findAvailableName(bitwindowAppDir.path, 'wallet_starters');
    final newPath = path.join(bitwindowAppDir.path, newName);
    await getWalletDir(bitwindowAppDir)!.rename(newPath);
    _logger.i('Moved wallet_starters directory to $newName');
  }

  Future<String> _findAvailableName(String dir, String originalName) async {
    final baseName = path.basenameWithoutExtension(originalName);
    final extension = path.extension(originalName);

    // Try the original name first
    String candidateName = originalName;
    int counter = 2;

    while (await Directory(path.join(dir, candidateName)).exists()) {
      candidateName = '$baseName-$counter$extension';
      counter++;
    }

    return candidateName;
  }

  Future<Map<String, dynamic>> generateWallet({String? customMnemonic, String? passphrase}) async {
    _logger.i('generateWallet: Starting wallet generation');

    final walletData = await _genWallet(customMnemonic: customMnemonic, passphrase: passphrase);

    _logger.i('generateWallet: Wallet data generated, restarting enforcer');

    // Restart enforcer to pick up the new wallet
    unawaited(restartEnforcer());

    // Reset HD wallet provider to pick up new wallet data
    try {
      final hdWalletProvider = GetIt.I.get<HDWalletProvider>();
      await hdWalletProvider.reset();
      await hdWalletProvider.init();
      _logger.i('generateWallet: HD wallet provider reset and re-initialized');
    } catch (e) {
      _logger.e('generateWallet: Failed to reset HD wallet provider: $e');
    }

    _logger.i('generateWallet: Complete');
    return walletData;
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

  Future<Map<String, dynamic>> _genWallet({String? customMnemonic, String? passphrase}) async {
    _logger.i('_genWallet: Starting');

    // Run heavy crypto operations in isolate to prevent UI blocking
    final walletData = await compute(_generateWalletInIsolate, {
      'customMnemonic': customMnemonic,
      'passphrase': passphrase,
    });

    _logger.i('_genWallet: Wallet data generated from isolate');

    _logger.i('_genWallet: About to save master wallet');
    await saveMasterWallet(walletData);

    _logger.i('_genWallet: Master wallet saved, generating starters for chains');
    await generateStartersForDownloadedChains();

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
      await saveMasterWallet(wallet);
      await generateStartersForDownloadedChains();

      // Reset HD wallet provider to pick up new wallet data
      try {
        final hdWalletProvider = GetIt.I.get<HDWalletProvider>();
        await hdWalletProvider.reset();
        await hdWalletProvider.init();
        _logger.i('generateWalletFromEntropy: HD wallet provider reset and re-initialized');
      } catch (e) {
        _logger.e('generateWalletFromEntropy: Failed to reset HD wallet provider: $e');
      }
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

  Future<void> saveMasterWallet(Map<String, dynamic> walletData) async {
    _logger.i('saveMasterWallet: Starting');

    walletData['name'] = 'Master';

    final requiredFields = ['mnemonic', 'seed_hex', 'master_key'];
    for (final field in requiredFields) {
      if (!walletData.containsKey(field) || walletData[field] == null) {
        throw Exception('Missing required wallet field: $field');
      }
    }

    _logger.i('saveMasterWallet: About to ensure wallet dir');
    await _ensureWalletDir();

    _logger.i('saveMasterWallet: Getting wallet file');
    final walletFile = await _getWalletFile('master_starter.json');

    if (walletFile == null) {
      _logger.e('saveMasterWallet: Wallet file is null!');
      throw Exception('Could not find wallet file, even after ensured');
    }

    _logger.i('saveMasterWallet: Writing wallet data to file');
    await walletFile.writeAsString(jsonEncode(walletData));

    // Don't notify listeners here - will be done after all wallets are generated
    _logger.i('saveMasterWallet: Complete (skipping notification)');

    _logger.i('saveMasterWallet: Complete');
  }

  Future<void> deleteWallet() async {
    final walletFile = await getMasterStarter();
    if (walletFile != null) {
      await walletFile.delete();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> loadMasterStarter() async {
    final walletFile = await getMasterStarter();
    if (walletFile == null) return null;

    final walletJson = await walletFile.readAsString();
    final walletData = jsonDecode(walletJson) as Map<String, dynamic>;

    if (!walletData.containsKey('mnemonic') || !walletData.containsKey('master_key')) {
      throw Exception('Invalid wallet data format');
    }

    return walletData;
  }

  Future<String?> getL1Starter() async {
    return _loadMnemonicStarter('l1_starter.txt');
  }

  Future<String?> getSidechainStarter(int sidechainSlot) async {
    return _loadMnemonicStarter('sidechain_${sidechainSlot}_starter.txt');
  }

  Future<String?> _loadMnemonicStarter(String fileName) async {
    try {
      final file = await _getWalletFile(fileName);
      if (file == null || !file.existsSync()) {
        return null;
      }

      return await file.readAsString();
    } catch (e) {
      _logger.e('Error loading starter $fileName: $e');
      return null;
    }
  }

  Future<void> _saveMnemonicStarter(String fileName, String mnemonic) async {
    _logger.i('_saveMnemonicStarter: Starting for $fileName');

    try {
      await _ensureWalletDir();

      _logger.i('_saveMnemonicStarter: Getting wallet file for $fileName');
      final file = await _getWalletFile(fileName);

      if (file == null) {
        _logger.e('_saveMnemonicStarter: File is null for $fileName!');
        throw Exception('Could not find wallet file, even after ensured');
      }

      _logger.i('_saveMnemonicStarter: Writing mnemonic to ${file.path}');
      await file.writeAsString(mnemonic);

      // Don't notify listeners here - will be done after all wallets are generated

      _logger.i('_saveMnemonicStarter: Complete for $fileName');
    } catch (e, stackTrace) {
      _logger.e('_saveMnemonicStarter: Error saving $fileName: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<File?> _getWalletFile(String fileName) async {
    _logger.i('_getWalletFile: Getting file $fileName');

    final walletDir = getWalletDir(bitwindowAppDir);
    if (walletDir == null) {
      _logger.e('_getWalletFile: walletDir is null for $fileName');
      return null;
    }

    final file = File(path.join(walletDir.path, fileName));
    _logger.i('_getWalletFile: Returning file at ${file.path}');
    return file;
  }

  Future<void> _ensureWalletDir() async {
    _logger.i('_ensureWalletDir: Starting');

    var walletDir = getWalletDir(bitwindowAppDir);
    if (walletDir == null) {
      _logger.e('_ensureWalletDir: Could not find wallet dir, creating new one');
      walletDir = Directory(path.join(bitwindowAppDir.path, 'wallet_starters'));
    } else {
      _logger.i('_ensureWalletDir: Found wallet dir: ${walletDir.path}');
      return;
    }

    _logger.i('_ensureWalletDir: Creating directory at ${walletDir.path}');
    await walletDir.create(recursive: true);

    _logger.i('_ensureWalletDir: Directory created');
  }

  Future<void> generateStartersForDownloadedChains() async {
    _logger.i('generateStartersForDownloadedChains: Starting');

    try {
      // Load master wallet once for all derivations
      final masterWallet = await loadMasterStarter();
      if (masterWallet == null) {
        throw Exception('Master starter not found');
      }
      if (!masterWallet.containsKey('seed_hex')) {
        throw Exception('Master starter is missing required field: seed_hex');
      }

      // first derive for L1 in isolate
      _logger.i('generateStartersForDownloadedChains: Deriving L1 starter');
      final l1StarterData = await compute(_deriveStarter, {
        'seedHex': masterWallet['seed_hex'],
        'derivationPath': "m/44'/0'/256'",
        'name': 'Bitcoin Core (Patched)',
      });
      l1StarterData['chain_layer'] = 1;
      await _saveMnemonicStarter('l1_starter.txt', l1StarterData['mnemonic']);

      // For each L2 chain in binaries
      final l2Chains = binaryProvider.binaries.where((b) => b.chainLayer == 2);
      _logger.i('generateStartersForDownloadedChains: Found ${l2Chains.length} L2 chains');

      // then derive for L2s in parallel using isolates
      final derivationFutures = l2Chains
          .whereType<Sidechain>()
          .map(
            (chain) => () async {
              try {
                _logger.i('generateStartersForDownloadedChains: Deriving starter for ${chain.name}');
                final starterData = await compute(_deriveStarter, {
                  'seedHex': masterWallet['seed_hex'],
                  'derivationPath': "m/44'/0'/${chain.slot}'",
                  'name': chain.name,
                });
                await _saveMnemonicStarter('sidechain_${chain.slot}_starter.txt', starterData['mnemonic']);
              } catch (e) {
                _logger.e('could not derive starter for ${chain.name}: $e');
              }
            }(),
          )
          .toList();

      _logger.i('generateStartersForDownloadedChains: Waiting for ${derivationFutures.length} futures');
      await Future.wait(derivationFutures);

      // Don't notify listeners here anymore - moved to _genWallet

      _logger.i('generateStartersForDownloadedChains: Complete');
    } catch (e, stack) {
      _logger.e('generateStartersForDownloadedChains: Error: $e\n$stack');
    }
  }

  // Delete Bitcoin Core wallet directories in Drivechain/signet
  Future<void> _deleteCoreMultisigWallets(Logger logger) async {
    try {
      final coreDataDir = Directory(path.join(BitcoinCore().datadir(), 'signet'));
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

    // Store connected and running binaries to reboot them after wallet wipe is complete
    final connected = binaryProvider.binaries.where(binaryProvider.isConnected).toList();
    final running = binaryProvider.runningBinaries;
    final allBinaries = [...running, ...connected];
    final runningBinaries = allBinaries.fold<List<Binary>>([], (unique, binary) {
      if (!unique.any((b) => b.name == binary.name)) {
        unique.add(binary);
      }
      return unique;
    });

    onStatusUpdate?.call('Stopping binaries');

    // then be extra sure and stop everything in the process manager
    try {
      await binaryProvider.stopAll();
    } catch (e) {
      _logger.e('could not stop all binaries: $e');
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

    try {
      await GetIt.I.get<BitDriveProvider>().wipeData(bitwindowAppDir);
      await _deleteCoreMultisigWallets(_logger);
    } catch (e) {
      _logger.e('could not delete multisig wallets: $e');
    }

    onStatusUpdate?.call('Moving master wallet directory');

    try {
      await moveMasterWalletDir();
    } catch (e) {
      _logger.e('could not move master wallet dir: $e');
    }

    try {
      if (beforeBoot != null) {
        await beforeBoot();
      }
    } catch (e) {
      _logger.e('could not run beforeBoot: $e');
    }

    onStatusUpdate?.call('Reset complete');
    onStatusUpdate?.call('Reset complete');

    try {
      // reboot L1-binaries
      await bootBinaries(_logger);
    } catch (e) {
      _logger.e('could not boot L1-binaries: $e');
    }

    // then restart all sidechains we stopped
    for (final binary in runningBinaries) {
      unawaited(binaryProvider.start(binary));
    }
  }
}
