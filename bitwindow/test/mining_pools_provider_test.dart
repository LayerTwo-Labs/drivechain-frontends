import 'package:bitwindow/providers/mining_pools_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';

class _Bitwindowd extends MockBitwindowdAPI {
  int calls = 0;
  int blockCount = 144;

  @override
  Future<ListMiningPoolsResponse> listMiningPools(MiningPoolWindow window) async {
    calls++;
    return ListMiningPoolsResponse(blockCount: blockCount);
  }
}

class _API extends MockAPI {
  _API(this._bitwindowd) : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _Bitwindowd _bitwindowd;

  @override
  BitwindowAPI get bitwindowd => _bitwindowd;
}

void main() {
  late _Bitwindowd bitwindowd;
  late MiningPoolsProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    bitwindowd = _Bitwindowd();
    GetIt.I.registerSingleton<BitwindowRPC>(_API(bitwindowd)..connected = true);
    provider = MiningPoolsProvider();
  });

  tearDown(() async {
    provider.dispose();
    await GetIt.I.reset();
  });

  test('a second listener does not fetch again', () async {
    provider.addListener(() {});
    await pumpEventQueue();
    provider.addListener(() {});
    await pumpEventQueue();

    expect(bitwindowd.calls, 1);
  });

  test('a fetch with the same pools does not notify', () async {
    provider.addListener(() {});
    await pumpEventQueue();
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.fetch();
    expect(notified, 0);

    bitwindowd.blockCount = 145;
    await provider.fetch();
    expect(notified, 1);
  });
}
