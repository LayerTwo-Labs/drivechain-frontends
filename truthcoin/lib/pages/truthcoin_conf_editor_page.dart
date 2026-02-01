import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/providers/truthcoin_conf_provider.dart';
import 'package:truthcoin/viewmodels/truthcoin_config_editor_viewmodel.dart';

@RoutePage()
class TruthcoinConfEditorPage extends StatelessWidget {
  const TruthcoinConfEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TruthcoinConfigEditorViewModel>.reactive(
      viewModelBuilder: () => TruthcoinConfigEditorViewModel(),
      onViewModelReady: (viewModel) => viewModel.loadConfig(),
      builder: (context, viewModel, child) => _TruthcoinConfEditorPageContent(viewModel: viewModel),
    );
  }
}

class _TruthcoinConfEditorPageContent extends StatelessWidget {
  final TruthcoinConfigEditorViewModel viewModel;

  const _TruthcoinConfEditorPageContent({required this.viewModel});

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
                    'Truthcoin Conf Configurator',
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
                      'Truthcoin does not read from a config file. These settings are converted to CLI arguments when Truthcoin starts. '
                      'Restart Truthcoin after saving for changes to take effect.',
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
              child: _MainContent(viewModel: viewModel),
            ),

            // CLI preview
            _CliPreview(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final TruthcoinConfigEditorViewModel viewModel;

  const _MainContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

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
          child: _EditableConfigPanel(viewModel: viewModel),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        // Right panel - Settings configurator
        SizedBox(
          width: 400,
          child: _ConfiguratorPanel(viewModel: viewModel),
        ),
      ],
    );
  }
}

class _EditableConfigPanel extends StatelessWidget {
  final TruthcoinConfigEditorViewModel viewModel;

  const _EditableConfigPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

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
}

class _ConfiguratorPanel extends StatelessWidget {
  final TruthcoinConfigEditorViewModel viewModel;

  const _ConfiguratorPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
          _DropdownSetting(
            label: 'Network',
            currentValue: config.getSetting('network') ?? 'signet',
            options: const ['signet', 'regtest'],
            onChanged: (value) => viewModel.updateSetting('network', value),
          ),

          // Headless
          _ToggleSetting(
            label: 'Headless Mode',
            currentValue: config.getSetting('headless') == 'true',
            onChanged: (value) => viewModel.updateSetting('headless', value.toString()),
          ),

          // Log Level
          _DropdownSetting(
            label: 'Log Level',
            currentValue: config.getSetting('log-level') ?? 'DEBUG',
            options: const ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR'],
            onChanged: (value) => viewModel.updateSetting('log-level', value),
          ),

          // Log Level File
          _DropdownSetting(
            label: 'Log Level (File)',
            currentValue: config.getSetting('log-level-file') ?? 'WARN',
            options: const ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR'],
            onChanged: (value) => viewModel.updateSetting('log-level-file', value),
          ),

          const SailSpacing(SailStyleValues.padding20),
          SailText.primary13('Network Addresses', bold: true),
          const SailSpacing(SailStyleValues.padding08),

          // RPC Address
          _TextSetting(
            label: 'RPC Address',
            currentValue: config.getSetting('rpc-addr') ?? '127.0.0.1:6013',
            onChanged: (value) => viewModel.updateSetting('rpc-addr', value),
          ),

          // P2P Address
          _TextSetting(
            label: 'P2P Address',
            currentValue: config.getSetting('net-addr') ?? '0.0.0.0:4013',
            onChanged: (value) => viewModel.updateSetting('net-addr', value),
          ),

          const SailSpacing(SailStyleValues.padding20),
          SailText.primary13('Mainchain Connection', bold: true),
          const SailSpacing(SailStyleValues.padding08),

          // Mainchain gRPC URL
          _TextSetting(
            label: 'Mainchain gRPC URL',
            currentValue: config.getSetting('mainchain-grpc-url') ?? 'http://localhost:50051',
            onChanged: (value) => viewModel.updateSetting('mainchain-grpc-url', value),
          ),
        ],
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  final String label;
  final String currentValue;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownSetting({
    required this.label,
    required this.currentValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ToggleSetting extends StatelessWidget {
  final String label;
  final bool currentValue;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.label,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

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
}

class _TextSetting extends StatelessWidget {
  final String label;
  final String currentValue;
  final ValueChanged<String> onChanged;

  const _TextSetting({
    required this.label,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _CliPreview extends StatelessWidget {
  final TruthcoinConfigEditorViewModel viewModel;

  const _CliPreview({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final confProvider = GetIt.I.get<TruthcoinConfProvider>();
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
              cliArgs.isEmpty ? '(no args)' : 'truthcoin ${cliArgs.join(' ')}',
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
