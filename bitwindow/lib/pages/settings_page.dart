import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/welcome/create_wallet_page.dart';
import 'package:bitwindow/providers/wallet_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
        return _AppearanceSettingsContent();
      case 2:
        return _AdvancedSettingsContent();
      case 3:
        return _ResetSettingsContent();
      case 4:
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
  String? _selectedBlocksDir;
  bool _isSelectingBlocksDir = false;

  @override
  void initState() {
    super.initState();
    // Listen to provider changes
    _settingsProvider.addListener(setstate);
    _confProvider.addListener(setstate);
    _selectedBlocksDir = _confProvider.detectedBlocksDir;
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
      // Check if we already have a custom blocksdir configured
      final hasBlocksDirConfigured = _selectedBlocksDir != null;

      if (!hasBlocksDirConfigured) {
        // Ask for blocksdir for mainnet
        final selectedPath = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const BlocksDirSelectionDialog(),
        );

        if (selectedPath != null) {
          // Save the selected data directory
          await _confProvider.updateBlocksDir(selectedPath);
        } else {
          // User cancelled, don't switch to mainnet
          return;
        }
      }
    }

    // Update network in config (saves automatically)
    await _confProvider.updateNetwork(network);
    await _confProvider.restartServicesForMainnet();

    // Reload theme with new accent color for the network
    if (mounted) {
      final app = SailApp.of(context);
      final newAccentColor = getNetworkAccentColor(network);
      app.reloadThemeWithCurrentSettings(newAccentColor);
    }
  }

  Future<void> _selectBlocksDirectory() async {
    setState(() {
      _isSelectingBlocksDir = true;
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
            _selectedBlocksDir = result;
          });
          await _confProvider.updateBlocksDir(result);
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
          _isSelectingBlocksDir = false;
        });
      }
    }
  }

  Future<void> _clearBlocksDir() async {
    await _confProvider.updateBlocksDir(null);
    setState(() {
      _selectedBlocksDir = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final showBlocksDir = _confProvider.network == Network.NETWORK_MAINNET || _selectedBlocksDir != null;
    final canEditBlocksDir = !_confProvider.hasPrivateBitcoinConf;

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

        // Bitcoin Blocks Directory (visible when mainnet is enabled or has value)
        if (showBlocksDir)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('Bitcoin Blocks Directory'),
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
                        color: canEditBlocksDir ? null : theme.colors.backgroundSecondary,
                      ),
                      child: SailText.secondary13(
                        _confProvider.detectedBlocksDir ?? _selectedBlocksDir ?? 'Default directory',
                      ),
                    ),
                  ),
                  if (canEditBlocksDir) ...[
                    SailButton(
                      label: 'Browse',
                      small: true,
                      loading: _isSelectingBlocksDir,
                      onPressed: () async => await _selectBlocksDirectory(),
                    ),
                    if (_selectedBlocksDir != null)
                      SailButton(
                        label: 'Clear',
                        small: true,
                        variant: ButtonVariant.secondary,
                        onPressed: () async => await _clearBlocksDir(),
                      ),
                  ],
                ],
              ),
              const SailSpacing(4),
              SailText.secondary12(
                canEditBlocksDir
                    ? 'Directory where Bitcoin block files are stored (2.5TB+ for mainnet)'
                    : 'Blocks directory is controlled by your bitcoin.conf file',
              ),
            ],
          ),

        SailSpacing(SailStyleValues.padding64),
      ],
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
      ],
    );
  }
}

class BlocksDirSelectionDialog extends StatefulWidget {
  const BlocksDirSelectionDialog({super.key});

  @override
  State<BlocksDirSelectionDialog> createState() => _BlocksDirSelectionDialogState();
}

class _BlocksDirSelectionDialogState extends State<BlocksDirSelectionDialog> {
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
          title: 'Select Bitcoin Blocks Directory',
          subtitle:
              'Bitcoin mainnet requires substantial storage space (approximately 2.5TB). '
              'Please select a directory with enough free space to store the Bitcoin block files.\n\n'
              'This directory will be used for all networks, but only for blocks-data',
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
