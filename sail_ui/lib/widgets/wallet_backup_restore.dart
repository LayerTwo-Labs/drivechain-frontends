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
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

/// Create a wallet backup zip file via backend RPC.
/// The backend reads wallet.json from disk and exports multisig/transaction
/// data from the DB, then returns a ZIP archive.
Future<String> createWalletBackup({
  required String destinationPath,
  required Logger log,
  required WalletWriterProvider walletProvider,
}) async {
  final walletApi = GetIt.I.get<BitwindowRPC>().wallet;
  final response = await walletApi.createBackup();
  final outputFile = File(destinationPath);
  await outputFile.writeAsBytes(response.backupData);
  log.i('Backup created successfully via RPC: $destinationPath');
  return destinationPath;
}

/// Restore wallet files from a validated backup.
///
/// DEPRECATED: Use WalletAPI.restoreBackup() RPC instead, which handles
/// wallet.json restoration and imports multisig/transaction data into the DB.
@Deprecated('Use WalletAPI.restoreBackup() RPC instead')
Future<void> restoreWalletFiles({
  required Directory tempDir,
  required Logger log,
  required WalletWriterProvider walletProvider,
}) async {
  final bitwindowAppDir = walletProvider.bitwindowAppDir;

  // wallet.json is mandatory — fail hard if missing
  final tempWalletJson = File(path.join(tempDir.path, 'wallet.json'));
  if (!await tempWalletJson.exists()) {
    throw Exception('Restore failed: wallet.json is missing from backup');
  }
  final destWalletJson = File(path.join(bitwindowAppDir.path, 'wallet.json'));
  await tempWalletJson.copy(destWalletJson.path);
  log.i('Restored: wallet.json');

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
    return BackupValidationResult(isValid: true, tempDir: tempDir);
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
    final multisigFile = File(
      path.join(tempDir.path, 'multisig', 'multisig.json'),
    );
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
    return BackupValidationResult(isValid: true, tempDir: tempDir);
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
  final walletJsonFile = File(
    path.join(walletProvider.bitwindowAppDir.path, 'wallet.json'),
  );
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
        SailText.primary40(title, bold: true, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SailText.primary15(subtitle, textAlign: TextAlign.center),
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
      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final defaultFileName = '${widget.appName.toLowerCase()}-backup-$timestamp.zip';

      final result = await FilePicker.saveFile(
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
      return _BackupSuccessScreen(selectedPath: _selectedPath);
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
                              SailText.primary13(
                                'What will be backed up:',
                                bold: true,
                              ),
                              const SizedBox(height: 12),
                              const BulletPoint(
                                'Master wallet and all derived keys',
                              ),
                              const BulletPoint('All sidechain wallet seeds'),
                              const BulletPoint(
                                'Multisig group configurations',
                              ),
                              const BulletPoint(
                                'Transaction history and notes',
                              ),
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
                            child: SailText.primary13(
                              _error!,
                              color: theme.colors.error,
                            ),
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
}

class _BackupSuccessScreen extends StatelessWidget {
  final String? selectedPath;

  const _BackupSuccessScreen({required this.selectedPath});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

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
                  selectedPath ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colors.textSecondary,
                    fontFamily: 'IBMPlexMono',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SailButton(
                  label: 'Complete',
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
}

/// Restore progress step
class RestoreProgressStep {
  final String id;
  String name;
  DateTime startTime;
  DateTime? endTime;

  RestoreProgressStep({
    String? id,
    required this.name,
    required this.startTime,
  }) : id = id ?? name;

  bool get isCompleted => endTime != null;
  Duration? get duration => endTime?.difference(startTime);
}

/// Page for restoring wallet from backup - matches CreateWalletPage style
@RoutePage()
class RestoreWalletPage extends StatelessWidget {
  final Future<void> Function(Logger log) bootBinaries;
  final List<Binary> binariesToStop;

  const RestoreWalletPage({
    super.key,
    required this.bootBinaries,
    required this.binariesToStop,
  });

  @override
  Widget build(BuildContext context) {
    return WalletBackupRestoreOptions(
      bootBinaries: bootBinaries,
      binariesToStop: binariesToStop,
      showScaffold: true,
      showTitle: true,
      showBackButton: true,
    );
  }
}

class WalletBackupRestoreOptions extends StatefulWidget {
  final Future<void> Function(Logger log) bootBinaries;
  final List<Binary> binariesToStop;
  final bool showScaffold;
  final bool showTitle;
  final bool showBackButton;

  const WalletBackupRestoreOptions({
    super.key,
    required this.bootBinaries,
    required this.binariesToStop,
    this.showScaffold = false,
    this.showTitle = false,
    this.showBackButton = false,
  });

  @override
  State<WalletBackupRestoreOptions> createState() => _WalletBackupRestoreOptionsState();
}

class _WalletBackupRestoreOptionsState extends State<WalletBackupRestoreOptions> {
  Logger get log => GetIt.I.get<Logger>();
  WalletWriterProvider get walletProvider => GetIt.I.get<WalletWriterProvider>();

  File? _selectedFile;
  wmpb.WalletBackup? _selectedBackup;
  List<wmpb.WalletBackup> _localBackups = [];
  String? _error;
  String? _backupListError;
  bool _loadingBackups = true;
  bool _isRestoring = false;
  final List<RestoreProgressStep> _steps = [];
  int _currentStepIndex = -1;
  bool _success = false;
  String? _autoBackupPath;

  @override
  void initState() {
    super.initState();
    _loadLocalBackups();
  }

  Future<void> _loadLocalBackups() async {
    setState(() {
      _loadingBackups = true;
      _backupListError = null;
    });

    try {
      final response = await GetIt.I.get<OrchestratorRPC>().wallet.listWalletBackups();
      if (!mounted) return;
      setState(() {
        _localBackups = response.backups;
        _loadingBackups = false;
      });
    } catch (e) {
      log.e('Failed to load wallet backups: $e');
      if (!mounted) return;
      setState(() {
        _backupListError = 'Failed to load local wallet backups: $e';
        _loadingBackups = false;
      });
    }
  }

  Future<void> _selectBackupFile() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select Wallet Backup',
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedBackup = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to open file picker: $e';
      });
    }
  }

  void _selectLocalBackup(wmpb.WalletBackup backup) {
    if (!backup.valid) return;
    setState(() {
      _selectedBackup = backup;
      _selectedFile = null;
      _error = null;
    });
  }

  void _initializeSteps({
    required bool hasAutoBackup,
    required bool validateFile,
  }) {
    final stepNames = [
      if (hasAutoBackup) 'Backing up current wallet',
      if (validateFile) 'Validating backup file',
      'Restoring wallet files',
      'Stopping binaries',
      'Waiting for processes to stop',
      'Recreating sidechain starter files',
      'Verifying restored wallet',
      'Restarting binaries',
      'Restore complete',
    ];

    setState(() {
      _steps.clear();
      _steps.addAll(
        stepNames.map(
          (name) => RestoreProgressStep(name: name, startTime: DateTime.now()),
        ),
      );
      _currentStepIndex = -1;
      _success = false;
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
    if (_selectedBackup != null) {
      await _startLocalRestore(_selectedBackup!);
      return;
    }

    if (_selectedFile == null) {
      setState(() {
        _error = 'Please select a backup first';
      });
      return;
    }

    // Check if current wallet exists
    final hasCurrent = await hasCurrentWallet(walletProvider);

    _autoBackupPath = null;
    if (hasCurrent) {
      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      _autoBackupPath = path.join(
        walletProvider.bitwindowAppDir.path,
        'wallet-backup-before-restore-$timestamp.zip',
      );
    }

    _initializeSteps(hasAutoBackup: hasCurrent, validateFile: true);

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
      final backupBytes = await _selectedFile!.readAsBytes();
      final filename = path.basename(_selectedFile!.path);
      final walletApi = GetIt.I.get<BitwindowRPC>().wallet;
      final validateResponse = await walletApi.validateBackup(backupBytes, filename);
      if (!validateResponse.valid) {
        final msg = validateResponse.errorMessage.isNotEmpty ? validateResponse.errorMessage : 'Invalid backup file';
        throw Exception(msg);
      }

      // 3. Restore via backend RPC BEFORE stopping binaries.
      // The RPC server must be running for this call to succeed.
      _updateStatus('Restoring wallet files');
      await walletApi.restoreBackup(backupBytes, filename);
      log.i('Wallet restore completed via RPC');

      // 4. Stop binaries so they pick up the new wallet on restart
      _updateStatus('Stopping binaries');
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      for (final binary in widget.binariesToStop) {
        await binaryProvider.stop(binary);
      }

      // 5. Wait for shutdown
      _updateStatus('Waiting for processes to stop');
      await Future.delayed(const Duration(seconds: 5));

      // 6. Recreate sidechain starter files
      _updateStatus('Recreating sidechain starter files');

      // 7. Verify restored wallet
      _updateStatus('Verifying restored wallet');

      // 8. Restart binaries
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

  Future<void> _startLocalRestore(wmpb.WalletBackup backup) async {
    var password = '';
    if (backup.encrypted) {
      final entered = await _promptBackupPassword(backup);
      if (entered == null) return;
      password = entered;
    }

    _autoBackupPath = null;
    setState(() {
      _steps.clear();
      _currentStepIndex = -1;
      _isRestoring = true;
      _error = null;
      _success = false;
    });

    try {
      await for (final progress in GetIt.I.get<OrchestratorRPC>().wallet.restoreWalletBackupStream(
        backupId: backup.backupId,
        password: password,
      )) {
        if (!mounted) return;
        if (progress.steps.isNotEmpty) {
          _applyBackendRestorePlan(progress.steps);
        }
        if (progress.hasStatus()) {
          _applyBackendRestoreStatus(progress.status);
        }
      }
      log.i('Wallet restore completed via orchestrator backup RPC');
    } catch (e) {
      log.e('Restore failed: $e');
      setState(() {
        _error = e.toString();
        _isRestoring = true;
      });
    }
  }

  void _applyBackendRestorePlan(List<wmpb.RestoreWalletBackupStep> steps) {
    setState(() {
      _steps.clear();
      _steps.addAll(
        steps.map(
          (step) => RestoreProgressStep(
            id: step.stepId,
            name: step.name,
            startTime: DateTime.now(),
          ),
        ),
      );
      _currentStepIndex = -1;
    });
  }

  void _applyBackendRestoreStatus(wmpb.RestoreWalletBackupProgressStatus status) {
    setState(() {
      if (status.stepId.isNotEmpty) {
        final index = _steps.indexWhere((step) => step.id == status.stepId);
        if (index >= 0) {
          final step = _steps[index];
          switch (status.state) {
            case wmpb.RestoreWalletBackupStepState.RESTORE_WALLET_BACKUP_STEP_STATE_STARTED:
              step.startTime = DateTime.now();
              step.endTime = null;
              _currentStepIndex = index;
              break;
            case wmpb.RestoreWalletBackupStepState.RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED:
              step.endTime ??= DateTime.now();
              _currentStepIndex = index;
              break;
            case wmpb.RestoreWalletBackupStepState.RESTORE_WALLET_BACKUP_STEP_STATE_FAILED:
              step.endTime ??= DateTime.now();
              _currentStepIndex = index;
              _error = status.error.isNotEmpty ? status.error : 'Restore failed';
              break;
            default:
              break;
          }
        }
      }
      if (status.error.isNotEmpty) {
        _error = status.error;
      }
      if (status.complete) {
        if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
          _steps[_currentStepIndex].endTime ??= DateTime.now();
        }
        _success = true;
        _isRestoring = false;
      }
    });
  }

  Future<String?> _promptBackupPassword(wmpb.WalletBackup backup) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) {
          final theme = SailTheme.of(context);
          return Dialog(
            backgroundColor: theme.colors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary20('Encrypted wallet backup', bold: true),
                  const SizedBox(height: 16),
                  SailText.secondary13(_formatBackupDate(backup)),
                  const SizedBox(height: 20),
                  SailText.primary13('Password', bold: true),
                  const SizedBox(height: 8),
                  SailTextField(
                    controller: controller,
                    hintText: 'Enter wallet password',
                    obscureText: true,
                    autofocus: true,
                    onSubmitted: (value) => Navigator.of(context).pop(value),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: SailText.primary13('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      SailButton(
                        label: 'Restore',
                        variant: ButtonVariant.primary,
                        onPressed: () async {
                          Navigator.of(context).pop(controller.text);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  String _formatBackupDate(wmpb.WalletBackup backup) {
    if (backup.hasCreatedAt()) {
      return DateFormat('yyyy-MM-dd HH:mm').format(backup.createdAt.toDateTime().toLocal());
    }
    if (backup.sourceName.isNotEmpty) return backup.sourceName;
    return backup.backupId;
  }

  String _formatBackupBalance(wmpb.WalletBackup backup) {
    if (backup.latestKnownBalance.isEmpty) return 'Balance unavailable';

    final confirmedSats = backup.latestKnownBalance.fold<int>(
      0,
      (total, balance) => total + balance.confirmedSats.toInt(),
    );
    final pendingSats = backup.latestKnownBalance.fold<int>(
      0,
      (total, balance) => total + balance.pendingSats.toInt(),
    );
    final confirmed = formatBitcoin(satoshiToBTC(confirmedSats));
    if (pendingSats == 0) return confirmed;

    final pending = formatBitcoin(satoshiToBTC(pendingSats));
    return '$confirmed + $pending pending';
  }

  String _formatBalanceBreakdown(wmpb.WalletBackup backup) {
    if (backup.latestKnownBalance.isEmpty) return 'No latestKnownBalance metadata';
    return backup.latestKnownBalance
        .map((balance) {
          final name = balance.displayName.isNotEmpty ? balance.displayName : _binaryDisplayName(balance.binary);
          final confirmed = formatBitcoin(satoshiToBTC(balance.confirmedSats.toInt()));
          if (balance.pendingSats.toInt() == 0) return '$name: $confirmed';

          final pending = formatBitcoin(satoshiToBTC(balance.pendingSats.toInt()));
          return '$name: $confirmed + $pending pending';
        })
        .join('  ');
  }

  String _binaryDisplayName(BinaryType binary) {
    return switch (binary) {
      BinaryType.BINARY_TYPE_BITCOIND => 'Bitcoin Core',
      BinaryType.BINARY_TYPE_THUNDER => 'Thunder',
      BinaryType.BINARY_TYPE_ZSIDE => 'ZSide',
      BinaryType.BINARY_TYPE_BITNAMES => 'BitNames',
      BinaryType.BINARY_TYPE_BITASSETS => 'BitAssets',
      BinaryType.BINARY_TYPE_TRUTHCOIN => 'Truthcoin',
      BinaryType.BINARY_TYPE_PHOTON => 'Photon',
      BinaryType.BINARY_TYPE_COINSHIFT => 'CoinShift',
      _ => binary.name,
    };
  }

  Widget _buildLocalBackups(SailThemeData theme) {
    if (_loadingBackups) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
              ),
            ),
            const SizedBox(width: 12),
            SailText.secondary13('Loading local wallet backups...'),
          ],
        ),
      );
    }

    if (_backupListError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SailText.primary13(
          _backupListError!,
          color: theme.colors.error,
        ),
      );
    }

    if (_localBackups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SailText.secondary13('No local wallet backups found'),
      );
    }

    return Column(
      children: _localBackups.map((backup) {
        final selected = _selectedBackup?.backupId == backup.backupId;
        final selectable = backup.valid;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: selectable ? () => _selectLocalBackup(backup) : null,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? theme.colors.primary.withValues(alpha: 0.08) : theme.colors.background,
                border: Border.all(
                  color: selected ? theme.colors.primary : theme.colors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        backup.encrypted ? Icons.lock_outline : Icons.wallet_outlined,
                        color: selected ? theme.colors.primary : theme.colors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SailText.primary13(
                          _formatBackupDate(backup),
                          bold: true,
                          color: selectable ? null : theme.colors.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: SailText.primary13(
                          _formatBackupBalance(backup),
                          monospace: true,
                          color: selectable ? null : theme.colors.textSecondary,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SailText.secondary12(
                    backup.valid ? _formatBalanceBreakdown(backup) : backup.errorMessage,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (_isRestoring || _success) {
      final progress = _RestoreProgressCard(
        success: _success,
        steps: _steps,
        currentStepIndex: _currentStepIndex,
        autoBackupPath: _autoBackupPath,
        error: _error,
        onClose: () async {
          await context.router.maybePop();
        },
      );

      if (!widget.showScaffold) {
        return progress;
      }

      return Scaffold(
        backgroundColor: theme.colors.background,
        body: Center(child: progress),
      );
    }

    final options = _buildRestoreOptions(theme);
    if (!widget.showScaffold) {
      return options;
    }

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(width: 600, child: options),
        ),
      ),
    );
  }

  Widget _buildRestoreOptions(SailThemeData theme) {
    return Column(
      mainAxisAlignment: widget.showScaffold ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: widget.showScaffold ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.showTitle)
          _PageTitle(
            title: 'Restore from backup',
            subtitle:
                'Restore your wallet from a local backup or a backup file. This will restore your master seed and all sidechain wallets.',
          ),
        if (widget.showScaffold)
          Expanded(
            child: SingleChildScrollView(
              child: _buildRestoreOptionsBody(theme),
            ),
          )
        else
          _buildRestoreOptionsBody(theme),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: widget.showBackButton ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
          children: [
            if (widget.showBackButton)
              SailButton(
                label: '\u2190 Back',
                variant: ButtonVariant.secondary,
                onPressed: () async {
                  await context.router.maybePop();
                },
              ),
            SailButton(
              label: 'Restore selected backup',
              variant: ButtonVariant.primary,
              disabled: _selectedFile == null && _selectedBackup == null,
              onPressed: _startRestore,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRestoreOptionsBody(SailThemeData theme) {
    return Column(
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
              SailText.primary13(
                'Backup restore',
                bold: true,
              ),
              const SizedBox(height: 12),
              const BulletPoint(
                '.zip - Full backup (wallet, multisig, transactions)',
              ),
              const BulletPoint(
                '.json - Just wallet.json (master seed only)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SailText.primary13('Local wallet backups:', bold: true),
        const SizedBox(height: 8),
        _buildLocalBackups(theme),
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
            child: SailText.primary13(
              _error!,
              color: theme.colors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _RestoreProgressCard extends StatelessWidget {
  final bool success;
  final List<RestoreProgressStep> steps;
  final int currentStepIndex;
  final String? autoBackupPath;
  final String? error;
  final Future<void> Function() onClose;

  const _RestoreProgressCard({
    required this.success,
    required this.steps,
    required this.currentStepIndex,
    required this.onClose,
    this.autoBackupPath,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final isCompleted = success;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
      child: SailCard(
        title: 'Restoring Wallet',
        subtitle: isCompleted
            ? 'Wallet restored successfully!'
            : error != null
            ? 'Restore failed: $error'
            : 'Please wait while your wallet is restored...',
        withCloseButton: true,
        child: SingleChildScrollView(
          child: SailColumn(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isActive = index == currentStepIndex && !step.isCompleted;
                return ProgressStepTile(
                  name: step.name,
                  isCompleted: step.isCompleted,
                  duration: step.duration,
                  isActive: isActive,
                );
              }),
              if (isCompleted && autoBackupPath != null) ...[
                const SailSpacing(SailStyleValues.padding16),
                Container(
                  padding: const EdgeInsets.all(SailStyleValues.padding12),
                  decoration: BoxDecoration(
                    color: theme.colors.backgroundSecondary,
                    borderRadius: SailStyleValues.borderRadiusSmall,
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: SailColumn(
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13('Previous wallet backed up to:'),
                      SelectableText(
                        autoBackupPath!,
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
              if (isCompleted || error != null) const SailSpacing(SailStyleValues.padding08),
              if (isCompleted || error != null)
                SailButton(
                  label: 'Close',
                  variant: isCompleted ? ButtonVariant.primary : ButtonVariant.secondary,
                  onPressed: onClose,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
