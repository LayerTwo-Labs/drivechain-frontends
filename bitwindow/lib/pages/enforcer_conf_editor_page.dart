import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/viewmodels/enforcer_config_editor_viewmodel.dart';
import 'package:bitwindow/widgets/enforcer_config_editor/actual_config_panel.dart';
import 'package:bitwindow/widgets/enforcer_config_editor/configurator_panel.dart';
import 'package:bitwindow/widgets/enforcer_config_editor/working_config_panel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class EnforcerConfEditorPage extends StatelessWidget {
  const EnforcerConfEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EnforcerConfigEditorViewModel>.reactive(
      viewModelBuilder: () => EnforcerConfigEditorViewModel(),
      onViewModelReady: (viewModel) => viewModel.loadConfig(),
      builder: (context, viewModel, child) => _buildPage(context, viewModel),
    );
  }

  Widget _buildPage(BuildContext context, EnforcerConfigEditorViewModel viewModel) {
    final theme = SailTheme.of(context);

    return SailPage(
      widgetTitle: SailText.secondary12('Back to settings'),
      body: QtPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SailText.primary24(
                    'Enforcer Conf Configurator',
                    bold: true,
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: [
                      // Preset dropdown
                      _buildSimpleDropdown(viewModel),
                      const SailSpacing(SailStyleValues.padding12),
                      // Reset button
                      SailButton(
                        label: 'Reset',
                        variant: ButtonVariant.secondary,
                        disabled: !viewModel.hasUnsavedChanges,
                        onPressed: () async {
                          viewModel.resetChanges();
                        },
                      ),
                      const SailSpacing(SailStyleValues.padding12),
                      // Save button
                      SailButton(
                        label: 'Save',
                        loading: viewModel.isLoading,
                        disabled: !viewModel.hasUnsavedChanges,
                        onPressed: () async {
                          await viewModel.saveConfig();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Info message about CLI args
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: theme.colors.info.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadius,
              ),
              child: Row(
                children: [
                  SailSVG.fromAsset(
                    SailSVGAsset.iconInfo,
                    color: theme.colors.info,
                    width: 16,
                    height: 16,
                  ),
                  const SailSpacing(SailStyleValues.padding08),
                  Expanded(
                    child: SailText.secondary12(
                      'The Enforcer does not read from a config file. These settings are converted to CLI arguments when the Enforcer starts. '
                      'Restart the Enforcer after saving for changes to take effect.',
                      color: theme.colors.info,
                    ),
                  ),
                ],
              ),
            ),

            const SailSpacing(SailStyleValues.padding12),

            // Warning when node-rpc settings are out of sync with Bitcoin conf
            _buildNodeRpcSyncWarning(context, viewModel),

            Divider(
              height: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),

            // Three-panel layout
            Expanded(
              child: _buildMainContent(theme, viewModel),
            ),

            // CLI preview
            _buildCliPreview(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(EnforcerConfigEditorViewModel viewModel) {
    return SailDropdownButton<EnforcerConfigPreset>(
      value: viewModel.currentPreset == EnforcerConfigPreset.custom ? null : viewModel.currentPreset,
      hint: 'Load a preset...',
      items: EnforcerConfigPreset.values.where((preset) => preset != EnforcerConfigPreset.custom).map((preset) {
        return SailDropdownItem<EnforcerConfigPreset>(
          value: preset,
          label: EnforcerConfigPresets.getPresetName(preset),
        );
      }).toList(),
      onChanged: (preset) {
        if (preset != null) {
          viewModel.applyPreset(preset);
        }
      },
    );
  }

  Widget _buildMainContent(SailThemeData theme, EnforcerConfigEditorViewModel viewModel) {
    if (viewModel.isLoading && viewModel.workingConfig == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SailText.primary15(
              'Error loading configuration',
            ),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(
              viewModel.errorMessage!,
            ),
            const SailSpacing(SailStyleValues.padding20),
            SailButton(
              label: 'Retry',
              onPressed: () async {
                await viewModel.loadConfig();
              },
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left panel - Changes
        Expanded(
          flex: 1,
          child: EnforcerWorkingConfigPanel(),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        // Middle panel - Saved File + Any Diff
        Expanded(
          flex: 1,
          child: EnforcerActualConfigPanel(),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        // Right panel - Configurator
        SizedBox(
          width: 350,
          child: EnforcerConfiguratorPanel(),
        ),
      ],
    );
  }

  Widget _buildNodeRpcSyncWarning(BuildContext context, EnforcerConfigEditorViewModel viewModel) {
    final theme = SailTheme.of(context);
    final enforcerConfProvider = GetIt.I.get<EnforcerConfProvider>();

    if (!enforcerConfProvider.nodeRpcDiffers) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colors.orange.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Row(
        children: [
          SailSVG.fromAsset(
            SailSVGAsset.iconWarning,
            color: theme.colors.orange,
            width: 16,
            height: 16,
          ),
          const SailSpacing(SailStyleValues.padding08),
          Expanded(
            child: SailText.secondary12(
              'Node RPC settings are out of sync with Bitcoin Core config.',
              color: theme.colors.orange,
            ),
          ),
          const SailSpacing(SailStyleValues.padding12),
          SailButton(
            label: 'Sync from Bitcoin Core',
            variant: ButtonVariant.secondary,
            onPressed: () async {
              await enforcerConfProvider.syncNodeRpcFromBitcoinConf();
              await viewModel.loadConfig();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCliPreview(BuildContext context, EnforcerConfigEditorViewModel viewModel) {
    final theme = SailTheme.of(context);
    final confProvider = GetIt.I.get<BitcoinConfProvider>();
    final enforcerConfProvider = GetIt.I.get<EnforcerConfProvider>();

    // Get CLI args from provider (includes node-rpc-* synced from Bitcoin conf)
    // Note: This shows the saved config args, not the working config preview
    final cliArgs = enforcerConfProvider.getCliArgs(confProvider.network ?? BitcoinNetwork.BITCOIN_NETWORK_SIGNET);

    // Mask the password for display
    final displayArgs = cliArgs.map((arg) {
      if (arg.startsWith('--node-rpc-pass=')) {
        return '--node-rpc-pass=****';
      }
      return arg;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        border: Border(
          top: BorderSide(color: theme.colors.divider),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12('CLI Preview:', bold: true),
          const SailSpacing(SailStyleValues.padding08),
          Expanded(
            child: SelectableText(
              displayArgs.isEmpty ? '(no args)' : 'bip300301-enforcer ${displayArgs.join(' ')}',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 12,
                color: theme.colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
