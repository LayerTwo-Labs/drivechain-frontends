import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class SailConfigureHomePage extends StatefulWidget {
  final Map<String, HomepageWidgetInfo> widgetCatalog;
  final HomepageProvider provider;
  final VoidCallback? onHomepageConfigured;
  final String? backButtonLabel;

  const SailConfigureHomePage({
    super.key,
    required this.widgetCatalog,
    required this.provider,
    this.onHomepageConfigured,
    this.backButtonLabel,
  });

  @override
  State<SailConfigureHomePage> createState() => _SailConfigureHomePageState();
}

class _SailConfigureHomePageState extends State<SailConfigureHomePage> {
  @override
  Widget build(BuildContext context) {
    return SailPage(
      widgetTitle: SailText.secondary12(widget.backButtonLabel ?? 'Back to homepage'),
      body: ViewModelBuilder<SailConfigureHomePageViewModel>.reactive(
        viewModelBuilder: () => SailConfigureHomePageViewModel(widget.provider),
        builder: (context, model, child) => QtPage(
          child: SailRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding16,
            children: [
              // Widget list with drag and drop
              Flexible(
                flex: 0,
                child: Container(
                  width: 370,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.sailTheme.colors.background,
                    border: Border.all(color: context.sailTheme.colors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailRow(
                        children: [
                          // Title and status
                          SailColumn(
                            spacing: SailStyleValues.padding04,
                            children: [
                              SailText.primary15('Make your own homepage'),
                              SailText.secondary12(
                                model.hasUnsavedChanges ? 'You have unsaved changes' : 'Drag widgets to reorder',
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          SailButton(
                            label: 'Add Widget',
                            icon: SailSVGAsset.plus,
                            onPressed: () async => _showAddWidgetDialog(context, model),
                            variant: ButtonVariant.primary,
                            skipLoading: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Current widgets list
                      SailText.primary13('Your current widgets'),
                      const SizedBox(height: 8),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 400,
                          ),
                          child: model.tempConfiguration.widgets.isEmpty
                              ? Center(
                                  child: SailColumn(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: SailStyleValues.padding08,
                                    children: [
                                      Icon(
                                        Icons.widgets_outlined,
                                        size: 48,
                                        color: context.sailTheme.colors.textTertiary,
                                      ),
                                      SailText.secondary13('No widgets added'),
                                      SailText.secondary12('Click "Add Widget" to get started'),
                                    ],
                                  ),
                                )
                              : Theme(
                                  data: Theme.of(context).copyWith(
                                    iconTheme: IconThemeData(
                                      color: context.sailTheme.colors.textSecondary,
                                    ),
                                    canvasColor: context.sailTheme.colors.backgroundSecondary,
                                    shadowColor: Colors.transparent,
                                    cardColor: context.sailTheme.colors.backgroundSecondary,
                                    scaffoldBackgroundColor: context.sailTheme.colors.backgroundSecondary,
                                  ),
                                  child: ReorderableListView.builder(
                                    buildDefaultDragHandles: true,
                                    proxyDecorator: (child, index, animation) {
                                      return Material(
                                        color: context.sailTheme.colors.backgroundSecondary,
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(8),
                                        shadowColor: Colors.black.withValues(alpha: 0.2),
                                        child: child,
                                      );
                                    },
                                    itemCount: model.tempConfiguration.widgets.length,
                                    onReorder: model.reorderWidgets,
                                    itemBuilder: (context, index) {
                                      final widgetConfig = model.tempConfiguration.widgets[index];
                                      final widgetInfo = widget.widgetCatalog[widgetConfig.widgetId];

                                      return Container(
                                        key: ValueKey(widgetConfig.widgetId + index.toString()),
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: context.sailTheme.colors.backgroundSecondary,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: context.sailTheme.colors.border),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SailSVG.icon(
                                                widgetInfo?.icon ?? SailSVGAsset.iconWarning,
                                                width: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SailText.primary13(widgetInfo?.name ?? 'Unknown Widget'),
                                                    SailText.secondary12(
                                                      widgetInfo?.size == WidgetSize.full ? 'Full Width' : 'Half Width',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SailButton(
                                                icon: SailSVGAsset.iconClose,
                                                variant: ButtonVariant.icon,
                                                onPressed: () async => model.removeWidget(index),
                                                textColor: SailColorScheme.red,
                                                small: true,
                                              ),
                                              const SizedBox(width: 32),
                                              // Drag handle will be added here automatically
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ),

                      // Save/Cancel buttons at the bottom
                      const SizedBox(height: 16),
                      Divider(color: context.sailTheme.colors.border),
                      const SizedBox(height: 16),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          Expanded(child: Container()),
                          SailButton(
                            label: 'Undo Changes',
                            onPressed: () async {
                              model.undoChanges();
                            },
                            variant: ButtonVariant.secondary,
                            disabled: !model.hasUnsavedChanges,
                          ),
                          SailButton(
                            label: 'Save Changes',
                            onPressed: () async {
                              await model.saveConfiguration();
                              if (context.mounted) {
                                showSnackBar(context, 'Homepage configuration saved!');
                                widget.onHomepageConfigured?.call();
                              }
                            },
                            variant: ButtonVariant.primary,
                            loading: model.isLoading,
                            disabled: !model.hasUnsavedChanges,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Preview area
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.sailTheme.colors.border),
                    borderRadius: SailStyleValues.borderRadius,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    child: HomepageBuilder(
                      configuration: model.tempConfiguration,
                      widgetCatalog: widget.widgetCatalog,
                      isPreview: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddWidgetDialog(BuildContext context, SailConfigureHomePageViewModel model) async {
    final allWidgets = widget.widgetCatalog.values.toList();

    // Filter out widgets that are already added
    final availableWidgets = allWidgets.where((widget) {
      return !model.tempConfiguration.widgets.any((w) => w.widgetId == widget.id);
    }).toList();

    if (availableWidgets.isEmpty) {
      showSnackBar(context, 'All available widgets have been added');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: context.sailTheme.colors.background,
        surfaceTintColor: Colors.transparent,
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.sailTheme.colors.background,
            borderRadius: SailStyleValues.borderRadius,
            border: Border.all(color: context.sailTheme.colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary20('Add Widget'),
              const SizedBox(height: 16),
              SailText.secondary13('Select a widget to add to your homepage'),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    children: availableWidgets.map((widget) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: context.sailTheme.colors.backgroundSecondary,
                          borderRadius: SailStyleValues.borderRadius,
                          border: Border.all(color: context.sailTheme.colors.border),
                        ),
                        child: ListTile(
                          tileColor: Colors.transparent,
                          leading: SailSVG.icon(widget.icon, width: 32),
                          title: SailText.primary15(widget.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.secondary12(widget.description),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.size == WidgetSize.full
                                      ? Colors.blue.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: SailStyleValues.borderRadius,
                                ),
                                child: SailText.secondary12(
                                  widget.size == WidgetSize.full ? 'Full Width' : 'Half Width',
                                ),
                              ),
                            ],
                          ),
                          trailing: SailButton(
                            label: 'Add',
                            onPressed: () async {
                              model.addWidget(widget.id);
                              Navigator.of(context).pop();
                            },
                            variant: ButtonVariant.primary,
                            small: true,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Close',
                    onPressed: () async => Navigator.of(context).pop(),
                    variant: ButtonVariant.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SailConfigureHomePageViewModel extends BaseViewModel {
  final HomepageProvider _provider;

  HomepageConfiguration get configuration => _provider.configuration;
  HomepageConfiguration get tempConfiguration => _provider.tempConfiguration;
  bool get isLoading => _provider.isLoading;
  bool get hasUnsavedChanges => _provider.hasUnsavedChanges;

  SailConfigureHomePageViewModel(this._provider) {
    _provider.addListener(notifyListeners);
  }

  Future<void> saveConfiguration() async {
    await _provider.saveConfiguration();
  }

  void addWidget(String widgetId) {
    _provider.addWidget(widgetId);
  }

  void removeWidget(int index) {
    _provider.removeWidget(index);
  }

  void reorderWidgets(int oldIndex, int newIndex) {
    _provider.reorderWidgets(oldIndex, newIndex);
  }

  void undoChanges() {
    _provider.undoChanges();
  }

  @override
  void dispose() {
    _provider.removeListener(notifyListeners);
    super.dispose();
  }
}
