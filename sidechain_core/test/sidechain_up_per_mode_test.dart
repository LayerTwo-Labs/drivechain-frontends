import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  late MockThunderRPC rpc;
  late BinaryProvider provider;
  final thunder = Thunder();

  setUp(() async {
    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = MockThunderRPC();
    GetIt.instance.registerSingleton<ThunderRPC>(rpc);
    provider = BinaryProvider.test(appDir: Directory.systemTemp, binaries: [thunder]);
  });

  void useMode(wmpb.NodeMode mode) {
    final nodeMode = NodeModeProvider();
    nodeMode.mode = mode;
    GetIt.instance.registerSingleton<NodeModeProvider>(nodeMode);
  }

  group('light mode', () {
    // A light install runs no daemon of its own, so its window is the only
    // thing it can stop.
    test('an open window is up', () {
      useMode(wmpb.NodeMode.NODE_MODE_LIGHT);
      rpc.windowOpen = true;
      expect(provider.isSidechainUp(thunder), isTrue);
    });

    test('no window is not up, whatever the daemon answers', () {
      useMode(wmpb.NodeMode.NODE_MODE_LIGHT);
      rpc.windowOpen = false;
      rpc.setConnected(true);
      expect(provider.isSidechainUp(thunder), isFalse);
    });
  });

  group('full mode', () {
    test('a daemon that answers is up', () {
      useMode(wmpb.NodeMode.NODE_MODE_FULL);
      rpc.setConnected(true);
      expect(provider.isSidechainUp(thunder), isTrue);
    });

    test('an open window alone is not up', () {
      useMode(wmpb.NodeMode.NODE_MODE_FULL);
      rpc.setConnected(false);
      rpc.windowOpen = true;
      expect(provider.isSidechainUp(thunder), isFalse);
    });
  });

  // An update stops whatever holds the files, in either mode.
  test('a window holds the files even when the daemon is down', () {
    useMode(wmpb.NodeMode.NODE_MODE_FULL);
    rpc.setConnected(false);
    rpc.windowOpen = true;
    expect(provider.holdsItsFiles(thunder), isTrue);
  });

  test('nothing running holds no files', () {
    useMode(wmpb.NodeMode.NODE_MODE_FULL);
    rpc.setConnected(false);
    rpc.windowOpen = false;
    expect(provider.holdsItsFiles(thunder), isFalse);
  });
}
