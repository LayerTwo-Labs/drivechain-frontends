import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';

/// Represents a user's holding of a specific asset
class AssetHolding {
  final String assetId;
  final String? assetName;
  final int amount;
  final double percentageOfPortfolio;

  AssetHolding({
    required this.assetId,
    required this.assetName,
    required this.amount,
    required this.percentageOfPortfolio,
  });

  String get displayName => assetName ?? (assetId == 'btc' ? 'BTC (Native)' : assetId.substring(0, 12));
  bool get isBtc => assetId == 'btc';
}

/// Represents an AMM liquidity pool with analytics data
class PoolAnalytics {
  final String asset0;
  final String asset1;
  final String? asset0Name;
  final String? asset1Name;
  final int reserve0;
  final int reserve1;
  final int outstandingLpTokens;
  final String creationTxid;

  PoolAnalytics({
    required this.asset0,
    required this.asset1,
    this.asset0Name,
    this.asset1Name,
    required this.reserve0,
    required this.reserve1,
    required this.outstandingLpTokens,
    required this.creationTxid,
  });

  String get asset0Display => asset0Name ?? (asset0 == 'btc' ? 'BTC' : asset0.substring(0, 8));
  String get asset1Display => asset1Name ?? (asset1 == 'btc' ? 'BTC' : asset1.substring(0, 8));
  String get pairName => '$asset0Display / $asset1Display';

  /// Price of asset1 in terms of asset0
  double get priceRatio => reserve1 > 0 ? reserve0 / reserve1 : 0;

  /// Total value locked (in terms of asset0, assuming equal value)
  int get tvl => reserve0 * 2;

  /// Calculate impermanent loss percentage for a given price change ratio
  /// priceChangeRatio = new_price / original_price
  static double calculateImpermanentLoss(double priceChangeRatio) {
    if (priceChangeRatio <= 0) return 0;
    final sqrtRatio = sqrt(priceChangeRatio);
    final ilFactor = 2 * sqrtRatio / (1 + priceChangeRatio);
    return (1 - ilFactor) * 100;
  }
}

/// Filter options for auction browser
enum AuctionFilter {
  all,
  active,
  ended,
  upcoming,
}

/// Sort options for auctions
enum AuctionSort {
  startBlockDesc,
  startBlockAsc,
  priceDesc,
  priceAsc,
  amountDesc,
  amountAsc,
}

/// Provider for asset analytics, portfolio tracking, and AMM data
class AssetAnalyticsProvider extends ChangeNotifier {
  BitAssetsRPC get rpc => GetIt.I.get<BitAssetsRPC>();

  // Portfolio holdings
  List<AssetHolding> holdings = [];
  int totalBtcBalance = 0;
  int pendingBtcBalance = 0;
  bool isLoadingHoldings = true;
  String? holdingsError;

  // AMM pool analytics
  List<PoolAnalytics> pools = [];
  bool isLoadingPools = true;
  String? poolsError;

  // Auction filtering state
  AuctionFilter auctionFilter = AuctionFilter.all;
  AuctionSort auctionSort = AuctionSort.startBlockDesc;
  String auctionSearchQuery = '';

  // Asset filtering state
  String assetSearchQuery = '';

  bool _isFetching = false;
  Timer? _refreshTimer;

  AssetAnalyticsProvider() {
    rpc.addListener(fetch);
    fetch();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    if (Environment.isInTest) return;

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetch();
    });
  }

  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;

    await Future.wait([
      _fetchHoldings(),
      _fetchPools(),
    ]);

    _isFetching = false;
    notifyListeners();
  }

  Future<void> _fetchHoldings() async {
    try {
      isLoadingHoldings = true;
      holdingsError = null;

      final balance = await rpc.getBalance();
      totalBtcBalance = balance.availableSats;
      pendingBtcBalance = balance.totalSats - balance.availableSats;

      // Fetch wallet UTXOs to calculate BitAsset holdings
      final utxos = await rpc.listUTXOs();

      // Group UTXOs by asset type
      final Map<String, int> assetAmounts = {};
      int totalValue = totalBtcBalance;

      for (final utxo in utxos) {
        if (utxo is! BitAssetsUTXO) continue;

        final content = utxo.output['content'] as Map<String, dynamic>?;
        if (content == null) continue;

        if (content.containsKey('BitAsset')) {
          final assetData = content['BitAsset'] as Map<String, dynamic>;
          final assetId = assetData['asset_id'] as String?;
          final amount = assetData['amount'] as int?;

          if (assetId != null && amount != null) {
            assetAmounts[assetId] = (assetAmounts[assetId] ?? 0) + amount;
            totalValue += amount;
          }
        }
      }

      // Create holdings list with percentages
      final newHoldings = <AssetHolding>[];

      // Add BTC holding
      if (totalBtcBalance > 0 || pendingBtcBalance > 0) {
        newHoldings.add(
          AssetHolding(
            assetId: 'btc',
            assetName: 'BTC (Native)',
            amount: totalBtcBalance + pendingBtcBalance,
            percentageOfPortfolio: totalValue > 0 ? ((totalBtcBalance + pendingBtcBalance) / totalValue) * 100 : 100,
          ),
        );
      }

      // Add BitAsset holdings
      for (final entry in assetAmounts.entries) {
        newHoldings.add(
          AssetHolding(
            assetId: entry.key,
            assetName: null, // Will be resolved by UI if needed
            amount: entry.value,
            percentageOfPortfolio: totalValue > 0 ? (entry.value / totalValue) * 100 : 0,
          ),
        );
      }

      holdings = newHoldings;
      isLoadingHoldings = false;
    } catch (e) {
      holdingsError = e.toString();
      isLoadingHoldings = false;
    }
  }

  Future<void> _fetchPools() async {
    try {
      isLoadingPools = true;
      poolsError = null;

      // Get all registered assets to enumerate possible pools
      final assets = await rpc.listBitAssets();
      final newPools = <PoolAnalytics>[];

      // Check for BTC pools with each asset
      for (final asset in assets) {
        try {
          final poolState = await rpc.getAmmPoolState(
            asset0: 'btc',
            asset1: asset.hash,
          );

          if (poolState != null && poolState.outstandingLpTokens > 0) {
            newPools.add(
              PoolAnalytics(
                asset0: 'btc',
                asset1: asset.hash,
                asset0Name: 'BTC',
                asset1Name: asset.plaintextName,
                reserve0: poolState.reserve0,
                reserve1: poolState.reserve1,
                outstandingLpTokens: poolState.outstandingLpTokens,
                creationTxid: poolState.creationTxid,
              ),
            );
          }
        } catch (_) {
          // Pool doesn't exist for this pair, skip
        }
      }

      // Check for asset-to-asset pools
      for (int i = 0; i < assets.length; i++) {
        for (int j = i + 1; j < assets.length; j++) {
          try {
            final poolState = await rpc.getAmmPoolState(
              asset0: assets[i].hash,
              asset1: assets[j].hash,
            );

            if (poolState != null && poolState.outstandingLpTokens > 0) {
              newPools.add(
                PoolAnalytics(
                  asset0: assets[i].hash,
                  asset1: assets[j].hash,
                  asset0Name: assets[i].plaintextName,
                  asset1Name: assets[j].plaintextName,
                  reserve0: poolState.reserve0,
                  reserve1: poolState.reserve1,
                  outstandingLpTokens: poolState.outstandingLpTokens,
                  creationTxid: poolState.creationTxid,
                ),
              );
            }
          } catch (_) {
            // Pool doesn't exist for this pair, skip
          }
        }
      }

      pools = newPools;
      isLoadingPools = false;
    } catch (e) {
      poolsError = e.toString();
      isLoadingPools = false;
    }
  }

  /// Get filtered and sorted auctions based on current filter state
  List<DutchAuctionEntry> getFilteredAuctions(List<DutchAuctionEntry> allAuctions, int currentBlock) {
    var filtered = allAuctions.where((auction) {
      // Apply search filter
      if (auctionSearchQuery.isNotEmpty) {
        final query = auctionSearchQuery.toLowerCase();
        if (!auction.id.toLowerCase().contains(query) &&
            !auction.baseAsset.toLowerCase().contains(query) &&
            !auction.quoteAsset.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Apply status filter
      final endBlock = auction.startBlock + auction.duration;
      switch (auctionFilter) {
        case AuctionFilter.all:
          return true;
        case AuctionFilter.active:
          return auction.startBlock <= currentBlock && endBlock > currentBlock;
        case AuctionFilter.ended:
          return endBlock <= currentBlock;
        case AuctionFilter.upcoming:
          return auction.startBlock > currentBlock;
      }
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (auctionSort) {
        case AuctionSort.startBlockDesc:
          return b.startBlock.compareTo(a.startBlock);
        case AuctionSort.startBlockAsc:
          return a.startBlock.compareTo(b.startBlock);
        case AuctionSort.priceDesc:
          return b.initialPrice.compareTo(a.initialPrice);
        case AuctionSort.priceAsc:
          return a.initialPrice.compareTo(b.initialPrice);
        case AuctionSort.amountDesc:
          return b.baseAmount.compareTo(a.baseAmount);
        case AuctionSort.amountAsc:
          return a.baseAmount.compareTo(b.baseAmount);
      }
    });

    return filtered;
  }

  /// Get filtered assets based on search query
  List<BitAssetEntry> getFilteredAssets(List<BitAssetEntry> allAssets) {
    if (assetSearchQuery.isEmpty) return allAssets;

    final query = assetSearchQuery.toLowerCase();
    return allAssets.where((asset) {
      return asset.hash.toLowerCase().contains(query) || (asset.plaintextName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Get auction status string
  String getAuctionStatus(DutchAuctionEntry auction, int currentBlock) {
    final endBlock = auction.startBlock + auction.duration;
    if (currentBlock < auction.startBlock) return 'Upcoming';
    if (currentBlock >= endBlock) return 'Ended';
    return 'Active';
  }

  /// Calculate current price for a Dutch auction
  /// Based on linear interpolation from initial_price to final_price over duration
  int calculateCurrentPrice(DutchAuctionEntry auction, int currentBlock) {
    if (currentBlock < auction.startBlock) return auction.initialPrice;

    final endBlock = auction.startBlock + auction.duration;
    if (currentBlock >= endBlock) return auction.finalPrice;

    // Linear interpolation
    final elapsed = currentBlock - auction.startBlock;
    final priceDiff = auction.initialPrice - auction.finalPrice;
    final priceDecrease = (priceDiff * elapsed) ~/ auction.duration;

    return auction.initialPrice - priceDecrease;
  }

  void setAuctionFilter(AuctionFilter filter) {
    auctionFilter = filter;
    notifyListeners();
  }

  void setAuctionSort(AuctionSort sort) {
    auctionSort = sort;
    notifyListeners();
  }

  void setAuctionSearchQuery(String query) {
    auctionSearchQuery = query;
    notifyListeners();
  }

  void setAssetSearchQuery(String query) {
    assetSearchQuery = query;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    rpc.removeListener(fetch);
    super.dispose();
  }
}
