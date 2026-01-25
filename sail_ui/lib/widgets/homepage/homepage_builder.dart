import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class HomepageBuilder extends StatelessWidget {
  final HomepageConfiguration configuration;
  final Map<String, HomepageWidgetInfo> widgetCatalog;
  final bool isPreview;

  const HomepageBuilder({
    super.key,
    required this.configuration,
    required this.widgetCatalog,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    if (configuration.widgets.isEmpty) {
      return Center(
        child: SailColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: SailStyleValues.padding16,
          children: [
            Icon(
              Icons.dashboard_customize,
              size: 64,
              color: context.sailTheme.colors.textTertiary,
            ),
            SailText.primary20('No widgets configured'),
            SailText.secondary13('Add widgets to customize your homepage'),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutWidgets = <Widget>[];
        final halfWidthBuffer = <Widget>[];

        for (int i = 0; i < configuration.widgets.length; i++) {
          final widgetConfig = configuration.widgets[i];
          final widgetInfo = widgetCatalog[widgetConfig.widgetId];

          if (widgetInfo == null) {
            continue;
          }

          // Create widget from catalog
          Widget createdWidget;
          final catalogInfo = widgetCatalog[widgetConfig.widgetId];
          if (catalogInfo == null) {
            createdWidget = Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('Widget not found: ${widgetConfig.widgetId}')),
            );
          } else {
            createdWidget = catalogInfo.builder(widgetConfig.settings);
          }

          // Wrap widget if in preview mode
          Widget wrappedWidget;
          if (!isPreview) {
            wrappedWidget = createdWidget;
          } else {
            wrappedWidget = DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(7),
                      ),
                    ),
                    child: Row(
                      children: [
                        SailSVG.icon(widgetInfo.icon, width: 12),
                        const SizedBox(width: 4),
                        SailText.secondary12(widgetInfo.name),
                        const Spacer(),
                        SailText.secondary12(
                          widgetInfo.size == WidgetSize.full ? 'Full Width' : 'Half Width',
                        ),
                      ],
                    ),
                  ),
                  createdWidget,
                ],
              ),
            );
          }

          if (widgetInfo.size == WidgetSize.full) {
            // Flush any pending half-width widgets
            if (halfWidthBuffer.isNotEmpty) {
              if (halfWidthBuffer.length == 1) {
                layoutWidgets.add(halfWidthBuffer[0]);
              } else {
                layoutWidgets.add(
                  SailRow(
                    spacing: SailStyleValues.padding16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: halfWidthBuffer.map((w) => Expanded(child: w)).toList(),
                  ),
                );
              }
              halfWidthBuffer.clear();
            }
            // Add full-width widget
            layoutWidgets.add(wrappedWidget);
          } else {
            // Add to half-width buffer
            halfWidthBuffer.add(wrappedWidget);

            // If we have 2 half-width widgets, create a row
            if (halfWidthBuffer.length == 2) {
              layoutWidgets.add(
                SailRow(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: halfWidthBuffer.map((w) => Expanded(child: w)).toList(),
                ),
              );
              halfWidthBuffer.clear();
            }
          }
        }

        // Flush any remaining half-width widget
        if (halfWidthBuffer.isNotEmpty) {
          if (halfWidthBuffer.length == 1) {
            layoutWidgets.add(halfWidthBuffer[0]);
          } else {
            layoutWidgets.add(
              SailRow(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: halfWidthBuffer.map((w) => Expanded(child: w)).toList(),
              ),
            );
          }
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isPreview ? 8 : 0),
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: layoutWidgets,
          ),
        );
      },
    );
  }
}
