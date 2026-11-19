import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;

  @override
  String? get detectedDataDir => '/qa/core';

  @override
  String? configPath = '/qa/bitwindow/bitwindow-bitcoin.conf';

  @override
  int rpcPort = 18543;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUp(() => GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf()));
  tearDown(GetIt.I.reset);

  test('bitcoin-cli reaches the node the app runs', () {
    final args = CLIConsole.wrapArgs('bitcoin-cli', ['getblockcount']);

    expect(args, [
      '-conf=/qa/bitwindow/bitwindow-bitcoin.conf',
      '-datadir=/qa/core',
      '-rpcport=18543',
      'getblockcount',
    ]);
  });

  test('other CLIs keep their args', () {
    expect(CLIConsole.wrapArgs('thunder-cli', ['balance']), ['balance']);
  });
}
