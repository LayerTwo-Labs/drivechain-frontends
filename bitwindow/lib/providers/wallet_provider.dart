import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/models/wallet_data.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:bitwindow/providers/encryption_provider.dart';
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
import 'package:synchronized/synchronized.dart';

class WalletProvider extends ChangeNotifier {
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();
  final Directory bitwindowAppDir;

  WalletProvider({
    required this.bitwindowAppDir,
  });

  final _logger = GetIt.I.get<Logger>();
  static const String defaultBip32Path = "m/44'/0'/0'";

  // Cached wallet data with thread-safe access
  WalletData? _cachedWallet;
  final Lock _walletLock = Lock();

  // File watcher for wallet.json changes
  StreamSubscription<FileSystemEvent>? _fileWatcher;

  Future<void> init() async {
    await migrate();

    await _walletLock.synchronized(() async {
      _logger.i('init: Initializing wallet provider');
      await _loadAndCacheWallet();
      _logger.i('init: Wallet provider initialized');
    });

    // Sync starter files from wallet.json
    await syncStarterFiles();

    // Set up file watcher for wallet.json
    _setupFileWatcher();
  }

  /// Set up file watcher to reload cache when wallet.json changes
  void _setupFileWatcher() {
    try {
      final walletFile = _getWalletJsonFile();
      _fileWatcher = walletFile
          .watch(events: FileSystemEvent.all)
          .listen(
            (event) async {
              _logger.i('File watcher: wallet.json ${event.type} event detected');

              // Reload cache when file is modified or created
              if (event.type == FileSystemEvent.modify || event.type == FileSystemEvent.create) {
                await _walletLock.synchronized(() async {
                  _logger.i('File watcher: Reloading wallet into cache');
                  await _loadAndCacheWallet();
                  notifyListeners();
                });

                // Sync starter files so enforcer and sidechains pick up changes
                _logger.i('File watcher: Syncing starter files after wallet.json change');
                await syncStarterFiles();
              }
              // Clear cache when file is deleted
              else if (event.type == FileSystemEvent.delete) {
                await _walletLock.synchronized(() async {
                  _logger.i('File watcher: Wallet deleted, clearing cache');
                  _cachedWallet = null;
                  notifyListeners();
                });
              }
            },
            onError: (error) {
              _logger.e('File watcher error: $error');
            },
          );
      _logger.i('File watcher: Started watching wallet.json');
    } catch (e, stack) {
      _logger.e('File watcher: Failed to set up file watcher: $e\n$stack');
    }
  }

  @override
  void dispose() {
    _fileWatcher?.cancel();
    _logger.i('File watcher: Stopped watching wallet.json');

    // Clean up temporary starter files from /tmp
    cleanupStarterFiles();

    super.dispose();
  }

  /// Load wallet from disk and cache it (must be called within lock)
  Future<void> _loadAndCacheWallet() async {
    try {
      final walletFile = _getWalletJsonFile();
      if (!await walletFile.exists()) {
        _cachedWallet = null;
        _logger.i('_loadAndCacheWallet: No wallet file found');
        return;
      }

      // Check if wallet is encrypted
      final encryptionProvider = GetIt.I.get<EncryptionProvider>();
      final isEncrypted = await encryptionProvider.isWalletEncrypted();

      if (isEncrypted) {
        // Wallet is encrypted - get decrypted data from EncryptionProvider
        if (encryptionProvider.isWalletUnlocked) {
          final decryptedJson = encryptionProvider.decryptedWalletJson;
          if (decryptedJson != null) {
            _logger.i('_loadAndCacheWallet: Loading encrypted wallet from memory');
            _cachedWallet = WalletData.fromJsonString(decryptedJson);
            _logger.i('_loadAndCacheWallet: Encrypted wallet cached successfully');
          } else {
            _logger.w('_loadAndCacheWallet: Wallet is encrypted but no decrypted data available');
            _cachedWallet = null;
          }
        } else {
          _logger.i('_loadAndCacheWallet: Wallet is encrypted and locked');
          _cachedWallet = null;
        }
      } else {
        // Wallet is not encrypted - read directly from disk
        _logger.i('_loadAndCacheWallet: Loading unencrypted wallet from disk');
        final json = await walletFile.readAsString();
        _cachedWallet = WalletData.fromJsonString(json);
        _logger.i('_loadAndCacheWallet: Wallet cached successfully');
      }
    } catch (e, stack) {
      _logger.e('_loadAndCacheWallet: Error loading wallet: $e\n$stack');
      _cachedWallet = null;
      rethrow;
    }
  }

  Future<bool> hasExistingWallet() async {
    final walletFile = _getWalletJsonFile();
    return await walletFile.exists();
  }

  /// Load wallet - returns cached wallet (thread-safe)
  Future<WalletData?> loadWallet() async {
    return await _walletLock.synchronized(() async {
      return _cachedWallet;
    });
  }

  /// Save wallet to new wallet.json structure and refresh cache
  Future<void> saveWallet(WalletData wallet) async {
    await _walletLock.synchronized(() async {
      try {
        _logger.i('saveWallet: Saving wallet to wallet.json');

        // Ensure bitwindowAppDir exists
        if (!await bitwindowAppDir.exists()) {
          await bitwindowAppDir.create(recursive: true);
        }

        final jsonString = wallet.toJsonString();

        // Check if wallet is encrypted
        final encryptionProvider = GetIt.I.get<EncryptionProvider>();
        final isEncrypted = await encryptionProvider.isWalletEncrypted();

        if (isEncrypted) {
          // Wallet is encrypted - use EncryptionProvider to update and re-encrypt
          _logger.i('saveWallet: Wallet is encrypted, updating via EncryptionProvider');
          await encryptionProvider.updateEncryptedWallet(jsonString);
          _logger.i('saveWallet: Encrypted wallet updated successfully');
        } else {
          // Wallet is not encrypted - write plaintext to disk
          final walletFile = _getWalletJsonFile();

          // Write atomically by writing to temp file first
          final tempFile = File('${walletFile.path}.tmp');
          await tempFile.writeAsString(jsonString);
          await tempFile.rename(walletFile.path);

          _logger.i('saveWallet: Wallet saved successfully to ${walletFile.path}');
        }

        // Update cache
        _cachedWallet = wallet;
        _logger.i('saveWallet: Cache updated');
      } catch (e, stack) {
        _logger.e('saveWallet: Error saving wallet: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Get the wallet.json file reference
  File _getWalletJsonFile() {
    return File(path.join(bitwindowAppDir.path, 'wallet.json'));
  }

  /// Get the temporary starter directory (create if needed)
  /// Uses process-specific directory for security and isolation
  Future<Directory> _getStarterDirectory() async {
    final tmpDir = Directory(path.join(Directory.systemTemp.path, 'bitwindow_starters_$pid'));
    if (!await tmpDir.exists()) {
      await tmpDir.create(recursive: true);
      // Set restrictive permissions (owner only: rwx------)
      if (!Platform.isWindows) {
        await Process.run('chmod', ['700', tmpDir.path]);
      }
      _logger.i('Created temporary starter directory: ${tmpDir.path}');
    }
    return tmpDir;
  }

  /// Static helper to get the tmp starter directory path
  /// Used by other packages that need to know where starter files are located
  static Directory getTmpStarterDirectory() {
    return Directory(path.join(Directory.systemTemp.path, 'bitwindow_starters_$pid'));
  }

  /// Write L1 starter file
  Future<void> _writeL1StarterFile(String mnemonic) async {
    try {
      final starterDir = await _getStarterDirectory();
      final l1File = File(path.join(starterDir.path, 'l1_starter.txt'));
      await l1File.writeAsString(mnemonic);
      _logger.i('Wrote l1_starter.txt');
    } catch (e, stack) {
      _logger.e('Failed to write l1_starter.txt: $e\n$stack');
      rethrow;
    }
  }

  /// Write sidechain starter file
  Future<void> _writeSidechainStarterFile(int slot, String mnemonic) async {
    try {
      final starterDir = await _getStarterDirectory();
      final scFile = File(path.join(starterDir.path, 'sidechain_${slot}_starter.txt'));
      await scFile.writeAsString(mnemonic);
      _logger.i('Wrote sidechain_${slot}_starter.txt');
    } catch (e, stack) {
      _logger.e('Failed to write sidechain_${slot}_starter.txt: $e\n$stack');
      rethrow;
    }
  }

  /// Sync all starter files from wallet.json
  /// Creates/updates all l1_starter.txt and sidechain_*_starter.txt files
  /// Public method for use by restore process and other external callers
  Future<void> syncStarterFiles() async {
    try {
      _logger.i('_syncStarterFiles: Starting sync');
      final wallet = await loadWallet();
      if (wallet == null) {
        _logger.i('_syncStarterFiles: No wallet to sync');
        return;
      }

      // Write L1 starter
      await _writeL1StarterFile(wallet.l1.mnemonic);

      // Write all sidechain starters
      for (final sc in wallet.sidechains) {
        await _writeSidechainStarterFile(sc.slot, sc.mnemonic);
      }

      _logger.i('_syncStarterFiles: Synced ${wallet.sidechains.length + 1} starter files');
    } catch (e, stack) {
      _logger.e('_syncStarterFiles: Failed to sync starter files: $e\n$stack');
      rethrow;
    }
  }

  /// Clean up temporary starter files from /tmp
  /// Called when locking wallet or disposing provider
  Future<void> cleanupStarterFiles() async {
    try {
      final tmpDir = getTmpStarterDirectory();
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
        _logger.i('Cleaned up temporary starter directory: ${tmpDir.path}');
      }
    } catch (e, stack) {
      _logger.w('Failed to cleanup starter files: $e\n$stack');
      // Don't rethrow - cleanup failures shouldn't break the app
    }
  }

  Future<File?> getWallet() async {
    // This method is deprecated and only used by legacy code
    // New code should use loadWallet() instead
    final wallet = await loadWallet();
    if (wallet == null) return null;

    // Return a dummy file reference since some legacy code expects a File
    return File(path.join(bitwindowAppDir.path, 'wallet.json'));
  }

  /// Backup wallet.json by renaming it with a timestamp
  /// Used when deleting all wallets to preserve the current wallet
  Future<void> moveWallet() async {
    await _walletLock.synchronized(() async {
      try {
        final walletFile = _getWalletJsonFile();
        if (!await walletFile.exists()) {
          _logger.i('moveMasterWalletDir: No wallet.json to backup');
          return;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupPath = path.join(bitwindowAppDir.path, 'wallet.json.backup_$timestamp');

        await walletFile.rename(backupPath);
        _logger.i('moveMasterWalletDir: Backed up wallet.json to $backupPath');

        // Clear the cached wallet since it no longer exists
        _cachedWallet = null;
      } catch (e, stack) {
        _logger.e('moveMasterWalletDir: Error backing up wallet: $e\n$stack');
        rethrow;
      }
    });
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

    _logger.i('_genWallet: About to save master wallet (includes all chains)');
    await saveMasterWallet(walletData);

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
    final completeWallet = WalletData(
      version: 1,
      master: masterWallet,
      l1: l1Wallet,
      sidechains: sidechainWallets,
    );

    // Save to wallet.json
    await saveWallet(completeWallet);

    // Sync all starter files
    await syncStarterFiles();

    _logger.i('saveMasterWallet: Complete');
  }

  Future<void> deleteWallet() async {
    final walletFile = await getWallet();
    if (walletFile != null) {
      await walletFile.delete();
      notifyListeners();
    }
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
    );

    // Save updated wallet
    await saveWallet(updatedWallet);
    _logger.i('getSidechainStarter: Generated and saved sidechain wallet for slot $sidechainSlot');

    // Write starter file for the new sidechain
    await _writeSidechainStarterFile(sidechainSlot, newSidechain.mnemonic);

    return newSidechain.mnemonic;
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

    try {
      await GetIt.I.get<BitDriveProvider>().wipeData(bitwindowAppDir);
      await _deleteCoreMultisigWallets(_logger);
    } catch (e) {
      _logger.e('could not delete multisig wallets: $e');
    }

    onStatusUpdate?.call('Moving master wallet directory');

    try {
      await moveWallet();
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

  /// Migrate from old wallet structure to new wallet.json
  /// Checks if migration is needed and performs it if necessary
  Future<void> migrate() async {
    try {
      // Check if wallet.json already exists (new structure)
      final walletJsonFile = _getWalletJsonFile();
      if (await walletJsonFile.exists()) {
        _logger.i('migrate: Wallet is already in new format');
        return;
      }

      // Check if old structure exists
      final oldMasterFile = File(path.join(bitwindowAppDir.path, 'wallet_starters', 'master_starter.json'));
      if (!await oldMasterFile.exists()) {
        _logger.i('migrate: No wallet found to migrate');
        return;
      }

      _logger.i('migrate: Detected old wallet structure, starting migration...');

      // Helper function to read from old file structure
      Future<String?> readOldMnemonicFile(String fileName) async {
        try {
          final file = File(path.join(bitwindowAppDir.path, 'wallet_starters', fileName));
          if (await file.exists()) {
            return await file.readAsString();
          }
          return null;
        } catch (e) {
          _logger.e('Error reading $fileName: $e');
          return null;
        }
      }

      // 1. Load all old files directly from old structure
      _logger.i('migrate: Loading old wallet files...');

      // Load master_starter.json
      final masterFile = File(path.join(bitwindowAppDir.path, 'wallet_starters', 'master_starter.json'));
      if (!await masterFile.exists()) {
        throw Exception('Could not load master_starter.json for migration');
      }
      final masterJson = await masterFile.readAsString();
      final masterData = jsonDecode(masterJson) as Map<String, dynamic>;

      // Load l1_starter.txt
      final l1Mnemonic = await readOldMnemonicFile('l1_starter.txt');
      if (l1Mnemonic == null) {
        throw Exception('Could not load l1_starter.txt for migration');
      }

      // Load sidechain starters
      final sidechains = <SidechainWallet>[];
      for (final binary in binaryProvider.binaries.whereType<Sidechain>()) {
        final mnemonic = await readOldMnemonicFile('sidechain_${binary.slot}_starter.txt');
        if (mnemonic != null) {
          sidechains.add(
            SidechainWallet(
              slot: binary.slot,
              name: binary.name,
              mnemonic: mnemonic,
            ),
          );
          _logger.i('migrate: Loaded sidechain starter for ${binary.name}');
        }
      }

      // 2. Create new WalletData structure
      _logger.i('migrate: Creating new wallet structure...');
      final walletData = WalletData(
        version: 1,
        master: MasterWallet(
          mnemonic: masterData['mnemonic'] as String,
          seedHex: masterData['seed_hex'] as String,
          masterKey: masterData['master_key'] as String,
          chainCode: masterData['chain_code'] as String,
          bip39Binary: masterData['bip39_binary'] as String?,
          bip39Checksum: masterData['bip39_checksum'] as String?,
          bip39ChecksumHex: masterData['bip39_checksum_hex'] as String?,
          name: masterData['name'] as String? ?? 'Master',
        ),
        l1: L1Wallet(
          mnemonic: l1Mnemonic,
          name: 'Bitcoin Core (Patched)',
        ),
        sidechains: sidechains,
      );

      // 3. Backup old files before any changes
      _logger.i('migrate: Backing up old wallet files...');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupDir = Directory(path.join(bitwindowAppDir.path, 'wallet_starters_backup_$timestamp'));
      await backupDir.create(recursive: true);

      final walletDir = Directory(path.join(bitwindowAppDir.path, 'wallet_starters'));
      if (await walletDir.exists()) {
        await for (final entity in walletDir.list()) {
          if (entity is File) {
            final basename = path.basename(entity.path);
            if (basename.endsWith('.json') || basename.endsWith('.txt')) {
              final newPath = path.join(backupDir.path, basename);
              await entity.copy(newPath);
              _logger.i('migrate: Backed up $basename');
            }
          }
        }
      }
      _logger.i('migrate: Backup created at ${backupDir.path}');

      // 4. Save to new wallet.json
      _logger.i('migrate: Saving new wallet.json...');
      await saveWallet(walletData);

      // 5. Verify new wallet can be loaded
      _logger.i('migrate: Verifying new wallet...');
      final verifyWallet = await loadWallet();
      if (verifyWallet == null) {
        throw Exception('Failed to verify newly migrated wallet');
      }

      // 6. Delete old files only after successful verification
      _logger.i('migrate: Deleting old wallet files...');
      if (await walletDir.exists()) {
        await for (final entity in walletDir.list()) {
          if (entity is File) {
            final basename = path.basename(entity.path);
            // Delete master_starter.json (old format)
            // Delete old .txt files (will be regenerated from wallet.json by _syncStarterFiles)
            if (basename == 'master_starter.json' || basename.endsWith('.txt')) {
              await entity.delete();
              _logger.i('migrate: Deleted $basename');
            }
          }
        }
      }

      _logger.i('migrate: Migration completed successfully!');
      _logger.i('migrate: Starter .txt files will be regenerated from wallet.json');
    } catch (e, stackTrace) {
      _logger.e('migrate: Failed to migrate wallet: $e\n$stackTrace');
      _logger.e('migrate: Old wallet files preserved. Please check backup.');
      // Don't throw - let the app continue
    }
  }
}
