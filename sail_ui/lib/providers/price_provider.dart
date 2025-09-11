import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sail_ui/env.dart';
import 'package:sail_ui/extensions/formatting.dart';

/// Provider that fetches and maintains the current BTC/USD exchange rate
class PriceProvider extends ChangeNotifier {
  double? btcusd;
  DateTime? lastUpdated;
  String? error;
  bool isFetching = false;
  Timer? _fetchTimer;

  /// URL for the blockchain.info ticker API
  static const String _tickerUrl = 'https://blockchain.info/ticker';

  PriceProvider() {
    // Fetch once immediately
    fetch();
    // Then start periodic fetch
    _startFetchingTimer();
  }

  void _startFetchingTimer() {
    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(Duration(seconds: 10), (timer) => fetch());
  }

  /// Fetch the latest BTCUSD price from blockchain.info
  Future<void> fetch() async {
    if (isFetching) {
      return;
    }

    isFetching = true;
    error = null;

    try {
      final response = await http.get(Uri.parse(_tickerUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Extract USD price
        if (data.containsKey('USD') && data['USD'] is Map<String, dynamic>) {
          final usdData = data['USD'] as Map<String, dynamic>;

          if (usdData.containsKey('last')) {
            final price = usdData['last'];

            // Convert to double if needed
            if (price is num) {
              btcusd = price.toDouble();
              lastUpdated = DateTime.now();
              error = null;
            } else {
              error = 'Invalid price format from API';
            }
          } else {
            error = 'USD price data missing "last" field';
          }
        } else {
          error = 'USD price data not found in response';
        }
      } else {
        error = 'Failed to fetch price: HTTP ${response.statusCode}';
      }
    } catch (e) {
      error = 'Error fetching price: $e';
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  /// Format the BTC price as a USD string
  String get formattedPrice {
    if (btcusd == null) {
      return 'Loading...';
    }

    return '\$${formatWithThousandSpacers(btcusd!.round())}';
  }

  /// Get the age of the last price update
  String get priceAge {
    if (lastUpdated == null) {
      return 'Never updated';
    }

    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  /// Convert BTC amount to USD
  double? btcToUsd(double btcAmount) {
    if (btcusd == null) {
      return null;
    }
    return btcAmount * btcusd!;
  }

  /// Convert USD amount to BTC
  double? usdToBtc(double usdAmount) {
    if (btcusd == null || btcusd == 0) {
      return null;
    }
    return usdAmount / btcusd!;
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }
}
