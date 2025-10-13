import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:auto_route/auto_route.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:bitwindow/dialogs/change_password_dialog.dart';
import 'package:bitwindow/dialogs/encrypt_wallet_dialog.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/welcome/create_wallet_page.dart';
import 'package:bitwindow/providers/encryption_provider.dart';
import 'package:bitwindow/providers/wallet_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/services/linux_updater.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/sidechain_main.dart' hide bootBinaries;
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding10,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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

            // Navigation and Content side by side
            Row(
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
                // Right content area
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _NetworkSettingsContent();
      case 1:
        return _SecuritySettingsContent();
      case 2:
        return _AppearanceSettingsContent();
      case 3:
        return _AdvancedSettingsContent();
      case 4:
        return _ResetSettingsContent();
      case 5:
        return _AboutSettingsContent();
      default:
        return _NetworkSettingsContent();
    }
  }
}

class _NetworkSettingsContent extends StatefulWidget {
  @override
  State<_NetworkSettingsContent> createState() => _NetworkSettingsContentState();
}

class _NetworkSettingsContentState extends State<_NetworkSettingsContent> {
  final _settingsProvider = GetIt.I.get<SettingsProvider>();
  BitcoinConfProvider get _confProvider => GetIt.I.get<BitcoinConfProvider>();
  String? _selectedDataDir;
  bool _isSelectingDataDir = false;

  @override
  void initState() {
    super.initState();
    // Listen to provider changes
    _settingsProvider.addListener(setstate);
    _confProvider.addListener(setstate);
    _selectedDataDir = _confProvider.detectedDataDir;
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(setstate);
    _confProvider.removeListener(setstate);
    super.dispose();
  }

  void setstate() {
    setState(() {});
  }

  Future<void> _handleNetworkChange(Network? network) async {
    if (network == null) return;

    // Save the current network before switching
    final fromNetwork = _confProvider.network;

    // Check if user config controls network
    if (_confProvider.hasPrivateBitcoinConf) {
      // Show info that network is controlled by bitcoin.conf
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Network is controlled by your bitcoin.conf file. To change network in bitwindow, delete your own bitcoin.conf file.',
            ),
            backgroundColor: SailTheme.of(context).colors.info,
          ),
        );
      }
      return;
    }

    // If switching TO mainnet, check if we need to require a blocks directory
    if (network == Network.NETWORK_MAINNET) {
      // Check if we already have a custom datadir configured
      final hasDataDirConfigured = _selectedDataDir != null;

      if (!hasDataDirConfigured) {
        // Ask for datadir for mainnet
        final selectedPath = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const DataDirSelectionDialog(),
        );

        if (selectedPath != null) {
          // Save the selected data directory
          await _confProvider.updateDataDir(selectedPath);
        } else {
          // User cancelled, don't switch to mainnet
          return;
        }
      }
    }

    // Show progress dialog and perform restart
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NetworkSwapProgressDialog(
          fromNetwork: fromNetwork,
          toNetwork: network,
          swapFunction: (updateStatus) async {
            await _confProvider.restartServicesWithProgress(network, updateStatus);
          },
        ),
      );
    }
  }

  Future<void> _selectDataDirectory() async {
    setState(() {
      _isSelectingDataDir = true;
    });

    try {
      // Get the default Bitcoin Core datadir to use as initial directory
      final defaultDir = BitcoinCore().datadir();

      final result = await FilePicker.platform.getDirectoryPath(
        initialDirectory: defaultDir,
      );
      if (result != null) {
        // Validate that the directory is writable
        final testFile = File(path.join(result, '.bitwindow_test'));
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
          setState(() {
            _selectedDataDir = result;
          });
          await _confProvider.updateDataDir(result);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected directory is not writable: $e'),
                backgroundColor: SailTheme.of(context).colors.error,
              ),
            );
          }
        }
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
          _isSelectingDataDir = false;
        });
      }
    }
  }

  Future<void> _clearDataDir() async {
    await _confProvider.updateDataDir(null);
    setState(() {
      _selectedDataDir = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final showDataDir = _confProvider.network == Network.NETWORK_MAINNET || _selectedDataDir != null;
    final canEditDataDir = !_confProvider.hasPrivateBitcoinConf;

    return SailColumn(
      spacing: SailStyleValues.padding32,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Network & Node'),
            SailText.secondary13('Configure Bitcoin network and node settings'),
          ],
        ),

        // Network Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Bitcoin Network'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<Network>(
              value: _confProvider.network,
              enabled: _confProvider.canEditNetwork,
              items: [
                SailDropdownItem<Network>(
                  value: Network.NETWORK_MAINNET,
                  label: 'Mainnet',
                ),
                SailDropdownItem<Network>(
                  value: Network.NETWORK_SIGNET,
                  label: 'Signet',
                ),
                SailDropdownItem<Network>(
                  value: Network.NETWORK_TESTNET,
                  label: 'Testnet',
                ),
                SailDropdownItem<Network>(
                  value: Network.NETWORK_REGTEST,
                  label: 'Regtest',
                ),
              ],
              onChanged: (Network? network) async {
                if (network != null && _confProvider.canEditNetwork) {
                  await _handleNetworkChange(network);
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              _confProvider.canEditNetwork
                  ? 'Select the Bitcoin network to connect to'
                  : 'Network is controlled by your bitcoin.conf file (${_confProvider.currentConfigFile})',
            ),
          ],
        ),

        // Bitcoin Configuration
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Bitcoin Conf Configuration'),
            const SailSpacing(SailStyleValues.padding08),
            SailButton(
              label: 'Edit Bitcoin Core Settings',
              onPressed: () async {
                // Add small delay to allow proper widget cleanup
                await Future.delayed(const Duration(milliseconds: 100));
                final router = GetIt.I.get<AppRouter>();
                await router.push(const BitcoinConfEditorRoute());
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'Configure your Bitcoin Core conf',
            ),
          ],
        ),

        // Bitcoin Data Directory (visible when mainnet is enabled or has value)
        if (showDataDir)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Bitcoin Data Directory'),
              const SailSpacing(SailStyleValues.padding08),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.border),
                        borderRadius: SailStyleValues.borderRadiusSmall,
                        color: canEditDataDir ? null : theme.colors.backgroundSecondary,
                      ),
                      child: SailText.secondary13(
                        _confProvider.detectedDataDir ?? _selectedDataDir ?? 'Default directory',
                      ),
                    ),
                  ),
                  if (canEditDataDir) ...[
                    SailButton(
                      label: 'Browse',
                      small: true,
                      loading: _isSelectingDataDir,
                      onPressed: () async => await _selectDataDirectory(),
                    ),
                    if (_selectedDataDir != null)
                      SailButton(
                        label: 'Clear',
                        small: true,
                        variant: ButtonVariant.secondary,
                        onPressed: () async => await _clearDataDir(),
                      ),
                  ],
                ],
              ),
              const SailSpacing(4),
              SailText.secondary12(
                canEditDataDir
                    ? 'Directory where Bitcoin data files are stored (2.5TB+ for mainnet)'
                    : 'Data directory is controlled by your bitcoin.conf file',
              ),
            ],
          ),

        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}

class _SecuritySettingsContent extends StatefulWidget {
  @override
  State<_SecuritySettingsContent> createState() => _SecuritySettingsContentState();
}

class _SecuritySettingsContentState extends State<_SecuritySettingsContent> {
  final EncryptionProvider _encryptionProvider = GetIt.I.get<EncryptionProvider>();
  bool _isEncrypted = false;
  bool _isCheckingEncryption = true;

  @override
  void initState() {
    super.initState();
    _checkEncryptionStatus();
    _encryptionProvider.addListener(_onEncryptionChanged);
  }

  @override
  void dispose() {
    _encryptionProvider.removeListener(_onEncryptionChanged);
    super.dispose();
  }

  void _onEncryptionChanged() {
    _checkEncryptionStatus();
  }

  Future<void> _checkEncryptionStatus() async {
    final encrypted = await _encryptionProvider.isWalletEncrypted();
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
                    if (mounted) {
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
              SailButton(
                label: 'Change Password',
                onPressed: () async {
                  final result = await ChangePasswordDialog.show(context);
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password changed successfully'),
                        backgroundColor: theme.colors.success,
                      ),
                    );
                  }
                },
              ),
              const SailSpacing(4),
              SailText.secondary12(
                'Change your wallet encryption password',
              ),
            ],
          ),

        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}

// Shared wallet backup function used by both backup and restore
Future<String> createWalletBackup({
  required String destinationPath,
  required Logger log,
  required WalletProvider walletProvider,
}) async {
  final archive = Archive();

  // Get app directory
  final appDir = await Environment.datadir();
  final bitwindowAppDir = walletProvider.bitwindowAppDir;

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

class BackupWalletDialog extends StatefulWidget {
  const BackupWalletDialog({super.key});

  @override
  State<BackupWalletDialog> createState() => _BackupWalletDialogState();
}

class _BackupWalletDialogState extends State<BackupWalletDialog> {
  Logger get log => GetIt.I.get<Logger>();
  WalletProvider get walletProvider => GetIt.I.get<WalletProvider>();

  String? _selectedPath;
  bool _isCreatingBackup = false;
  String? _error;

  Future<void> _selectSaveLocation() async {
    try {
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final defaultFileName = 'bitwindow-backup-$timestamp.zip';

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
    // Use shared backup function
    await createWalletBackup(
      destinationPath: destinationPath,
      log: log,
      walletProvider: walletProvider,
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
  final Directory? tempDir;

  BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.tempDir,
  });
}

// Validate backup ZIP file
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
    tempDir = await Directory.systemTemp.createTemp('bitwindow_restore_');

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

      // Validate structure
      if (!walletJSON.containsKey('master') || !walletJSON.containsKey('l1')) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'wallet.json has invalid structure (missing master or l1)',
        );
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

// Check if current wallet exists
Future<bool> hasCurrentWallet(WalletProvider walletProvider) async {
  final walletJsonFile = File(path.join(walletProvider.bitwindowAppDir.path, 'wallet.json'));
  return await walletJsonFile.exists();
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
  final WalletProvider walletProvider = GetIt.I.get<WalletProvider>();

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
      'Waiting for processes to stop',
      'Deleting old wallet files',
      'Restoring wallet files',
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
      // 1. Backup current wallet if exists
      if (widget.autoBackupPath != null) {
        _updateStatus('Backing up current wallet');
        await createWalletBackup(
          destinationPath: widget.autoBackupPath!,
          log: log,
          walletProvider: walletProvider,
        );
      }

      // 2. Validate backup
      _updateStatus('Validating backup file');
      final validation = await validateBackupZip(zipFile: widget.backupFile, log: log);
      if (!validation.isValid) {
        throw Exception(validation.errorMessage);
      }

      // 3. Stop binaries
      _updateStatus('Stopping binaries');
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      final binariesToStop = [BitcoinCore(), Enforcer(), BitWindow()];
      for (final binary in binariesToStop) {
        await binaryProvider.stop(binary);
      }

      // 4. Wait for shutdown
      _updateStatus('Waiting for processes to stop');
      await Future.delayed(const Duration(seconds: 5));

      // 5. Delete old files
      _updateStatus('Deleting old wallet files');
      final appDir = await Environment.datadir();
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

      // Clean up temp
      await tempDir.delete(recursive: true);

      // 7. Recreate sidechain starter files
      _updateStatus('Recreating sidechain starter files');
      await walletProvider.syncStarterFiles();
      log.i('Regenerated sidechain starter files from wallet.json');

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
      await bootBinaries(log);

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
          withCloseButton: _isCompleted || _error != null,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ..._steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isActive = index == _currentStepIndex && !step.isCompleted;
                  return _buildStepTile(step, theme, index, isActive);
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

  Widget _buildStepTile(RestoreProgressStep step, SailThemeData theme, int index, bool isActive) {
    Widget iconWidget;
    String timeText = '';

    if (step.isCompleted) {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circleCheck, color: SailColorScheme.green, width: 16, height: 16);
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
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
        ),
      );
    } else {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circle, color: theme.colors.textSecondary, width: 16, height: 16);
    }

    return SailRow(
      spacing: SailStyleValues.padding04,
      children: [
        SizedBox(width: 16, child: iconWidget),
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
  WalletProvider get walletProvider => GetIt.I.get<WalletProvider>();

  File? _selectedFile;
  String? _error;

  Future<void> _selectBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Wallet Backup',
        type: FileType.custom,
        allowedExtensions: ['zip'],
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
      final hasCurrent = await hasCurrentWallet(walletProvider);

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
            await showDialog(
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
                  await _resetWallets(context);
                },
              ),
            );
          },
        ),
        SailButton(
          label: 'Reset Everything',
          variant: ButtonVariant.destructive,
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => SailAlertCard(
                title: 'Reset Everything?',
                subtitle:
                    'Are you sure you want to reset absolutely everything? Even wallets will be deleted. This action cannot be undone.',
                confirmButtonVariant: ButtonVariant.destructive,
                onConfirm: () async {
                  await _resetEverything(context);
                },
              ),
            );
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
      await binary.wipeAppDir();
    }

    // finally, boot the binaries
    unawaited(bootBinaries(GetIt.I.get<Logger>()));

    final mainchainRPC = GetIt.I.get<MainchainRPC>();
    while (!mainchainRPC.connected) {
      await Future.delayed(const Duration(seconds: 1));
    }
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

        SailSpacing(SailStyleValues.padding64),
      ],
    );
  }
}

class _AdvancedSettingsContent extends StatefulWidget {
  @override
  State<_AdvancedSettingsContent> createState() => _AdvancedSettingsContentState();
}

class _AdvancedSettingsContentState extends State<_AdvancedSettingsContent> {
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

  Future<void> _showDebugModeWarning() async {
    await showDialog(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Enable Debug Mode?',
        subtitle:
            'Enabling debug mode will send detailed error reports Sentry.\r\n\r\nEvery time a component crashes or an error is thrown, '
            'Sentry will collect technical information about your device, app usage patterns, and error details.'
            '\r\n\r\nIt is very helpful to the devs, but it also includes information such as your IP address, device type, and location. '
            'If you dont trust Sentry with this information, enable a VPN, or press Cancel.',
        onConfirm: () async {
          await _settingsProvider.updateDebugMode(true);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
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
            SailText.primary20('Advanced'),
            SailText.secondary13('Developer options and experimental features'),
          ],
        ),

        // Debug Mode
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Debug Mode'),
            const SailSpacing(SailStyleValues.padding08),
            SailDropdownButton<bool>(
              value: _settingsProvider.debugMode,
              items: [
                SailDropdownItem<bool>(
                  value: false,
                  label: 'Disabled',
                ),
                SailDropdownItem<bool>(
                  value: true,
                  label: 'Enabled',
                ),
              ],
              onChanged: (bool? newValue) async {
                if (newValue == true) {
                  await _showDebugModeWarning();
                } else {
                  await _settingsProvider.updateDebugMode(false);
                }
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'When enabled, detailed error reporting will be collected to fix bugs hastily.',
            ),
          ],
        ),

        // Test Sidechains
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Test Sidechains'),
            const SailSpacing(SailStyleValues.padding08),
            SailToggle(
              label: 'Use Test Sidechains',
              value: _settingsProvider.useTestSidechains,
              onChanged: (value) async {
                await _settingsProvider.updateUseTestSidechains(value);
              },
            ),
            const SailSpacing(4),
            SailText.secondary12(
              'Download and run alternative frontends for sidechains',
            ),
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
  LinuxUpdater? _linuxUpdater;
  UpdateStatus _updateStatus = UpdateStatus.idle;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux) {
      _linuxUpdater = LinuxUpdater(log: GetIt.I.get<Logger>());
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _updateStatus = UpdateStatus.checking;
      _statusMessage = null;
    });

    try {
      if (Platform.isLinux) {
        // Use custom updater for Linux
        final hasUpdate = await _linuxUpdater!.checkForUpdates();
        setState(() {
          _updateStatus = _linuxUpdater!.status;

          if (hasUpdate) {
            _statusMessage = 'Update available: v${_linuxUpdater!.latestVersion}';
          } else if (_updateStatus == UpdateStatus.upToDate) {
            _statusMessage = 'You have the latest version';
          } else if (_updateStatus == UpdateStatus.error) {
            _statusMessage = 'Error: ${_linuxUpdater!.errorMessage}';
          }
        });
      } else {
        // Use auto_updater for Windows/macOS
        await autoUpdater.checkForUpdates();
        setState(() {
          _updateStatus = UpdateStatus.upToDate;
          _statusMessage = 'Check complete. If update available, you will be notified.';
        });
      }
    } catch (e) {
      setState(() {
        _updateStatus = UpdateStatus.error;
        _statusMessage = 'Error checking for updates: $e';
      });
    }
  }

  Future<void> _performUpdate() async {
    if (!Platform.isLinux || _linuxUpdater == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Update BitWindow?',
        subtitle:
            'The application will download and install version ${_linuxUpdater!.latestVersion}, then restart automatically.',
        onConfirm: () async => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _updateStatus = UpdateStatus.downloading;
      _statusMessage = 'Downloading update...';
    });

    try {
      await _linuxUpdater!.performUpdate();
    } catch (e) {
      if (mounted) {
        setState(() {
          _updateStatus = UpdateStatus.error;
          _statusMessage = 'Update failed: $e';
        });

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
                  loading:
                      _updateStatus == UpdateStatus.checking ||
                      _updateStatus == UpdateStatus.downloading ||
                      _updateStatus == UpdateStatus.installing,
                  onPressed: () async => await _checkForUpdates(),
                ),
                if (_updateStatus == UpdateStatus.updateAvailable && Platform.isLinux)
                  SailButton(
                    label: 'Install Update',
                    variant: ButtonVariant.primary,
                    onPressed: () async => await _performUpdate(),
                  ),
              ],
            ),
            if (_statusMessage != null) ...[
              const SailSpacing(4),
              SailText.secondary12(
                _statusMessage!,
                color: _updateStatus == UpdateStatus.error
                    ? SailTheme.of(context).colors.error
                    : _updateStatus == UpdateStatus.updateAvailable
                    ? SailTheme.of(context).colors.primary
                    : null,
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
      // Get the default Bitcoin Core datadir to use as initial directory
      final defaultDir = BitcoinCore().datadir();

      final result = await FilePicker.platform.getDirectoryPath(
        initialDirectory: defaultDir,
      );
      if (result != null) {
        // Validate that the directory is writable
        final testFile = File(path.join(result, '.bitwindow_test'));
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
          setState(() {
            selectedPath = result;
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected directory is not writable: $e'),
                backgroundColor: SailTheme.of(context).colors.error,
              ),
            );
          }
        }
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

  const ResetProgressDialog({super.key, required this.resetFunction});

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
    } catch (e) {
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
                  return _buildStepTile(step, theme, index, isActive);
                }),
                if (_isCompleted) const SailSpacing(SailStyleValues.padding08),
                if (_isCompleted)
                  SailButton(
                    label: 'Create New Wallet',
                    variant: ButtonVariant.primary,
                    onPressed: () async {
                      GetIt.I.get<AppRouter>().pop();
                      await GetIt.I.get<AppRouter>().push(
                        CreateWalletRoute(
                          initalScreen: WelcomeScreen.initial,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile(ResetProgressStep step, SailThemeData theme, int index, bool isActive) {
    Widget iconWidget;
    String timeText = '';

    if (step.isCompleted) {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circleCheck, color: SailColorScheme.green, width: 16, height: 16);
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
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
        ),
      );
    } else {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circle, color: theme.colors.textSecondary, width: 16, height: 16);
    }

    return SailRow(
      spacing: SailStyleValues.padding04,
      children: [
        SizedBox(width: 16, child: iconWidget),
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
  final Network fromNetwork;
  final Network toNetwork;
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
    final theme = SailTheme.of(context);
    final fromNetworkName = _networkDisplayName(widget.fromNetwork);
    final toNetworkName = _networkDisplayName(widget.toNetwork);

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
                  return _buildStepTile(step, theme, index, isActive);
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

  Widget _buildStepTile(NetworkSwapStep step, SailThemeData theme, int index, bool isActive) {
    Widget iconWidget;
    String timeText = '';

    if (step.isCompleted) {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circleCheck, color: SailColorScheme.green, width: 16, height: 16);
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
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
        ),
      );
    } else {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circle, color: theme.colors.textSecondary, width: 16, height: 16);
    }

    return SailRow(
      spacing: SailStyleValues.padding04,
      children: [
        SizedBox(width: 16, child: iconWidget),
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
    );
  }

  String _networkDisplayName(Network network) {
    return switch (network) {
      Network.NETWORK_MAINNET => 'Mainnet',
      Network.NETWORK_TESTNET => 'Testnet',
      Network.NETWORK_SIGNET => 'Signet',
      Network.NETWORK_REGTEST => 'Regtest',
      _ => 'Unknown',
    };
  }
}

Future<void> _resetWallets(
  BuildContext context, {
  Future<void> Function()? beforeBoot,
  void Function(String status)? onStatusUpdate,
}) async {
  final logger = GetIt.I.get<Logger>();

  try {
    await GetIt.I.get<WalletProvider>().deleteAllWallets(
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

  Navigator.of(context).pop(); // pop the current dialog

  // Show the new one
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ResetProgressDialog(
      resetFunction: (updateStatus) async {
        updateStatus('Wiping wallets');

        await _resetWallets(
          context,
          onStatusUpdate: updateStatus,
          beforeBoot: () async {
            log.i('resetting blockchain data');

            final allBinaries = [
              BitcoinCore(),
              Enforcer(),
              BitWindow(),
              Thunder(),
              BitNames(),
              BitAssets(),
              ZSide(),
            ];

            updateStatus('Wiping blockchain data');

            // wipe all chain data - don't swallow errors
            try {
              await Future.wait(allBinaries.map((binary) => binary.wipeAppDir()));
              log.i('Successfully wiped all blockchain data');
            } catch (e) {
              log.e('could not reset blockchain data: $e');
            }

            updateStatus('Wiping asset data');

            try {
              await Future.wait(allBinaries.map((binary) => binary.wipeAsset(binDir(appDir.path))));

              // rewrite bitwindow-binary
              await copyBinariesFromAssets(log, appDir);
              log.i('Successfully wiped all blockchain data');
            } catch (e) {
              log.e('could not reset blockchain data: $e');
            }
          },
        );
      },
    ),
  );
}
