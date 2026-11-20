import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  HomepageWidgetInfo info(String id, List<WidgetSize> sizes) =>
      HomepageWidgetInfo(id: id, name: id, sizes: sizes, builder: (_) => const SizedBox());

  final catalog = {
    'quotes': info('quotes', [WidgetSize.bar]),
    'news': info('news', [WidgetSize.full, WidgetSize.half]),
    'txs': info('txs', [WidgetSize.half]),
    'blocks': info('blocks', [WidgetSize.half]),
  };
  const widgets = [
    HomepageWidgetConfig(widgetId: 'quotes'),
    HomepageWidgetConfig(widgetId: 'news', size: WidgetSize.full),
    HomepageWidgetConfig(widgetId: 'txs'),
    HomepageWidgetConfig(widgetId: 'blocks'),
  ];

  List<List<String>> layout(List<List<HomepageWidgetEntry>> rows) => [
    for (final row in rows) [for (final e in row) '${e.info.id}:${e.size.name}'],
  ];

  test('the desktop pairs two half-width widgets in a row', () {
    expect(layout(homepageRows(widgets, catalog)), [
      ['quotes:bar'],
      ['news:full'],
      ['txs:half', 'blocks:half'],
    ]);
  });

  test('one column puts each widget in its own row and builds full-width widgets at half width', () {
    expect(layout(homepageRows(widgets, catalog, oneColumn: true)), [
      ['quotes:bar'],
      ['news:half'],
      ['txs:half'],
      ['blocks:half'],
    ]);
  });

  test('one column skips a widget that is not in the catalog', () {
    expect(homepageRows(const [HomepageWidgetConfig(widgetId: 'gone')], catalog, oneColumn: true), isEmpty);
  });
}
