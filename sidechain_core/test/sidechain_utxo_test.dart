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

  test('a block pays a miner through a coinbase outpoint', () {
    final utxo = SidechainUTXO.fromJson({
      'outpoint': {
        'Coinbase': {'merkle_root': 'bb', 'vout': 2},
      },
      'output': {
        'address': 'mine',
        'content': {'Value': 5000},
      },
    });

    expect(utxo.type, OutpointType.coinbase);
    expect(utxo.outpoint, 'bb:2');
  });

  test('a bitnames coin reads its own value key and its pending flag', () {
    final utxo = BitnamesUTXO.fromJson({
      'outpoint': {'Deposit': 'abcd:0'},
      'output': {
        'address': 'mine',
        'content': {'BitcoinSats': 750},
        'memo': <int>[],
      },
      'confirmed': false,
    });

    expect(utxo.type, OutpointType.deposit);
    expect(utxo.outpoint, 'abcd:0');
    expect(utxo.valueSats, 750);
    expect(utxo.confirmed, isFalse);
  });

  test('a bitassets coin reads the outpoint the node writes', () {
    final utxo = BitAssetsUTXO.fromJson({
      'outpoint': {
        'Regular': {'txid': 'cc', 'vout': 3},
      },
      'output': {
        'address': 'mine',
        'content': {'BitcoinSats': 900},
        'memo': <int>[],
      },
      'confirmed': false,
    });

    expect(utxo.type, OutpointType.regular);
    expect(utxo.outpoint, 'cc:3');
    expect(utxo.valueSats, 900);
    expect(utxo.confirmed, isFalse);
  });

  // The node writes a BitAsset output content as the pair [asset id, amount].
  test('a bitassets coin keeps the asset it holds', () {
    final utxo = BitAssetsUTXO.fromJson({
      'outpoint': {
        'Regular': {'txid': 'dd', 'vout': 1},
      },
      'output': {
        'address': 'mine',
        'content': {
          'BitAsset': ['c0ffee', 500],
        },
        'memo': <int>[],
      },
    });

    expect(utxo.holding?.assetId, 'c0ffee');
    expect(utxo.holding?.amount, 500);
    expect(utxo.valueSats, 500);
  });

  test('a bitassets coin that holds bitcoin names no asset', () {
    final utxo = BitAssetsUTXO.fromJson({
      'outpoint': {
        'Regular': {'txid': 'ee', 'vout': 0},
      },
      'output': {
        'address': 'mine',
        'content': {'BitcoinSats': 900},
        'memo': <int>[],
      },
    });

    expect(utxo.holding, isNull);
    expect(utxo.valueSats, 900);
  });
}
