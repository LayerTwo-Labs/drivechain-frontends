import 'dart:convert';

import 'package:bitwindow/providers/fast_withdrawal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sidechain_core/rpcs/thunder_rpc.dart';

class _FakeThunder implements ThunderRPC {
  @override
  bool connected = true;

  int sends = 0;

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    sends++;
    return 'l2-txid';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FastWithdrawalProvider _pendingWithdrawal() {
  return FastWithdrawalProvider()
    ..layer2Chain = 'Thunder'
    ..withdrawalHash = 'hash-1'
    ..l2Address = 'server-l2-address'
    ..l2Amount = '0.00100000'
    ..stage = FastWithdrawalStage.awaitingPayment;
}

http.Response _paidOk() => http.Response(
  jsonEncode({
    'status': 'success',
    'message': {'info': 'l1-txid'},
  }),
  200,
);

void main() {
  late _FakeThunder thunder;

  setUp(() {
    thunder = _FakeThunder();
    GetIt.I.registerSingleton<ThunderRPC>(thunder);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('a retry after a failed /paid sends the L2 coins once', () async {
    final provider = _pendingWithdrawal();
    final paidTxids = <String>[];
    final client = MockClient((request) async {
      paidTxids.add(jsonDecode(request.body)['txid'] as String);
      if (paidTxids.length == 1) {
        return http.Response(jsonEncode({'status': 'error', 'error': 'server down'}), 500);
      }
      return _paidOk();
    });

    await http.runWithClient(() async {
      await provider.sendL2AndComplete(null);
      expect(provider.stage, FastWithdrawalStage.error);
      expect(thunder.sends, 1);

      provider.retryPayment();
      await provider.sendL2AndComplete(null);
    }, () => client);

    expect(thunder.sends, 1);
    expect(paidTxids, ['l2-txid', 'l2-txid']);
    expect(provider.stage, FastWithdrawalStage.done);
    expect(provider.l1Txid, 'l1-txid');
  });

  test('an empty manual txid sends nothing', () async {
    final provider = _pendingWithdrawal();
    var httpCalls = 0;

    await http.runWithClient(() => provider.sendL2AndComplete('   '), () {
      return MockClient((request) async {
        httpCalls++;
        return _paidOk();
      });
    });

    expect(thunder.sends, 0);
    expect(httpCalls, 0);
    expect(provider.errorMessage, 'Paste the L2 txid first.');
    expect(provider.stage, FastWithdrawalStage.awaitingPayment);
  });

  test('a pasted txid completes without a send', () async {
    final provider = _pendingWithdrawal();
    final paidTxids = <String>[];

    await http.runWithClient(() => provider.sendL2AndComplete('abc'), () {
      return MockClient((request) async {
        paidTxids.add(jsonDecode(request.body)['txid'] as String);
        return _paidOk();
      });
    });

    expect(thunder.sends, 0);
    expect(paidTxids, ['abc']);
    expect(provider.stage, FastWithdrawalStage.done);
  });
}
