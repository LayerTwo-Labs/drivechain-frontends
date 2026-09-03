import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _TestConfProvider extends GenericSidechainConfProvider {
  @override
  String get appName => 'Test';

  @override
  String get configFileName => 'test.conf';

  @override
  String getDataDir() => '/tmp/test';

  @override
  Map<String, String> getNetworkPorts(String network) => {};

  @override
  String getDefaultConfig() => '';

  @override
  List<String> get skippedCliKeys => ['network'];
}

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger());
    }
  });

  // The CLI preview shows a command the user can copy. A daemon stops on an
  // option it does not know, so the migration marker must never reach it.
  test('getCliArgs withholds the config version', () {
    final provider = _TestConfProvider()
      ..currentConfig = GenericAppConfig.parse(
        'net-addr=0.0.0.0:4009\nconfig-version=1\nnetwork=signet\n',
        appName: 'Test',
      );

    final args = provider.getCliArgs();

    expect(args, contains('--net-addr=0.0.0.0:4009'));
    expect(args.any((a) => a.startsWith('--config-version')), isFalse);
    expect(args.any((a) => a.startsWith('--network')), isFalse);
  });
}
