import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/viewmodels/bitcoin_config_editor_viewmodel.dart';
import 'package:bitwindow/widgets/config_editor/actual_config_panel.dart';
import 'package:bitwindow/widgets/config_editor/configurator_panel.dart';
import 'package:bitwindow/widgets/config_editor/working_config_panel.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BitcoinConfEditorPage extends StatelessWidget {
  const BitcoinConfEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BitcoinConfigEditorViewModel>.reactive(
      viewModelBuilder: () => BitcoinConfigEditorViewModel(),
      onViewModelReady: (viewModel) => viewModel.loadConfig(),
      builder: (context, viewModel, child) => _buildPage(context, viewModel),
    );
  }

  Widget _buildPage(BuildContext context, BitcoinConfigEditorViewModel viewModel) {
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
                    'Conf File Configurator',
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

            Divider(
              height: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),

            // Three-panel layout
            Expanded(
              child: _buildMainContent(theme, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(BitcoinConfigEditorViewModel viewModel) {
    return SailDropdownButton<ConfigPreset>(
      value: viewModel.currentPreset == ConfigPreset.custom ? null : viewModel.currentPreset,
      hint: 'Load a preset...',
      items: ConfigPreset.values.where((preset) => preset != ConfigPreset.custom).map((preset) {
        return SailDropdownItem<ConfigPreset>(
          value: preset,
          label: ConfigPresets.getPresetName(preset),
        );
      }).toList(),
      onChanged: (preset) {
        if (preset != null) {
          viewModel.applyPreset(preset);
        }
      },
    );
  }

  Widget _buildMainContent(SailThemeData theme, BitcoinConfigEditorViewModel viewModel) {
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
          child: WorkingConfigPanel(),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        // Middle panel - Saved File + Any Diff
        Expanded(
          flex: 1,
          child: ActualConfigPanel(),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        // Right panel - Configurator
        SizedBox(
          width: 350,
          child: ConfiguratorPanel(),
        ),
      ],
    );
  }
}
