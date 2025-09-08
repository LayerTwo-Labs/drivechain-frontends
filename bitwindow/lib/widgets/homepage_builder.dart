import 'package:bitwindow/models/homepage_configuration.dart';
import 'package:bitwindow/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class HomepageBuilder extends StatelessWidget {
  final HomepageConfiguration configuration;
  final bool isPreview;

  const HomepageBuilder({
    super.key,
    required this.configuration,
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
        final widgets = _buildWidgetLayout(context, constraints);

        return SingleChildScrollView(
          padding: EdgeInsets.all(isPreview ? 8 : 0),
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
        );
      },
    );
  }

  List<Widget> _buildWidgetLayout(BuildContext context, BoxConstraints constraints) {
    final List<Widget> layoutWidgets = [];
    final List<Widget> halfWidthBuffer = [];

    for (int i = 0; i < configuration.widgets.length; i++) {
      final widgetConfig = configuration.widgets[i];
      final widgetInfo = HomepageWidgetCatalog.getWidget(widgetConfig.widgetId);

      if (widgetInfo == null) {
        continue;
      }

      final widget = _wrapWidget(
        HomepageWidgetCatalog.buildWidget(
          widgetConfig.widgetId,
          settings: widgetConfig.settings,
        ),
        widgetInfo,
        isPreview,
      );

      if (widgetInfo.size == WidgetSize.full) {
        // Flush any pending half-width widgets
        if (halfWidthBuffer.isNotEmpty) {
          layoutWidgets.add(_createHalfWidthRow(halfWidthBuffer, constraints));
          halfWidthBuffer.clear();
        }
        // Add full-width widget
        layoutWidgets.add(widget);
      } else {
        // Add to half-width buffer
        halfWidthBuffer.add(widget);

        // If we have 2 half-width widgets, create a row
        if (halfWidthBuffer.length == 2) {
          layoutWidgets.add(_createHalfWidthRow(halfWidthBuffer, constraints));
          halfWidthBuffer.clear();
        }
      }
    }

    // Flush any remaining half-width widget
    if (halfWidthBuffer.isNotEmpty) {
      layoutWidgets.add(_createHalfWidthRow(halfWidthBuffer, constraints));
    }

    return layoutWidgets;
  }

  Widget _createHalfWidthRow(List<Widget> widgets, BoxConstraints constraints) {
    if (widgets.length == 1) {
      // Single half-width widget takes full width
      return widgets[0];
    }

    // Two half-width widgets side by side
    return SailRow(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets.map((widget) => Expanded(child: widget)).toList(),
    );
  }

  Widget _wrapWidget(Widget widget, HomepageWidgetInfo info, bool isPreview) {
    if (!isPreview) {
      return widget;
    }

    // Add preview wrapper with info
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
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
                SailSVG.icon(info.icon, width: 12),
                const SizedBox(width: 4),
                SailText.secondary12(info.name),
                const Spacer(),
                SailText.secondary12(
                  info.size == WidgetSize.full ? 'Full Width' : 'Half Width',
                ),
              ],
            ),
          ),
          widget,
        ],
      ),
    );
  }
}
