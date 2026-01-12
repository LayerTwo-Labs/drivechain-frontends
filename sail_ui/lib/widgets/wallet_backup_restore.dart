import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';

/// Get the application data directory
Future<Directory> _getAppDataDir() async {
  return await getApplicationSupportDirectory();
}

/// Create a wallet backup zip file
Future<String> createWalletBackup({
  required String destinationPath,
  required Logger log,
  required WalletWriterProvider walletProvider,
}) async {
  final archive = Archive();

  // Get app directory
  final appDir = await _getAppDataDir();
  final bitwindowAppDir = walletProvider.bitwindowAppDir;

  // 0. Add README
  final readme =
      '''BitWindow Wallet Backup
=======================

Created: ${DateTime.now().toIso8601String()}

CONTENTS
--------
This backup contains:

1. wallet.json - Your master wallet data including:
   - Master seed (BIP39 mnemonic)
   - All derived wallet keys
   - Sidechain wallet seeds (derived from master)

2. multisig/multisig.json - Multisig group configurations

3. transactions.json - Transaction history and notes

IMPORTANT: SIDECHAIN WALLETS
----------------------------
All sidechain wallets (Thunder, BitNames, BitAssets, ZSide, etc.) are
DERIVED from the master seed in wallet.json. This means:

- Restoring this backup restores ALL your sidechain wallets automatically
- You do NOT need separate backups for each sidechain
- Each sidechain uses a deterministic derivation path from the master seed

HOW TO RESTORE
--------------
1. Open BitWindow (or any sidechain app)
2. Go to Your Wallet menu > Restore Wallet
3. Select this backup file
4. Your master wallet and all sidechain wallets will be restored

SECURITY WARNING
----------------
- Keep this backup file secure and encrypted
- Anyone with access to this file can access ALL your funds
- Store in multiple secure locations
- Never share this file with anyone

If your wallet was encrypted with a password, the wallet.json in this
backup is also encrypted. You will need your password to restore.
''';
  final readmeBytes = utf8.encode(readme);
  archive.addFile(
    ArchiveFile(
      'README.txt',
      readmeBytes.length,
      readmeBytes,
    ),
  );
  log.i('Added to backup: README.txt');

  // 1. Backup wallet.json
  final walletJsonFile = File(path.join(bitwindowAppDir.path, 'wallet.json'));
  if (await walletJsonFile.exists()) {
    final bytes = await walletJsonFile.readAsBytes();
    archive.addFile(
      ArchiveFile(
        'wallet.json',
        bytes.length,
        bytes,
      ),
    );
    log.i('Added to backup: wallet.json');
  } else {
    log.w('wallet.json not found');
  }

  // 2. Backup multisig.json
  final multisigFile = File(path.join(appDir.path, 'bitdrive', 'multisig', 'multisig.json'));
  if (await multisigFile.exists()) {
    final bytes = await multisigFile.readAsBytes();
    archive.addFile(
      ArchiveFile(
        'multisig/multisig.json',
        bytes.length,
        bytes,
      ),
    );
    log.i('Added to backup: multisig/multisig.json');
  } else {
    log.w('multisig.json not found');
  }

  // 3. Backup transactions.json
  final transactionsFile = File(path.join(appDir.path, 'bitdrive', 'transactions.json'));
  if (await transactionsFile.exists()) {
    final bytes = await transactionsFile.readAsBytes();
    archive.addFile(
      ArchiveFile(
        'transactions.json',
        bytes.length,
        bytes,
      ),
    );
    log.i('Added to backup: transactions.json');
  } else {
    log.w('transactions.json not found');
  }

  // Encode the archive as a ZIP file
  final zipEncoder = ZipEncoder();
  final zipData = zipEncoder.encode(archive);

  // Write to destination
  final outputFile = File(destinationPath);
  await outputFile.writeAsBytes(zipData);

  log.i('Backup created successfully: $destinationPath');
  return destinationPath;
}

/// Restore wallet files from a validated backup
Future<void> restoreWalletFiles({
  required Directory tempDir,
  required Logger log,
  required WalletWriterProvider walletProvider,
}) async {
  final bitwindowAppDir = walletProvider.bitwindowAppDir;
  final appDir = await _getAppDataDir();

  // Copy wallet.json
  final tempWalletJson = File(path.join(tempDir.path, 'wallet.json'));
  if (await tempWalletJson.exists()) {
    final destWalletJson = File(path.join(bitwindowAppDir.path, 'wallet.json'));
    await tempWalletJson.copy(destWalletJson.path);
    log.i('Restored: wallet.json');
  }

  // Copy multisig.json if present
  final tempMultisig = File(path.join(tempDir.path, 'multisig', 'multisig.json'));
  if (await tempMultisig.exists()) {
    final destMultisigDir = Directory(path.join(appDir.path, 'bitdrive', 'multisig'));
    await destMultisigDir.create(recursive: true);
    await tempMultisig.copy(path.join(destMultisigDir.path, 'multisig.json'));
    log.i('Restored: multisig.json');
  }

  // Copy transactions.json if present
  final tempTransactions = File(path.join(tempDir.path, 'transactions.json'));
  if (await tempTransactions.exists()) {
    final destBitdriveDir = Directory(path.join(appDir.path, 'bitdrive'));
    await destBitdriveDir.create(recursive: true);
    await tempTransactions.copy(path.join(destBitdriveDir.path, 'transactions.json'));
    log.i('Restored: transactions.json');
  }

  log.i('Wallet files restored successfully');
}

/// Result of backup validation
class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Directory? tempDir;

  BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.tempDir,
  });
}

/// Validate backup file (ZIP or JSON)
Future<BackupValidationResult> validateBackup({
  required File backupFile,
  required Logger log,
}) async {
  final extension = path.extension(backupFile.path).toLowerCase();

  if (extension == '.json') {
    return validateBackupJson(jsonFile: backupFile, log: log);
  } else if (extension == '.zip') {
    return validateBackupZip(zipFile: backupFile, log: log);
  } else {
    return BackupValidationResult(
      isValid: false,
      errorMessage: 'Unsupported file type. Please select a .zip or .json file.',
    );
  }
}

/// Validate backup JSON file (wallet.json directly)
Future<BackupValidationResult> validateBackupJson({
  required File jsonFile,
  required Logger log,
}) async {
  Directory? tempDir;

  try {
    // Validate JSON structure
    final walletJSON = jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;

    // Support both old format (master/l1 at root) and new format (wallets array)
    final isOldFormat = walletJSON.containsKey('master') && walletJSON.containsKey('l1');
    final isNewFormat = walletJSON.containsKey('wallets') && walletJSON['wallets'] is List;

    if (!isOldFormat && !isNewFormat) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'wallet.json has invalid structure (missing master/l1 or wallets array)',
      );
    }

    // For new format, validate at least one wallet exists with master and l1
    if (isNewFormat) {
      final wallets = walletJSON['wallets'] as List;
      if (wallets.isEmpty) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'wallet.json contains no wallets',
        );
      }
      final firstWallet = wallets.first as Map<String, dynamic>;
      if (!firstWallet.containsKey('master') || !firstWallet.containsKey('l1')) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'wallet.json has invalid wallet structure (missing master or l1)',
        );
      }
    }

    // Create temp directory with the wallet.json
    tempDir = await Directory.systemTemp.createTemp('wallet_restore_');
    final tempWalletFile = File(path.join(tempDir.path, 'wallet.json'));
    await jsonFile.copy(tempWalletFile.path);

    log.i('JSON backup validation successful');
    return BackupValidationResult(
      isValid: true,
      tempDir: tempDir,
    );
  } catch (e) {
    // Clean up temp directory on error
    if (tempDir != null) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
    return BackupValidationResult(
      isValid: false,
      errorMessage: 'Failed to validate JSON backup: $e',
    );
  }
}

/// Validate backup ZIP file
Future<BackupValidationResult> validateBackupZip({
  required File zipFile,
  required Logger log,
}) async {
  Directory? tempDir;

  try {
    // Read and decode ZIP
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract to temp directory
    tempDir = await Directory.systemTemp.createTemp('wallet_restore_');

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final filePath = path.join(tempDir.path, filename);

        // Create parent directories if needed
        final fileDir = Directory(path.dirname(filePath));
        if (!await fileDir.exists()) {
          await fileDir.create(recursive: true);
        }

        final outFile = File(filePath);
        await outFile.writeAsBytes(data);
      }
    }

    // Validate wallet.json exists
    final walletFile = File(path.join(tempDir.path, 'wallet.json'));

    if (!await walletFile.exists()) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'Backup is missing wallet.json',
      );
    }

    // Validate wallet.json structure
    try {
      final walletJSON = jsonDecode(await walletFile.readAsString()) as Map<String, dynamic>;

      // Support both old format (master/l1 at root) and new format (wallets array)
      final isOldFormat = walletJSON.containsKey('master') && walletJSON.containsKey('l1');
      final isNewFormat = walletJSON.containsKey('wallets') && walletJSON['wallets'] is List;

      if (!isOldFormat && !isNewFormat) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'wallet.json has invalid structure (missing master/l1 or wallets array)',
        );
      }

      // For new format, validate at least one wallet exists with master and l1
      if (isNewFormat) {
        final wallets = walletJSON['wallets'] as List;
        if (wallets.isEmpty) {
          return BackupValidationResult(
            isValid: false,
            errorMessage: 'wallet.json contains no wallets',
          );
        }
        final firstWallet = wallets.first as Map<String, dynamic>;
        if (!firstWallet.containsKey('master') || !firstWallet.containsKey('l1')) {
          return BackupValidationResult(
            isValid: false,
            errorMessage: 'wallet.json has invalid wallet structure (missing master or l1)',
          );
        }
      }

      log.i('Backup validation successful');
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'wallet.json contains invalid JSON: $e',
      );
    }

    // Validate multisig.json if present
    final multisigFile = File(path.join(tempDir.path, 'multisig', 'multisig.json'));
    if (await multisigFile.exists()) {
      try {
        final multisigContent = await multisigFile.readAsString();
        jsonDecode(multisigContent);
      } catch (e) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'multisig.json contains invalid JSON: $e',
        );
      }
    }

    log.i('Backup validation successful');
    return BackupValidationResult(
      isValid: true,
      tempDir: tempDir,
    );
  } catch (e) {
    log.e('Backup validation failed: $e');
    // Clean up temp directory on error
    if (tempDir != null && await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    return BackupValidationResult(
      isValid: false,
      errorMessage: 'Failed to validate backup: $e',
    );
  }
}

/// Check if current wallet exists
Future<bool> hasCurrentWallet(WalletWriterProvider walletProvider) async {
  final walletJsonFile = File(path.join(walletProvider.bitwindowAppDir.path, 'wallet.json'));
  return await walletJsonFile.exists();
}

/// Title widget matching CreateWalletPage style
class _PageTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PageTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        SailText.primary40(
          title,
          bold: true,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SailText.primary15(
          subtitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

/// Page for backing up wallet - matches CreateWalletPage style
@RoutePage()
class BackupWalletPage extends StatefulWidget {
  final String appName;

  const BackupWalletPage({
    super.key,
    @PathParam('appName') this.appName = 'wallet',
  });

  @override
  State<BackupWalletPage> createState() => _BackupWalletPageState();
}

class _BackupWalletPageState extends State<BackupWalletPage> {
  Logger get log => GetIt.I.get<Logger>();
  WalletWriterProvider get walletProvider => GetIt.I.get<WalletWriterProvider>();

  String? _selectedPath;
  bool _isCreatingBackup = false;
  String? _error;
  bool _success = false;

  Future<void> _selectSaveLocation() async {
    try {
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final defaultFileName = '${widget.appName.toLowerCase()}-backup-$timestamp.zip';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Wallet Backup',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        setState(() {
          _selectedPath = result;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to open file picker: $e';
      });
    }
  }

  Future<void> _createBackup() async {
    if (_selectedPath == null) {
      setState(() {
        _error = 'Please select a save location first';
      });
      return;
    }

    setState(() {
      _isCreatingBackup = true;
      _error = null;
    });

    try {
      await createWalletBackup(
        destinationPath: _selectedPath!,
        log: log,
        walletProvider: walletProvider,
      );

      if (mounted) {
        setState(() {
          _success = true;
          _isCreatingBackup = false;
        });
      }
    } catch (e) {
      log.e('Backup failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Backup failed: $e';
          _isCreatingBackup = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (_success) {
      return _buildSuccessScreen(theme);
    }

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PageTitle(
                  title: 'Backup your wallet',
                  subtitle:
                      'Create a secure backup of your wallet. This includes your master seed, all sidechain wallets, multisig configurations, and transaction history.',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // What's included
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.primary13('What will be backed up:', bold: true),
                              const SizedBox(height: 12),
                              _buildBulletPoint('Master wallet and all derived keys'),
                              _buildBulletPoint('All sidechain wallet seeds'),
                              _buildBulletPoint('Multisig group configurations'),
                              _buildBulletPoint('Transaction history and notes'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // File selection
                        SailText.primary13('Save location:', bold: true),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _isCreatingBackup ? null : _selectSaveLocation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedPath != null ? theme.colors.primary : theme.colors.border,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SailText.secondary13(
                                    _selectedPath ?? 'Click to choose save location...',
                                  ),
                                ),
                                Icon(
                                  Icons.folder_open,
                                  color: theme.colors.textSecondary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SailText.primary13(_error!, color: theme.colors.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailButton(
                      label: '\u2190 Back',
                      variant: ButtonVariant.secondary,
                      onPressed: () async {
                        await context.router.maybePop();
                      },
                    ),
                    SailButton(
                      label: 'Create Backup',
                      variant: ButtonVariant.primary,
                      loading: _isCreatingBackup,
                      disabled: _selectedPath == null,
                      onPressed: _createBackup,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(SailThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: SailColorScheme.green,
                ),
                const SizedBox(height: 24),
                SailText.primary40(
                  'Backup complete!',
                  bold: true,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SailText.primary15(
                  'Your wallet has been backed up successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _selectedPath ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colors.textSecondary,
                    fontFamily: 'IBMPlexMono',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SailButton(
                  label: 'Done',
                  variant: ButtonVariant.primary,
                  onPressed: () async {
                    await context.router.maybePop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13('\u2022  '),
          Expanded(child: SailText.secondary13(text)),
        ],
      ),
    );
  }
}

/// Restore progress step
class RestoreProgressStep {
  String name;
  DateTime startTime;
  DateTime? endTime;

  RestoreProgressStep({
    required this.name,
    required this.startTime,
  });

  bool get isCompleted => endTime != null;
  Duration? get duration => endTime?.difference(startTime);
}

/// Page for restoring wallet from backup - matches CreateWalletPage style
@RoutePage()
class RestoreWalletPage extends StatefulWidget {
  final Future<void> Function(Logger log) bootBinaries;
  final List<Binary> binariesToStop;

  const RestoreWalletPage({
    super.key,
    required this.bootBinaries,
    required this.binariesToStop,
  });

  @override
  State<RestoreWalletPage> createState() => _RestoreWalletPageState();
}

class _RestoreWalletPageState extends State<RestoreWalletPage> {
  Logger get log => GetIt.I.get<Logger>();
  WalletWriterProvider get walletProvider => GetIt.I.get<WalletWriterProvider>();

  File? _selectedFile;
  String? _error;
  bool _isRestoring = false;
  final List<RestoreProgressStep> _steps = [];
  int _currentStepIndex = -1;
  bool _success = false;
  String? _autoBackupPath;

  Future<void> _selectBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Wallet Backup',
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to open file picker: $e';
      });
    }
  }

  void _initializeSteps(bool hasAutoBackup) {
    final stepNames = [
      if (hasAutoBackup) 'Backing up current wallet',
      'Validating backup file',
      'Stopping binaries',
      'Waiting for processes to stop',
      'Deleting old wallet files',
      'Restoring wallet files',
      'Recreating sidechain starter files',
      'Verifying restored wallet',
      'Restarting binaries',
      'Restore complete',
    ];

    setState(() {
      _steps.clear();
      _steps.addAll(
        stepNames.map((name) => RestoreProgressStep(name: name, startTime: DateTime.now())),
      );
    });
  }

  void _updateStatus(String status) {
    setState(() {
      if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
        _steps[_currentStepIndex].endTime = DateTime.now();
      }
      _currentStepIndex++;
      if (_currentStepIndex < _steps.length) {
        _steps[_currentStepIndex].startTime = DateTime.now();
      }
    });
  }

  Future<void> _startRestore() async {
    if (_selectedFile == null) {
      setState(() {
        _error = 'Please select a backup file first';
      });
      return;
    }

    // Check if current wallet exists
    final hasCurrent = await hasCurrentWallet(walletProvider);

    if (hasCurrent) {
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      _autoBackupPath = path.join(
        walletProvider.bitwindowAppDir.path,
        'wallet-backup-before-restore-$timestamp.zip',
      );
    }

    _initializeSteps(hasCurrent);

    setState(() {
      _isRestoring = true;
      _error = null;
    });

    try {
      // 1. Backup current wallet if exists
      if (_autoBackupPath != null) {
        _updateStatus('Backing up current wallet');
        await createWalletBackup(
          destinationPath: _autoBackupPath!,
          log: log,
          walletProvider: walletProvider,
        );
      }

      // 2. Validate backup
      _updateStatus('Validating backup file');
      final validation = await validateBackup(backupFile: _selectedFile!, log: log);
      if (!validation.isValid) {
        throw Exception(validation.errorMessage);
      }

      // 3. Stop binaries
      _updateStatus('Stopping binaries');
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      for (final binary in widget.binariesToStop) {
        await binaryProvider.stop(binary);
      }

      // 4. Wait for shutdown
      _updateStatus('Waiting for processes to stop');
      await Future.delayed(const Duration(seconds: 5));

      // 5. Delete old files
      _updateStatus('Deleting old wallet files');
      final appDir = await _getAppDataDir();
      final bitwindowAppDir = walletProvider.bitwindowAppDir;

      // Delete wallet.json
      final walletJsonFile = File(path.join(bitwindowAppDir.path, 'wallet.json'));
      if (await walletJsonFile.exists()) {
        await walletJsonFile.delete();
      }

      // Delete multisig.json
      final multisigFile = File(path.join(appDir.path, 'bitdrive', 'multisig', 'multisig.json'));
      if (await multisigFile.exists()) {
        await multisigFile.delete();
      }

      // Delete transactions.json
      final transactionsFile = File(path.join(appDir.path, 'bitdrive', 'transactions.json'));
      if (await transactionsFile.exists()) {
        await transactionsFile.delete();
      }

      // 6. Restore files
      _updateStatus('Restoring wallet files');
      final tempDir = validation.tempDir!;

      await restoreWalletFiles(
        tempDir: tempDir,
        log: log,
        walletProvider: walletProvider,
      );

      // Clean up temp
      await tempDir.delete(recursive: true);

      // 7. Recreate sidechain starter files
      _updateStatus('Recreating sidechain starter files');

      // 8. Verify restored wallet
      _updateStatus('Verifying restored wallet');
      final restoredWalletJson = File(path.join(bitwindowAppDir.path, 'wallet.json'));
      if (!await restoredWalletJson.exists()) {
        throw Exception('Restored wallet verification failed');
      }
      final walletContent = await restoredWalletJson.readAsString();
      jsonDecode(walletContent); // Verify it's valid JSON

      // 9. Restart binaries
      _updateStatus('Restarting binaries');
      await widget.bootBinaries(log);

      // 10. Complete
      _updateStatus('Restore complete');

      setState(() {
        if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
          _steps[_currentStepIndex].endTime = DateTime.now();
        }
        _success = true;
      });
    } catch (e) {
      log.e('Restore failed: $e');
      setState(() {
        _error = e.toString();
        _isRestoring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (_isRestoring || _success) {
      return _buildProgressScreen(theme);
    }

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PageTitle(
                  title: 'Restore from backup',
                  subtitle:
                      'Restore your wallet from a backup file. This will restore your master seed and all sidechain wallets. Your current wallet will be backed up automatically.',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Supported formats
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.primary13('Supported formats:', bold: true),
                              const SizedBox(height: 12),
                              _buildBulletPoint('.zip - Full backup (wallet, multisig, transactions)'),
                              _buildBulletPoint('.json - Just wallet.json (master seed only)'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // File selection
                        SailText.primary13('Select backup file:', bold: true),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectBackupFile,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedFile != null ? theme.colors.primary : theme.colors.border,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SailText.secondary13(
                                    _selectedFile?.path ?? 'Click to choose backup file...',
                                  ),
                                ),
                                Icon(
                                  Icons.file_open,
                                  color: theme.colors.textSecondary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SailText.primary13(_error!, color: theme.colors.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailButton(
                      label: '\u2190 Back',
                      variant: ButtonVariant.secondary,
                      onPressed: () async {
                        await context.router.maybePop();
                      },
                    ),
                    SailButton(
                      label: 'Restore Wallet',
                      variant: ButtonVariant.primary,
                      disabled: _selectedFile == null,
                      onPressed: _startRestore,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressScreen(SailThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PageTitle(
                  title: _success ? 'Restore complete!' : 'Restoring your wallet',
                  subtitle: _success
                      ? 'Your wallet has been restored successfully.'
                      : 'Please wait while your wallet is being restored...',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._steps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          final isActive = index == _currentStepIndex && !step.isCompleted;
                          return _buildStepRow(step, theme, isActive);
                        }),
                        if (_success && _autoBackupPath != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.primary13('Previous wallet backed up to:', bold: true),
                                const SizedBox(height: 8),
                                SelectableText(
                                  _autoBackupPath!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colors.textSecondary,
                                    fontFamily: 'IBMPlexMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SailText.primary13(_error!, color: theme.colors.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_success || _error != null)
                  SailButton(
                    label: 'Done',
                    variant: ButtonVariant.primary,
                    onPressed: () async {
                      await context.router.maybePop();
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(RestoreProgressStep step, SailThemeData theme, bool isActive) {
    Widget iconWidget;
    String timeText = '';

    if (step.isCompleted) {
      iconWidget = Icon(Icons.check_circle, color: SailColorScheme.green, size: 20);
      if (step.duration != null) {
        final duration = step.duration!;
        if (duration.inSeconds > 0) {
          timeText = '${duration.inSeconds}.${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}s';
        } else {
          timeText = '${duration.inMilliseconds}ms';
        }
      }
    } else if (isActive) {
      iconWidget = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
        ),
      );
    } else {
      iconWidget = Icon(Icons.circle_outlined, color: theme.colors.textSecondary, size: 20);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Expanded(
            child: SailText.primary13(
              step.name,
              color: isActive
                  ? theme.colors.primary
                  : step.isCompleted
                  ? SailColorScheme.green
                  : theme.colors.textSecondary,
            ),
          ),
          if (timeText.isNotEmpty)
            SailText.secondary12(
              timeText,
              color: SailColorScheme.green,
            ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13('\u2022  '),
          Expanded(child: SailText.secondary13(text)),
        ],
      ),
    );
  }
}
