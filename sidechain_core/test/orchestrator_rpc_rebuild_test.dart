import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pbenum.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger());
    }
  });

  // BMMProvider captures OrchestratorRPC.bmm once and holds it for the life of
  // the app. A rebuild that swapped the wrapper left that copy pointed at a
  // pool nobody could reach, and closing the pool broke it for good.
  test('a captured client still reaches the daemon after a rebuild', () async {
    var requests = 0;
    final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    server.listen((req) {
      requests++;
      req.response.statusCode = 500;
      req.response.close();
    });
    addTearDown(() => server.close(force: true));

    final rpc = OrchestratorRPC(host: '127.0.0.1', port: server.port);
    final captured = rpc.bmm;

    await expectLater(captured.stop(BinaryType.BINARY_TYPE_THUNDER), throwsA(isA<Object>()));
    expect(requests, 1);

    rpc.recreateConnection();

    expect(identical(captured, rpc.bmm), isTrue, reason: 'a rebuild must not swap the wrapper');
    await expectLater(captured.stop(BinaryType.BINARY_TYPE_THUNDER), throwsA(isA<Object>()));
    expect(requests, 2, reason: 'the captured client must reach the daemon through the new pool');
  });

  test('the wallet client derives index zero without a new address', () async {
    final requests = <DeriveAddressesRequest>[];
    final paths = <String>[];
    final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      paths.add(request.uri.path);
      final bytes = await request.fold<List<int>>([], (bytes, part) => bytes..addAll(part));
      requests.add(DeriveAddressesRequest.fromBuffer(bytes));
      request.response.headers.contentType = io.ContentType('application', 'proto');
      request.response.add(DeriveAddressesResponse(addresses: ['first-wallet-address']).writeToBuffer());
      await request.response.close();
    });
    final rpc = OrchestratorRPC(host: '127.0.0.1', port: server.port);

    final result = await rpc.wallet.deriveAddresses(walletId: 'active-wallet', startIndex: 0, count: 1);

    expect(paths, ['/walletmanager.v1.WalletManagerService/DeriveAddresses']);
    expect(requests, hasLength(1));
    expect(requests.single.walletId, 'active-wallet');
    expect(requests.single.startIndex, 0);
    expect(requests.single.count, 1);
    expect(result.addresses, ['first-wallet-address']);
  });

  const warning = 'This transaction burns Alphanet coins for a claim of real ECX. You cannot reverse this transaction.';
  final messages = {'backend text': warning, 'no warning': '', 'long warning': List.filled(4, warning).join(' ')};
  for (final message in messages.entries) {
    test('the wallet client keeps the decode warning: ${message.key}', () async {
      final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        await request.drain<void>();
        request.response.headers.contentType = io.ContentType('application', 'proto');
        request.response.add(DecodeTransactionResponse(warningMessage: message.value).writeToBuffer());
        await request.response.close();
      });
      final rpc = OrchestratorRPC(host: '127.0.0.1', port: server.port);

      final result = await rpc.wallet.decodeTransaction(input: 'psbt', walletId: 'wallet-1');

      expect(result.details.warningMessage, message.value);
    });

    test('the wallet client keeps the details warning: ${message.key}', () async {
      final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        await request.drain<void>();
        request.response.headers.contentType = io.ContentType('application', 'proto');
        request.response.add(
          GetTransactionDetailsResponse(transaction: TransactionEntry(warningMessage: message.value)).writeToBuffer(),
        );
        await request.response.close();
      });
      final rpc = OrchestratorRPC(host: '127.0.0.1', port: server.port);

      final result = await rpc.wallet.getTransactionDetails(txid: 'aa' * 32, walletId: 'wallet-1');

      expect(result.warningMessage, message.value);
    });
  }
}
