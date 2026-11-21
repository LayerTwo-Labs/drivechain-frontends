import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Shows every widget of the catalog as a live preview. A pick opens [WidgetSizeDialog].
Future<void> showWidgetLibrary(BuildContext context, HomepageProvider provider) {
  final theme = SailTheme.of(context);
  final height = MediaQuery.sizeOf(context).height;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: theme.colors.background,
    constraints: BoxConstraints(maxHeight: height * 0.88, maxWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: theme.chrome.radiusLarge.topLeft),
    ),
    builder: (context) => ListenableBuilder(
      listenable: provider,
      builder: (context, _) => _WidgetLibrary(provider: provider),
    ),
  );
}

class _WidgetLibrary extends StatelessWidget {
  final HomepageProvider provider;

  const _WidgetLibrary({required this.provider});

  WidgetSize? _currentSize(HomepageWidgetInfo info) {
    for (final config in provider.widgets) {
      if (config.widgetId == info.id) {
        return info.sizeOf(config);
      }
    }
    return null;
  }

  Future<void> _pick(BuildContext context, HomepageWidgetInfo info) async {
    final size = await showThemedDialog<WidgetSize>(
      context: context,
      builder: (context) => WidgetSizeDialog(info: info, currentSize: _currentSize(info)),
    );
    if (size == null || !context.mounted) {
      return;
    }
    provider.add(info.id, size);
    Navigator.of(context).pop();
  }

  Widget _cell(BuildContext context, HomepageWidgetInfo info) {
    final onHomepage = _currentSize(info) != null;
    final canPick = !onHomepage || info.sizes.length > 1;
    return MouseRegion(
      cursor: canPick ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        key: Key('WidgetLibrary-${info.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: canPick ? () => _pick(context, info) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IgnorePointer(
              child: ExcludeFocus(
                child: Opacity(opacity: onHomepage ? 0.45 : 1, child: info.builder(info.sizes.first)),
              ),
            ),
            Positioned(
              left: -8,
              top: -8,
              child: HomepageRoundBadge(
                icon: onHomepage ? SailSVGAsset.check : SailSVGAsset.plus,
                light: onHomepage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phoneRow(BuildContext context, HomepageWidgetInfo info) {
    final theme = SailTheme.of(context);
    final onHomepage = _currentSize(info) != null;
    final canPick = !onHomepage || info.sizes.length > 1;
    final subtitle = info.subtitle;
    return GestureDetector(
      key: Key('WidgetLibrary-${info.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: canPick ? () => _pick(context, info) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding12),
        child: SailRow(
          spacing: SailStyleValues.padding12,
          children: [
            Expanded(
              child: SailColumn(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13(info.name, bold: true),
                  if (subtitle != null) SailText.secondary12(subtitle),
                ],
              ),
            ),
            SailSVG.icon(
              onHomepage ? SailSVGAsset.check : SailSVGAsset.plus,
              width: 14,
              height: 14,
              color: theme.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _phoneGroup(BuildContext context, String? title, List<HomepageWidgetInfo> infos) {
    return [
      if (title != null) SailText.primary16(title),
      SailStatList(children: [for (final info in infos) _phoneRow(context, info)]),
    ];
  }

  List<Widget> _group(BuildContext context, String? title, List<HomepageWidgetInfo> infos) {
    final rows = <Widget>[];
    HomepageWidgetInfo? waiting;
    void flush(HomepageWidgetInfo? second) {
      final first = waiting;
      if (first == null) {
        return;
      }
      rows.add(
        SailRow(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _cell(context, first)),
            Expanded(child: second == null ? const SizedBox.shrink() : _cell(context, second)),
          ],
        ),
      );
      waiting = null;
    }

    for (final info in infos) {
      if (info.sizes.first != WidgetSize.half) {
        flush(null);
        rows.add(_cell(context, info));
      } else if (waiting == null) {
        waiting = info;
      } else {
        flush(info);
      }
    }
    flush(null);

    return [
      if (title != null) SailText.primary15(title),
      ...rows,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String?, List<HomepageWidgetInfo>>{};
    for (final info in provider.catalog.values) {
      groups.putIfAbsent(info.group, () => []).add(info);
    }
    final phone = SailStyleValues.phoneLayout(context);

    return Column(
      key: const Key('WidgetLibrary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SailStyleValues.padding25,
            0,
            SailStyleValues.padding16,
            SailStyleValues.padding16,
          ),
          child: SailRow(
            children: [
              Expanded(child: SailText.primary20('Add Widget')),
              SailButton(
                variant: ButtonVariant.icon,
                icon: SailSVGAsset.x,
                small: true,
                skipLoading: true,
                onPressed: () async => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SailStyleValues.padding25,
              SailStyleValues.padding08,
              SailStyleValues.padding25,
              SailStyleValues.padding32,
            ),
            children: [
              if (phone)
                SailColumn(
                  spacing: SailStyleValues.padding08,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, entry) in groups.entries.indexed) ...[
                      if (i > 0) const SizedBox(height: SailStyleValues.padding08),
                      ..._phoneGroup(context, entry.key, entry.value),
                    ],
                  ],
                )
              else
                SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entry in groups.entries) ..._group(context, entry.key, entry.value),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shows a widget in each size it has. Pops with the size the user picks.
class WidgetSizeDialog extends StatefulWidget {
  final HomepageWidgetInfo info;

  /// The size on the homepage. Null when the widget is not on the homepage.
  final WidgetSize? currentSize;

  const WidgetSizeDialog({super.key, required this.info, this.currentSize});

  @override
  State<WidgetSizeDialog> createState() => _WidgetSizeDialogState();
}

class _WidgetSizeDialogState extends State<WidgetSizeDialog> {
  late WidgetSize _size = widget.currentSize ?? widget.info.sizes.first;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final info = widget.info;
    final preview = IgnorePointer(child: ExcludeFocus(child: info.builder(_size)));

    return Dialog(
      backgroundColor: theme.colors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SailStyleValues.padding25),
          child: SailColumn(
            key: const Key('WidgetSizeDialog'),
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SailRow(
                children: [
                  Expanded(child: SailText.primary20(info.name)),
                  SailButton(
                    variant: ButtonVariant.icon,
                    icon: SailSVGAsset.x,
                    small: true,
                    skipLoading: true,
                    onPressed: () async => Navigator.of(context).pop(),
                  ),
                ],
              ),
              if (info.sizes.length > 1)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.colors.backgroundSecondary,
                      borderRadius: theme.chrome.radius,
                    ),
                    child: SailRow(
                      children: [
                        for (final size in info.sizes)
                          SailTabItem(
                            key: Key('WidgetSize-${size.name}'),
                            label: size.label,
                            isSelected: size == _size,
                            onTap: () => setState(() => _size = size),
                          ),
                      ],
                    ),
                  ),
                ),
              if (_size == WidgetSize.half)
                LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: (constraints.maxWidth - SailStyleValues.padding16) / 2, child: preview),
                  ),
                )
              else
                preview,
              SailButton(
                key: const Key('WidgetSizeConfirm'),
                label: widget.currentSize == null ? 'Add' : 'Save',
                skipLoading: true,
                onPressed: () async => Navigator.of(context).pop(_size),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
