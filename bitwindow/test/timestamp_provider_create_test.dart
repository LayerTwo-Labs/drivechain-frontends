import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';

final _confirmed = FileTimestamp(
  id: Int64(1),
  filename: 'proof.txt',
  fileHash: 'hash',
  txid: 'txid',
  status: 'confirmed',
  blockHeight: Int64(102),
  confirmations: 3,
);

class _MiscAPI extends MockMiscAPI {
  @override
  Future<TimestampFileResponse> timestampFile(String filename, List<int> fileData) async =>
      TimestampFileResponse(id: Int64(1), fileHash: 'hash', txid: 'txid');

  @override
  Future<List<FileTimestamp>> listTimestamps() async => [_confirmed];
}

class _BitwindowRPC extends ChangeNotifier implements BitwindowRPC {
  @override
  final MiscAPI misc = _MiscAPI();

  @override
  bool get connected => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SyncProvider extends ChangeNotifier implements SyncProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<BitwindowRPC>(_BitwindowRPC());
    GetIt.I.registerSingleton<SyncProvider>(_SyncProvider());
  });

  tearDown(() => GetIt.I.reset());

  test('a timestamp of a confirmed file shows the stored row', () async {
    final provider = TimestampProvider();
    addTearDown(provider.dispose);
    await provider.fetch();

    final timestamp = await provider.timestampFile('proof.txt', [1, 2, 3]);

    expect(timestamp?.status, 'confirmed');
    expect(timestamp?.confirmations, 3);
    expect(provider.timestamps, hasLength(1));
  });
}
