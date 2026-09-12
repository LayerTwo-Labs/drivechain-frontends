import 'dart:async';

import 'package:bitnames/pages/tabs/reserve_register_page.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'mocks/storage_mock.dart';

final _digest = 'a' * 64;

/// Holds one read open, so a test can edit an address field while the read
/// runs.
class _SlowBitnamesRPC extends MockBitnamesRPC {
  final Completer<ReadCommitmentResult> reply = Completer<ReadCommitmentResult>();
  final List<String> registered = [];
  String? readAddress;

  @override
  Future<ReadCommitmentResult> readCommitment(String address) {
    readAddress = address;
    return reply.future;
  }

  @override
  Future<String> registerBitName(String plainName, BitNameData? data) {
    registered.add('${data?.socketAddrHost}|${data?.commitment}');
    return Future.value('txid');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late _SlowBitnamesRPC rpc;
  late BalanceProvider balances;

  setUp(() async {
    await GetIt.I.reset();
    rpc = _SlowBitnamesRPC();
    final sidechainRPC = MockSidechainRPC();
    final log = Logger();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    GetIt.I.registerSingleton<SidechainRPC>(sidechainRPC);
    GetIt.I.registerSingleton<BitnamesRPC>(rpc);
    GetIt.I.registerSingleton<BitnamesProvider>(BitnamesProvider());
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
    balances = BalanceProvider(connections: [sidechainRPC]);
    balances.setBalance(sidechainRPC, 1.0, 0.0);
    GetIt.I.registerSingleton<BalanceProvider>(balances);
  });

  test('a read drops a digest the user makes stale', () async {
    final model = BitnamesViewModel();
    model.websiteController.text = 'psztorc.com';

    final read = model.readCommitmentFromServer();
    expect(rpc.readAddress, 'psztorc.com:6002');

    model.websiteController.text = 'other.com';
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{}', commitment: _digest));
    await read;

    expect(model.commitmentAddress, isNull);
    expect(model.commitmentController.text, isEmpty);
    expect(model.commitmentData, isNull);
    expect(model.readLoading, isFalse);
  });

  test('a read keeps a digest the user leaves alone', () async {
    final model = BitnamesViewModel();
    model.websiteController.text = 'psztorc.com';

    final read = model.readCommitmentFromServer();
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{"email":"a@b.c"}', commitment: _digest));
    await read;

    expect(model.commitmentAddress, 'psztorc.com:6002');
    expect(model.commitmentController.text, _digest);
  });

  testWidgets('register refuses a send the read no longer covers', (tester) async {
    final model = BitnamesViewModel();
    model.registerNameController.text = 'satoshi';
    model.websiteController.text = 'psztorc.com';

    await tester.pumpWidget(const SizedBox.shrink());
    final register = model.registerBitname(tester.element(find.byType(SizedBox)));
    expect(rpc.readAddress, 'psztorc.com:6002');

    model.websiteController.text = 'other.com';
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{}', commitment: _digest));
    await register;

    expect(rpc.registered, isEmpty);
    expect(model.registerError, contains('address changed'));
  });

  testWidgets('register sends the digest of the address it holds', (tester) async {
    final model = BitnamesViewModel();
    model.registerNameController.text = 'satoshi';
    model.websiteController.text = 'psztorc.com';

    await tester.pumpWidget(const SizedBox.shrink());
    final register = model.registerBitname(tester.element(find.byType(SizedBox)));
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{}', commitment: _digest));
    await register;

    expect(rpc.registered, ['psztorc.com:6002|$_digest']);
  });
}
