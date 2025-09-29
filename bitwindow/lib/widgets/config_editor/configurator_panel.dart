import 'dart:io';
import 'package:bitwindow/models/bitcoin_config_options.dart';
import 'package:bitwindow/viewmodels/bitcoin_config_editor_viewmodel.dart';
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
  final Map<String, bool> _fileSelectionLoading = {};

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
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search and filters
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

          Container(
            height: 1,
            color: theme.colors.divider,
          ),

          // Options list
          Expanded(
            child: widget.viewModel.workingConfig == null
                ? Center(
                    child: SailText.secondary13('No config loaded'),
                  )
                : _buildOptionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    final filteredOptions = _getFilteredOptions();

    if (filteredOptions.isEmpty) {
      return Center(
        child: SailText.secondary13('No options match your filters'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildOptionsWithUsefulFirst(filteredOptions),
      ),
    );
  }

  List<BitcoinConfigOption> _getFilteredOptions() {
    List<BitcoinConfigOption> options = BitcoinConfigOptions.allOptions;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      options = options.where((option) {
        return option.key.toLowerCase().contains(_searchQuery) ||
            option.description.toLowerCase().contains(_searchQuery) ||
            option.tooltip.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      options = options.where((option) => option.category == _selectedCategory).toList();
    }

    // Filter by useful only
    if (_showOnlyUseful) {
      options = options.where((option) => option.isUseful).toList();
    }

    return options;
  }

  List<Widget> _buildOptionsWithUsefulFirst(List<BitcoinConfigOption> options) {
    final widgets = <Widget>[];

    // Split into useful and regular options
    final usefulOptions = options.where((o) => o.isUseful).toList();
    final regularOptions = options.where((o) => !o.isUseful).toList();

    // Show useful options first if any exist and not filtering by useful only
    if (usefulOptions.isNotEmpty && !_showOnlyUseful) {
      widgets.add(_buildUsefulSection(usefulOptions));
      widgets.add(const SailSpacing(SailStyleValues.padding32));
    }

    // Show regular options grouped by category
    if (!_showOnlyUseful) {
      widgets.addAll(_buildGroupedOptions(regularOptions));
    } else {
      widgets.addAll(_buildGroupedOptions(usefulOptions));
    }

    return widgets;
  }

  Widget _buildUsefulSection(List<BitcoinConfigOption> usefulOptions) {
    // Group useful options by category
    final groupedUseful = <String, List<BitcoinConfigOption>>{};
    for (final option in usefulOptions) {
      groupedUseful.putIfAbsent(option.category, () => []).add(option);
    }

    final widgets = <Widget>[];
    widgets.add(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SailTheme.of(context).colors.orange.withValues(alpha: 0.1),
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(color: SailTheme.of(context).colors.orange.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...groupedUseful.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary20(entry.key, bold: true, color: SailTheme.of(context).colors.orange),
                  const SailSpacing(SailStyleValues.padding08),
                  ...entry.value.map((option) => _buildOptionWidget(option)),
                  const SailSpacing(SailStyleValues.padding12),
                ],
              );
            }),
          ],
        ),
      ),
    );

    return Column(children: widgets);
  }

  List<Widget> _buildGroupedOptions(List<BitcoinConfigOption> options) {
    final groupedOptions = <String, List<BitcoinConfigOption>>{};

    for (final option in options) {
      groupedOptions.putIfAbsent(option.category, () => []).add(option);
    }

    final widgets = <Widget>[];

    for (final category in groupedOptions.keys.toList()..sort()) {
      final categoryOptions = groupedOptions[category]!;
      categoryOptions.sort((a, b) => a.key.compareTo(b.key));

      widgets.add(_buildCategorySection(category, categoryOptions));
      widgets.add(const SailSpacing(SailStyleValues.padding32));
    }

    return widgets;
  }

  Widget _buildCategorySection(String category, List<BitcoinConfigOption> options) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: SailTheme.of(context).colors.background,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: SailTheme.of(context).colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: SailTheme.of(context).colors.primary.withValues(alpha: 0.1),
              borderRadius: SailStyleValues.borderRadiusSmall,
            ),
            child: SailText.primary15(category, bold: true, color: SailTheme.of(context).colors.primary),
          ),
          const SailSpacing(SailStyleValues.padding20),
          ...options.map((option) => _buildOptionWidget(option)),
        ],
      ),
    );
  }

  Widget _buildOptionWidget(BitcoinConfigOption option) {
    final currentValue = widget.viewModel.workingConfig!.getSetting(option.key);

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
          _buildInputWidget(option, currentValue),
        ],
      ),
    );
  }

  Widget _buildInputWidget(BitcoinConfigOption option, String? currentValue) {
    switch (option.inputType) {
      case ConfigInputType.dropdown:
        return _buildDropdownInput(option, currentValue);
      case ConfigInputType.boolean:
        return _buildBooleanInput(option, currentValue);
      case ConfigInputType.number:
        return _buildNumberInput(option, currentValue);
      case ConfigInputType.bitcoinAmount:
        return _buildBitcoinAmountInput(option, currentValue);
      case ConfigInputType.text:
      case ConfigInputType.command:
      case ConfigInputType.ipAddress:
      case ConfigInputType.network:
        return _buildTextInput(option, currentValue);
      case ConfigInputType.file:
      case ConfigInputType.directory:
        return _buildFileInput(option, currentValue);
    }
  }

  Widget _buildDropdownInput(BitcoinConfigOption option, String? currentValue) {
    return SailDropdownButton<String>(
      value: option.dropdownValues!.contains(currentValue) ? currentValue : null,
      hint: 'Select ${option.description}',
      items: option.dropdownValues!.map((value) {
        return SailDropdownItem<String>(
          value: value,
          label: value,
        );
      }).toList(),
      onChanged: (value) {
        widget.viewModel.updateSetting(option.key, value);
      },
    );
  }

  Widget _buildBooleanInput(BitcoinConfigOption option, String? currentValue) {
    final boolValue = currentValue == '1' || currentValue == 'true';

    return SailToggle(
      label: option.key,
      value: boolValue,
      onChanged: (value) {
        widget.viewModel.updateSetting(option.key, value ? '1' : '0');
      },
    );
  }

  Widget _buildNumberInput(BitcoinConfigOption option, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? '');

    controller.addListener(() {
      final value = controller.text;
      if (value.trim().isEmpty) {
        widget.viewModel.updateSetting(option.key, null);
      } else {
        widget.viewModel.updateSetting(option.key, value);
      }
    });

    return SailTextField(
      controller: controller,
      hintText: option.defaultValue != null
          ? 'Default: ${_formatNumber(option.defaultValue.toString())}${option.unit != null ? ' ${option.unit}' : ''}'
          : 'Enter ${option.description.toLowerCase()}${option.unit != null ? ' (${option.unit})' : ''}',
      suffix: option.unit,
    );
  }

  Widget _buildBitcoinAmountInput(BitcoinConfigOption option, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? '');

    controller.addListener(() {
      final value = controller.text;
      if (value.trim().isEmpty) {
        widget.viewModel.updateSetting(option.key, null);
      } else {
        widget.viewModel.updateSetting(option.key, value);
      }
    });

    return SailTextField(
      controller: controller,
      hintText: option.defaultValue != null
          ? 'Default: ${_formatBitcoinAmount(option.defaultValue.toString())}${option.unit != null ? ' ${option.unit}' : ''}'
          : 'Enter ${option.description.toLowerCase()}${option.unit != null ? ' (${option.unit})' : ''}',
      suffix: option.unit,
    );
  }

  Widget _buildTextInput(BitcoinConfigOption option, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? '');

    controller.addListener(() {
      final value = controller.text;
      if (value.trim().isEmpty) {
        widget.viewModel.updateSetting(option.key, null);
      } else {
        widget.viewModel.updateSetting(option.key, value);
      }
    });

    return SailTextField(
      controller: controller,
      hintText: option.defaultValue != null
          ? 'Default: ${option.defaultValue}'
          : 'Enter ${option.description.toLowerCase()}',
    );
  }

  Widget _buildFileInput(BitcoinConfigOption option, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? '');
    final isLoading = _fileSelectionLoading[option.key] ?? false;

    controller.addListener(() {
      final value = controller.text;
      if (value.trim().isEmpty) {
        widget.viewModel.updateSetting(option.key, null);
      } else {
        widget.viewModel.updateSetting(option.key, value);
      }
    });

    return Row(
      children: [
        Expanded(
          child: SailTextField(
            controller: controller,
            hintText: option.defaultValue != null
                ? 'Default: ${option.defaultValue}'
                : 'Enter ${option.description.toLowerCase()} path',
          ),
        ),
        const SailSpacing(SailStyleValues.padding08),
        SailButton(
          label: 'Browse',
          variant: ButtonVariant.outline,
          small: true,
          loading: isLoading,
          onPressed: () async => await _selectPath(option, controller),
        ),
      ],
    );
  }

  Future<void> _selectPath(BitcoinConfigOption option, TextEditingController controller) async {
    setState(() {
      _fileSelectionLoading[option.key] = true;
    });

    try {
      String? result;

      if (option.inputType == ConfigInputType.directory) {
        result = await FilePicker.platform.getDirectoryPath(
          initialDirectory: controller.text.isNotEmpty ? controller.text : null,
        );
      } else {
        final fileResult = await FilePicker.platform.pickFiles(
          initialDirectory: controller.text.isNotEmpty ? path.dirname(controller.text) : null,
          type: FileType.any,
        );
        result = fileResult?.files.single.path;
      }

      if (result != null) {
        // For directories, validate that it's writable
        if (option.inputType == ConfigInputType.directory) {
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

        controller.text = result;
        widget.viewModel.updateSetting(option.key, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error selecting ${option.inputType == ConfigInputType.directory ? 'directory' : 'file'}: $e',
            ),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _fileSelectionLoading[option.key] = false;
        });
      }
    }
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return value;

    final number = int.tryParse(value);
    if (number == null) return value;

    // Use thousand separators for large numbers
    return formatWithThousandSpacers(number);
  }

  String _formatBitcoinAmount(String value) {
    if (value.isEmpty) return value;

    final number = double.tryParse(value);
    if (number == null) return value;

    // Handle scientific notation by converting to fixed decimal
    if (value.contains('e') || value.contains('E')) {
      // Format with enough precision to avoid scientific notation
      return number.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    return value;
  }
}
