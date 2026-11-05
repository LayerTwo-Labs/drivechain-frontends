import 'dart:convert';
import 'dart:io';

import 'package:connectrpc/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/zside/v1/zside.pb.dart' as pb;
import 'package:sidechain_core/sidechain_core.dart';

/// Answers each ZSideService call the test sets, and records the requests.
class _FakeTransport implements connect.Transport {
  final requests = <Object>[];
  final answers = <String, Object>{};

  /// JSON results of the node methods that CallRaw reaches.
  final nodeResults = <String, Object?>{};

  @override
  Future<connect.UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    I input, [
    connect.CallOptions? options,
  ]) async {
    requests.add(input);
    if (input is pb.CallRawRequest) {
      final answer = pb.CallRawResponse(resultJson: jsonEncode(nodeResults[input.method]));
      return connect.UnaryResponse(spec, connect.Headers(), answer as O, connect.Headers());
    }
    return connect.UnaryResponse(spec, connect.Headers(), answers[spec.procedure] as O, connect.Headers());
  }

  @override
  Future<connect.StreamResponse<I, O>> stream<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    Stream<I> input, [
    connect.CallOptions? options,
  ]) => throw UnimplementedError(spec.procedure);
}

void main() {
  late _FakeTransport transport;
  late ZSideLive rpc;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    transport = _FakeTransport()
      ..answers.addAll({
        '/zside.v1.ZSideService/Shield': pb.ShieldResponse(txid: 'shield-txid'),
        '/zside.v1.ZSideService/Unshield': pb.UnshieldResponse(txid: 'unshield-txid'),
      });
    rpc = ZSideLive(transport: transport);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  UnshieldedUTXO utxo(double amount) =>
      UnshieldedUTXO(txid: 'a:0', address: 'addr', amount: amount, confirmations: 1, generated: false, raw: 'a:0');

  test('the debug window lists only methods the zSide node serves', () {
    final file = File('../sidechain-orchestrator/sidechain/zside/testdata/openapi_schema.json');
    final paths = (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['paths'] as Map<String, dynamic>;
    // The schema names sidechain_wealth after its Rust function.
    final served = {...paths.keys, 'sidechain_wealth'};

    expect(served, containsAll(zsideRPCMethods));
  });

  test('shield sends the asked amount and the fee in sats', () async {
    await rpc.shield(utxo(2), 0.5);

    final request = transport.requests.single as pb.ShieldRequest;
    expect(request.amountSats.toInt(), 50000000);
    expect(request.feeSats.toInt(), btcToSatoshi(await rpc.sideEstimateFee()));
  });

  test('deshield sends the asked amount and the fee in sats', () async {
    final note = ShieldedUTXO(
      txid: 'b',
      pool: 'orchard',
      type: 'note',
      outindex: 0,
      confirmations: 1,
      spendable: true,
      address: 'z',
      amount: 2,
      amountZat: 200000000,
      memo: '',
      change: false,
      raw: 'b',
    );
    await rpc.deshield(note, 0.25);

    final request = transport.requests.single as pb.UnshieldRequest;
    expect(request.amountSats.toInt(), 25000000);
    expect(request.feeSats.toInt(), btcToSatoshi(await rpc.sideEstimateFee()));
  });

  test('the coins to shield are the confirmed wallet UTXOs, less a pending withdrawal', () async {
    transport.answers['/zside.v1.ZSideService/GetWalletUtxos'] = pb.GetWalletUtxosResponse(
      utxosJson: jsonEncode([
        {
          'outpoint': {
            'Regular': {'txid': 'ab', 'vout': 1},
          },
          'output': {
            'address': 'addr',
            'content': {'Value': 150000},
          },
        },
        {
          'outpoint': {
            'Regular': {'txid': 'ef', 'vout': 0},
          },
          'output': {
            'address': 'change-addr',
            'content': {'Value': 70000},
          },
          'confirmed': false,
        },
        {
          'outpoint': {
            'Regular': {'txid': 'cd', 'vout': 0},
          },
          'output': {
            'address': 'withdrawal-addr',
            'content': {
              'Withdrawal': {'value': 5000000, 'main_fee': 10000, 'main_address': 'bcrt1q'},
            },
          },
        },
      ]),
    );

    final coins = await rpc.listUnshieldedUTXOs();

    expect(coins.single.txid, 'ab:1');
    expect(coins.single.address, 'addr');
    expect(coins.single.amount, 0.0015);
  });

  test('a coin that a failed bundle gives back does not stop the coins to shield', () async {
    transport.answers['/zside.v1.ZSideService/GetWalletUtxos'] = pb.GetWalletUtxosResponse(
      utxosJson: jsonEncode([
        {
          'outpoint': {
            'Regular': {'txid': 'ab', 'vout': 1},
          },
          'output': {
            'address': 'addr',
            'content': {'Value': 150000},
          },
        },
        {
          'outpoint': {
            'UnsuccessfulWithdrawal': {'m6id': 'm6', 'height': 40, 'vout': 0},
          },
          'output': {
            'address': 'withdrawal-addr',
            'content': {
              'Withdrawal': {'value_sats': 5000000, 'main_fee_sats': 10000, 'main_address': 'bcrt1q'},
            },
          },
        },
      ]),
    );

    final coins = await rpc.listUnshieldedUTXOs();

    expect(coins.single.txid, 'ab:1');
  });

  test('a node with no pending withdrawal bundle answers null', () async {
    transport.answers['/zside.v1.ZSideService/GetPendingWithdrawalBundle'] = pb.GetPendingWithdrawalBundleResponse(
      bundleJson: 'null',
    );

    expect(await rpc.getPendingWithdrawalBundle(), isNull);
  });

  test('the private coins are the Orchard notes of the wallet', () async {
    transport.nodeResults['get_wallet_orchard_notes'] = [
      {'nullifier': 'n1', 'recipient': 'z-one', 'value_sats': 250000},
    ];
    transport.nodeResults['get_wallet_orchard_notes_unconfirmed'] = [
      {'nullifier': 'n2', 'recipient': 'z-two', 'value_sats': 1000},
    ];

    final notes = await rpc.listShieldedUTXOs();

    expect(notes.map((note) => note.txid), ['n1', 'n2']);
    expect(notes.first.amount, 0.0025);
    expect(notes.first.address, 'z-one');
    expect(notes.first.spendable, isTrue);
    expect(notes.last.spendable, isFalse, reason: 'an unconfirmed note cannot be spent yet');
    expect(await rpc.listPrivateTransactions(), notes);
  });

  test('a node fault in the notes reaches the caller', () async {
    transport.nodeResults['get_wallet_orchard_notes'] = 'not a list';
    await expectLater(rpc.listShieldedUTXOs(), throwsA(isA<TypeError>()));
  });

  test('the transaction history maps each wallet entry to a core transaction', () async {
    transport.answers['/zside.v1.ZSideService/ListWalletTransactions'] = pb.ListWalletTransactionsResponse(
      transactions: [
        pb.WalletTransaction(txid: 'deposit', valueSats: Int64(50000000), confirmed: true, vout: 2),
        pb.WalletTransaction(txid: 'send', valueSats: Int64(-1000), confirmed: true),
        pb.WalletTransaction(txid: 'pending', valueSats: Int64(3000)),
      ],
    );

    final txs = await rpc.listTransactions();

    expect(transport.requests.single, isA<pb.ListWalletTransactionsRequest>());
    expect(txs.map((tx) => tx.txid), ['deposit', 'send', 'pending']);
    expect(txs.map((tx) => tx.amount), [50000000, -1000, 3000]);
    expect(txs.map((tx) => tx.category), ['receive', 'send', 'receive']);
    expect(txs.map((tx) => tx.confirmations), [1, 1, 0]);
    expect(txs.first.vout, 2);
  });

  test('a confirmed entry differs from its pending form', () async {
    const procedure = '/zside.v1.ZSideService/ListWalletTransactions';
    transport.answers[procedure] = pb.ListWalletTransactionsResponse(
      transactions: [pb.WalletTransaction(txid: 'send', valueSats: Int64(-1000))],
    );
    final pending = await rpc.listTransactions();
    transport.answers[procedure] = pb.ListWalletTransactionsResponse(
      transactions: [pb.WalletTransaction(txid: 'send', valueSats: Int64(-1000), confirmed: true)],
    );
    final confirmed = await rpc.listTransactions();

    expect(pending.single, isNot(confirmed.single));
  });

  test('a shielded address is the one with the t-shld prefix', () {
    expect(isZSideShieldedAddress('t-shld1xasc5pa3u5z7azpy4ypmk786aa3sfket407slyasurfqsrkmr2m2hckls'), isTrue);
    expect(isZSideShieldedAddress('yG8idPmC9WdSBYbTBQA95ao97y6'), isFalse);
    expect(isZSideShieldedAddress('tG8idPmC9WdSBYbTBQA95ao97y6'), isFalse);
    expect(isZSideShieldedAddress(''), isFalse);
  });
}
