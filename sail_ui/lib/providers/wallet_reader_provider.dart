import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/settings/last_used_wallet_setting.dart';
import 'package:synchronized/synchronized.dart';

/// Single source of truth for wallet data
/// Handles loading, caching, encryption/decryption
class WalletReaderProvider extends ChangeNotifier {
  final Directory bitwindowAppDir;
  final _logger = GetIt.I.get<Logger>();
  final Lock _lock = Lock();

  List<WalletData> wallets = [];
  Uint8List? _encryptionKey;
  String? unlockedPassword;
  String? activeWalletId;
  Timer? _reloadDebounceTimer;

  WalletData? get activeWallet => wallets.firstWhereOrNull(
    (w) => w.id == activeWalletId,
  );

  WalletData? get enforcerWallet => wallets.firstWhereOrNull(
    (w) => w.walletType == BinaryType.enforcer,
  );

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

  StreamSubscription<FileSystemEvent>? _walletDirWatcher;

  ClientSettings get _clientSettings => GetIt.I.get<ClientSettings>();

  WalletReaderProvider(this.bitwindowAppDir) {
    _startWatchingWalletsDirectory();
  }

  @override
  void dispose() {
    _walletDirWatcher?.cancel();
    _reloadDebounceTimer?.cancel();
    wallets = [];
    _encryptionKey = null;
    super.dispose();
  }

  void _startWatchingWalletsDirectory() {
    final walletFile = getWalletFile();
    if (!walletFile.existsSync()) {
      return;
    }

    _walletDirWatcher = walletFile.watch(events: FileSystemEvent.modify).listen((event) {
      if (event.path.endsWith('wallet.json')) {
        _logger.i('Wallet file modified: ${event.path}');

        // Debounce: cancel previous timer and start new one
        _reloadDebounceTimer?.cancel();
        _reloadDebounceTimer = Timer(const Duration(milliseconds: 100), () {
          Future.microtask(() async {
            await _lock.synchronized(() async {
              try {
                final previousWallets = List<WalletData>.from(wallets);
                await _loadWalletIntoCache();

                // Only notify if data actually changed
                bool hasChanges = false;
                if (previousWallets.length != wallets.length) {
                  hasChanges = true;
                } else {
                  for (var i = 0; i < wallets.length; i++) {
                    if (previousWallets[i].toJsonString() != wallets[i].toJsonString()) {
                      hasChanges = true;
                      break;
                    }
                  }
                }

                if (hasChanges) {
                  notifyListeners();
                }
              } catch (e) {
                _logger.w('File watcher failed to reload wallet: $e');
              }
            });
          });
        });
      }
    });
  }

  File getWalletFile() {
    return File(path.join(bitwindowAppDir.path, 'wallet.json'));
  }

  File _getMetadataFile() {
    return File(path.join(bitwindowAppDir.path, 'wallet_encryption.json'));
  }

  /// Initialize - load wallet file
  Future<void> init() async {
    await _lock.synchronized(() async {
      await _loadWalletIntoCache();
    });
  }

  /// Load all wallets from single wallet.json file
  /// MUST be called within _lock.synchronized() OR from init() after lock is released
  Future<void> _loadWalletIntoCache() async {
    final walletFile = getWalletFile();
    if (!await walletFile.exists()) {
      wallets = [];
      activeWalletId = null;
      return;
    }

    final isEncrypted = await _isWalletEncrypted();

    try {
      Map<String, dynamic> fileJson;

      if (isEncrypted) {
        // If we have an unlocked password, try to decrypt
        if (unlockedPassword != null) {
          final metadata = await _loadMetadata();
          if (metadata != null && metadata.encrypted) {
            final encryptedData = await walletFile.readAsString();
            final salt = base64.decode(metadata.salt);
            final key = await EncryptionService.deriveKey(unlockedPassword!, salt, metadata.iterations);
            final decryptedJson = EncryptionService.decrypt(encryptedData, key);
            fileJson = jsonDecode(decryptedJson) as Map<String, dynamic>;
            _encryptionKey = key;
          } else {
            return; // Encrypted but no metadata - keep existing wallets
          }
        } else {
          return; // Encrypted but not unlocked - keep existing wallets
        }
      } else {
        // Not encrypted - load directly
        final jsonString = await walletFile.readAsString();
        fileJson = jsonDecode(jsonString) as Map<String, dynamic>;
      }

      // Parse the file structure: { version, activeWalletId, wallets: [...] }
      final newActiveWalletId = fileJson['activeWalletId'] as String?;
      final walletsJson = fileJson['wallets'] as List<dynamic>?;

      final newWallets = <WalletData>[];
      if (walletsJson != null) {
        for (final walletJson in walletsJson) {
          final wallet = WalletData.fromJson(walletJson as Map<String, dynamic>);
          newWallets.add(wallet);
          _logger.i('_loadWalletIntoCache: Loaded wallet ${wallet.id} named "${wallet.name}"');
        }
      }
      _logger.i('_loadWalletIntoCache: Total wallets loaded: ${newWallets.length}');

      // Only update state after successfully loading
      wallets = newWallets;
      activeWalletId = newActiveWalletId;
    } catch (e, stack) {
      _logger.e('Failed to load wallet file: $e\n$stack');
    }
  }

  /// Check if wallet is encrypted
  Future<bool> _isWalletEncrypted() async {
    final metadataFile = _getMetadataFile();
    if (!await metadataFile.exists()) {
      return false;
    }

    try {
      final metadataJson = await metadataFile.readAsString();
      final metadata = EncryptionMetadata.fromJsonString(metadataJson);
      return metadata.encrypted;
    } catch (e, stack) {
      _logger.e('Error reading metadata: $e\n$stack');
      return false;
    }
  }

  /// Check if wallet is encrypted (public)
  Future<bool> isWalletEncrypted() async {
    return await _lock.synchronized(() async {
      return await _isWalletEncrypted();
    });
  }

  /// Check if wallet is unlocked (cached in memory)
  bool get isWalletUnlocked => wallets.isNotEmpty;

  /// Check if wallet is locked
  bool get isWalletLocked {
    return !isWalletUnlocked;
  }

  /// Unlock wallet file with password
  Future<bool> unlockWallet(String password) async {
    if (password.isEmpty) {
      return false;
    }

    return await _lock.synchronized(() async {
      try {
        final metadata = await _loadMetadata();
        if (metadata == null || !metadata.encrypted) {
          return false;
        }

        final walletFile = getWalletFile();
        if (!await walletFile.exists()) {
          return false;
        }

        final salt = base64.decode(metadata.salt);
        final key = await EncryptionService.deriveKey(password, salt, metadata.iterations);

        // Test password
        try {
          final encryptedData = await walletFile.readAsString();
          EncryptionService.decrypt(encryptedData, key);
        } catch (e) {
          return false; // Wrong password
        }

        // Password is correct, store it and reload
        _encryptionKey = key;
        unlockedPassword = password;
        await _loadWalletIntoCache();
        notifyListeners();
        return true;
      } catch (e, stack) {
        _logger.e('unlockWallet: Unexpected error: $e\n$stack');
        return false;
      }
    });
  }

  /// Lock wallets (clear cache)
  Future<void> lockWallet() async {
    await _lock.synchronized(() async {
      wallets = [];
      _encryptionKey = null;
      unlockedPassword = null;

      try {
        final tmpDir = Directory(path.join(Directory.systemTemp.path, 'bitwindow_starters_$pid'));
        if (await tmpDir.exists()) {
          await tmpDir.delete(recursive: true);
        }
      } catch (e, stack) {
        _logger.w('lockWallet: Failed to cleanup starter files: $e\n$stack');
      }

      notifyListeners();
    });
  }

  /// Encrypt wallet file with password
  Future<void> encryptWallet(String password) async {
    await _lock.synchronized(() async {
      try {
        if (await _isWalletEncrypted()) {
          throw Exception('Wallet is already encrypted');
        }

        final walletFile = getWalletFile();
        if (!await walletFile.exists()) {
          throw Exception('No wallet file found to encrypt');
        }

        final salt = EncryptionService.generateSalt();
        final key = await EncryptionService.deriveKey(password, salt, EncryptionService.defaultIterations);

        // Backup
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupFile = File(path.join(bitwindowAppDir.path, 'wallet.json.backup_before_encryption_$timestamp'));
        await walletFile.copy(backupFile.path);

        // Encrypt
        final walletJson = await walletFile.readAsString();
        final encryptedData = EncryptionService.encrypt(walletJson, key);

        final tempFile = File('${walletFile.path}.tmp');
        await tempFile.writeAsString(encryptedData);
        await tempFile.rename(walletFile.path);

        final metadata = EncryptionMetadata(
          salt: base64.encode(salt),
          iterations: EncryptionService.defaultIterations,
          encrypted: true,
        );
        final metadataFile = _getMetadataFile();
        await metadataFile.writeAsString(metadata.toJsonString());

        _encryptionKey = key;
        unlockedPassword = password;

        // Reload
        await _loadWalletIntoCache();

        notifyListeners();
      } catch (e, stack) {
        _logger.e('encryptWallet: Failed to encrypt wallet: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Change password for wallet file
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _lock.synchronized(() async {
      try {
        final metadata = await _loadMetadata();
        if (metadata == null || !metadata.encrypted) {
          throw Exception('Wallet is not encrypted');
        }

        final unlocked = await unlockWallet(oldPassword);
        if (!unlocked || wallets.isEmpty) {
          throw Exception('Incorrect old password');
        }

        final newSalt = EncryptionService.generateSalt();
        final newKey = await EncryptionService.deriveKey(newPassword, newSalt, EncryptionService.defaultIterations);

        // Re-encrypt the wallet file
        final fileJson = {
          'version': 1,
          'activeWalletId': activeWalletId,
          'wallets': wallets.map((w) => w.toJson()).toList(),
        };
        final walletJsonString = jsonEncode(fileJson);
        final newEncryptedData = EncryptionService.encrypt(walletJsonString, newKey);

        final walletFile = getWalletFile();
        final tempFile = File('${walletFile.path}.tmp');
        await tempFile.writeAsString(newEncryptedData);
        await tempFile.rename(walletFile.path);

        final newMetadata = EncryptionMetadata(
          salt: base64.encode(newSalt),
          iterations: EncryptionService.defaultIterations,
          encrypted: true,
        );
        final metadataFile = _getMetadataFile();
        await metadataFile.writeAsString(newMetadata.toJsonString());

        _encryptionKey = newKey;
        unlockedPassword = newPassword;

        notifyListeners();
      } catch (e, stack) {
        _logger.e('changePassword: Failed to change password: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Save all wallets to file
  Future<void> _saveWalletsToFile() async {
    final fileJson = {
      'version': 1,
      'activeWalletId': activeWalletId,
      'wallets': wallets.map((w) => w.toJson()).toList(),
    };

    final jsonString = jsonEncode(fileJson);
    final walletFile = getWalletFile();

    // Ensure parent directory exists
    final parentDir = walletFile.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    final isEncrypted = await _isWalletEncrypted();
    if (isEncrypted) {
      if (_encryptionKey == null) {
        throw Exception('Wallets are locked');
      }
      final encryptedData = EncryptionService.encrypt(jsonString, _encryptionKey!);
      final tempFile = File('${walletFile.path}.tmp');
      await tempFile.writeAsString(encryptedData);
      await tempFile.rename(walletFile.path);
    } else {
      final tempFile = File('${walletFile.path}.tmp');
      await tempFile.writeAsString(jsonString);
      await tempFile.rename(walletFile.path);
    }
  }

  /// Update wallet and save to file
  Future<void> updateWallet(WalletData wallet) async {
    await _lock.synchronized(() async {
      try {
        // Update in list, or add if not found (used for both creating and updating)
        final index = wallets.indexWhere((w) => w.id == wallet.id);
        if (index != -1) {
          _logger.i('updateWallet: Updating existing wallet ${wallet.id} "${wallet.name}" at index $index');
          wallets[index] = wallet;
        } else {
          _logger.i('updateWallet: Adding NEW wallet ${wallet.id} "${wallet.name}" (current count: ${wallets.length})');
          wallets.add(wallet);
        }

        _logger.i('updateWallet: Total wallets after update: ${wallets.length}');
        await _saveWalletsToFile();
        notifyListeners();
      } catch (e, stack) {
        _logger.e('updateWallet: Failed to update wallet: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Get L1 mnemonic from active wallet
  String? getL1Mnemonic() {
    return activeWallet?.l1.mnemonic;
  }

  /// Get sidechain mnemonic from active wallet
  String? getSidechainMnemonic(int slot) {
    final wallet = activeWallet;
    if (wallet == null) return null;

    final sidechain = wallet.sidechains.firstWhereOrNull((sc) => sc.slot == slot);
    return sidechain?.mnemonic;
  }

  /// Write enforcer L1 starter file - ONLY loads from enforcer wallet
  Future<File> writeEnforcerL1Starter() async {
    final wallet = enforcerWallet;
    if (wallet == null) {
      throw Exception('Enforcer wallet not found');
    }

    final mnemonic = wallet.l1.mnemonic;
    if (mnemonic.isEmpty) {
      throw Exception('L1 mnemonic not found in enforcer wallet');
    }

    final tmpDir = Directory(path.join(Directory.systemTemp.path, 'bitwindow_starters_$pid'));
    if (!tmpDir.existsSync()) {
      tmpDir.createSync(recursive: true);
      if (!Platform.isWindows) {
        Process.runSync('chmod', ['700', tmpDir.path]);
      }
    }

    final l1File = File(path.join(tmpDir.path, 'l1_starter.txt'));
    l1File.writeAsStringSync(mnemonic);
    return l1File;
  }

  /// Write sidechain starter file
  Future<File> writeSidechainStarter(int slot) async {
    final mnemonic = getSidechainMnemonic(slot);
    if (mnemonic == null || mnemonic.isEmpty) {
      throw Exception('Sidechain slot $slot mnemonic not found');
    }

    final tmpDir = Directory(path.join(Directory.systemTemp.path, 'bitwindow_starters_$pid'));
    if (!tmpDir.existsSync()) {
      tmpDir.createSync(recursive: true);
      if (!Platform.isWindows) {
        Process.runSync('chmod', ['700', tmpDir.path]);
      }
    }

    final scFile = File(path.join(tmpDir.path, 'sidechain_${slot}_starter.txt'));
    scFile.writeAsStringSync(mnemonic);
    return scFile;
  }

  /// Cleanup starter files
  Future<void> cleanupStarterFiles() async {
    final tmpDir = Directory(path.join(Directory.systemTemp.path, 'bitwindow_starters_$pid'));
    if (await tmpDir.exists()) {
      await tmpDir.delete(recursive: true);
    }
  }

  /// Load metadata
  Future<EncryptionMetadata?> _loadMetadata() async {
    final metadataFile = _getMetadataFile();
    if (!await metadataFile.exists()) {
      return null;
    }

    try {
      final metadataJson = await metadataFile.readAsString();
      return EncryptionMetadata.fromJsonString(metadataJson);
    } catch (e, stack) {
      _logger.e('_loadMetadata: Error reading metadata: $e\n$stack');
      return null;
    }
  }

  /// Switch to a different wallet
  Future<void> switchWallet(String walletId) async {
    _logger.i('switchWallet: Acquiring lock for wallet $walletId');
    await _lock.synchronized(() async {
      _logger.i('switchWallet: Lock acquired');
      if (!wallets.any((w) => w.id == walletId)) {
        throw Exception('Wallet $walletId not found');
      }

      _logger.i('switchWallet: Setting activeWalletId');
      activeWalletId = walletId;

      _logger.i('switchWallet: Saving to file');
      await _saveWalletsToFile();

      _logger.i('switchWallet: Saving to client settings');
      await _clientSettings.setValue(LastUsedWalletSetting(newValue: walletId));

      _logger.i('switchWallet: Notifying listeners');
      notifyListeners();
      _logger.i('switchWallet: Complete');
    });
  }

  /// Remove wallet from list
  Future<void> removeWalletFromList(String walletId) async {
    await _lock.synchronized(() async {
      // Remove from in-memory list
      wallets.removeWhere((w) => w.id == walletId);

      // Switch wallet if we just deleted the active one
      if (activeWalletId == walletId) {
        if (wallets.isNotEmpty) {
          activeWalletId = wallets.first.id;
        } else {
          activeWalletId = null;
        }
      }

      // Save updated list to file
      await _saveWalletsToFile();
      notifyListeners();
    });
  }

  /// Update wallet metadata
  Future<void> updateWalletMetadata(String walletId, String name, WalletGradient gradient) async {
    _logger.i('updateWalletMetadata: walletId=$walletId, name=$name, background=${gradient.backgroundSvg}');
    _logger.i('updateWalletMetadata: Waiting for lock...');
    await _lock.synchronized(() async {
      _logger.i('updateWalletMetadata: Lock acquired!');

      final walletIndex = wallets.indexWhere((w) => w.id == walletId);
      if (walletIndex == -1) {
        throw Exception('Wallet $walletId not found');
      }

      _logger.i('updateWalletMetadata: Updating wallet in memory list');
      final wallet = wallets[walletIndex];
      final updatedWallet = WalletData(
        version: wallet.version,
        master: wallet.master,
        l1: wallet.l1,
        sidechains: wallet.sidechains,
        id: wallet.id,
        name: name,
        gradient: gradient,
        createdAt: wallet.createdAt,
        walletType: wallet.walletType,
      );

      // Update in place (already have lock, don't call updateWallet)
      wallets[walletIndex] = updatedWallet;
      await _saveWalletsToFile();
      _logger.i('updateWalletMetadata: Wallet updated successfully');

      notifyListeners();
    });
  }
}
