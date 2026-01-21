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

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search
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
        child: SailText.secondary13('No options match your search'),
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

  List<EnforcerConfigOption> _getFilteredOptions() {
    // Only show editable options
    List<EnforcerConfigOption> options = EnforcerConfigOptions.editableOptions;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      options = options.where((option) {
        return option.key.toLowerCase().contains(_searchQuery) ||
            option.description.toLowerCase().contains(_searchQuery) ||
            option.tooltip.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return options;
  }

  List<Widget> _buildOptionsWithUsefulFirst(List<EnforcerConfigOption> options) {
    final widgets = <Widget>[];

    // Split into useful and regular options
    final usefulOptions = options.where((o) => o.isUseful).toList();
    final regularOptions = options.where((o) => !o.isUseful).toList();

    // Show useful options first
    if (usefulOptions.isNotEmpty) {
      widgets.add(_buildUsefulSection(usefulOptions));
      widgets.add(const SailSpacing(SailStyleValues.padding32));
    }

    // Show regular options grouped by category
    widgets.addAll(_buildGroupedOptions(regularOptions));

    return widgets;
  }

  Widget _buildUsefulSection(List<EnforcerConfigOption> usefulOptions) {
    // Group useful options by category
    final groupedUseful = <String, List<EnforcerConfigOption>>{};
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

  List<Widget> _buildGroupedOptions(List<EnforcerConfigOption> options) {
    final groupedOptions = <String, List<EnforcerConfigOption>>{};

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

  Widget _buildCategorySection(String category, List<EnforcerConfigOption> options) {
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

  Widget _buildOptionWidget(EnforcerConfigOption option) {
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

  Widget _buildInputWidget(EnforcerConfigOption option, String? currentValue) {
    switch (option.inputType) {
      case EnforcerConfigInputType.boolean:
        return _buildBooleanInput(option, currentValue);
      case EnforcerConfigInputType.select:
        return _buildSelectInput(option, currentValue);
      case EnforcerConfigInputType.text:
      case EnforcerConfigInputType.url:
      case EnforcerConfigInputType.number:
      case EnforcerConfigInputType.path:
        return _buildTextInput(option, currentValue);
    }
  }

  Widget _buildBooleanInput(EnforcerConfigOption option, String? currentValue) {
    final boolValue = currentValue == 'true' || currentValue == '1';

    return SailToggle(
      label: option.key,
      value: boolValue,
      onChanged: (value) {
        widget.viewModel.updateSetting(option.key, value ? 'true' : 'false');
      },
    );
  }

  Widget _buildSelectInput(EnforcerConfigOption option, String? currentValue) {
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
          widget.viewModel.updateSetting(option.key, value);
        }
      },
    );
  }

  Widget _buildTextInput(EnforcerConfigOption option, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? '');

    controller.addListener(() {
      final value = controller.text;
      if (value.trim().isEmpty) {
        widget.viewModel.updateSetting(option.key, null);
      } else {
        widget.viewModel.updateSetting(option.key, value);
      }
    });

    String hintText;
    if (option.inputType == EnforcerConfigInputType.url) {
      // Show network-specific default URL hint
      final confProvider = GetIt.I.get<BitcoinConfProvider>();
      final enforcerConfProvider = GetIt.I.get<EnforcerConfProvider>();
      final defaultUrl = enforcerConfProvider.getEsploraUrlForNetwork(
        confProvider.network,
      );
      hintText = defaultUrl != null ? 'Default: $defaultUrl' : 'Enter ${option.description.toLowerCase()}';
    } else {
      hintText = option.defaultValue != null
          ? 'Default: ${option.defaultValue}'
          : 'Enter ${option.description.toLowerCase()}';
    }

    return SailTextField(
      controller: controller,
      hintText: hintText,
    );
  }
}
