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

  // Filter state
  MarketState? stateFilter;
  String searchQuery = '';
  MarketSort sortBy = MarketSort.volume;
  bool sortAscending = false;

  /// Filtered and sorted markets
  List<MarketSummary> get filteredMarkets {
    var result = markets.where((m) {
      // State filter
      if (stateFilter != null && m.marketState != stateFilter) {
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

  /// Load a specific market
  Future<void> loadMarket(String marketId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _rpc.marketGet(marketId);
      if (response != null) {
        selectedMarket = MarketData.fromJson(response);
        _log.d('Loaded market: ${selectedMarket!.title}');
      } else {
        error = 'Market not found';
      }
    } catch (e) {
      error = 'Failed to load market: $e';
      _log.e(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load user positions
  Future<void> loadUserPositions(String address) async {
    try {
      final response = await _rpc.marketPositions(address: address);
      userPositions = UserHoldings.fromJson(response);
      _log.d('Loaded ${userPositions!.positions.length} positions for $address');
      notifyListeners();
    } catch (e) {
      _log.e('Failed to load positions: $e');
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
      return TradePreview(
        shares: shares,
        costSats: (response['cost_sats'] ?? 0) as int,
        feeSats: (response['trading_fee_sats'] ?? 0) as int,
        totalCostSats: ((response['cost_sats'] ?? 0) as int) + ((response['trading_fee_sats'] ?? 0) as int),
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
    List<String>? tags,
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
        tags: tags,
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
