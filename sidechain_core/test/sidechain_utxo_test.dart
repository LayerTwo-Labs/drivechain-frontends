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

  test('only a BitName coin names an owned BitName', () {
    BitnamesUTXO coin(Map<String, dynamic> content) => BitnamesUTXO.fromJson({
      'outpoint': outpoint,
      'output': {'address': 'mine', 'content': content},
    });
    final owned = coin({'BitName': 'a' * 64});

    expect(owned.type, OutpointType.bitname);
    expect(owned.bitNameHash, 'a' * 64);
    expect(
      ownedBitNames([
        owned,
        coin({'BitNameReservation': 'b' * 64}),
        coin({'BitcoinSats': 10}),
        SidechainUTXO.fromJson({
          'outpoint': outpoint,
          'output': {
            'address': 'mine',
            'content': {'Value': 10},
          },
        }),
      ]),
      {'a' * 64},
    );
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

  test('a bitasset coin reads the asset hash and the amount', () {
    final utxo = BitAssetsUTXO.fromJson({
      'outpoint': outpoint,
      'output': {
        'address': 'mine',
        'content': {
          'BitAsset': ['e6' * 32, 7000000],
        },
        'memo': '',
      },
    });

    expect(utxo.type, OutpointType.bitAsset);
    expect(utxo.bitAsset?.hash, 'e6' * 32);
    expect(utxo.bitAsset?.amount, 7000000);
    expect(utxo.valueSats, 7000000);
  });

  test('a control coin names the asset it owns', () {
    final utxo = BitAssetsUTXO.fromJson({
      'outpoint': outpoint,
      'output': {
        'address': 'mine',
        'content': {'BitAssetControl': 'aa' * 32},
      },
    });

    expect(utxo.type, OutpointType.bitAssetControl);
    expect(utxo.bitAssetControlHash, 'aa' * 32);
    expect(utxo.bitAsset, isNull);
    expect(controlledBitAssets([utxo]), {'aa' * 32});
  });

  test('the coins of one asset add up to the amount the wallet holds', () {
    BitAssetsUTXO coin(Map<String, dynamic> content) => BitAssetsUTXO.fromJson({
      'outpoint': outpoint,
      'output': {'address': 'mine', 'content': content},
    });

    expect(
      bitAssetAmounts([
        coin({
          'BitAsset': ['e6' * 32, 7000000],
        }),
        coin({
          'BitAsset': ['e6' * 32, 3000000],
        }),
        coin({
          'BitAsset': ['bb' * 32, 5],
        }),
        coin({'BitcoinSats': 900}),
        coin({'BitAssetControl': 'aa' * 32}),
      ]),
      {'e6' * 32: 10000000, 'bb' * 32: 5},
    );
  });

  test('an amm token coin reads its own amount', () {
    final utxo = BitAssetsUTXO.fromJson({
      'outpoint': outpoint,
      'output': {
        'address': 'mine',
        'content': {
          'AmmLpToken': {'asset0': 'aa' * 32, 'asset1': 'bb' * 32, 'amount': 42},
        },
      },
    });

    expect(utxo.type, OutpointType.ammLpToken);
    expect(utxo.valueSats, 42);
    expect(utxo.bitAsset, isNull);
    expect(utxo.ammLpPair?.asset0, 'aa' * 32);
    expect(utxo.ammLpPair?.asset1, 'bb' * 32);
  });

  test('a coin of one asset names no pool', () {
    final utxo = BitAssetsUTXO.fromJson({
      'outpoint': outpoint,
      'output': {
        'address': 'mine',
        'content': {
          'BitAsset': ['e6' * 32, 1],
        },
      },
    });

    expect(utxo.ammLpPair, isNull);
  });
}
