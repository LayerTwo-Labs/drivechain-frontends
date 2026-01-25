import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class EnforcerConfiguratorPanel extends ViewModelWidget<EnforcerConfigEditorViewModel> {
  const EnforcerConfiguratorPanel({super.key});

  @override
  Widget build(BuildContext context, EnforcerConfigEditorViewModel viewModel) {
    return _EnforcerConfiguratorPanelContent(viewModel: viewModel);
  }
}

class _EnforcerConfiguratorPanelContent extends StatefulWidget {
  final EnforcerConfigEditorViewModel viewModel;

  const _EnforcerConfiguratorPanelContent({required this.viewModel});

  @override
  State<_EnforcerConfiguratorPanelContent> createState() => _EnforcerConfiguratorPanelContentState();
}

class _EnforcerConfiguratorPanelContentState extends State<_EnforcerConfiguratorPanelContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  List<EnforcerConfigOption> _getFilteredOptions() {
    List<EnforcerConfigOption> options = EnforcerConfigOptions.editableOptions;

    if (_searchQuery.isNotEmpty) {
      options = options.where((option) {
        return option.key.toLowerCase().contains(_searchQuery) ||
            option.description.toLowerCase().contains(_searchQuery) ||
            option.tooltip.toLowerCase().contains(_searchQuery);
      }).toList();
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
          Container(
            height: 1,
            color: theme.colors.divider,
          ),
          Expanded(
            child: widget.viewModel.workingConfig == null
                ? Center(child: SailText.secondary13('No config loaded'))
                : filteredOptions.isEmpty
                ? Center(child: SailText.secondary13('No options match your search'))
                : _OptionsList(
                    options: filteredOptions,
                    viewModel: widget.viewModel,
                  ),
          ),
        ],
      ),
    );
  }
}

class _OptionsList extends StatelessWidget {
  final List<EnforcerConfigOption> options;
  final EnforcerConfigEditorViewModel viewModel;

  const _OptionsList({required this.options, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final usefulOptions = options.where((o) => o.isUseful).toList();
    final regularOptions = options.where((o) => !o.isUseful).toList();

    final groupedRegular = <String, List<EnforcerConfigOption>>{};
    for (final option in regularOptions) {
      groupedRegular.putIfAbsent(option.category, () => []).add(option);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (usefulOptions.isNotEmpty) ...[
            _UsefulSection(options: usefulOptions, viewModel: viewModel),
            const SailSpacing(SailStyleValues.padding32),
          ],
          for (final category in groupedRegular.keys.toList()..sort()) ...[
            _CategorySection(
              category: category,
              options: groupedRegular[category]!..sort((a, b) => a.key.compareTo(b.key)),
              viewModel: viewModel,
            ),
            const SailSpacing(SailStyleValues.padding32),
          ],
        ],
      ),
    );
  }
}

class _UsefulSection extends StatelessWidget {
  final List<EnforcerConfigOption> options;
  final EnforcerConfigEditorViewModel viewModel;

  const _UsefulSection({required this.options, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final groupedUseful = <String, List<EnforcerConfigOption>>{};
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
            for (final option in entry.value) _OptionWidget(option: option, viewModel: viewModel),
            const SailSpacing(SailStyleValues.padding12),
          ],
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<EnforcerConfigOption> options;
  final EnforcerConfigEditorViewModel viewModel;

  const _CategorySection({
    required this.category,
    required this.options,
    required this.viewModel,
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
          for (final option in options) _OptionWidget(option: option, viewModel: viewModel),
        ],
      ),
    );
  }
}

class _OptionWidget extends StatelessWidget {
  final EnforcerConfigOption option;
  final EnforcerConfigEditorViewModel viewModel;

  const _OptionWidget({required this.option, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final currentValue = viewModel.workingConfig!.getSetting(option.key);

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
          _InputWidget(option: option, currentValue: currentValue, viewModel: viewModel),
        ],
      ),
    );
  }
}

class _InputWidget extends StatelessWidget {
  final EnforcerConfigOption option;
  final String? currentValue;
  final EnforcerConfigEditorViewModel viewModel;

  const _InputWidget({
    required this.option,
    required this.currentValue,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    switch (option.inputType) {
      case EnforcerConfigInputType.boolean:
        return _BooleanInput(option: option, currentValue: currentValue, viewModel: viewModel);
      case EnforcerConfigInputType.select:
        return _SelectInput(option: option, currentValue: currentValue, viewModel: viewModel);
      case EnforcerConfigInputType.text:
      case EnforcerConfigInputType.url:
      case EnforcerConfigInputType.number:
      case EnforcerConfigInputType.path:
        return _TextInput(option: option, currentValue: currentValue, viewModel: viewModel);
    }
  }
}

class _BooleanInput extends StatelessWidget {
  final EnforcerConfigOption option;
  final String? currentValue;
  final EnforcerConfigEditorViewModel viewModel;

  const _BooleanInput({
    required this.option,
    required this.currentValue,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final boolValue = currentValue == 'true' || currentValue == '1';

    return SailToggle(
      label: option.key,
      value: boolValue,
      onChanged: (value) {
        viewModel.updateSetting(option.key, value ? 'true' : 'false');
      },
    );
  }
}

class _SelectInput extends StatelessWidget {
  final EnforcerConfigOption option;
  final String? currentValue;
  final EnforcerConfigEditorViewModel viewModel;

  const _SelectInput({
    required this.option,
    required this.currentValue,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final options = option.selectOptions ?? [];
    final effectiveValue = currentValue ?? option.defaultValue?.toString();

    return SailDropdownButton<String>(
      value: effectiveValue,
      items: options
          .map(
            (opt) => SailDropdownItem<String>(
              value: opt,
              label: opt,
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          viewModel.updateSetting(option.key, value);
        }
      },
    );
  }
}

class _TextInput extends StatefulWidget {
  final EnforcerConfigOption option;
  final String? currentValue;
  final EnforcerConfigEditorViewModel viewModel;

  const _TextInput({
    required this.option,
    required this.currentValue,
    required this.viewModel,
  });

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
    if (value.trim().isEmpty) {
      widget.viewModel.updateSetting(widget.option.key, null);
    } else {
      widget.viewModel.updateSetting(widget.option.key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    String hintText;
    if (widget.option.inputType == EnforcerConfigInputType.url) {
      final confProvider = GetIt.I.get<BitcoinConfProvider>();
      final enforcerConfProvider = GetIt.I.get<EnforcerConfProvider>();
      final defaultUrl = enforcerConfProvider.getEsploraUrlForNetwork(confProvider.network);
      hintText = defaultUrl != null ? 'Default: $defaultUrl' : 'Enter ${widget.option.description.toLowerCase()}';
    } else {
      hintText = widget.option.defaultValue != null
          ? 'Default: ${widget.option.defaultValue}'
          : 'Enter ${widget.option.description.toLowerCase()}';
    }

    return SailTextField(
      controller: _controller,
      hintText: hintText,
    );
  }
}
