import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  const outpoint = {
    'Regular': {'txid': 'aa', 'vout': 1},
  };

  test('a coin the node lists reads as confirmed', () {
    final utxo = SidechainUTXO.fromJson({
      'outpoint': outpoint,
      'output': {
        'address': 'mine',
        'content': {'Value': 2000},
      },
    });

    expect(utxo.confirmed, isTrue, reason: 'a node lists only mined coins');
    expect(utxo.outpoint, 'aa:1');
    expect(utxo.valueSats, 2000);
    expect(utxo.type, OutpointType.regular);
  });

  test('a coin the mempool holds reads as unconfirmed', () {
    final utxo = SidechainUTXO.fromJson({
      'outpoint': outpoint,
      'output': {
        'address': 'mine',
        'content': {'Value': 10000},
      },
      'confirmed': false,
    });

    expect(utxo.confirmed, isFalse);
    expect(utxo.valueSats, 10000);
  });

  test('a deposit keeps its own outpoint form', () {
    final utxo = SidechainUTXO.fromJson({
      'outpoint': {'Deposit': 'abcd:0'},
      'output': {
        'address': 'mine',
        'content': {'Value': 500},
      },
    });

    expect(utxo.type, OutpointType.deposit);
    expect(utxo.outpoint, 'abcd:0');
  });
}
