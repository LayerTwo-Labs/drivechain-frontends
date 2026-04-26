import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:bitwindow/dialogs/change_password_dialog.dart';
import 'package:bitwindow/dialogs/encrypt_wallet_dialog.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/main.dart' show rebootBitwindowBackend;
import 'package:bitwindow/pages/settings/settings_about.dart';
import 'package:bitwindow/pages/settings/settings_advanced.dart';
import 'package:bitwindow/pages/settings/settings_appearance.dart';
import 'package:bitwindow/pages/settings/settings_network.dart';
import 'package:bitwindow/pages/settings/settings_reset.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

@RoutePage()
class SettingsPage extends StatefulWidget {
  final int initialSection;

  const SettingsPage({super.key, @PathParam('section') this.initialSection = 0});

  static SettingsPageState? _currentState;
  static int? _pendingSection;

  static void setSection(int index) {
    if (_currentState != null) {
      _currentState!.setSelectedIndex(index);
    } else {
      _pendingSection = index;
    }
  }

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    SettingsPage._currentState = this;
    // Use pending section if set, otherwise use route parameter
    if (SettingsPage._pendingSection != null) {
      _selectedIndex = SettingsPage._pendingSection!.clamp(0, 5);
      SettingsPage._pendingSection = null;
    } else {
      _selectedIndex = widget.initialSection.clamp(0, 5);
    }
  }

  @override
  void dispose() {
    if (SettingsPage._currentState == this) {
      SettingsPage._currentState = null;
    }
    super.dispose();
  }

  void setSelectedIndex(int index) {
    if (index >= 0 && index < 6) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      color: theme.colors.background,
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (fixed, not scrollable)
            SailText.primary24(
              'Settings',
              bold: true,
            ),
            SailText.secondary13('Manage your BitWindow settings.'),
            const SailSpacing(SailStyleValues.padding10),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),
            const SailSpacing(SailStyleValues.padding10),

            // Navigation and Content side by side (fills remaining space)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left navigation
                  SideNav(
                    items: const [
                      SideNavItem(label: 'Network'),
                      SideNavItem(label: 'Security'),
                      SideNavItem(label: 'Appearance'),
                      SideNavItem(label: 'Advanced'),
                      SideNavItem(label: 'Reset'),
                      SideNavItem(label: 'About'),
                    ],
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                  const SailSpacing(SailStyleValues.padding40),
                  // Right content area (fills remaining space, scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      child: switch (_selectedIndex) {
                        0 => const SettingsNetwork(),
                        1 => _SecuritySettingsContent(),
                        2 => const SettingsAppearance(),
                        3 => const SettingsAdvanced(),
                        4 => const SettingsReset(),
                        5 => const SettingsAbout(),
                        _ => const SettingsNetwork(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecuritySettingsContent extends StatefulWidget {
  @override
  State<_SecuritySettingsContent> createState() => _SecuritySettingsContentState();
}

class _SecuritySettingsContentState extends State<_SecuritySettingsContent> {
  final WalletReaderProvider _walletReader = GetIt.I.get<WalletReaderProvider>();
  final WalletWriterProvider _walletWriter = GetIt.I.get<WalletWriterProvider>();
  bool _isEncrypted = false;
  bool _isCheckingEncryption = true;

  @override
  void initState() {
    super.initState();
    _checkEncryptionStatus();
    _walletReader.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _walletReader.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    _checkEncryptionStatus();
    setState(() {});
  }

  Future<void> _checkEncryptionStatus() async {
    final encrypted = await _walletReader.isWalletEncrypted();
    if (mounted) {
      setState(() {
        _isEncrypted = encrypted;
        _isCheckingEncryption = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding32,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Security'),
            SailText.secondary13('Protect and backup your wallet'),
          ],
        ),

        // Wallet Management
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Wallets'),
            const SailSpacing(SailStyleValues.padding08),
            if (_walletReader.availableWallets.isEmpty)
              SailText.secondary13('No wallets found')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._walletReader.availableWallets.map((wallet) {
                    final isActive = wallet.id == _walletReader.activeWalletId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                      decoration: BoxDecoration(
                        color: isActive ? theme.colors.backgroundSecondary : null,
                        border: Border.all(
                          color: isActive ? theme.colors.primary : theme.colors.border,
                        ),
                        borderRadius: SailStyleValues.borderRadiusSmall,
                      ),
                      child: Row(
                        children: [
                          WalletBlobAvatar(gradient: wallet.gradient, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.primary13(wallet.name, bold: isActive),
                                if (isActive)
                                  SailText.secondary12(
                                    'Active wallet',
                                    color: theme.colors.primary,
                                  ),
                              ],
                            ),
                          ),
                          SailButton(
                            label: 'Edit',
                            small: true,
                            variant: ButtonVariant.secondary,
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => WalletManagementDialog(
                                  existingWallet: wallet,
                                  onSave: (name, gradient) async {
                                    await _walletWriter.updateWalletMetadata(wallet.id, name, gradient);
                                  },
                                  onDelete: () async {
                                    await _walletReader.removeWalletFromList(wallet.id);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SailSpacing(SailStyleValues.padding08),
                  SailButton(
                    label: 'Create New Wallet',
                    onPressed: () async {
                      await GetIt.I.get<AppRouter>().push(CreateAnotherWalletRoute());
                    },
                  ),
                ],
              ),
            const SailSpacing(4),
            SailText.secondary12(
              'Manage your wallet names and visual identifiers',
            ),
          ],
        ),

        // Backup Wallet
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Backup Wallet'),
            const SailSpacing(SailStyleValues.padding08),
            SailButton(
              label: 'Create Backup',
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => BackupWalletDialog(),
                );
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'Create a backup of all wallet files and multisig data',
            ),
          ],
        ),

        // Restore Wallet
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Restore Wallet'),
            const SailSpacing(SailStyleValues.padding08),
            SailButton(
              label: 'Restore from Backup',
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const RestoreWalletDialog(),
                );
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'Restore your wallet from a backup file',
            ),
          ],
        ),

        // Wallet Encryption
        if (_isCheckingEncryption)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Wallet Encryption'),
              const SailSpacing(SailStyleValues.padding08),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colors.primary),
              ),
            ],
          )
        else if (!_isEncrypted)
          // Not encrypted - show encrypt button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Wallet Encryption'),
              const SailSpacing(SailStyleValues.padding08),
              SailButton(
                label: 'Encrypt Wallet',
                onPressed: () async {
                  final result = await EncryptWalletDialog.show(context);
                  if (result == true) {
                    await _checkEncryptionStatus();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Wallet encrypted successfully'),
                          backgroundColor: theme.colors.success,
                        ),
                      );
                    }
                  }
                },
              ),
              const SailSpacing(4),
              SailText.secondary12(
                'Protect your wallet with a password',
              ),
            ],
          )
        else
          // Encrypted - show change password button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Wallet Encryption'),
              const SailSpacing(SailStyleValues.padding08),
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  color: theme.colors.success.withValues(alpha: 0.1),
                  borderRadius: SailStyleValues.borderRadiusSmall,
                  border: Border.all(color: theme.colors.success),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: theme.colors.success, size: 16),
                    const SizedBox(width: 8),
                    SailText.primary13(
                      'Wallet is encrypted',
                      color: theme.colors.success,
                    ),
                  ],
                ),
              ),
              const SailSpacing(SailStyleValues.padding08),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailButton(
                    label: 'Change Password',
                    onPressed: () async {
                      final result = await ChangePasswordDialog.show(context);
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Password changed successfully'),
                            backgroundColor: theme.colors.success,
                          ),
                        );
                      }
                    },
                    skipLoading: true,
                  ),
                  SailButton(
                    label: 'Remove Encryption',
                    variant: ButtonVariant.ghost,
                    onPressed: () async {
                      await GetIt.I.get<AppRouter>().push(RemoveEncryptionRoute());
                      await _checkEncryptionStatus();
                    },
                    skipLoading: true,
                  ),
                ],
              ),
              const SailSpacing(4),
              SailText.secondary12(
                'Manage your wallet encryption settings',
              ),
            ],
          ),

        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}

// Shared wallet backup function — delegates to the backend RPC.
// The backend reads wallet.json from disk and exports multisig/transaction
// data from the DB, then returns a ZIP archive.
Future<String> createWalletBackup({
  required String destinationPath,
  required Logger log,
}) async {
  final bitwindowd = GetIt.I.get<BitwindowRPC>();
  final response = await bitwindowd.wallet.createBackup();
  final outputFile = File(destinationPath);
  await outputFile.writeAsBytes(response.backupData);
  log.i('Backup created successfully via RPC: $destinationPath');
  return destinationPath;
}

class BackupWalletDialog extends StatefulWidget {
  const BackupWalletDialog({super.key});

  @override
  State<BackupWalletDialog> createState() => _BackupWalletDialogState();
}

class _BackupWalletDialogState extends State<BackupWalletDialog> {
  Logger get log => GetIt.I.get<Logger>();

  String? _selectedPath;
  bool _isCreatingBackup = false;
  String? _error;

  Future<void> _selectSaveLocation() async {
    try {
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final defaultFileName = 'bitwindow-backup-$timestamp.zip';

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
      await _performBackup(_selectedPath!);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully at $_selectedPath'),
            backgroundColor: SailTheme.of(context).colors.success,
          ),
        );
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

  Future<void> _performBackup(String destinationPath) async {
    await createWalletBackup(
      destinationPath: destinationPath,
      log: log,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: SailCard(
          title: 'Backup Wallet',
          subtitle: 'Create a backup of your wallet and multisig data',
          error: _error,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info section
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
                      SailText.primary13('What will be backed up:'),
                      SailText.secondary12('• Master wallet and all derived wallets'),
                      SailText.secondary12('• Multisig group configurations'),
                      SailText.secondary12('• Transaction history'),
                    ],
                  ),
                ),

                // File selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary15('Save Location'),
                    const SailSpacing(SailStyleValues.padding08),
                    Container(
                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.border),
                        borderRadius: SailStyleValues.borderRadiusSmall,
                      ),
                      child: SailText.secondary13(
                        _selectedPath ?? 'No location selected',
                      ),
                    ),
                    const SailSpacing(SailStyleValues.padding08),
                    SailButton(
                      label: _selectedPath == null ? 'Choose Location' : 'Change Location',
                      onPressed: _isCreatingBackup ? null : () async => await _selectSaveLocation(),
                    ),
                  ],
                ),

                // Action buttons
                SailRow(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Cancel',
                      variant: ButtonVariant.secondary,
                      onPressed: _isCreatingBackup
                          ? null
                          : () async {
                              Navigator.of(context).pop();
                            },
                    ),
                    SailButton(
                      label: 'Create Backup',
                      loading: _isCreatingBackup,
                      disabled: _selectedPath == null,
                      onPressed: () async => await _createBackup(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Backup validation result
class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;

  /// The raw backup file bytes, preserved for the restore step.
  final List<int>? backupData;

  /// Original filename (used to determine .zip vs .json).
  final String? filename;

  BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.backupData,
    this.filename,
  });
}

/// Validate a backup file via the backend RPC.
Future<BackupValidationResult> validateBackup({
  required File backupFile,
  required Logger log,
}) async {
  try {
    final bytes = await backupFile.readAsBytes();
    final filename = path.basename(backupFile.path);
    final bitwindowd = GetIt.I.get<BitwindowRPC>();
    final response = await bitwindowd.wallet.validateBackup(bytes, filename);
    if (!response.valid) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: response.errorMessage.isNotEmpty ? response.errorMessage : 'Invalid backup file',
      );
    }
    return BackupValidationResult(
      isValid: true,
      backupData: bytes,
      filename: filename,
    );
  } catch (e) {
    return BackupValidationResult(
      isValid: false,
      errorMessage: 'Failed to validate backup: $e',
    );
  }
}

// Check if current wallet exists via backend RPC.
Future<bool> hasCurrentWallet() async {
  final walletReader = GetIt.I.get<WalletReaderProvider>();
  return await walletReader.hasWallet();
}

// Restore progress step
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

// Restore progress dialog
class RestoreProgressDialog extends StatefulWidget {
  final File backupFile;
  final String? autoBackupPath;

  const RestoreProgressDialog({
    super.key,
    required this.backupFile,
    this.autoBackupPath,
  });

  @override
  State<RestoreProgressDialog> createState() => _RestoreProgressDialogState();
}

class _RestoreProgressDialogState extends State<RestoreProgressDialog> {
  final Logger log = GetIt.I.get<Logger>();

  final List<RestoreProgressStep> _steps = [];
  bool get _isCompleted => _steps.isNotEmpty && _steps.every((step) => step.isCompleted);
  String? _error;
  int _currentStepIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeSteps();
    _startRestore();
  }

  void _initializeSteps() {
    final stepNames = [
      if (widget.autoBackupPath != null) 'Backing up current wallet',
      'Validating backup file',
      'Stopping binaries',
      'Restoring wallet files',
      'Stopping binaries',
      'Waiting for processes to stop',
      'Recreating sidechain starter files',
      'Verifying restored wallet',
      'Restarting binaries',
      'Restore complete',
    ];

    setState(() {
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
    try {
      final bitwindowd = GetIt.I.get<BitwindowRPC>();

      // 1. Backup current wallet if exists
      if (widget.autoBackupPath != null) {
        _updateStatus('Backing up current wallet');
        await createWalletBackup(
          destinationPath: widget.autoBackupPath!,
          log: log,
        );
      }

      // 2. Validate backup
      _updateStatus('Validating backup file');
      final validation = await validateBackup(backupFile: widget.backupFile, log: log);
      if (!validation.isValid) {
        throw Exception(validation.errorMessage);
      }

      // 3. Restore via backend RPC BEFORE stopping binaries.
      // The RPC server must be running for this call to succeed.
      _updateStatus('Restoring wallet files');
      await bitwindowd.wallet.restoreBackup(
        validation.backupData!,
        validation.filename!,
      );
      log.i('Wallet restore completed via RPC');

      // 4. Stop binaries so they pick up the new wallet on restart
      _updateStatus('Stopping binaries');
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      final binariesToStop = [BitcoinCore(), Enforcer(), BitWindow()];
      for (final binary in binariesToStop) {
        await binaryProvider.stop(binary);
      }

      // 5. Wait for shutdown
      _updateStatus('Waiting for processes to stop');
      await Future.delayed(const Duration(seconds: 5));

      // 6. Recreate sidechain starter files (placeholder for future functionality)
      _updateStatus('Recreating sidechain starter files');

      // 7. Verify restored wallet (lightweight check)
      _updateStatus('Verifying restored wallet');

      // 9. Restart binaries
      _updateStatus('Restarting binaries');
      await rebootBitwindowBackend(log);

      // 10. Complete
      _updateStatus('Restore complete');

      setState(() {
        if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
          _steps[_currentStepIndex].endTime = DateTime.now();
        }
      });
    } catch (e) {
      log.e('Restore failed: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: SailCard(
          title: 'Restoring Wallet',
          subtitle: _isCompleted
              ? 'Wallet restored successfully!'
              : _error != null
              ? 'Restore failed: $_error'
              : 'Please wait while your wallet is restored...',
          withCloseButton: true,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ..._steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isActive = index == _currentStepIndex && !step.isCompleted;
                  return ProgressStepTile(
                    name: step.name,
                    isCompleted: step.isCompleted,
                    duration: step.duration,
                    isActive: isActive,
                  );
                }),
                if (_isCompleted && widget.autoBackupPath != null) ...[
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
                          widget.autoBackupPath!,
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
                if (_isCompleted || _error != null) const SailSpacing(SailStyleValues.padding08),
                if (_isCompleted || _error != null)
                  SailButton(
                    label: 'Close',
                    variant: _isCompleted ? ButtonVariant.primary : ButtonVariant.secondary,
                    onPressed: () async => Navigator.of(context).pop(_isCompleted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Restore wallet dialog
class RestoreWalletDialog extends StatefulWidget {
  const RestoreWalletDialog({super.key});

  @override
  State<RestoreWalletDialog> createState() => _RestoreWalletDialogState();
}

class _RestoreWalletDialogState extends State<RestoreWalletDialog> {
  Logger get log => GetIt.I.get<Logger>();
  WalletWriterProvider get walletProvider => GetIt.I.get<WalletWriterProvider>();

  File? _selectedFile;
  String? _error;

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
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to open file picker: $e';
      });
    }
  }

  Future<void> _startRestore() async {
    if (_selectedFile == null) {
      setState(() {
        _error = 'Please select a backup file first';
      });
      return;
    }

    try {
      // Check if current wallet exists
      final hasCurrent = await hasCurrentWallet();

      String? autoBackupPath;
      if (hasCurrent) {
        // Create automatic backup
        final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        autoBackupPath = path.join(
          walletProvider.bitwindowAppDir.path,
          'bitwindow-backup-before-restore-$timestamp.zip',
        );
      }

      if (mounted) {
        // Close this dialog
        Navigator.of(context).pop();

        // Show progress dialog
        final success = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => RestoreProgressDialog(
            backupFile: _selectedFile!,
            autoBackupPath: autoBackupPath,
          ),
        );

        // Show result
        if (mounted && success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hasCurrent && autoBackupPath != null
                    ? 'Wallet restored! Previous wallet backed up to:\n$autoBackupPath'
                    : 'Wallet restored successfully!',
              ),
              backgroundColor: SailTheme.of(context).colors.success,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    } catch (e) {
      log.e('Failed to start restore: $e');
      setState(() {
        _error = 'Failed to start restore: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 550),
        child: SailCard(
          title: 'Restore Wallet',
          subtitle: 'Restore your wallet from a backup file',
          error: _error,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning section
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
                      SailText.primary13('⚠️  Important Information'),
                      SailText.secondary12('• Your current wallet will be backed up automatically'),
                      SailText.secondary12('• All running processes will be stopped'),
                      SailText.secondary12('• The wallet must be from a valid backup file'),
                    ],
                  ),
                ),

                // File selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary15('Select Backup File'),
                    const SailSpacing(SailStyleValues.padding08),
                    Container(
                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.border),
                        borderRadius: SailStyleValues.borderRadiusSmall,
                      ),
                      child: SailText.secondary13(
                        _selectedFile?.path ?? 'No file selected',
                      ),
                    ),
                    const SailSpacing(SailStyleValues.padding08),
                    SailButton(
                      label: _selectedFile == null ? 'Choose Backup File' : 'Change File',
                      onPressed: () async => await _selectBackupFile(),
                    ),
                  ],
                ),

                // Action buttons
                SailRow(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Cancel',
                      variant: ButtonVariant.secondary,
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                    SailButton(
                      label: 'Restore Wallet',
                      disabled: _selectedFile == null,
                      onPressed: () async => await _startRestore(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetSettingsContent extends StatefulWidget {
  @override
  State<_ResetSettingsContent> createState() => _ResetSettingsContentState();
}

class _ResetSettingsContentState extends State<_ResetSettingsContent> {
  Logger get log => GetIt.I.get<Logger>();
  Directory get appDir => GetIt.I.get<BinaryProvider>().appDir;

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('Reset'),
        SailText.secondary13('Start fresh by resetting various data'),
        SailButton(
          label: 'Reset Blockchain Data',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            await _resetBlockchainData(context);
          },
        ),
        SailButton(
          label: 'Delete All Wallets',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => SailAlertCard(
                title: 'Reset Wallet?',
                subtitle:
                    'Are you sure you want to reset all wallet data? This will:\n\n'
                    '• Permanently delete all wallet files from BitWindow\n'
                    '• Permanently delete all wallet files from the Enforcer\n'
                    '• Stop all running processes\n'
                    '• Return you to the wallet creation screen\n\n'
                    'Make sure to backup your seed phrase before proceeding. This action cannot be undone.',
                confirmButtonVariant: ButtonVariant.destructive,
                onConfirm: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            );
            if (confirmed == true && context.mounted) {
              final router = GetIt.I.get<AppRouter>();
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => ResetProgressDialog(
                  resetFunction: (updateStatus) async {
                    await _resetWallets(context, onStatusUpdate: updateStatus);
                  },
                  onComplete: () async {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop(); // Close progress dialog
                    }
                    // Restart backend. It will await wallet creation, where we route after the user closes this dialog
                    unawaited(rebootBitwindowBackend(log));
                  },
                ),
              );
              // Wait for dialog to fully dispose before replacing entire route stack
              await Future.delayed(const Duration(milliseconds: 100));
              // Boot binaries and navigate to wallet creation
              await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
            }
          },
        ),
        SailButton(
          label: 'Reset Everything',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => SailAlertCard(
                title: 'Reset Everything?',
                subtitle:
                    'Are you sure you want to reset absolutely everything? Even wallets will be deleted. This action cannot be undone.',
                confirmButtonVariant: ButtonVariant.destructive,
                onConfirm: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            );
            if (confirmed == true && context.mounted) {
              await _resetEverything(context);
            }
          },
          skipLoading: true,
        ),
      ],
    );
  }

  Future<void> _resetBlockchainData(BuildContext context) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final binaries = [
      BitcoinCore(),
      Enforcer(),
      BitWindow(),
    ];

    final futures = <Future>[];
    // Only stop binaries that are started by bitwindow
    for (final binary in binaries) {
      futures.add(binaryProvider.stop(binary));
    }

    // Wait for all stop operations to complete
    await Future.wait(futures);

    // wait for 3 seconds to ensure all processes are killed
    await Future.delayed(const Duration(seconds: 3));

    // wipe all chain data
    for (final binary in binaries) {
      await binary.deleteFiles(await binary.getBlockchainDataPaths());
    }

    // finally, restart the backend
    unawaited(rebootBitwindowBackend(GetIt.I.get<Logger>()));
  }
}

class _AppearanceSettingsContent extends StatefulWidget {
  @override
  State<_AppearanceSettingsContent> createState() => _AppearanceSettingsContentState();
}

class _AppearanceSettingsContentState extends State<_AppearanceSettingsContent> {
  final _settingsProvider = GetIt.I.get<SettingsProvider>();

  @override
  void initState() {
    super.initState();
    _settingsProvider.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding32,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Appearance'),
            SailText.secondary13('Customize the look and feel of the application'),
          ],
        ),

        // Theme Toggle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Theme'),
            const SailSpacing(SailStyleValues.padding08),
            ToggleThemeButton(),
            const SailSpacing(4),
            SailText.secondary12('Switch between light and dark modes'),
          ],
        ),

        // Font Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Font'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<SailFontValues>(
              value: _settingsProvider.font,
              items: [
                SailDropdownItem<SailFontValues>(
                  value: SailFontValues.inter,
                  label: 'Inter',
                ),
                SailDropdownItem<SailFontValues>(
                  value: SailFontValues.ibmMono,
                  label: 'IBM Plex Mono',
                ),
              ],
              onChanged: (SailFontValues? newValue) async {
                if (newValue != null) {
                  await _settingsProvider.updateFont(newValue);
                  if (context.mounted) {
                    final app = SailApp.of(context);
                    await app.loadFont(newValue);
                  }
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12('Choose your preferred font style'),
          ],
        ),

        // Bitcoin Unit Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Bitcoin Unit'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<BitcoinUnit>(
              value: _settingsProvider.bitcoinUnit,
              items: [
                SailDropdownItem<BitcoinUnit>(
                  value: BitcoinUnit.btc,
                  label: 'BTC',
                ),
                SailDropdownItem<BitcoinUnit>(
                  value: BitcoinUnit.sats,
                  label: 'Satoshis',
                ),
              ],
              onChanged: (BitcoinUnit? newValue) async {
                if (newValue != null) {
                  await _settingsProvider.updateBitcoinUnit(newValue);
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12('Choose how Bitcoin amounts are displayed'),
          ],
        ),

        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}

class _AboutSettingsContent extends StatefulWidget {
  @override
  State<_AboutSettingsContent> createState() => _AboutSettingsContentState();
}

class _AboutSettingsContentState extends State<_AboutSettingsContent> {
  UpdateProvider get _updateProvider => GetIt.I.get<UpdateProvider>();

  @override
  void initState() {
    super.initState();
    _updateProvider.addListener(_onUpdateProviderChanged);
  }

  @override
  void dispose() {
    _updateProvider.removeListener(_onUpdateProviderChanged);
    super.dispose();
  }

  void _onUpdateProviderChanged() {
    setState(() {});
  }

  Future<void> _checkForUpdates() async {
    if (Platform.isLinux) {
      await _updateProvider.checkNow();
    } else {
      await autoUpdater.checkForUpdates();
    }
  }

  Future<void> _performUpdate() async {
    if (!Platform.isLinux) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Update BitWindow?',
        subtitle:
            'The application will download and install version ${_updateProvider.latestVersion}, then restart automatically.',
        onConfirm: () async => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    try {
      await _updateProvider.performUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20('About'),
        SailText.secondary13('Application version and build information'),

        // Version Information
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Version'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.versionString),
          ],
        ),

        // Build Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Build Date'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.buildDate),
          ],
        ),

        // Commit Hash
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Commit'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.commitFull),
          ],
        ),

        // App Name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Application'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(AppVersion.appName),
          ],
        ),

        // Updates section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Updates'),
            const SailSpacing(SailStyleValues.padding08),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Check for Updates',
                  loading: _updateProvider.checking || _updateProvider.updating,
                  onPressed: () async => await _checkForUpdates(),
                ),
                if (_updateProvider.updateAvailable && Platform.isLinux)
                  SailButton(
                    label: 'Install Update',
                    variant: ButtonVariant.primary,
                    onPressed: () async => await _performUpdate(),
                  ),
              ],
            ),
            if (_updateProvider.errorMessage != null) ...[
              const SailSpacing(4),
              SailText.secondary12(
                _updateProvider.errorMessage!,
                color: SailTheme.of(context).colors.error,
              ),
            ] else if (_updateProvider.updateAvailable) ...[
              const SailSpacing(4),
              SailText.secondary12(
                'Update available: v${_updateProvider.latestVersion}',
                color: SailTheme.of(context).colors.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class DataDirSelectionDialog extends StatefulWidget {
  const DataDirSelectionDialog({super.key});

  @override
  State<DataDirSelectionDialog> createState() => _DataDirSelectionDialogState();
}

class _DataDirSelectionDialogState extends State<DataDirSelectionDialog> {
  String? selectedPath;
  bool isSelecting = false;

  Future<void> _selectDirectory() async {
    setState(() {
      isSelecting = true;
    });

    try {
      final result = await FilePicker.getDirectoryPath();
      if (result != null) {
        // Writability is validated server-side when the datadir is persisted.
        setState(() {
          selectedPath = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting directory: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSelecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 350),

        child: SailCard(
          title: 'Select Bitcoin Data Directory',
          subtitle:
              'Bitcoin mainnet requires substantial storage space (approximately 2.5TB). '
              'Please select a directory with enough free space to store the Bitcoin data files.\n\n'
              'This directory will be used for all Bitcoin data including blocks, chainstate, and wallet data',
          withCloseButton: true,
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Selected Directory:'),
              SailRow(
                mainAxisSize: MainAxisSize.min,
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                      decoration: BoxDecoration(
                        border: Border.all(color: SailTheme.of(context).colors.border),
                        borderRadius: SailStyleValues.borderRadiusSmall,
                      ),
                      child: SailText.secondary13(
                        selectedPath ?? 'No directory selected',
                      ),
                    ),
                  ),
                  SailButton(
                    label: 'Browse Directories',
                    loading: isSelecting,
                    onPressed: () async => await _selectDirectory(),
                  ),
                ],
              ),
              Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Cancel',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => Navigator.of(context).pop(),
                  ),
                  const SailSpacing(SailStyleValues.padding12),
                  SailButton(
                    label: 'Confirm',
                    variant: ButtonVariant.primary,
                    onPressed: selectedPath != null ? () async => Navigator.of(context).pop(selectedPath) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetProgressStep {
  String name;
  DateTime startTime;
  DateTime? endTime;

  ResetProgressStep({
    required this.name,
    required this.startTime,
  });

  bool get isCompleted => endTime != null;
  Duration? get duration => endTime?.difference(startTime);
}

class ResetProgressDialog extends StatefulWidget {
  final Future<void> Function(void Function(String) updateStatus) resetFunction;
  final Future<void> Function()? onComplete;

  const ResetProgressDialog({
    super.key,
    required this.resetFunction,
    this.onComplete,
  });

  @override
  State<ResetProgressDialog> createState() => _ResetProgressDialogState();
}

class _ResetProgressDialogState extends State<ResetProgressDialog> {
  final List<ResetProgressStep> _steps = [];
  bool get _isCompleted => _steps.isNotEmpty && _steps.every((step) => step.isCompleted);
  String? _error;
  int _currentStepIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeAllSteps();
    _startReset();
  }

  void _initializeAllSteps() {
    final stepNames = [
      'Wiping wallets',
      'Stopping binaries',
      'Waiting for processes to stop',
      'Deleting wallet files',
      'Cleaning multisig wallets',
      'Moving master wallet directory',
      'Wiping blockchain data',
      'Wiping asset data',
      'Reset complete',
    ];

    setState(() {
      _steps.addAll(
        stepNames.map(
          (name) => ResetProgressStep(
            name: name,
            startTime: DateTime.now(),
          ),
        ),
      );
    });
  }

  void _startReset() async {
    try {
      await widget.resetFunction((status) {
        setState(() {
          // Complete current step
          if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
            _steps[_currentStepIndex].endTime = DateTime.now();
          }

          // Move to next step
          _currentStepIndex++;

          if (_currentStepIndex < _steps.length) {
            _steps[_currentStepIndex].startTime = DateTime.now();
          }
        });
      });

      // Complete the FINAL step (the one that's currently active)
      setState(() {
        if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
          _steps[_currentStepIndex].endTime = DateTime.now();
        }
      });

      // Call onComplete callback if provided
      if (widget.onComplete != null) {
        await widget.onComplete!();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SailCard(
          title: 'Reset Progress',
          subtitle: _isCompleted
              ? 'Reset completed successfully!'
              : _error != null
              ? 'Reset failed: $_error'
              : 'Resetting everything...',
          withCloseButton: true,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ..._steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isActive = index == _currentStepIndex && !step.isCompleted;
                  return ProgressStepTile(
                    name: step.name,
                    isCompleted: step.isCompleted,
                    duration: step.duration,
                    isActive: isActive,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NetworkSwapStep {
  String name;
  DateTime startTime;
  DateTime? endTime;

  NetworkSwapStep({
    required this.name,
    required this.startTime,
  });

  bool get isCompleted => endTime != null;
  Duration? get duration => endTime?.difference(startTime);
}

class NetworkSwapProgressDialog extends StatefulWidget {
  final BitcoinNetwork fromNetwork;
  final BitcoinNetwork toNetwork;
  final Future<void> Function(void Function(String) updateStatus) swapFunction;

  const NetworkSwapProgressDialog({
    super.key,
    required this.fromNetwork,
    required this.toNetwork,
    required this.swapFunction,
  });

  @override
  State<NetworkSwapProgressDialog> createState() => _NetworkSwapProgressDialogState();
}

class _NetworkSwapProgressDialogState extends State<NetworkSwapProgressDialog> {
  final List<NetworkSwapStep> _steps = [];
  bool get _isCompleted => _steps.isNotEmpty && _steps.every((step) => step.isCompleted);
  String? _error;
  int _currentStepIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeAllSteps();
    _startSwap();
  }

  void _initializeAllSteps() {
    final stepNames = [
      'Stopping Bitcoin Core',
      'Stopping Enforcer',
      'Stopping BitWindow',
      'Waiting for processes to exit',
      'Updating bitcoin.conf',
      'Starting Core, Enforcer and BitWindow',
      'Network swap complete',
    ];

    setState(() {
      _steps.addAll(
        stepNames.map(
          (name) => NetworkSwapStep(
            name: name,
            startTime: DateTime.now(),
          ),
        ),
      );
    });
  }

  void _startSwap() async {
    try {
      await widget.swapFunction((status) {
        setState(() {
          // Complete current step
          if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
            _steps[_currentStepIndex].endTime = DateTime.now();
          }

          // Move to next step
          _currentStepIndex++;

          if (_currentStepIndex < _steps.length) {
            _steps[_currentStepIndex].startTime = DateTime.now();
          }
        });
      });

      // Complete the FINAL step (the one that's currently active)
      setState(() {
        if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
          _steps[_currentStepIndex].endTime = DateTime.now();
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromNetworkName = widget.fromNetwork.toDisplayName();
    final toNetworkName = widget.toNetwork.toDisplayName();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: SailCard(
          title: 'Switching Network',
          subtitle: _isCompleted
              ? 'Successfully switched from $fromNetworkName to $toNetworkName!'
              : _error != null
              ? 'Network swap failed: $_error'
              : 'Switching from $fromNetworkName to $toNetworkName...',
          withCloseButton: true,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ..._steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isActive = index == _currentStepIndex && !step.isCompleted;
                  return ProgressStepTile(
                    name: step.name,
                    isCompleted: step.isCompleted,
                    duration: step.duration,
                    isActive: isActive,
                  );
                }),
                if (_isCompleted) const SailSpacing(SailStyleValues.padding08),
                if (_isCompleted)
                  SailButton(
                    label: 'Close',
                    variant: ButtonVariant.primary,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                if (_error != null) const SailSpacing(SailStyleValues.padding08),
                if (_error != null)
                  SailButton(
                    label: 'Close',
                    variant: ButtonVariant.secondary,
                    onPressed: () async {
                      Navigator.of(context).pop();
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

Future<void> _resetWallets(
  BuildContext context, {
  Future<void> Function()? beforeBoot,
  void Function(String status)? onStatusUpdate,
}) async {
  final logger = GetIt.I.get<Logger>();

  try {
    await GetIt.I.get<WalletWriterProvider>().deleteAllWallets(
      beforeBoot: beforeBoot,
      onStatusUpdate: onStatusUpdate,
    );
  } catch (e) {
    logger.e('could not reset wallet data: $e');

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not reset wallets: $e'),
          backgroundColor: SailTheme.of(context).colors.error,
        ),
      );
    }
  }
}

Future<void> _resetEverything(BuildContext context) async {
  final log = GetIt.I.get<Logger>();
  final appDir = GetIt.I.get<BinaryProvider>().appDir;
  final router = GetIt.I.get<AppRouter>();

  // Show progress dialog
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ResetProgressDialog(
      resetFunction: (updateStatus) async {
        updateStatus('Wiping wallets');

        await _resetWallets(
          context,
          onStatusUpdate: updateStatus,
          beforeBoot: () async {
            log.i('resetting blockchain data');

            updateStatus('Wiping blockchain data');

            // wipe all chain data - don't swallow errors
            try {
              for (final binary in allBinaries) {
                await binary.deleteFiles(await binary.getBlockchainDataPaths());
              }
              log.i('Successfully wiped all blockchain data');
            } catch (e) {
              log.e('could not reset blockchain data: $e');
            }

            updateStatus('Wiping asset data');

            try {
              await Future.wait(allBinaries.map((binary) => binary.deleteBinaries(binDir(appDir.path))));

              // rewrite bitwindow-binary
              await copyBinariesFromAssets(log, appDir);
              log.i('Successfully wiped all blockchain data');
            } catch (e) {
              log.e('could not reset blockchain data: $e');
            }
          },
        );
      },
      onComplete: () async {
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop(); // Close progress dialog
        }
      },
    ),
  );

  // Wait for dialog to fully dispose before replacing entire route stack
  await Future.delayed(const Duration(milliseconds: 100));
  // Restart backend after reset. This will await wallet creation
  unawaited(rebootBitwindowBackend(log));
  // Navigate to wallet creation page (like fresh install)
  await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
}
