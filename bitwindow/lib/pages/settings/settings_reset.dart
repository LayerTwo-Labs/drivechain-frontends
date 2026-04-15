import 'dart:async';

import 'package:bitwindow/main.dart' show rebootBitwindowBackend;
import 'package:bitwindow/pages/root_page.dart' show setRootPageNavigatingAway;
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

class SettingsReset extends StatefulWidget {
  const SettingsReset({super.key});

  @override
  State<SettingsReset> createState() => _SettingsResetState();
}

class _SettingsResetState extends State<SettingsReset> {
  Logger get log => GetIt.I.get<Logger>();

  bool _deleteNodeSoftware = false;
  bool _deleteBlockchainData = false;
  bool _deleteLogs = false;
  bool _deleteWalletFiles = false;
  bool _deleteSettings = false;
  bool _alsoResetSidechains = false;
  bool _obliterateEverything = false;

  bool get _hasSelection =>
      _deleteNodeSoftware ||
      _deleteBlockchainData ||
      _deleteLogs ||
      _deleteWalletFiles ||
      _deleteSettings ||
      _obliterateEverything;

  void _updateObliterate() {
    _obliterateEverything =
        _deleteNodeSoftware &&
        _deleteBlockchainData &&
        _deleteLogs &&
        _deleteWalletFiles &&
        _deleteSettings &&
        _alsoResetSidechains;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary20('Reset'),
              SailText.secondary13('Select what you want to reset and click the button below'),
              const SailSpacing(SailStyleValues.padding08),
              ResetOptionTile(
                value: _deleteNodeSoftware,
                onChanged: (v) => setState(() {
                  _deleteNodeSoftware = v;
                  _updateObliterate();
                }),
                title: 'Delete Node Software and Data',
                subtitle: 'Deletes all binaries for re-downloading',
                isDestructive: false,
              ),
              ResetOptionTile(
                value: _deleteBlockchainData,
                onChanged: (v) => setState(() {
                  _deleteBlockchainData = v;
                  _updateObliterate();
                }),
                title: 'Delete Blockchain Data',
                subtitle: 'Resyncs the blockchain from scratch',
                isDestructive: false,
              ),
              ResetOptionTile(
                value: _deleteLogs,
                onChanged: (v) => setState(() {
                  _deleteLogs = v;
                  _updateObliterate();
                }),
                title: 'Delete Log Files',
                subtitle: 'Removes all debug and server log files',
                isDestructive: false,
              ),
              ResetOptionTile(
                value: _deleteSettings,
                onChanged: (v) => setState(() {
                  _deleteSettings = v;
                  _updateObliterate();
                }),
                title: 'Delete BitWindow Settings',
                subtitle: 'Resets all configuration to defaults',
                isDestructive: false,
              ),
              ResetOptionTile(
                value: _deleteWalletFiles,
                onChanged: (v) => setState(() {
                  _deleteWalletFiles = v;
                  _updateObliterate();
                }),
                title: 'Delete My Wallet Files',
                subtitle: 'Backup your seed phrase first!',
                isDestructive: true,
              ),
              ResetOptionTile(
                value: _alsoResetSidechains,
                onChanged: (v) => setState(() {
                  _alsoResetSidechains = v;
                  _updateObliterate();
                }),
                title: 'Reset Sidechain Data',
                subtitle: 'Also wipes all data for Thunder, BitNames, BitAssets and ZSide',
                isDestructive: true,
              ),
              ResetOptionTile(
                value: _obliterateEverything,
                onChanged: (v) => setState(() {
                  _obliterateEverything = v;
                  _deleteNodeSoftware = v;
                  _deleteBlockchainData = v;
                  _deleteLogs = v;
                  _deleteWalletFiles = v;
                  _deleteSettings = v;
                  _alsoResetSidechains = v;
                }),
                title: 'Fully Obliterate Everything',
                subtitle: 'Deletes all data including sidechains',
                isDestructive: true,
              ),
            ],
          ),
        ),
        BottomActionBar(
          maxWidth: double.infinity,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SailButton(
              label: 'Reset Selected',
              variant: ButtonVariant.destructive,
              skipLoading: true,
              disabled: !_hasSelection,
              onPressed: () async {
                await _executeReset(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _executeReset(BuildContext context) async {
    if (!context.mounted) return;

    // Show confirmation dialog
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _ResetConfirmationPage(
          deleteBlockchainData: _deleteBlockchainData,
          deleteNodeSoftware: _deleteNodeSoftware,
          deleteLogs: _deleteLogs,
          deleteSettings: _deleteSettings,
          deleteWalletFiles: _deleteWalletFiles,
          alsoResetSidechains: _alsoResetSidechains,
        ),
      ),
    );

    if (!context.mounted) return;

    // If deletion happened, restart binaries
    if (confirmed == true) {
      // Clear in-memory wallet state so the create wallet page sees a fresh state
      if (_deleteWalletFiles || _obliterateEverything) {
        GetIt.I.get<WalletReaderProvider>().clearState();
      }

      unawaited(rebootBitwindowBackend(log));

      final router = GetIt.I.get<AppRouter>();
      final needsWalletCreation = _deleteWalletFiles || _obliterateEverything;

      if (needsWalletCreation) {
        // Prevent RootPage.dispose() from triggering app shutdown during navigation
        setRootPageNavigatingAway(true);
        await router.replaceAll([SailCreateWalletRoute(homeRoute: const RootRoute())]);
      }
    }
  }
}

/// Confirmation page that shows categories and executes the reset via orchestrator RPC.
class _ResetConfirmationPage extends StatefulWidget {
  final bool deleteBlockchainData;
  final bool deleteNodeSoftware;
  final bool deleteLogs;
  final bool deleteSettings;
  final bool deleteWalletFiles;
  final bool alsoResetSidechains;

  const _ResetConfirmationPage({
    required this.deleteBlockchainData,
    required this.deleteNodeSoftware,
    required this.deleteLogs,
    required this.deleteSettings,
    required this.deleteWalletFiles,
    required this.alsoResetSidechains,
  });

  @override
  State<_ResetConfirmationPage> createState() => _ResetConfirmationPageState();
}

class _ResetConfirmationPageState extends State<_ResetConfirmationPage> {
  Logger get log => GetIt.I.get<Logger>();
  OrchestratorRPC get orchestrator => GetIt.I.get<OrchestratorRPC>();

  bool _isResetting = false;
  bool _resetComplete = false;
  String? _errorMessage;
  ResetDataResponse? _result;

  List<String> get _selectedCategories {
    final categories = <String>[];
    if (widget.deleteNodeSoftware) categories.add('Node Software & Binaries');
    if (widget.deleteBlockchainData) categories.add('Blockchain Data');
    if (widget.deleteLogs) categories.add('Log Files');
    if (widget.deleteSettings) categories.add('Settings & Configuration');
    if (widget.deleteWalletFiles) categories.add('Wallet Files');
    if (widget.alsoResetSidechains) categories.add('Sidechain Data');
    return categories;
  }

  Future<void> _startReset() async {
    setState(() {
      _isResetting = true;
      _errorMessage = null;
    });

    try {
      final response = await orchestrator.resetData(
        deleteBlockchainData: widget.deleteBlockchainData,
        deleteNodeSoftware: widget.deleteNodeSoftware,
        deleteLogs: widget.deleteLogs,
        deleteSettings: widget.deleteSettings,
        deleteWalletFiles: widget.deleteWalletFiles,
        alsoResetSidechains: widget.alsoResetSidechains,
      );

      if (mounted) {
        setState(() {
          _result = response;
          _resetComplete = true;
          if (response.failedItems.isNotEmpty) {
            _errorMessage = '${response.failedItems.length} items failed to delete';
          }
        });
      }
    } catch (e) {
      log.e('Reset failed: $e');
      if (mounted) {
        setState(() {
          _resetComplete = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _handleBack() {
    Navigator.of(context).pop(_isResetting);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return PopScope(
      canPop: !_isResetting || _resetComplete,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _resetComplete) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          foregroundColor: theme.colors.text,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isResetting && !_resetComplete ? null : _handleBack,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: 800,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          SailRow(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: SailStyleValues.padding12,
                            children: [
                              if (_resetComplete && _errorMessage == null)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colors.success,
                                  size: 32,
                                )
                              else
                                SailSVG.fromAsset(
                                  SailSVGAsset.iconWarning,
                                  color: theme.colors.error,
                                  width: 32,
                                  height: 32,
                                ),
                              SailText.primary24(
                                _resetComplete ? 'Reset Complete' : 'Confirm Reset',
                                bold: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isResetting && !_resetComplete)
                            SailRow(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: SailStyleValues.padding08,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colors.primary,
                                  ),
                                ),
                                SailText.secondary13('Stopping binaries and deleting data...'),
                              ],
                            )
                          else if (_resetComplete && _result != null)
                            SailText.secondary13(
                              'Deleted ${_result!.deletedItems.length} items'
                              '${_result!.failedItems.isNotEmpty ? ', ${_result!.failedItems.length} failed' : ''}',
                            )
                          else
                            SailText.secondary13(
                              'The following categories will be reset:',
                            ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            SailText.secondary13(
                              _errorMessage!,
                              color: theme.colors.error,
                            ),
                          ],
                          const SizedBox(height: 24),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colors.backgroundSecondary,
                              borderRadius: SailStyleValues.borderRadiusSmall,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(SailStyleValues.padding12),
                              child: _resetComplete && _result != null
                                  ? _buildResultList(theme)
                                  : _buildCategoryList(theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              BottomActionBar(
                children: [
                  if (!_isResetting) ...[
                    SailButton(
                      label: 'Cancel',
                      onPressed: () async => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: SailStyleValues.padding12),
                    SailButton(
                      label: 'Reset ${_selectedCategories.length} categories',
                      variant: ButtonVariant.destructive,
                      onPressed: () async => await _startReset(),
                    ),
                  ] else if (_resetComplete)
                    SailButton(
                      label: 'Continue',
                      variant: ButtonVariant.primary,
                      onPressed: () async => _handleBack(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(SailThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedCategories
          .map(
            (cat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Icon(Icons.delete_outline, size: 16, color: theme.colors.error),
                  SailText.secondary13(cat),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildResultList(SailThemeData theme) {
    final items = <Widget>[];

    for (final item in _result!.deletedItems) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Icon(Icons.check_circle, size: 16, color: theme.colors.success),
              Expanded(
                child: SailText.secondary12(item.path, monospace: true),
              ),
            ],
          ),
        ),
      );
    }

    for (final item in _result!.failedItems) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Icon(Icons.error, size: 16, color: theme.colors.error),
              Expanded(
                child: SailText.secondary12(
                  '${item.path}: ${item.error}',
                  monospace: true,
                  color: theme.colors.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}
