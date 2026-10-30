import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/sidechain_conf_editor_viewmodel.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainConfEditorPage extends StatelessWidget {
  const SidechainConfEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SidechainConfEditorViewModel>.reactive(
      viewModelBuilder: () => SidechainConfEditorViewModel(),
      onViewModelReady: (viewModel) => viewModel.loadConfig(),
      builder: (context, viewModel, child) => _SidechainConfEditorPageContent(viewModel: viewModel),
    );
  }
}

class _SidechainConfEditorPageContent extends StatelessWidget {
  final SidechainConfEditorViewModel viewModel;

  const _SidechainConfEditorPageContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final appName = viewModel.module.appName;

    return SailPage(
      widgetTitle: SailText.secondary12('Back to settings'),
      body: QtPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SailText.primary24(
                    '$appName Conf Configurator',
                    bold: true,
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: [
                      SailButton(
                        label: 'Reset to Default',
                        variant: ButtonVariant.secondary,
                        onPressed: () async {
                          viewModel.resetToDefault();
                        },
                      ),
                      const SailSpacing(SailStyleValues.padding12),
                      SailButton(
                        label: 'Reset',
                        variant: ButtonVariant.secondary,
                        disabled: !viewModel.hasUnsavedChanges,
                        onPressed: () async {
                          viewModel.resetChanges();
                        },
                      ),
                      const SailSpacing(SailStyleValues.padding12),
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
                      '$appName does not read from a config file. These settings are converted to CLI arguments when $appName starts. '
                      'Restart $appName after saving for changes to take effect.',
                      color: theme.colors.info,
                    ),
                  ),
                ],
              ),
            ),

            const SailSpacing(SailStyleValues.padding12),

            SailSeparator(
              thickness: 1,
              color: theme.colors.divider,
            ),

            Expanded(
              child: _MainContent(viewModel: viewModel),
            ),

            _CliPreview(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final SidechainConfEditorViewModel viewModel;

  const _MainContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (viewModel.isLoading && viewModel.workingConfig == null) {
      return const Center(
        child: LoadingIndicator(),
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
        Expanded(
          flex: 1,
          child: _EditableConfigPanel(viewModel: viewModel),
        ),

        Container(
          width: 1,
          color: theme.colors.divider,
        ),

        SizedBox(
          width: 400,
          child: _ConfiguratorPanel(viewModel: viewModel),
        ),
      ],
    );
  }
}

class _EditableConfigPanel extends StatelessWidget {
  final SidechainConfEditorViewModel viewModel;

  const _EditableConfigPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
            child: SailTextField(
              controller: TextEditingController(text: viewModel.workingConfigText),
              hintText: '',
              expands: true,
              monospace: true,
              onChanged: viewModel.updateFromRawText,
            ),
          ),
        ),
      ],
    );
  }
}

const _endpointLabels = {
  'rpc-addr': 'RPC Address',
  'rpc-host': 'RPC Host',
  'rpc-port': 'RPC Port',
  'net-addr': 'P2P Address',
  'zmq-addr': 'ZMQ Address',
  'mainchain-grpc-url': 'Mainchain gRPC URL',
  'mainchain-grpc-host': 'Mainchain gRPC Host',
  'mainchain-grpc-port': 'Mainchain gRPC Port',
};

class _ConfiguratorPanel extends StatelessWidget {
  final SidechainConfEditorViewModel viewModel;

  const _ConfiguratorPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final config = viewModel.workingConfig;
    if (config == null) {
      return const SizedBox.shrink();
    }
    final module = viewModel.module;
    final defaults = GenericAppConfig.parse(module.defaultConf('signet'), appName: module.fullName);
    final endpointKeys = defaults.settings.keys.where(_endpointLabels.containsKey).toList();
    final addressKeys = endpointKeys.where((key) => !key.startsWith('mainchain-')).toList();
    final mainchainKeys = endpointKeys.where((key) => key.startsWith('mainchain-')).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Settings', bold: true),
          const SailSpacing(SailStyleValues.padding12),

          // The mainchain owns the network, so this row only reports it.
          _DerivedSetting(
            label: 'Network',
            value: GetIt.I.get<GenericSidechainConfProvider>().network,
          ),

          _ToggleSetting(
            label: 'Headless Mode',
            currentValue: config.getSetting('headless') == 'true',
            onChanged: (value) => viewModel.updateSetting('headless', value.toString()),
          ),

          _DropdownSetting(
            label: 'Log Level',
            currentValue: config.getSetting('log-level') ?? 'DEBUG',
            options: const ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR'],
            onChanged: (value) => viewModel.updateSetting('log-level', value),
          ),

          if (defaults.hasSetting('log-level-file'))
            _DropdownSetting(
              label: 'Log Level (File)',
              currentValue: config.getSetting('log-level-file') ?? 'WARN',
              options: const ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR'],
              onChanged: (value) => viewModel.updateSetting('log-level-file', value),
            ),

          const SailSpacing(SailStyleValues.padding20),
          SailText.primary13('Network Addresses', bold: true),
          const SailSpacing(SailStyleValues.padding08),

          for (final key in addressKeys)
            _TextSetting(
              label: _endpointLabels[key]!,
              currentValue: config.getSetting(key) ?? defaults.getSetting(key)!,
              onChanged: (value) => viewModel.updateSetting(key, value),
            ),

          const SailSpacing(SailStyleValues.padding20),
          SailText.primary13('Mainchain Connection', bold: true),
          const SailSpacing(SailStyleValues.padding08),

          for (final key in mainchainKeys)
            _TextSetting(
              label: _endpointLabels[key]!,
              currentValue: config.getSetting(key) ?? defaults.getSetting(key)!,
              onChanged: (value) => viewModel.updateSetting(key, value),
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
              if (value != null) {
                onChanged(value);
              }
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary12(label),
          SailSwitch(
            value: currentValue,
            onChanged: onChanged,
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
  final SidechainConfEditorViewModel viewModel;

  const _CliPreview({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final confProvider = GetIt.I.get<GenericSidechainConfProvider>();
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
            child: SailSelectableText(
              cliArgs.isEmpty ? '(no args)' : '${viewModel.module.chain.registryKey} ${cliArgs.join(' ')}',
              monospace: true,
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

class _DerivedSetting extends StatelessWidget {
  final String label;
  final String value;

  const _DerivedSetting({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12(label),
          const SailSpacing(SailStyleValues.padding04),
          SailText.primary13(value),
        ],
      ),
    );
  }
}
