import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thunder/providers/thunder_conf_provider.dart';
import 'package:thunder/viewmodels/thunder_config_editor_viewmodel.dart';

@RoutePage()
class ThunderConfEditorPage extends StatelessWidget {
  const ThunderConfEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ThunderConfigEditorViewModel>.reactive(
      viewModelBuilder: () => ThunderConfigEditorViewModel(),
      onViewModelReady: (viewModel) => viewModel.loadConfig(),
      builder: (context, viewModel, child) => _buildPage(context, viewModel),
    );
  }

  Widget _buildPage(BuildContext context, ThunderConfigEditorViewModel viewModel) {
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
                    'Thunder Conf Configurator',
                    bold: true,
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: [
                      // Reset to default button
                      SailButton(
                        label: 'Reset to Default',
                        variant: ButtonVariant.secondary,
                        onPressed: () async {
                          viewModel.resetToDefault();
                        },
                      ),
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
                      'Thunder does not read from a config file. These settings are converted to CLI arguments when Thunder starts. '
                      'Restart Thunder after saving for changes to take effect.',
                      color: theme.colors.info,
                    ),
                  ),
                ],
              ),
            ),

            const SailSpacing(SailStyleValues.padding12),

            Divider(
              height: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),

            // Main content
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

  Widget _buildMainContent(SailThemeData theme, ThunderConfigEditorViewModel viewModel) {
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
        // Left panel - Editable config
        Expanded(
          flex: 1,
          child: _buildEditableConfigPanel(theme, viewModel),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        // Right panel - Settings configurator
        SizedBox(
          width: 400,
          child: _buildConfiguratorPanel(theme, viewModel),
        ),
      ],
    );
  }

  Widget _buildEditableConfigPanel(SailThemeData theme, ThunderConfigEditorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SailText.primary15('Configuration', bold: true),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: TextEditingController(text: viewModel.workingConfigText),
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 12,
                color: theme.colors.text,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: SailStyleValues.borderRadius,
                  borderSide: BorderSide(color: theme.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: SailStyleValues.borderRadius,
                  borderSide: BorderSide(color: theme.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: SailStyleValues.borderRadius,
                  borderSide: BorderSide(color: theme.colors.primary),
                ),
                filled: true,
                fillColor: theme.colors.background,
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: viewModel.updateFromRawText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfiguratorPanel(SailThemeData theme, ThunderConfigEditorViewModel viewModel) {
    final config = viewModel.workingConfig;
    if (config == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Settings', bold: true),
          const SailSpacing(SailStyleValues.padding12),

          // Network
          _buildDropdownSetting(
            theme,
            'Network',
            config.getSetting('network') ?? 'signet',
            ['signet', 'regtest'],
            (value) => viewModel.updateSetting('network', value),
          ),

          // Headless
          _buildToggleSetting(
            theme,
            'Headless Mode',
            config.getSetting('headless') == 'true',
            (value) => viewModel.updateSetting('headless', value.toString()),
          ),

          // Log Level
          _buildDropdownSetting(
            theme,
            'Log Level',
            config.getSetting('log-level') ?? 'DEBUG',
            ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR'],
            (value) => viewModel.updateSetting('log-level', value),
          ),

          // Log Level File
          _buildDropdownSetting(
            theme,
            'Log Level (File)',
            config.getSetting('log-level-file') ?? 'WARN',
            ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR'],
            (value) => viewModel.updateSetting('log-level-file', value),
          ),

          const SailSpacing(SailStyleValues.padding20),
          SailText.primary13('Network Addresses', bold: true),
          const SailSpacing(SailStyleValues.padding08),

          // RPC Address
          _buildTextSetting(
            theme,
            'RPC Address',
            config.getSetting('rpc-addr') ?? '127.0.0.1:6009',
            (value) => viewModel.updateSetting('rpc-addr', value),
          ),

          // P2P Address
          _buildTextSetting(
            theme,
            'P2P Address',
            config.getSetting('net-addr') ?? '0.0.0.0:4009',
            (value) => viewModel.updateSetting('net-addr', value),
          ),

          const SailSpacing(SailStyleValues.padding20),
          SailText.primary13('Mainchain Connection', bold: true),
          const SailSpacing(SailStyleValues.padding08),

          // Mainchain gRPC URL
          _buildTextSetting(
            theme,
            'Mainchain gRPC URL',
            config.getSetting('mainchain-grpc-url') ?? 'http://localhost:50051',
            (value) => viewModel.updateSetting('mainchain-grpc-url', value),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    SailThemeData theme,
    String label,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12(label),
          const SailSpacing(SailStyleValues.padding04),
          SailDropdownButton<String>(
            value: currentValue,
            items: options.map((opt) => SailDropdownItem<String>(value: opt, label: opt)).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    SailThemeData theme,
    String label,
    bool currentValue,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary12(label),
          Switch(
            value: currentValue,
            onChanged: onChanged,
            activeTrackColor: theme.colors.primary.withValues(alpha: 0.5),
            activeThumbColor: theme.colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTextSetting(
    SailThemeData theme,
    String label,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12(label),
          const SailSpacing(SailStyleValues.padding04),
          _TextSettingField(
            initialValue: currentValue,
            hintText: label,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCliPreview(BuildContext context, ThunderConfigEditorViewModel viewModel) {
    final theme = SailTheme.of(context);
    final confProvider = GetIt.I.get<ThunderConfProvider>();

    final cliArgs = confProvider.getCliArgs();

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
              cliArgs.isEmpty ? '(no args)' : 'thunder ${cliArgs.join(' ')}',
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

class _TextSettingField extends StatefulWidget {
  final String initialValue;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _TextSettingField({
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<_TextSettingField> createState() => _TextSettingFieldState();
}

class _TextSettingFieldState extends State<_TextSettingField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _TextSettingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.removeListener(_onTextChanged);
      _controller.text = widget.initialValue;
      _controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailTextField(
      controller: _controller,
      hintText: widget.hintText,
    );
  }
}
