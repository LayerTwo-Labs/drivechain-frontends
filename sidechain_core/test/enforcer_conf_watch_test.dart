import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  setUp(() => GetIt.I.registerSingleton<Logger>(Logger(level: Level.off)));
  tearDown(() => GetIt.I.reset());

  test('a watch frame notifies once per change', () {
    final conf = EnforcerConfProvider.empty();
    var notifies = 0;
    conf.addListener(() => notifies++);

    final frame = WatchEnforcerConfigResponse(
      config: GetEnforcerConfigResponse(configContent: 'log-level=info', configPath: '/tmp/e.conf'),
    );
    conf.applyWatchFrame(frame);
    conf.applyWatchFrame(frame.deepCopy());
    conf.applyWatchFrame(WatchEnforcerConfigResponse(heartbeat: true));
    expect(notifies, 1);
    expect(conf.configPath, '/tmp/e.conf');

    conf.applyWatchFrame(
      WatchEnforcerConfigResponse(config: GetEnforcerConfigResponse(configContent: 'log-level=trace')),
    );
    expect(notifies, 2);
    expect(conf.getCurrentConfigContent(), contains('trace'));
  });
}
