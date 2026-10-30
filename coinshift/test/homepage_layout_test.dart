import 'dart:convert';
import 'dart:io';

import 'package:coinshift/coinshift_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

const _key = 'coinshift_homepage_configuration';

void main() {
  late Directory dir;
  late File settingsFile;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('coinshift-homepage-');
    settingsFile = File(path.join(dir.path, 'settings.json'));
    final log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(
      ClientSettings(
        store: await KeyValueStore.create(dir: dir),
        log: log,
      ),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
    await dir.delete(recursive: true);
  });

  test('the homepage provider reads, writes and reads back a saved coinshift layout', () async {
    final saved = jsonEncode({
      'widgets': [
        {'widgetId': 'balance_card', 'settings': {}},
        {'widgetId': 'quote_bar', 'settings': {}},
      ],
      'lastModified': '2026-01-01T00:00:00.000',
    });
    await settingsFile.writeAsString(jsonEncode({_key: saved}));

    final provider = SidechainHomepageProvider(CoinShiftModule());
    await provider.loaded;
    expect(provider.configuration.widgets.map((w) => w.widgetId), ['balance_card', 'quote_bar']);

    provider.addWidget('quote_bar');
    await provider.saveConfiguration();

    final stored = jsonDecode(await settingsFile.readAsString()) as Map<String, dynamic>;
    final layout = HomepageConfiguration.fromJson(stored[_key] as String);
    expect(layout.widgets.map((w) => w.widgetId), ['balance_card', 'quote_bar', 'quote_bar']);

    final reread = SidechainHomepageProvider(CoinShiftModule());
    await reread.loaded;
    expect(reread.configuration.widgets.map((w) => w.widgetId), ['balance_card', 'quote_bar', 'quote_bar']);
  });

  test('the homepage provider shows the old default layout when no layout is saved', () async {
    final provider = SidechainHomepageProvider(CoinShiftModule());
    await provider.loaded;
    expect(provider.configuration.widgets.map((w) => w.widgetId), [
      'quote_bar',
      'balance_card',
      'receive_card',
      'send_card',
      'swap_card',
      'active_swaps',
      'utxo_table',
    ]);
  });
}
