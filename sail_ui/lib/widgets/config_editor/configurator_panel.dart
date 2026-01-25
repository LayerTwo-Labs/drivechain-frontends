import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ConfiguratorPanel extends ViewModelWidget<BitcoinConfigEditorViewModel> {
  const ConfiguratorPanel({super.key});

  @override
  Widget build(BuildContext context, BitcoinConfigEditorViewModel viewModel) {
    return _ConfiguratorPanelContent(viewModel: viewModel);
  }
}

class _ConfiguratorPanelContent extends StatefulWidget {
  final BitcoinConfigEditorViewModel viewModel;

  const _ConfiguratorPanelContent({required this.viewModel});

  @override
  State<_ConfiguratorPanelContent> createState() => _ConfiguratorPanelContentState();
}

class _ConfiguratorPanelContentState extends State<_ConfiguratorPanelContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  final bool _showOnlyUseful = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onConfigChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onConfigChanged);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.toLowerCase());
  }

  static const _networkSpecificKeys = {'datadir', 'port', 'rpcport', 'rpcbind', 'bind'};

  String? _getSectionForOption(BitcoinConfigOption option) {
    if (_networkSpecificKeys.contains(option.key)) {
      return (widget.viewModel.confProvider.network).toCoreNetwork();
    }
    return null;
  }

  List<BitcoinConfigOption> _getFilteredOptions() {
    List<BitcoinConfigOption> options = BitcoinConfigOptions.allOptions;

    if (_searchQuery.isNotEmpty) {
      options = options.where((option) {
        return option.key.toLowerCase().contains(_searchQuery) ||
            option.description.toLowerCase().contains(_searchQuery) ||
            option.tooltip.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (_selectedCategory != null) {
      options = options.where((option) => option.category == _selectedCategory).toList();
    }

    if (_showOnlyUseful) {
      options = options.where((option) => option.isUseful).toList();
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final filteredOptions = _getFilteredOptions();

    return Container(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.5),
            child: SailTextField(
              controller: _searchController,
              hintText: 'Search config options',
              prefixIcon: SailPadding(
                padding: EdgeInsets.only(left: 8),
                child: SailSVG.fromAsset(
                  SailSVGAsset.search,
                  height: 13,
                  width: 13,
                  color: theme.colors.textSecondary,
                ),
              ),
              prefixIconConstraints: BoxConstraints(maxWidth: 21, maxHeight: 13),
            ),
          ),
          Container(height: 1, color: theme.colors.divider),
          Expanded(
            child: widget.viewModel.workingConfig == null
                ? Center(child: SailText.secondary13('No config loaded'))
                : filteredOptions.isEmpty
                ? Center(child: SailText.secondary13('No options match your filters'))
                : _OptionsList(
                    options: filteredOptions,
                    viewModel: widget.viewModel,
                    showOnlyUseful: _showOnlyUseful,
                    getSectionForOption: _getSectionForOption,
                  ),
          ),
        ],
      ),
    );
  }
}

class _OptionsList extends StatelessWidget {
  final List<BitcoinConfigOption> options;
  final BitcoinConfigEditorViewModel viewModel;
  final bool showOnlyUseful;
  final String? Function(BitcoinConfigOption) getSectionForOption;

  const _OptionsList({
    required this.options,
    required this.viewModel,
    required this.showOnlyUseful,
    required this.getSectionForOption,
  });

  @override
  Widget build(BuildContext context) {
    final usefulOptions = options.where((o) => o.isUseful).toList();
    final regularOptions = options.where((o) => !o.isUseful).toList();

    final groupedRegular = <String, List<BitcoinConfigOption>>{};
    final optionsToGroup = showOnlyUseful ? usefulOptions : regularOptions;
    for (final option in optionsToGroup) {
      groupedRegular.putIfAbsent(option.category, () => []).add(option);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (usefulOptions.isNotEmpty && !showOnlyUseful) ...[
            _UsefulSection(
              options: usefulOptions,
              viewModel: viewModel,
              getSectionForOption: getSectionForOption,
            ),
            const SailSpacing(SailStyleValues.padding32),
          ],
          for (final category in groupedRegular.keys.toList()..sort()) ...[
            _CategorySection(
              category: category,
              options: groupedRegular[category]!..sort((a, b) => a.key.compareTo(b.key)),
              viewModel: viewModel,
              getSectionForOption: getSectionForOption,
            ),
            const SailSpacing(SailStyleValues.padding32),
          ],
        ],
      ),
    );
  }
}

class _UsefulSection extends StatelessWidget {
  final List<BitcoinConfigOption> options;
  final BitcoinConfigEditorViewModel viewModel;
  final String? Function(BitcoinConfigOption) getSectionForOption;

  const _UsefulSection({
    required this.options,
    required this.viewModel,
    required this.getSectionForOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final groupedUseful = <String, List<BitcoinConfigOption>>{};
    for (final option in options) {
      groupedUseful.putIfAbsent(option.category, () => []).add(option);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.orange.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in groupedUseful.entries) ...[
            SailText.primary20(entry.key, bold: true, color: theme.colors.orange),
            const SailSpacing(SailStyleValues.padding08),
            for (final option in entry.value)
              _OptionWidget(
                option: option,
                viewModel: viewModel,
                getSectionForOption: getSectionForOption,
              ),
            const SailSpacing(SailStyleValues.padding12),
          ],
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<BitcoinConfigOption> options;
  final BitcoinConfigEditorViewModel viewModel;
  final String? Function(BitcoinConfigOption) getSectionForOption;

  const _CategorySection({
    required this.category,
    required this.options,
    required this.viewModel,
    required this.getSectionForOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              borderRadius: SailStyleValues.borderRadiusSmall,
            ),
            child: SailText.primary15(category, bold: true, color: theme.colors.primary),
          ),
          const SailSpacing(SailStyleValues.padding20),
          for (final option in options)
            _OptionWidget(
              option: option,
              viewModel: viewModel,
              getSectionForOption: getSectionForOption,
            ),
        ],
      ),
    );
  }
}

class _OptionWidget extends StatelessWidget {
  final BitcoinConfigOption option;
  final BitcoinConfigEditorViewModel viewModel;
  final String? Function(BitcoinConfigOption) getSectionForOption;

  const _OptionWidget({
    required this.option,
    required this.viewModel,
    required this.getSectionForOption,
  });

  @override
  Widget build(BuildContext context) {
    final section = getSectionForOption(option);
    final currentValue = section != null
        ? viewModel.workingConfig!.getEffectiveSetting(option.key, section)
        : viewModel.workingConfig!.getSetting(option.key);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: option.tooltip,
            child: SailText.primary15(option.description, bold: true),
          ),
          const SailSpacing(SailStyleValues.padding08),
          _InputWidget(
            option: option,
            currentValue: currentValue,
            viewModel: viewModel,
            getSectionForOption: getSectionForOption,
          ),
        ],
      ),
    );
  }
}

class _InputWidget extends StatelessWidget {
  final BitcoinConfigOption option;
  final String? currentValue;
  final BitcoinConfigEditorViewModel viewModel;
  final String? Function(BitcoinConfigOption) getSectionForOption;

  const _InputWidget({
    required this.option,
    required this.currentValue,
    required this.viewModel,
    required this.getSectionForOption,
  });

  void _updateSetting(dynamic value) {
    viewModel.updateSetting(option.key, value, section: getSectionForOption(option));
  }

  @override
  Widget build(BuildContext context) {
    switch (option.inputType) {
      case ConfigInputType.dropdown:
        return _DropdownInput(option: option, currentValue: currentValue, onChanged: _updateSetting);
      case ConfigInputType.boolean:
        return _BooleanInput(option: option, currentValue: currentValue, onChanged: _updateSetting);
      case ConfigInputType.number:
        return _NumberInput(option: option, currentValue: currentValue, onChanged: _updateSetting);
      case ConfigInputType.bitcoinAmount:
        return _BitcoinAmountInput(option: option, currentValue: currentValue, onChanged: _updateSetting);
      case ConfigInputType.text:
      case ConfigInputType.command:
      case ConfigInputType.ipAddress:
      case ConfigInputType.network:
        return _TextInput(option: option, currentValue: currentValue, onChanged: _updateSetting);
      case ConfigInputType.file:
      case ConfigInputType.directory:
        return _FileInput(option: option, currentValue: currentValue, onChanged: _updateSetting);
    }
  }
}

class _DropdownInput extends StatelessWidget {
  final BitcoinConfigOption option;
  final String? currentValue;
  final void Function(dynamic) onChanged;

  const _DropdownInput({required this.option, required this.currentValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SailDropdownButton<String>(
      value: option.dropdownValues!.contains(currentValue) ? currentValue : null,
      hint: 'Select ${option.description}',
      items: option.dropdownValues!.map((value) {
        return SailDropdownItem<String>(value: value, label: value);
      }).toList(),
      onChanged: (value) => onChanged(value),
    );
  }
}

class _BooleanInput extends StatelessWidget {
  final BitcoinConfigOption option;
  final String? currentValue;
  final void Function(dynamic) onChanged;

  const _BooleanInput({required this.option, required this.currentValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final boolValue = currentValue == '1' || currentValue == 'true';

    return SailToggle(
      label: option.key,
      value: boolValue,
      onChanged: (value) => onChanged(value ? '1' : '0'),
    );
  }
}

class _NumberInput extends StatefulWidget {
  final BitcoinConfigOption option;
  final String? currentValue;
  final void Function(dynamic) onChanged;

  const _NumberInput({required this.option, required this.currentValue, required this.onChanged});

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final value = _controller.text;
    widget.onChanged(value.trim().isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    final defaultStr = widget.option.defaultValue?.toString();
    final formattedDefault = defaultStr != null ? formatWithThousandSpacers(int.tryParse(defaultStr) ?? 0) : null;

    return SailTextField(
      controller: _controller,
      hintText: formattedDefault != null
          ? 'Default: $formattedDefault${widget.option.unit != null ? ' ${widget.option.unit}' : ''}'
          : 'Enter ${widget.option.description.toLowerCase()}${widget.option.unit != null ? ' (${widget.option.unit})' : ''}',
      suffix: widget.option.unit,
    );
  }
}

class _BitcoinAmountInput extends StatefulWidget {
  final BitcoinConfigOption option;
  final String? currentValue;
  final void Function(dynamic) onChanged;

  const _BitcoinAmountInput({required this.option, required this.currentValue, required this.onChanged});

  @override
  State<_BitcoinAmountInput> createState() => _BitcoinAmountInputState();
}

class _BitcoinAmountInputState extends State<_BitcoinAmountInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final value = _controller.text;
    widget.onChanged(value.trim().isEmpty ? null : value);
  }

  String _formatBitcoinAmount(String value) {
    if (value.isEmpty) return value;
    final number = double.tryParse(value);
    if (number == null) return value;
    if (value.contains('e') || value.contains('E')) {
      return number.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final defaultStr = widget.option.defaultValue?.toString();
    final formattedDefault = defaultStr != null ? _formatBitcoinAmount(defaultStr) : null;

    return SailTextField(
      controller: _controller,
      hintText: formattedDefault != null
          ? 'Default: $formattedDefault${widget.option.unit != null ? ' ${widget.option.unit}' : ''}'
          : 'Enter ${widget.option.description.toLowerCase()}${widget.option.unit != null ? ' (${widget.option.unit})' : ''}',
      suffix: widget.option.unit,
    );
  }
}

class _TextInput extends StatefulWidget {
  final BitcoinConfigOption option;
  final String? currentValue;
  final void Function(dynamic) onChanged;

  const _TextInput({required this.option, required this.currentValue, required this.onChanged});

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final value = _controller.text;
    widget.onChanged(value.trim().isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    return SailTextField(
      controller: _controller,
      hintText: widget.option.defaultValue != null
          ? 'Default: ${widget.option.defaultValue}'
          : 'Enter ${widget.option.description.toLowerCase()}',
    );
  }
}

class _FileInput extends StatefulWidget {
  final BitcoinConfigOption option;
  final String? currentValue;
  final void Function(dynamic) onChanged;

  const _FileInput({required this.option, required this.currentValue, required this.onChanged});

  @override
  State<_FileInput> createState() => _FileInputState();
}

class _FileInputState extends State<_FileInput> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final value = _controller.text;
    widget.onChanged(value.trim().isEmpty ? null : value);
  }

  Future<void> _selectPath() async {
    setState(() => _isLoading = true);

    try {
      String? result;

      if (widget.option.inputType == ConfigInputType.directory) {
        result = await FilePicker.platform.getDirectoryPath(
          initialDirectory: _controller.text.isNotEmpty ? _controller.text : null,
        );
      } else {
        final fileResult = await FilePicker.platform.pickFiles(
          initialDirectory: _controller.text.isNotEmpty ? path.dirname(_controller.text) : null,
          type: FileType.any,
        );
        result = fileResult?.files.single.path;
      }

      if (result != null) {
        if (widget.option.inputType == ConfigInputType.directory) {
          final testFile = File(path.join(result, '.bitwindow_test'));
          try {
            await testFile.writeAsString('test');
            await testFile.delete();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected directory is not writable: $e'),
                  backgroundColor: SailTheme.of(context).colors.error,
                ),
              );
            }
            return;
          }
        }

        _controller.text = result;
        widget.onChanged(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error selecting ${widget.option.inputType == ConfigInputType.directory ? 'directory' : 'file'}: $e',
            ),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SailTextField(
            controller: _controller,
            hintText: widget.option.defaultValue != null
                ? 'Default: ${widget.option.defaultValue}'
                : 'Enter ${widget.option.description.toLowerCase()} path',
          ),
        ),
        const SailSpacing(SailStyleValues.padding08),
        SailButton(
          label: 'Browse',
          variant: ButtonVariant.outline,
          small: true,
          loading: _isLoading,
          onPressed: _selectPath,
        ),
      ],
    );
  }
}
