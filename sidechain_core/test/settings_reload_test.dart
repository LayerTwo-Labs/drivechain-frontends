import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _Store implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> update(String key, String Function(String? current) change) async {
    await setString(key, change(await getString(key)));
  }
}

void main() {
  setUp(() {
    final log = Logger(level: Level.off);
    final store = _Store();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: store, log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: store, log: log));
  });

  tearDown(GetIt.I.reset);

  test('reload reads a setting that another window changed', () async {
    final spare = await SettingsProvider.create();
    final main = await SettingsProvider.create();
    expect(spare.bitcoinUnit, BitcoinUnit.btc);

    await main.updateBitcoinUnit(BitcoinUnit.sats);
    await spare.reload();

    expect(spare.bitcoinUnit, BitcoinUnit.sats);
  });
}
