import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';

class _RawTruthcoin extends TruthcoinLive {
  final Object Function() answer;

  _RawTruthcoin(this.answer);

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async => answer();
}

void main() {
  setUp(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger());
    }
  });

  tearDown(() async => GetIt.I.reset());

  test('marketPriceHistory returns the node points', () async {
    final rpc = _RawTruthcoin(
      () => [
        {
          'height': 416,
          'block_hash': 'bb',
          'timestamp': 1,
          'prices': [0.635, 0.365],
        },
      ],
    );

    final points = await rpc.marketPriceHistory('m');

    expect(points!.single['height'], 416);
  });

  test(
    'marketPriceHistory answers null when the node lacks the method',
    () async {
      final rpc = _RawTruthcoin(
        () => throw ConnectException(
          Code.unknown,
          'rpc error -32601: Method not found',
        ),
      );

      expect(await rpc.marketPriceHistory('m'), isNull);
    },
  );

  test('marketPriceHistory throws any other node error', () async {
    final rpc = _RawTruthcoin(
      () => throw ConnectException(
        Code.unknown,
        'rpc error -1: Market not found',
      ),
    );

    expect(rpc.marketPriceHistory('m'), throwsA(isA<ConnectException>()));
  });
}
