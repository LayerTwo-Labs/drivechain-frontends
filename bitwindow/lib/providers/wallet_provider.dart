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
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';

class WalletProvider extends ChangeNotifier {
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();
  final Directory appDir;

  WalletProvider({
    required this.appDir,
  });

  final _logger = Logger();
  static const String defaultBip32Path = "m/44'/0'/0'";

  Future<bool> hasExistingWallet() async {
    return (await getMasterStarter()) != null;
  }

  Future<bool> hasLauncherModeDir() async {
    var walletDir = path.join(appDir.path, 'wallet_starters');
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
    final isInLauncherMode = await hasLauncherModeDir();
    if (!isInLauncherMode) {
      throw Exception(
        'Tried to move wallet dir WITHOUT being in launcher mode, this should never happen. Devs messed up',
      );
    }

    final newName = await _findAvailableName(appDir.path, 'wallet_starters');
    final newPath = path.join(appDir.path, newName);
    await getBitwindowWalletDir(appDir)!.rename(newPath);
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
    final walletData = await deleteAllWallets(() async {
      return _genWallet(customMnemonic: customMnemonic, passphrase: passphrase);
    });
    if (walletData == null) {
      throw Exception('No wallet data returned from deleteAllWallets');
    }

    return walletData;
  }

  Future<Map<String, dynamic>> _genWallet({String? customMnemonic, String? passphrase}) async {
    final Mnemonic mnemonicObj = customMnemonic != null
        ? Mnemonic.fromSentence(customMnemonic, Language.english, passphrase: passphrase ?? '')
        : Mnemonic.generate(Language.english, entropyLength: 128, passphrase: passphrase ?? '');

    final seedHex = hex.encode(mnemonicObj.seed);

    // Create chain from seed
    final chain = Chain.seed(seedHex);
    final masterKey = chain.forPath('m') as ExtendedPrivateKey;

    final walletData = {
      'mnemonic': mnemonicObj.sentence,
      'seed_hex': seedHex,
      'master_key': masterKey.privateKeyHex(),
      'chain_code': hex.encode(masterKey.chainCode!),
      'bip39_binary': _bytesToBinary(mnemonicObj.entropy),
      'bip39_checksum': _calculateChecksumBits(mnemonicObj.entropy),
      'bip39_checksum_hex': hex.encode([int.parse(_calculateChecksumBits(mnemonicObj.entropy), radix: 2)]),
    };

    await saveMasterWallet(walletData);
    await generateStartersForDownloadedChains();

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
    }

    return wallet;
  }

  String _bytesToBinary(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
  }

  String _calculateChecksumBits(List<int> entropy) {
    final entropyBits = entropy.length * 8;
    final checksumSize = entropyBits ~/ 32;

    final hash = sha256.convert(entropy);
    final hashBits = _bytesToBinary(hash.bytes);
    return hashBits.substring(0, checksumSize);
  }

  Future<void> saveMasterWallet(Map<String, dynamic> walletData) async {
    walletData['name'] = 'Master';

    final requiredFields = ['mnemonic', 'seed_hex', 'master_key'];
    for (final field in requiredFields) {
      if (!walletData.containsKey(field) || walletData[field] == null) {
        throw Exception('Missing required wallet field: $field');
      }
    }

    await _ensureWalletDir();
    final walletFile = await _getWalletFile('master_starter.json');
    if (walletFile == null) {
      throw Exception('Could not find wallet file, even after ensured');
    }
    await walletFile.writeAsString(jsonEncode(walletData));
    notifyListeners();
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

  /// Derive a starter from the master wallet using a specific derivation path
  Future<Map<String, dynamic>> _deriveStarter(String derivationPath, {String? name}) async {
    try {
      // Load and validate master wallet
      final masterWallet = await loadMasterStarter();
      if (masterWallet == null) {
        throw Exception('Master starter not found');
      }
      if (!masterWallet.containsKey('seed_hex')) {
        throw Exception('Master starter is missing required field: seed_hex');
      }

      // Create chain from seed hex and derive key
      final chain = Chain.seed(masterWallet['seed_hex']);
      final derivedKey = chain.forPath(derivationPath) as ExtendedPrivateKey;

      // Generate new entropy from derived key
      final privateKeyBytes = hex.decode(derivedKey.privateKeyHex());
      final hashedKey = sha256.convert(privateKeyBytes).bytes;
      final entropy = hashedKey.sublist(0, 16);

      // Create new mnemonic from entropy
      final mnemonic = Mnemonic(entropy, Language.english);
      final seedHex = hex.encode(mnemonic.seed);

      return {
        'mnemonic': mnemonic.sentence,
        'seed_hex': seedHex,
        'master_key': derivedKey.privateKeyHex(),
        'chain_code': hex.encode(derivedKey.chainCode!),
        'parent_master_key': masterWallet['master_key'],
        'derivation_path': derivationPath,
        if (name != null) 'name': name,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> deriveSidechainStarter(int sidechainSlot) async {
    try {
      final binary =
          binaryProvider.binaries.where((binary) => binary is Sidechain && binary.slot == sidechainSlot).firstOrNull;
      if (binary == null) {
        throw Exception('Could not find chain config for sidechain slot $sidechainSlot');
      }

      final starterData = await _deriveStarter(
        "m/44'/0'/$sidechainSlot'",
        name: binary.name,
      );

      // Save to sidechain-specific file
      await _saveMnemonicStarter('sidechain_${sidechainSlot}_starter.txt', starterData['mnemonic']);

      return starterData;
    } catch (e, stackTrace) {
      _logger.e('Error deriving sidechain starter: $e\n$stackTrace');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> deriveL1Starter() async {
    try {
      final starterData = await _deriveStarter(
        "m/44'/0'/256'",
        name: 'Bitcoin Core (Patched)',
      );
      starterData['chain_layer'] = 1;

      // Save to L1-specific file
      await _saveMnemonicStarter('l1_starter.txt', starterData['mnemonic']);

      return starterData;
    } catch (e, stackTrace) {
      _logger.e('Error deriving L1 starter: $e\n$stackTrace');
      rethrow;
    }
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
    try {
      await _ensureWalletDir();
      final file = await _getWalletFile(fileName);
      if (file == null) {
        throw Exception('Could not find wallet file, even after ensured');
      }
      await file.writeAsString(mnemonic);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error saving starter $fileName: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<File?> _getWalletFile(String fileName) async {
    final walletDir = getWalletDir(appDir);
    if (walletDir == null) {
      return null;
    }

    return File(path.join(walletDir.path, fileName));
  }

  Future<void> _ensureWalletDir() async {
    var walletDir = getBitwindowWalletDir(appDir);
    if (walletDir == null) {
      _logger.e('Could not find wallet dir, creating new one');
      walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    } else {
      _logger.i('Found wallet dir: ${walletDir.path}');
    }

    await walletDir.create(recursive: true);
  }

  Future<void> generateStartersForDownloadedChains() async {
    try {
      // first derive for L1
      await deriveL1Starter();

      // For each L2 chain in binaries
      final l2Chains = binaryProvider.binaries.where((b) => b.chainLayer == 2);

      // then derive for L2s in parallel
      final derivationFutures = l2Chains
          .whereType<Sidechain>()
          .map(
            (chain) => () async {
              try {
                await deriveSidechainStarter(chain.slot);
              } catch (e) {
                _logger.e('could not derive starter for ${chain.name}: $e');
              }
            }(),
          )
          .toList();

      await Future.wait(derivationFutures);

      // Notify listeners after all starters are generated
      notifyListeners();
    } catch (e, stack) {
      _logger.e('Error generating starters for downloaded chains: $e\n$stack');
    }
  }

  Future<Map<String, dynamic>?> deleteAllWallets(Future<Map<String, dynamic>?> Function()? beforeRebootAction) async {
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

    // then be extra sure and stop everything in the process manager
    await binaryProvider.stopAll();

    for (final binary in binaryProvider.binaries) {
      // stop absolutely all binaries, to avoid corruption/file overwriting
      await binaryProvider.stop(binary);
    }

    await Future.delayed(const Duration(seconds: 5));

    for (final binary in binaryProvider.binaries) {
      // wipe all wallets
      await binary.deleteWallet();
    }

    await moveMasterWalletDir();
    final walletData = await beforeRebootAction?.call();

    // reboot L1-binaries
    await binaryProvider.startWithEnforcer(binaryProvider.binaries.where((b) => b.name == BitWindow().name).first);

    // then restart all sidechains we stopped
    for (final binary in runningBinaries) {
      unawaited(binaryProvider.start(binary));
    }

    return walletData;
  }
}
