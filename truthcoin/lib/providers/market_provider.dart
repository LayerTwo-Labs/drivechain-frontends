import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';

/// Provider for prediction market data
class MarketProvider extends ChangeNotifier {
  final TruthcoinRPC _rpc = GetIt.I.get<TruthcoinRPC>();
  final Logger _log = GetIt.I.get<Logger>();

  List<MarketSummary> markets = [];
  MarketData? selectedMarket;
  UserHoldings? userPositions;
  bool isLoading = false;
  String? error;

  /// Full market data per market id. market_list carries no prices.
  Map<String, MarketData> marketDetails = {};
  bool isLoadingPrices = false;
  String? priceError;

  // Filter state
  MarketState? stateFilter;
  String? tagFilter;
  String searchQuery = '';
  MarketSort sortBy = MarketSort.volume;
  bool sortAscending = false;

  /// Every tag the loaded markets carry, in alphabetical order.
  List<String> get availableTags {
    final tags = <String>{for (final detail in marketDetails.values) ...detail.tags};
    final sorted = tags.toList()..sort();
    return sorted;
  }

  /// Filtered and sorted markets
  List<MarketSummary> get filteredMarkets {
    var result = markets.where((m) {
      // State filter
      if (stateFilter != null && m.marketState != stateFilter) {
        return false;
      }
      // Tag filter. A market with no loaded detail carries no tag.
      if (tagFilter != null && !(marketDetails[m.marketId]?.tags.contains(tagFilter) ?? false)) {
        return false;
      }
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return m.title.toLowerCase().contains(query) || m.description.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Sort
    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case MarketSort.volume:
          comparison = a.volumeSats.compareTo(b.volumeSats);
        case MarketSort.created:
          comparison = a.createdAtHeight.compareTo(b.createdAtHeight);
        case MarketSort.title:
          comparison = a.title.compareTo(b.title);
      }
      return sortAscending ? comparison : -comparison;
    });

    return result;
  }

  /// Load all markets
  Future<void> loadMarkets() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _rpc.marketList();
      markets = response.map((m) => MarketSummary.fromJson(m)).toList();
      _log.d('Loaded ${markets.length} markets');
    } catch (e) {
      error = 'Failed to load markets: $e';
      _log.e(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load the outcome prices of every listed market, a few at a time.
  /// A market already in [marketDetails] loads again only when [refresh] is true.
  Future<void> loadMarketPrices({int batchSize = 4, bool refresh = false}) async {
    if (markets.isEmpty) return;

    final ids = markets
        .map((m) => m.marketId)
        .where((id) => id.isNotEmpty && (refresh || !marketDetails.containsKey(id)))
        .toList();
    if (ids.isEmpty) return;

    isLoadingPrices = true;
    priceError = null;
    notifyListeners();

    for (var start = 0; start < ids.length; start += batchSize) {
      final batch = ids.skip(start).take(batchSize);
      final results = await Future.wait(
        batch.map((id) async {
          try {
            final response = await _rpc.marketGet(id);
            return response == null ? null : MapEntry(id, MarketData.fromJson(response));
          } catch (e) {
            priceError = 'Failed to load prices: $e';
            _log.e(priceError);
            return null;
          }
        }),
      );

      marketDetails = {
        ...marketDetails,
        for (final entry in results.whereType<MapEntry<String, MarketData>>()) entry.key: entry.value,
      };
      notifyListeners();
    }

    isLoadingPrices = false;
    notifyListeners();
  }

  /// Load a specific market
  Future<void> loadMarket(String marketId) async {
    isLoading = true;
    error = null;
    // Drop the market of the last route, or a failed load shows it again.
    selectedMarket = null;
    notifyListeners();

    try {
      final response = await _rpc.marketGet(marketId);
      if (response != null) {
        selectedMarket = MarketData.fromJson(response);
        // The grid reads this cache, so a fresh load also refreshes the card.
        marketDetails = {...marketDetails, marketId: selectedMarket!};
        _log.d('Loaded market: ${selectedMarket!.title}');
      } else {
        error = 'Market not found';
        marketDetails = {...marketDetails}..remove(marketId);
      }
    } catch (e) {
      error = 'Failed to load market: $e';
      _log.e(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load the positions of one address. Returns false when the node fails.
  Future<bool> loadUserPositions(String address) async {
    try {
      final response = await _rpc.marketPositions(address: address);
      userPositions = UserHoldings.fromJson(response);
      error = null;
      _log.d('Loaded ${userPositions!.positions.length} positions for $address');
      notifyListeners();
      return true;
    } catch (e) {
      userPositions = null;
      error = 'Failed to load positions: $e';
      _log.e(error);
      notifyListeners();
      return false;
    }
  }

  /// Buy shares with dry run preview
  Future<TradePreview> buySharesPreview({
    required String marketId,
    required int outcomeIndex,
    required int shares,
    int? maxCost,
  }) async {
    try {
      final response = await _rpc.marketBuy(
        marketId: marketId,
        outcomeIndex: outcomeIndex,
        sharesAmount: shares.toDouble(),
        dryRun: true,
        maxCost: maxCost,
      );
      // The node reports cost_sats with the trading fee inside it.
      final totalCostSats = (response['cost_sats'] ?? 0) as int;
      final feeSats = (response['trading_fee_sats'] ?? 0) as int;
      return TradePreview(
        shares: shares,
        costSats: (totalCostSats - feeSats).clamp(0, totalCostSats),
        feeSats: feeSats,
        totalCostSats: totalCostSats,
        postTradePrice: (response['new_price'] ?? 0.0) as double,
      );
    } catch (e) {
      return TradePreview.error('Preview failed: $e');
    }
  }

  /// Execute buy shares
  Future<String?> buyShares({
    required String marketId,
    required int outcomeIndex,
    required int shares,
    int? maxCost,
    int feeSats = 1000,
  }) async {
    try {
      final response = await _rpc.marketBuy(
        marketId: marketId,
        outcomeIndex: outcomeIndex,
        sharesAmount: shares.toDouble(),
        dryRun: false,
        feeSats: feeSats,
        maxCost: maxCost,
      );
      final txid = response['txid']?.toString();
      if (txid != null) {
        _log.i('Bought $shares shares: $txid');
        // Reload market data
        await loadMarket(marketId);
      }
      return txid;
    } catch (e) {
      _log.e('Buy failed: $e');
      error = 'Buy failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Sell shares with dry run preview
  Future<MarketSellResponse?> sellSharesPreview({
    required String marketId,
    required int outcomeIndex,
    required int shares,
    required String sellerAddress,
    int? minProceeds,
  }) async {
    try {
      final response = await _rpc.marketSell(
        marketId: marketId,
        outcomeIndex: outcomeIndex,
        sharesAmount: shares,
        sellerAddress: sellerAddress,
        dryRun: true,
        minProceeds: minProceeds,
      );
      return MarketSellResponse.fromJson(response);
    } catch (e) {
      _log.e('Sell preview failed: $e');
      return null;
    }
  }

  /// Execute sell shares
  Future<String?> sellShares({
    required String marketId,
    required int outcomeIndex,
    required int shares,
    required String sellerAddress,
    int? minProceeds,
    int feeSats = 1000,
  }) async {
    try {
      final response = await _rpc.marketSell(
        marketId: marketId,
        outcomeIndex: outcomeIndex,
        sharesAmount: shares,
        sellerAddress: sellerAddress,
        dryRun: false,
        feeSats: feeSats,
        minProceeds: minProceeds,
      );
      final txid = response['txid']?.toString();
      if (txid != null) {
        _log.i('Sold $shares shares: $txid');
        // Reload market data
        await loadMarket(marketId);
      }
      return txid;
    } catch (e) {
      _log.e('Sell failed: $e');
      error = 'Sell failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Calculate initial liquidity for market creation
  Future<InitialLiquidityCalculation?> calculateInitialLiquidity({
    required double beta,
    int? numOutcomes,
    String? dimensions,
  }) async {
    try {
      final response = await _rpc.calculateInitialLiquidity(
        beta: beta,
        numOutcomes: numOutcomes,
        dimensions: dimensions,
      );
      return InitialLiquidityCalculation.fromJson(response);
    } catch (e) {
      _log.e('Calculate liquidity failed: $e');
      return null;
    }
  }

  /// Create a new market
  Future<String?> createMarket({
    required String title,
    required String description,
    required String dimensions,
    required int feeSats,
    double? beta,
    int? initialLiquidity,
    double? tradingFee,
  }) async {
    try {
      final txid = await _rpc.marketCreate(
        title: title,
        description: description,
        dimensions: dimensions,
        feeSats: feeSats,
        beta: beta,
        initialLiquidity: initialLiquidity,
        tradingFee: tradingFee,
      );
      _log.i('Created market: $txid');
      // Reload markets list
      await loadMarkets();
      return txid;
    } catch (e) {
      _log.e('Create market failed: $e');
      error = 'Create market failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Set filter state
  void setStateFilter(MarketState? state) {
    stateFilter = state;
    notifyListeners();
  }

  /// Keep only the markets that carry the tag. Null shows every market.
  void setTagFilter(String? tag) {
    tagFilter = tag;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  /// Set sort
  void setSort(MarketSort sort, {bool? ascending}) {
    if (sortBy == sort && ascending == null) {
      sortAscending = !sortAscending;
    } else {
      sortBy = sort;
      if (ascending != null) sortAscending = ascending;
    }
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    selectedMarket = null;
    notifyListeners();
  }
}

/// Market sort options
enum MarketSort {
  volume,
  created,
  title,
}
