import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/extensions/formatting.dart';
import 'package:sidechain_core/providers/bitcoin_conf_provider.dart';
import 'package:sidechain_core/ticker.dart';

/// A USD price feed for one coin.
class PriceSource {
  const PriceSource._(this.url, this.parse, this.interval);

  final String url;

  /// Reads the USD price out of the decoded response body.
  final double Function(Object? body) parse;

  /// Minimum time between two fetches.
  final Duration interval;

  static const blockchainInfo = PriceSource._(
    'https://blockchain.info/ticker',
    _parseBlockchainInfo,
    Duration(seconds: 10),
  );

  /// Orca wbECX/USDC pool. wbECX is betanet ECX, wrapped 1:1 on Solana.
  static const wbECX = PriceSource._(
    'https://api.dexscreener.com/latest/dex/pairs/solana/nNKg814Wq3uTkoG4fM8LzvBQv4Fu2iCgKFmK2YmPQzM',
    _parseDexScreener,
    Duration(seconds: 60),
  );

  /// Orca wECX/USDC pool. wECX is mainnet ECX, traded before the launch.
  static const wECX = PriceSource._(
    'https://api.dexscreener.com/latest/dex/pairs/solana/7T4xAj1ENEuPckhWqz6nJP9ZkvDnFpVF7nLbUAvSwm43',
    _parseDexScreener,
    Duration(seconds: 60),
  );
}

/// The USD price feed for [ticker], or null when no market trades the coin.
PriceSource? priceSourceFor(Ticker ticker) => switch (ticker) {
  Ticker.bitcoin => PriceSource.blockchainInfo,
  Ticker.betanet => PriceSource.wbECX,
  Ticker.ecash => PriceSource.wECX,
  _ => null,
};

double _parseBlockchainInfo(Object? body) {
  if (body case {'USD': {'last': final num last}}) {
    return last.toDouble();
  }
  throw const FormatException('blockchain.info: no USD "last" price');
}

double _parseDexScreener(Object? body) {
  if (body case {'pairs': [{'priceUsd': final String price}, ...]}) {
    final parsed = double.tryParse(price);
    if (parsed != null) {
      return parsed;
    }
  }
  throw const FormatException('dexscreener: no "priceUsd" for the pair');
}

/// Fetches and keeps the USD price of the coin on the active network.
class PriceProvider extends ChangeNotifier {
  /// [networkChanges] fires when the active network changes. It defaults to
  /// the registered [BitcoinConfProvider].
  PriceProvider({http.Client? client, PriceSource? Function()? source, Listenable? networkChanges})
    : _client = client ?? http.Client(),
      _source = source ?? (() => priceSourceFor(activeTicker)),
      _networkChanges =
          networkChanges ?? (GetIt.I.isRegistered<BitcoinConfProvider>() ? GetIt.I.get<BitcoinConfProvider>() : null) {
    _networkChanges?.addListener(fetch);
    fetch();
    if (!Environment.isInTest) {
      _fetchTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());
    }
  }

  final http.Client _client;
  final PriceSource? Function() _source;
  final Listenable? _networkChanges;

  /// USD price of one whole coin of the active network.
  double? usdPrice;
  DateTime? lastUpdated;
  String? error;
  bool isFetching = false;
  Timer? _fetchTimer;
  PriceSource? _pricedBy;

  /// Fetches the price when the source's interval has passed. A network
  /// change clears the old price, which belongs to another coin.
  Future<void> fetch() async {
    final source = _source();
    if (source != _pricedBy) {
      _pricedBy = source;
      usdPrice = null;
      lastUpdated = null;
      error = null;
      notifyListeners();
    }
    if (source == null || isFetching) {
      return;
    }
    final last = lastUpdated;
    if (last != null && DateTime.now().difference(last) < source.interval) {
      return;
    }

    isFetching = true;
    try {
      final response = await _client.get(Uri.parse(source.url));
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', Uri.parse(source.url));
      }
      final price = source.parse(json.decode(response.body));
      if (_pricedBy == source) {
        usdPrice = price;
        lastUpdated = DateTime.now();
        error = null;
      }
    } catch (e) {
      if (_pricedBy == source) {
        error = 'Error fetching price: $e';
      }
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  /// Format the price as a USD string
  String get formattedPrice {
    if (usdPrice == null) {
      return 'Loading...';
    }

    return formatUsd(usdPrice!);
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

  /// Convert a coin amount to USD
  double? toUsd(double amount) {
    if (usdPrice == null) {
      return null;
    }
    return amount * usdPrice!;
  }

  /// Convert a USD amount to coins
  double? fromUsd(double usdAmount) {
    if (usdPrice == null || usdPrice == 0) {
      return null;
    }
    return usdAmount / usdPrice!;
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _networkChanges?.removeListener(fetch);
    _client.close();
    super.dispose();
  }
}
