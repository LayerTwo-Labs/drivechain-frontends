import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

const _badgeOverhang = 8.0;

/// The homepage widgets. In edit mode the user drags, removes and adds widgets.
class HomepageView extends StatefulWidget {
  final HomepageProvider provider;

  const HomepageView({super.key, required this.provider});

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  final _keys = <String, GlobalKey>{};

  GlobalKey _keyFor(String widgetId) => _keys.putIfAbsent(widgetId, GlobalKey.new);

  Future<void> _done() async {
    try {
      await widget.provider.finishEdit();
    } catch (e) {
      if (mounted) {
        showSailToast(context, 'Could not save the homepage: $e', variant: SailToastVariant.destructive);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final provider = widget.provider;
        final editing = provider.editing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRect(
                clipper: _OutsetClipper(editing ? _badgeOverhang : 0),
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in homepageRows(
                        provider.widgets,
                        provider.catalog,
                        oneColumn: SailStyleValues.phoneLayout(context),
                      ))
                        _row(row, editing),
                      if (!editing)
                        Center(
                          child: SailButton(
                            key: const Key('HomepageEdit'),
                            label: 'Edit homepage',
                            variant: ButtonVariant.outline,
                            small: true,
                            skipLoading: true,
                            disabled: !provider.ready,
                            onPressed: () async => provider.startEdit(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (editing)
              _EditBar(
                saving: provider.saving,
                onAdd: () => showWidgetLibrary(context, provider),
                onDone: _done,
              ),
          ],
        );
      },
    );
  }

  Widget _row(List<HomepageWidgetEntry> row, bool editing) {
    Widget cell(HomepageWidgetEntry entry) {
      final child = entry.info.builder(entry.size);
      if (!editing) {
        return KeyedSubtree(key: ValueKey('HomepageWidget-${entry.info.id}'), child: child);
      }
      return _EditableWidget(
        key: _keyFor(entry.info.id),
        widgetId: entry.info.id,
        provider: widget.provider,
        child: child,
      );
    }

    if (row.length == 1) {
      return cell(row.single);
    }
    return SailRow(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final entry in row) Expanded(child: cell(entry))],
    );
  }
}

class HomepageWidgetEntry {
  final HomepageWidgetInfo info;
  final WidgetSize size;

  const HomepageWidgetEntry(this.info, this.size);
}

/// Two half-width widgets share a row. A bar or a full-width widget takes a row alone.
/// With [oneColumn], every widget takes a row alone, and a full-width widget builds at half width.
List<List<HomepageWidgetEntry>> homepageRows(
  List<HomepageWidgetConfig> widgets,
  Map<String, HomepageWidgetInfo> catalog, {
  bool oneColumn = false,
}) {
  if (oneColumn) {
    return [
      for (final config in widgets)
        if (catalog[config.widgetId] case final info?)
          [HomepageWidgetEntry(info, info.sizeOf(config) == WidgetSize.full ? WidgetSize.half : info.sizeOf(config))],
    ];
  }
  final rows = <List<HomepageWidgetEntry>>[];
  List<HomepageWidgetEntry>? pair;
  for (final config in widgets) {
    final info = catalog[config.widgetId];
    if (info == null) {
      continue;
    }
    final entry = HomepageWidgetEntry(info, info.sizeOf(config));
    if (entry.size != WidgetSize.half) {
      if (pair != null) {
        rows.add(pair);
      }
      pair = null;
      rows.add([entry]);
      continue;
    }
    if (pair == null) {
      pair = [entry];
    } else {
      rows.add([...pair, entry]);
      pair = null;
    }
  }
  if (pair != null) {
    rows.add(pair);
  }
  return rows;
}

class _EditableWidget extends StatelessWidget {
  final String widgetId;
  final HomepageProvider provider;
  final Widget child;

  const _EditableWidget({super.key, required this.widgetId, required this.provider, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final radius = theme.chrome.radius;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        provider.moveTo(details.data, widgetId);
        return details.data != widgetId;
      },
      builder: (context, _, _) => LayoutBuilder(
        builder: (context, constraints) => Draggable<String>(
          key: Key('HomepageDrag-$widgetId'),
          data: widgetId,
          hitTestBehavior: HitTestBehavior.opaque,
          feedback: SizedBox(
            width: constraints.maxWidth,
            child: Transform.scale(
              scale: 1.04,
              child: Material(
                type: MaterialType.transparency,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: SailColorScheme.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: IgnorePointer(child: child),
                ),
              ),
            ),
          ),
          childWhenDragging: Stack(
            children: [
              Opacity(opacity: 0, child: IgnorePointer(child: child)),
              Positioned.fill(
                child: DecoratedBox(
                  key: const Key('HomepageDropPlace'),
                  decoration: BoxDecoration(color: theme.colors.backgroundSecondary, borderRadius: radius),
                ),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                foregroundPainter: _DashedOutline(color: theme.colors.textTertiary, radius: radius),
                child: IgnorePointer(child: child),
              ),
              Positioned(
                left: -_badgeOverhang,
                top: -_badgeOverhang,
                child: HomepageRoundBadge(
                  key: Key('HomepageRemove-$widgetId'),
                  icon: SailSVGAsset.minus,
                  onTap: () => provider.remove(widgetId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The round badge on the corner of a widget: remove in edit mode, add or added in the library.
class HomepageRoundBadge extends StatelessWidget {
  final SailSVGAsset icon;
  final VoidCallback? onTap;
  final bool light;

  const HomepageRoundBadge({super.key, required this.icon, this.onTap, this.light = false});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final badge = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: light ? colors.backgroundSecondary : colors.text,
      ),
      child: SailSVG.icon(icon, width: 14, height: 14, color: light ? colors.text : colors.background),
    );
    if (onTap == null) {
      return badge;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: badge),
    );
  }
}

class _EditBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onAdd;
  final Future<void> Function() onDone;

  const _EditBar({required this.saving, required this.onAdd, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return Container(
      key: const Key('HomepageEditBar'),
      margin: const EdgeInsets.only(top: SailStyleValues.padding12),
      padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SailRow(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: SailStyleValues.padding08,
        children: [
          SailButton(
            key: const Key('HomepageAddWidget'),
            label: 'Add Widget',
            variant: ButtonVariant.secondary,
            skipLoading: true,
            disabled: saving,
            onPressed: () async => onAdd(),
          ),
          SailButton(
            key: const Key('HomepageDone'),
            label: 'Done',
            loading: saving,
            onPressed: onDone,
          ),
        ],
      ),
    );
  }
}

/// Clips to the child's box grown by [outset] on the top, left and right.
class _OutsetClipper extends CustomClipper<Rect> {
  final double outset;

  const _OutsetClipper(this.outset);

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-outset, -outset, size.width + outset, size.height);

  @override
  bool shouldReclip(_OutsetClipper old) => old.outset != outset;
}

class _DashedOutline extends CustomPainter {
  final Color color;
  final BorderRadius radius;

  const _DashedOutline({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()..addRRect(radius.toRRect(Offset.zero & size).deflate(0.5));
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutline old) => old.color != color || old.radius != radius;
}
