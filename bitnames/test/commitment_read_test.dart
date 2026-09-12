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
    registered.add('${data?.socketAddrV4}|${data?.commitment}');
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

  test('a lookup fills the two address fields the chain holds', () async {
    final model = BitnamesViewModel();
    model.websiteController.text = 'psztorc.com';

    final read = model.readCommitmentFromServer();
    expect(rpc.readAddress, 'psztorc.com:6002');
    rpc.reply.complete(
      ReadCommitmentResult(
        dataJson: '{}',
        commitment: _digest,
        socketAddrV4: '203.0.113.7:6002',
        socketAddrV6: '[2606:4700::1111]:6002',
      ),
    );
    await read;

    expect(model.ipv4Controller.text, '203.0.113.7:6002');
    expect(model.ipv6Controller.text, '[2606:4700::1111]:6002');
    expect(model.commitmentController.text, _digest);
  });

  test('a typed address reads without a domain', () async {
    final model = BitnamesViewModel();
    model.ipv4Controller.text = '203.0.113.7:6002';

    final read = model.readCommitmentFromServer();
    expect(rpc.readAddress, '203.0.113.7:6002');
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{}', commitment: _digest));
    await read;

    expect(model.commitmentController.text, _digest);
  });

  test('a second lookup clears a family the new server does not serve', () async {
    final model = BitnamesViewModel();
    model.ipv4Controller.text = '198.51.100.9:6002';
    model.websiteController.text = 'psztorc.com';

    final read = model.readCommitmentFromServer();
    rpc.reply.complete(
      ReadCommitmentResult(
        dataJson: '{}',
        commitment: _digest,
        socketAddrV6: '[2606:4700::1111]:6002',
      ),
    );
    await read;

    // The old ipv4 belongs to a server the user left behind.
    expect(model.ipv4Controller.text, isEmpty);
    expect(model.ipv6Controller.text, '[2606:4700::1111]:6002');
  });

  // The chain holds the address fields, so an edit to either one leaves the
  // digest describing a server the registration never names.
  test('an edit to a resolved address drops the digest', () async {
    final model = BitnamesViewModel();
    model.websiteController.text = 'psztorc.com';

    final read = model.readCommitmentFromServer();
    rpc.reply.complete(
      ReadCommitmentResult(dataJson: '{}', commitment: _digest, socketAddrV4: '203.0.113.7:6002'),
    );
    await read;
    expect(model.commitmentController.text, _digest);

    // The domain box still holds psztorc.com, so only the ipv4 field changed.
    model.ipv4Controller.text = '198.51.100.9:6002';
    expect(model.commitmentController.text, isEmpty);
    expect(model.commitmentAddress, isNull);
  });

  test('a read drops a digest the user makes stale', () async {
    final model = BitnamesViewModel();
    model.websiteController.text = 'psztorc.com';

    final read = model.readCommitmentFromServer();
    expect(rpc.readAddress, 'psztorc.com:6002');

    model.websiteController.text = 'other.com';
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{}', commitment: _digest, socketAddrV4: '203.0.113.7:6002'));
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
    rpc.reply.complete(
      ReadCommitmentResult(dataJson: '{"email":"a@b.c"}', commitment: _digest, socketAddrV4: '203.0.113.7:6002'),
    );
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
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{}', commitment: _digest, socketAddrV4: '203.0.113.7:6002'));
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
    rpc.reply.complete(ReadCommitmentResult(dataJson: '{}', commitment: _digest, socketAddrV4: '203.0.113.7:6002'));
    await register;

    expect(rpc.registered, ['203.0.113.7:6002|$_digest']);
  });
}
