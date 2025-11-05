import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/models/wallet_gradient.dart';
import 'package:sail_ui/models/wallet_metadata.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:sail_ui/settings/last_used_wallet_setting.dart';
import 'package:sail_ui/wallet/encryption_service.dart';
import 'package:synchronized/synchronized.dart';

/// Single source of truth for wallet data
/// Handles loading, caching, encryption/decryption
class WalletReaderProvider extends ChangeNotifier {
  final Directory bitwindowAppDir;
  final _logger = GetIt.I.get<Logger>();
  final Lock _lock = Lock();

  Map<String, dynamic>? _cachedWalletJson;
  Uint8List? _encryptionKey;
  String? unlockedPassword;

  String? activeWalletId;
  List<WalletMetadata> availableWallets = [];

  StreamSubscription<FileSystemEvent>? _walletDirWatcher;

  ClientSettings get _clientSettings => GetIt.I.get<ClientSettings>();

  WalletReaderProvider(this.bitwindowAppDir) {
    _startWatchingWalletsDirectory();
  }

  @override
  void dispose() {
    _walletDirWatcher?.cancel();
    _cachedWalletJson = null;
    _encryptionKey = null;
    super.dispose();
  }

  void _startWatchingWalletsDirectory() {
    if (!walletsDirectory.existsSync()) {
      return;
    }

    _walletDirWatcher = walletsDirectory.watch(events: FileSystemEvent.all).listen((event) {
      if (event.path.endsWith('.json') && event.path.contains('wallet_')) {
        _logger.i('Wallet directory changed: ${event.type} ${event.path}');
        // File watcher should NEVER use locks - it's read-only and just triggers UI updates
        // This prevents deadlocks when other operations are holding the lock
        Future.microtask(() async {
          try {
            // For create/delete: always reload and notify
            if (event.type == FileSystemEvent.create || event.type == FileSystemEvent.delete) {
              await _loadWalletsList();
              notifyListeners();
              return;
            }

            // Extract wallet ID from filename: wallet_XXXXX.json
            final fileName = path.basename(event.path);
            final match = RegExp(r'wallet_(.+)\.json').firstMatch(fileName);
            if (match == null) return;

            final changedWalletId = match.group(1)!;

            // For modify: only notify if data actually changed
            final previousWallet = availableWallets.where((w) => w.id == changedWalletId).firstOrNull;
            await _loadWalletsList();
            final newWallet = availableWallets.where((w) => w.id == changedWalletId).firstOrNull;

            if (previousWallet?.toJsonString() != newWallet?.toJsonString()) {
              notifyListeners();
            }
          } catch (e) {
            _logger.w('File watcher failed to reload wallets: $e');
          }
        });
      }
    });
  }

  Directory get walletsDirectory {
    return Directory(path.join(bitwindowAppDir.path, 'wallets'));
  }

  File getWalletFile([String? walletId]) {
    walletId ??= activeWalletId;

    if (walletId != null) {
      return File(path.join(walletsDirectory.path, 'wallet_$walletId.json'));
    }

    return File(path.join(bitwindowAppDir.path, 'wallet.json'));
  }

  File _getMetadataFile() {
    return File(path.join(walletsDirectory.path, 'wallet_encryption.json'));
  }

  /// Initialize - load wallets list, load active wallet
  Future<void> init() async {
    _logger.i('[LOCK] init: Acquiring lock');
    await _lock.synchronized(() async {
      _logger.i('[LOCK] init: Lock acquired');
      await _loadWalletsList();
      await _loadActiveWalletId();
      _logger.i('[LOCK] init: Releasing lock');
    });
    await _loadWalletIntoCache();
  }

  /// Load wallet from disk into cache
  /// MUST be called within _lock.synchronized() OR from init() after lock is released
  Future<void> _loadWalletIntoCache() async {
    final walletFile = getWalletFile();
    if (!await walletFile.exists()) {
      _cachedWalletJson = null;
      return;
    }

    final isEncrypted = await _isWalletEncrypted();
    if (isEncrypted) {
      // If we have an unlocked password, try to decrypt
      if (unlockedPassword != null) {
        try {
          final metadata = await _loadMetadata();
          if (metadata != null && metadata.encrypted) {
            final encryptedData = await walletFile.readAsString();
            final salt = base64.decode(metadata.salt);
            final key = await EncryptionService.deriveKey(unlockedPassword!, salt, metadata.iterations);
            final decryptedJson = EncryptionService.decrypt(encryptedData, key);
            _cachedWalletJson = jsonDecode(decryptedJson) as Map<String, dynamic>;
            _encryptionKey = key;
          } else {
            _cachedWalletJson = null;
          }
        } catch (e, stack) {
          _logger.e('Failed to decrypt wallet with stored password: $e\n$stack');
          _cachedWalletJson = null;
        }
      } else {
        // Encrypted but not unlocked - leave cache empty
        _cachedWalletJson = null;
      }
    } else {
      // Not encrypted - load into cache
      try {
        final jsonString = await walletFile.readAsString();
        _cachedWalletJson = jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e, stack) {
        _logger.e('Failed to load unencrypted wallet: $e\n$stack');
        _cachedWalletJson = null;
      }
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
  bool get isWalletUnlocked => _cachedWalletJson != null;

  /// Check if wallet is locked
  bool get isWalletLocked {
    return !isWalletUnlocked;
  }

  /// Unlock wallet with password
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

        final encryptedData = await walletFile.readAsString();

        final salt = base64.decode(metadata.salt);
        final key = await EncryptionService.deriveKey(password, salt, metadata.iterations);

        try {
          final decryptedJson = EncryptionService.decrypt(encryptedData, key);
          _cachedWalletJson = jsonDecode(decryptedJson) as Map<String, dynamic>;
          _encryptionKey = key;
          unlockedPassword = password;
          notifyListeners();
          return true;
        } catch (e) {
          return false;
        }
      } catch (e, stack) {
        _logger.e('unlockWallet: Unexpected error: $e\n$stack');
        return false;
      }
    });
  }

  /// Lock wallet (clear cache)
  Future<void> lockWallet() async {
    await _lock.synchronized(() async {
      _cachedWalletJson = null;
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

  /// Encrypt wallet with password
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

        final walletJson = await walletFile.readAsString();

        final salt = EncryptionService.generateSalt();
        final key = await EncryptionService.deriveKey(password, salt, EncryptionService.defaultIterations);

        final encryptedData = EncryptionService.encrypt(walletJson, key);

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupFile = File(path.join(bitwindowAppDir.path, 'wallet.json.backup_before_encryption_$timestamp'));
        await walletFile.copy(backupFile.path);

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

        _cachedWalletJson = jsonDecode(walletJson) as Map<String, dynamic>;
        _encryptionKey = key;

        notifyListeners();
      } catch (e, stack) {
        _logger.e('encryptWallet: Failed to encrypt wallet: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _lock.synchronized(() async {
      try {
        final metadata = await _loadMetadata();
        if (metadata == null || !metadata.encrypted) {
          throw Exception('Wallet is not encrypted');
        }

        final unlocked = await unlockWallet(oldPassword);
        if (!unlocked || _cachedWalletJson == null) {
          throw Exception('Incorrect old password');
        }

        final newSalt = EncryptionService.generateSalt();
        final newKey = await EncryptionService.deriveKey(newPassword, newSalt, EncryptionService.defaultIterations);

        final walletJsonString = jsonEncode(_cachedWalletJson);
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

        notifyListeners();
      } catch (e, stack) {
        _logger.e('changePassword: Failed to change password: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Update wallet JSON and re-encrypt if needed
  Future<void> updateWalletJson(Map<String, dynamic> newWalletJson) async {
    await _lock.synchronized(() async {
      try {
        _cachedWalletJson = newWalletJson;

        final walletJsonString = jsonEncode(newWalletJson);
        final walletFile = getWalletFile();

        // Ensure parent directory exists
        final parentDir = walletFile.parent;
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }

        final isEncrypted = await _isWalletEncrypted();
        if (isEncrypted) {
          if (_encryptionKey == null) {
            throw Exception('Wallet is locked');
          }
          final encryptedData = EncryptionService.encrypt(walletJsonString, _encryptionKey!);
          final tempFile = File('${walletFile.path}.tmp');
          await tempFile.writeAsString(encryptedData);
          await tempFile.rename(walletFile.path);
        } else {
          final tempFile = File('${walletFile.path}.tmp');
          await tempFile.writeAsString(walletJsonString);
          await tempFile.rename(walletFile.path);
        }

        notifyListeners();
      } catch (e, stack) {
        _logger.e('updateWalletJson: Failed to update wallet: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Get L1 mnemonic
  String? getL1Mnemonic() {
    if (_cachedWalletJson == null) return null;
    final l1 = _cachedWalletJson!['l1'] as Map<String, dynamic>?;
    return l1?['mnemonic'] as String?;
  }

  /// Get sidechain mnemonic
  String? getSidechainMnemonic(int slot) {
    if (_cachedWalletJson == null) return null;
    final sidechains = _cachedWalletJson!['sidechains'] as List<dynamic>?;
    if (sidechains == null) return null;

    for (final sc in sidechains) {
      final scMap = sc as Map<String, dynamic>;
      if (scMap['slot'] == slot) {
        return scMap['mnemonic'] as String?;
      }
    }
    return null;
  }

  /// Write L1 starter file
  Future<File> writeL1Starter() async {
    final mnemonic = getL1Mnemonic();
    if (mnemonic == null || mnemonic.isEmpty) {
      throw Exception('L1 mnemonic not found');
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

  /// Get cached wallet JSON (read-only access)
  Map<String, dynamic>? get walletJson => _cachedWalletJson;

  /// Load wallets list by scanning wallets directory
  /// MUST be called within _lock.synchronized()
  Future<void> _loadWalletsList() async {
    try {
      if (!await walletsDirectory.exists()) {
        availableWallets = [];
        return;
      }

      final walletFiles = walletsDirectory
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json') && f.path.contains('wallet_'))
          .toList();

      final wallets = <WalletMetadata>[];
      for (final file in walletFiles) {
        try {
          final content = await file.readAsString();
          final walletJson = jsonDecode(content) as Map<String, dynamic>;

          final walletId = walletJson['id'] as String;

          // Migrate: ensure all wallets have gradient with SVG background
          WalletGradient gradient;
          bool needsSave = false;

          if (walletJson['gradient'] == null) {
            // No gradient at all - generate new one
            gradient = WalletGradient.fromWalletId(walletId);
            needsSave = true;
          } else {
            gradient = WalletGradient.fromJson(walletJson['gradient'] as Map<String, dynamic>);
            // Check if gradient exists but has no SVG background
            if (gradient.backgroundSvg == null) {
              gradient = WalletGradient.fromWalletId(walletId);
              needsSave = true;
            }
          }

          // Save updated gradient back to file if needed
          if (needsSave) {
            walletJson['gradient'] = gradient.toJson();
            await file.writeAsString(jsonEncode(walletJson));
            _logger.i('Migrated wallet $walletId to use SVG background: ${gradient.backgroundSvg}');
          }

          wallets.add(
            WalletMetadata(
              id: walletId,
              name: walletJson['name'] as String,
              gradient: gradient,
              createdAt: DateTime.parse(walletJson['created_at'] as String),
              lastUsed: walletJson['last_used'] != null
                  ? DateTime.parse(walletJson['last_used'] as String)
                  : DateTime.parse(walletJson['created_at'] as String),
            ),
          );
        } catch (e) {
          _logger.w('Failed to load wallet metadata from ${file.path}: $e');
        }
      }

      wallets.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      availableWallets = wallets;
    } catch (e, stack) {
      _logger.e('Failed to load wallets list: $e\n$stack');
      availableWallets = [];
    }
  }

  /// Load active wallet ID from settings (last used)
  /// MUST be called within _lock.synchronized()
  Future<void> _loadActiveWalletId() async {
    try {
      final lastUsedSetting = await _clientSettings.getValue(LastUsedWalletSetting());
      final lastUsedId = lastUsedSetting.value;

      if (lastUsedId.isNotEmpty && availableWallets.any((w) => w.id == lastUsedId)) {
        activeWalletId = lastUsedId;
      } else if (availableWallets.isNotEmpty) {
        activeWalletId = availableWallets.first.id;
      }
    } catch (e, stack) {
      _logger.e('Failed to load last used wallet ID: $e\n$stack');
      if (availableWallets.isNotEmpty) {
        activeWalletId = availableWallets.first.id;
      }
    }
  }

  /// Switch to a different wallet
  Future<void> switchWallet(String walletId) async {
    _logger.i('switchWallet: Acquiring lock for wallet $walletId');
    await _lock.synchronized(() async {
      _logger.i('switchWallet: Lock acquired');
      if (!availableWallets.any((w) => w.id == walletId)) {
        throw Exception('Wallet $walletId not found');
      }

      _logger.i('switchWallet: Setting activeWalletId');
      activeWalletId = walletId;

      // Update in-memory metadata without writing to file (avoids file watcher deadlock)
      _logger.i('switchWallet: Updating in-memory metadata');
      final index = availableWallets.indexWhere((w) => w.id == walletId);
      if (index != -1) {
        availableWallets[index] = availableWallets[index].copyWith(
          lastUsed: DateTime.now(),
        );
      }

      _logger.i('switchWallet: Saving to client settings');
      await _clientSettings.setValue(LastUsedWalletSetting(newValue: walletId));

      _logger.i('switchWallet: Clearing cache');
      _cachedWalletJson = null;
      _encryptionKey = null;

      _logger.i('switchWallet: Loading wallet into cache');
      await _loadWalletIntoCache();

      _logger.i('switchWallet: Notifying listeners');
      notifyListeners();
      _logger.i('switchWallet: Complete');
    });
  }

  /// Remove wallet from list
  Future<void> removeWalletFromList(String walletId) async {
    await _lock.synchronized(() async {
      // 1. Delete the file
      final walletFile = getWalletFile(walletId);
      if (await walletFile.exists()) {
        await walletFile.delete();
      }

      // 2. Switch wallet if needed
      if (activeWalletId == walletId && availableWallets.isNotEmpty) {
        await switchWallet(availableWallets.first.id);
      }

      // 3. File watcher will automatically reload availableWallets
    });
  }

  /// Update wallet metadata
  Future<void> updateWalletMetadata(String walletId, String name, WalletGradient gradient) async {
    _logger.i('updateWalletMetadata: walletId=$walletId, name=$name, background=${gradient.backgroundSvg}');
    _logger.i('updateWalletMetadata: Waiting for lock...');
    await _lock.synchronized(() async {
      _logger.i('updateWalletMetadata: Lock acquired!');
      final index = availableWallets.indexWhere((w) => w.id == walletId);
      if (index == -1) {
        throw Exception('Wallet $walletId not found');
      }

      availableWallets[index] = availableWallets[index].copyWith(
        name: name,
        gradient: gradient,
      );

      if (activeWalletId == walletId && _cachedWalletJson != null) {
        _logger.i('updateWalletMetadata: Updating active wallet via cached JSON');
        _cachedWalletJson!['name'] = name;
        _cachedWalletJson!['gradient'] = gradient.toJson();

        // Write to disk without nested lock
        try {
          final walletJsonString = jsonEncode(_cachedWalletJson!);
          final walletFile = getWalletFile();

          final isEncrypted = await _isWalletEncrypted();
          _logger.i('updateWalletMetadata: isEncrypted=$isEncrypted, hasKey=${_encryptionKey != null}');
          if (isEncrypted) {
            if (_encryptionKey == null) {
              throw Exception('Wallet is locked');
            }
            final encryptedData = EncryptionService.encrypt(walletJsonString, _encryptionKey!);
            final tempFile = File('${walletFile.path}.tmp');
            await tempFile.writeAsString(encryptedData);
            _logger.i('updateWalletMetadata: Wrote encrypted temp file');
            await tempFile.rename(walletFile.path);
            _logger.i('updateWalletMetadata: Renamed temp file to ${walletFile.path}');
          } else {
            final tempFile = File('${walletFile.path}.tmp');
            await tempFile.writeAsString(walletJsonString);
            _logger.i('updateWalletMetadata: Wrote unencrypted temp file');
            await tempFile.rename(walletFile.path);
            _logger.i('updateWalletMetadata: Renamed temp file to ${walletFile.path}');
          }

          _logger.i('updateWalletMetadata: Active wallet updated successfully');
        } catch (e, stack) {
          _logger.e('updateWalletMetadata: Failed to update active wallet: $e\n$stack');
          rethrow;
        }
      } else {
        _logger.i(
          'updateWalletMetadata: Updating via direct file access (activeId=$activeWalletId, cached=${_cachedWalletJson != null})',
        );

        final walletFile = getWalletFile(walletId);
        if (await walletFile.exists()) {
          try {
            final content = await walletFile.readAsString();
            Map<String, dynamic> walletJson;

            // Check if wallet is encrypted
            final isEncrypted = await _isWalletEncrypted();
            if (isEncrypted && _encryptionKey != null) {
              // Decrypt the wallet
              final decryptedJson = EncryptionService.decrypt(content, _encryptionKey!);
              walletJson = jsonDecode(decryptedJson) as Map<String, dynamic>;
            } else if (!isEncrypted) {
              // Not encrypted
              walletJson = jsonDecode(content) as Map<String, dynamic>;
            } else {
              _logger.w('Cannot update metadata for encrypted wallet $walletId without encryption key');
              return;
            }

            walletJson['name'] = name;
            walletJson['gradient'] = gradient.toJson();

            // Re-encrypt if needed
            if (isEncrypted && _encryptionKey != null) {
              final jsonString = jsonEncode(walletJson);
              final encrypted = EncryptionService.encrypt(jsonString, _encryptionKey!);
              await walletFile.writeAsString(encrypted);
            } else {
              await walletFile.writeAsString(jsonEncode(walletJson));
            }

            _logger.i('Updated metadata for wallet $walletId: background=${gradient.backgroundSvg}');
          } catch (e, stack) {
            _logger.e('Failed to update metadata for wallet $walletId: $e\n$stack');
          }
        }
      }

      notifyListeners();
    });
  }
}
