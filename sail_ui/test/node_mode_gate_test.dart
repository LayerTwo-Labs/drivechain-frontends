import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

// Every backend-dependent surface reads this one predicate. Reading the wallet
// type instead let full mode claim "ready" while Core was still syncing.
void main() {
  setUp(() => GetIt.I.registerSingleton<Logger>(Logger()));
  tearDown(() async => GetIt.I.reset());

  test('an app with no node mode runs its backends', () {
    expect(NodeModeProvider.runsLocalBackends, isTrue);
  });

  test('full mode runs local backends', () {
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_FULL);
    expect(NodeModeProvider.runsLocalBackends, isTrue);
  });

  test('light mode runs none', () {
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_LIGHT);
    expect(NodeModeProvider.runsLocalBackends, isFalse);
  });

  test('an unpicked mode runs none, because nothing boots until the user picks', () {
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider());
    expect(NodeModeProvider.runsLocalBackends, isFalse);
  });
}
