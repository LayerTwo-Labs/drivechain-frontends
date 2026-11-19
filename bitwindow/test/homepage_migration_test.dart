import 'dart:convert';

import 'package:bitwindow/providers/homepage_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/store_mock.dart';

const _key = 'homepage_configuration';

String _oldShape(List<String> ids) => jsonEncode({
  'widgets': [
    for (final id in ids) {'widgetId': id, 'settings': {}},
  ],
  'lastModified': '2026-01-01T00:00:00.000',
});

List<(String, WidgetSize?)> _layout(List<HomepageWidgetConfig> widgets) => [
  for (final w in widgets) (w.widgetId, w.size),
];

void main() {
  late MockStore store;

  setUp(() {
    store = MockStore();
    final log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: store, log: log));
  });

  tearDown(() => GetIt.I.reset());

  test('a saved large news widget opens at full width, and a second start changes nothing', () async {
    await store.setString(
      _key,
      _oldShape(['quote_bar', 'coin_news_large', 'hacker_coin_news_large', 'latest_blocks']),
    );
    const expected = [
      ('quote_bar', null),
      ('coin_news', WidgetSize.full),
      ('hacker_coin_news', WidgetSize.full),
      ('latest_blocks', null),
    ];

    final first = BitwindowHomepageProvider();
    await first.loaded;
    expect(_layout(first.configuration.widgets), expected);

    final stored = HomepageConfiguration.fromJson((await store.getString(_key))!);
    expect(_layout(stored.widgets), expected);
    final rewritten = await store.getString(_key);

    final second = BitwindowHomepageProvider();
    await second.loaded;
    expect(_layout(second.configuration.widgets), expected);
    expect(await store.getString(_key), rewritten);
  });

  test('a layout with the large and the half news widget keeps one news widget', () {
    final migrated = migrateLargeNewsWidgets(
      HomepageConfiguration.fromJson(_oldShape(['coin_news', 'coin_news_large'])),
    );
    expect(_layout(migrated!.widgets), [('coin_news', null)]);
  });

  test('a layout with no large news widget needs no migration', () {
    final configuration = HomepageConfiguration.fromJson(_oldShape(['quote_bar', 'coin_news']));
    expect(migrateLargeNewsWidgets(configuration), isNull);
  });
}
