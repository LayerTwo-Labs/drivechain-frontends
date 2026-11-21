import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sidechain_core/sidechain_core.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory root;
  late File stagedDrivechaind;

  setUp(() async {
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    root = await Directory.systemTemp.createTemp('bitwindow-qa');
    stagedDrivechaind = File(path.join(binDir(path.join(root.path, 'bitwindow')).path, Drivechaind().binary));
    await stagedDrivechaind.create(recursive: true);
  });

  tearDown(() async {
    Binary.isSidechainApp = false;
    await root.delete(recursive: true);
    await GetIt.I.reset();
  });

  test('a sidechain app in a path with bitwindow in it finds the drivechaind of BitWindow', () async {
    Binary.isSidechainApp = true;

    final resolved = await Drivechaind().resolveBinaryPath(Directory(path.join(root.path, 'thunder')));

    expect(resolved.path, stagedDrivechaind.path);
  });

  test('BitWindow does not look for its drivechaind in a sibling bitwindow dir', () async {
    final otherApp = Directory(path.join(root.path, 'other'));

    await expectLater(Drivechaind().resolveBinaryPath(otherApp), throwsException);
  });
}
