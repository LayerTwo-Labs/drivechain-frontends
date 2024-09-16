import 'package:faucet_client/api/api.dart';
import 'package:faucet_client/gen/bitcoin/bitcoind/v1alpha/bitcoin.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  testWidgets('can parse transactions', (WidgetTester tester) async {
    final transactions = parseClaims(jsonRes);

    expect(transactions.length, 3);
    expect(transactions[0].amount, 1);
    expect(transactions[0].fee, 0.0000328);
    expect(transactions[0].confirmations, 16576);
    expect(transactions[0].blockHash, '779167921002679182731c2a728d3e41c3f9cb3ac03472cb516c9c6e39705e43');
    expect(transactions[0].blockIndex, 1);
    expect(transactions[0].txid, '007cd4943f49b19b3d1fbe46c46b5ed8a0f950b5291c2dbd57d9eae977f47c07');
    expect(transactions[0].time.seconds, Int64(1725370260));
    expect(transactions[0].timeReceived.seconds, Int64(1725370260));
    expect(transactions[0].bip125Replaceable, GetTransactionResponse_Replaceable.REPLACEABLE_NO);
  });
}

const jsonRes = '''
[{
    "amount": 1,
    "fee": 0.0000328,
    "confirmations": 16576,
    "block_hash": "779167921002679182731c2a728d3e41c3f9cb3ac03472cb516c9c6e39705e43",
    "block_index": 1,
    "txid": "007cd4943f49b19b3d1fbe46c46b5ed8a0f950b5291c2dbd57d9eae977f47c07",
       "block_time": {
        "seconds": 1725370260
    },
    "time": {
        "seconds": 1725370260
    },
    "time_received": {
        "seconds": 1725370260
    },
    "bip125_replaceable": 2,
    "details": [{
        "address": "bc1qp0c3wns6d7kewsh4sa3ztc2s62jd2ty69svn3f",
        "category": 1,
        "amount": -1,
        "fee": -0.0000328
    }]
}, {
    "amount": 1,
    "fee": 0.000029,
    "confirmations": 8932,
    "block_hash": "739e643d2ba61561756c18bb046e8f2d120b4cd1a0b774dc2bc105fbc30dd345",
    "block_index": 4,
    "txid": "f973e4500ffdf20d675d66465eaf2f91792f987546886fedc37279c301fbf46e",
    "time": {
        "seconds": 1725872875
    },
    "time_received": {
        "seconds": 1725872875
    },
    "bip125_replaceable": 2,
    "details": [{
        "address": "1EsMYjCpJpwsV9ctoo8Jqub1FXELmm5K1X",
        "category": 1,
        "amount": -1,
        "fee": -0.000029
    }]
}, {
    "amount": 1,
    "fee": 0.000029,
    "confirmations": 8932
}]''';
