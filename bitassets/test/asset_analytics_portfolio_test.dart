import 'dart:async';

import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/rpcs/bitassets_rpc.dart';
import 'package:sidechain_core/rpcs/bitnames_rpc.dart';
import 'package:sidechain_core/rpcs/thunder_utxo.dart';

import 'mocks/rpc_mock_bitassets.dart';

const _assetA = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _assetB = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

void main() {
  late _PortfolioRPC rpc;

  setUp(() async {
    await GetIt.I.reset();
    rpc = _PortfolioRPC();
    GetIt.I.registerSingleton<BitAssetsRPC>(rpc);
  });

  tearDown(() async {
    rpc.dispose();
    await GetIt.I.reset();
  });

  test('BTC includes the pending balance in its portfolio share', () async {
    rpc.balanceResult = BalanceResponse(totalSats: 200, availableSats: 100);
    rpc.utxos = [];
    rpc.assets = [];
    rpc.pools = {};

    final provider = await _loadProvider();

    expect(provider.totalBtcBalance, 100);
    expect(provider.pendingBtcBalance, 100);
    expect(provider.holdings.single.assetId, 'btc');
    expect(provider.holdings.single.amount, 200);
    expect(provider.holdings.single.estimatedValueSats, 200);
    expect(provider.holdings.single.percentageOfPortfolio, 100);
  });

  test('the direct BTC pool gives equal shares for equal values', () async {
    final provider = await _loadProvider();
    final btc = provider.holdings.singleWhere((holding) => holding.isBtc);
    final asset = provider.holdings.singleWhere((holding) => holding.assetId == _assetA);

    expect(btc.amount, 200);
    expect(btc.estimatedValueSats, 200);
    expect(btc.percentageOfPortfolio, 50);
    expect(asset.amount, 10);
    expect(asset.estimatedValueSats, 200);
    expect(asset.percentageOfPortfolio, 50);
  });

  for (final entry in <String, AmmPoolState?>{
    'an absent pool': null,
    'a pool with zero BTC reserves': _pool(0, 100),
    'a pool with zero asset reserves': _pool(2000, 0),
  }.entries) {
    test('${entry.key} leaves every portfolio share unknown', () async {
      rpc.pools = {('btc', _assetA): entry.value};

      final provider = await _loadProvider();
      final btc = provider.holdings.singleWhere((holding) => holding.isBtc);
      final asset = provider.holdings.singleWhere((holding) => holding.assetId == _assetA);

      expect(btc.estimatedValueSats, 200);
      expect(asset.amount, 10);
      expect(asset.estimatedValueSats, isNull);
      expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(isNull));
    });
  }

  test('an absent pool RPC error leaves every portfolio share unknown', () async {
    rpc.poolError = ConnectException(Code.unknown, 'Pool does not exist');

    final provider = await _loadProvider();
    final asset = provider.holdings.singleWhere((holding) => holding.assetId == _assetA);

    expect(provider.poolsError, isNull);
    expect(provider.pools, isEmpty);
    expect(asset.estimatedValueSats, isNull);
    expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(isNull));
  });

  test('an indirect pool leaves every portfolio share unknown', () async {
    rpc.assets.add(BitAssetEntry(sequenceID: 2, hash: _assetB, details: BitAssetDetails()));
    rpc.pools = {
      ('btc', _assetB): _pool(2000, 100),
      (_assetA, _assetB): _pool(100, 100),
    };

    final provider = await _loadProvider();
    final asset = provider.holdings.singleWhere((holding) => holding.assetId == _assetA);

    expect(provider.pools, hasLength(2));
    expect(asset.estimatedValueSats, isNull);
    expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(isNull));
  });

  test('a zero asset amount does not make the BTC share unknown', () async {
    rpc.utxos = [_assetCoin(_assetA, 0)];
    rpc.pools = {};

    final provider = await _loadProvider();
    final btc = provider.holdings.singleWhere((holding) => holding.isBtc);
    final asset = provider.holdings.singleWhere((holding) => holding.assetId == _assetA);

    expect(btc.percentageOfPortfolio, 100);
    expect(asset.estimatedValueSats, 0);
    expect(asset.percentageOfPortfolio, 0);
  });

  test('a refresh clears shares when the direct pool disappears', () async {
    final provider = await _loadProvider();
    expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(50));

    rpc.pools = {};
    await provider.fetch();

    final asset = provider.holdings.singleWhere((holding) => holding.assetId == _assetA);
    expect(provider.pools, isEmpty);
    expect(asset.amount, 10);
    expect(asset.estimatedValueSats, isNull);
    expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(isNull));
  });

  test('an asset list error does not reuse the previous pool price', () async {
    final provider = await _loadProvider();
    expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(50));

    rpc.assetsError = StateError('Asset list read failed');
    rpc.utxos = [_assetCoin(_assetA, 20)];
    await provider.fetch();

    final asset = provider.holdings.singleWhere((holding) => holding.assetId == _assetA);
    expect(provider.poolsError, contains('Asset list read failed'));
    expect(asset.amount, 20);
    expect(asset.estimatedValueSats, isNull);
    expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(isNull));
  });

  for (final source in ['balance', 'UTXO']) {
    test('a $source read error clears values and keeps the previous quantities', () async {
      final provider = await _loadProvider();
      expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(50));

      rpc.balanceResult = BalanceResponse(totalSats: 300, availableSats: 300);
      rpc.utxos = [_assetCoin(_assetA, 20)];
      if (source == 'balance') {
        rpc.balanceError = StateError('Balance read failed');
      } else {
        rpc.utxosError = StateError('UTXO read failed');
      }
      await provider.fetch();

      expect(provider.holdingsError, contains('read failed'));
      expect(
        {for (final holding in provider.holdings) holding.assetId: holding.amount},
        {'btc': 200, _assetA: 10},
      );
      expect(provider.holdings.map((holding) => holding.estimatedValueSats), everyElement(isNull));
      expect(provider.holdings.map((holding) => holding.percentageOfPortfolio), everyElement(isNull));
    });
  }
}

Future<AssetAnalyticsProvider> _loadProvider() async {
  final provider = AssetAnalyticsProvider();
  addTearDown(provider.dispose);
  final loaded = Completer<void>();
  void onChange() {
    if (!provider.isLoadingHoldings && !provider.isLoadingPools && !loaded.isCompleted) {
      loaded.complete();
    }
  }

  provider.addListener(onChange);
  onChange();
  try {
    await loaded.future;
  } finally {
    provider.removeListener(onChange);
  }
  return provider;
}

AmmPoolState _pool(int reserve0, int reserve1) => AmmPoolState(
  reserve0: reserve0,
  reserve1: reserve1,
  outstandingLpTokens: 100,
  creationTxid: 'pool',
);

BitAssetsUTXO _assetCoin(String hash, int amount) => BitAssetsUTXO.fromJson({
  'outpoint': {
    'Regular': {'txid': 'aa', 'vout': 0},
  },
  'output': {
    'address': 'mine',
    'content': {
      'BitAsset': [hash, amount],
    },
  },
});

class _PortfolioRPC extends MockBitAssetsRPC {
  BalanceResponse balanceResult = BalanceResponse(totalSats: 200, availableSats: 200);
  List<SidechainUTXO> utxos = [_assetCoin(_assetA, 10)];
  List<BitAssetEntry> assets = [BitAssetEntry(sequenceID: 1, hash: _assetA, details: BitAssetDetails())];
  Map<(String, String), AmmPoolState?> pools = {('btc', _assetA): _pool(2000, 100)};
  StateError? balanceError;
  StateError? utxosError;
  StateError? assetsError;
  ConnectException? poolError;

  @override
  Future<BalanceResponse> getBalance() async {
    if (balanceError != null) throw balanceError!;
    return balanceResult;
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    if (utxosError != null) throw utxosError!;
    return utxos;
  }

  @override
  Future<List<BitAssetEntry>> listBitAssets() async {
    if (assetsError != null) throw assetsError!;
    return assets;
  }

  @override
  Future<AmmPoolState?> getAmmPoolState({required String asset0, required String asset1}) async {
    if (poolError != null) throw poolError!;
    return pools[(asset0, asset1)];
  }
}
