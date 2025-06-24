import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Provider that fetches and maintains the current BTC/USD exchange rate
class PriceProvider extends ChangeNotifier {
  double? btcPriceUsd;
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
    _fetchTimer = Timer.periodic(
      Duration(seconds: 10),
      (timer) => fetch(),
    );
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
              btcPriceUsd = price.toDouble();
              lastUpdated = DateTime.now();
              error = null;
              notifyListeners();
            } else {
              error = 'Invalid price format from API';
              notifyListeners();
            }
          } else {
            error = 'USD price data missing "last" field';
            notifyListeners();
          }
        } else {
          error = 'USD price data not found in response';
          notifyListeners();
        }
      } else {
        error = 'Failed to fetch price: HTTP ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      error = 'Error fetching price: $e';
      notifyListeners();
    } finally {
      isFetching = false;
    }
  }

  /// Format the BTC price as a USD string
  String get formattedPrice {
    if (btcPriceUsd == null) {
      return 'Loading...';
    }

    // Format with commas and 2 decimal places
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    return formatter.format(btcPriceUsd);
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
    if (btcPriceUsd == null) {
      return null;
    }
    return btcAmount * btcPriceUsd!;
  }

  /// Convert USD amount to BTC
  double? usdToBtc(double usdAmount) {
    if (btcPriceUsd == null || btcPriceUsd == 0) {
      return null;
    }
    return usdAmount / btcPriceUsd!;
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }
}
