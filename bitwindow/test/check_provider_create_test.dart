import 'package:bitwindow/providers/check_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'mocks/api_mock.dart';

final _createdAt = Timestamp(seconds: Int64(1768523696));

class _WalletAPI extends MockWalletAPI {
  @override
  Future<CreateChequeResponse> createCheque(String walletId, int expectedAmountSats) async =>
      CreateChequeResponse(id: Int64(7), derivationIndex: 7, address: 'bcrt1qcheck');

  @override
  Future<Cheque> getCheque(String walletId, int id) async => Cheque(
    id: Int64(id),
    derivationIndex: id,
    address: 'bcrt1qcheck',
    expectedAmountSats: Int64(100000),
    createdAt: _createdAt,
  );
}

class _BitwindowRPC implements BitwindowRPC {
  @override
  final WalletAPI wallet = _WalletAPI();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

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
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    GetIt.I.registerSingleton<SyncProvider>(_SyncProvider());
  });

  tearDown(() => GetIt.I.reset());

  test('a new check holds the creation time from the server', () async {
    final provider = CheckProvider();
    addTearDown(provider.dispose);

    final check = await provider.createCheck(100000);

    expect(check.createdAt, _createdAt);
    expect(provider.checks.first.createdAt, _createdAt);
  });
}
