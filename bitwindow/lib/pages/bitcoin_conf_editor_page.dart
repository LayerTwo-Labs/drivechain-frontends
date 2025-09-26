import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/models/bitcoin_config.dart';
import 'package:bitwindow/providers/bitcoin_config_provider.dart';
import 'package:bitwindow/widgets/config_editor/actual_config_panel.dart';
import 'package:bitwindow/widgets/config_editor/configurator_panel.dart';
import 'package:bitwindow/widgets/config_editor/working_config_panel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class BitcoinConfEditorPage extends StatefulWidget {
  const BitcoinConfEditorPage({super.key});

  @override
  State<BitcoinConfEditorPage> createState() => _BitcoinConfEditorPageState();
}

class _BitcoinConfEditorPageState extends State<BitcoinConfEditorPage> {
  late final BitcoinConfigProvider _configProvider;

  @override
  void initState() {
    super.initState();
    _configProvider = GetIt.I.get<BitcoinConfigProvider>();
    _configProvider.addListener(_onConfigChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configProvider.loadConfig();
    });
  }

  @override
  void dispose() {
    _configProvider.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when config changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      _buildSimpleDropdown(),
                      const SailSpacing(SailStyleValues.padding12),
                      // Reset button
                      SailButton(
                        label: 'Reset',
                        variant: ButtonVariant.secondary,
                        disabled: !_configProvider.hasUnsavedChanges,
                        onPressed: () async {
                          _configProvider.resetChanges();
                        },
                      ),
                      const SailSpacing(SailStyleValues.padding12),
                      // Save button
                      SailButton(
                        label: 'Save',
                        loading: _configProvider.isLoading,
                        disabled: !_configProvider.hasUnsavedChanges,
                        onPressed: () async {
                          await _configProvider.saveConfig();
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
              child: _buildMainContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown() {
    return SailDropdownButton<ConfigPreset>(
      value: _configProvider.currentPreset == ConfigPreset.custom ? null : _configProvider.currentPreset,
      hint: 'Load a preset...',
      items: ConfigPreset.values.where((preset) => preset != ConfigPreset.custom).map((preset) {
        return SailDropdownItem<ConfigPreset>(
          value: preset,
          label: ConfigPresets.getPresetName(preset),
        );
      }).toList(),
      onChanged: (preset) {
        if (preset != null) {
          _configProvider.applyPreset(preset);
        }
      },
    );
  }

  Widget _buildMainContent(SailThemeData theme) {
    if (_configProvider.isLoading && _configProvider.workingConfig == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_configProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SailText.primary15(
              'Error loading configuration',
            ),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(
              _configProvider.errorMessage!,
            ),
            const SailSpacing(SailStyleValues.padding20),
            SailButton(
              label: 'Retry',
              onPressed: () async {
                await _configProvider.loadConfig();
              },
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left panel - Your Changes
        Expanded(
          flex: 1,
          child: WorkingConfigPanel(),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        // Middle panel - Actual File
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
