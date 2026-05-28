import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/settings_provider.dart';

enum BitcoinUnit {
  btc,
  sats;

  String get symbol => this == BitcoinUnit.btc ? 'BTC' : 'sats';
  String get label => this == BitcoinUnit.btc ? 'BTC' : 'Satoshis';
}

/// Utility class for Bitcoin amount formatting based on user's unit preference
/// Use this directly in views instead of going through ViewModels
class BitcoinFormatting {
  /// Format satoshis according to the current user preference
  static String formatSatsWithUnit(BuildContext context, int sats) {
    final settings = GetIt.I<SettingsProvider>();
    return formatBitcoinWithUnit(satoshiToBTC(sats), settings.bitcoinUnit);
  }

  /// Format BTC according to the current user preference
  static String formatBTCWithUnit(BuildContext context, double btc) {
    final settings = GetIt.I<SettingsProvider>();
    return formatBitcoinWithUnit(btc, settings.bitcoinUnit);
  }

  /// Get the current unit from settings
  static BitcoinUnit currentUnit(BuildContext context) {
    final settings = GetIt.I<SettingsProvider>();
    return settings.bitcoinUnit;
  }
}

double satoshiToBTC(int sats) {
  const int satoshiPerBitcoin = 100000000;
  return sats / satoshiPerBitcoin;
}

int btcToSatoshi(double btc) {
  const int satoshiPerBitcoin = 100000000;
  return (btc * satoshiPerBitcoin).toInt();
}

String formatBitcoin(num? number, {String symbol = 'BTC'}) {
  if (number == null || number.isNaN || number.isInfinite) {
    return '0.0000,0000${symbol.isEmpty ? '' : ' $symbol'}';
  }

  // Ensure positive number and handle negatives
  bool isNegative = number < 0;
  number = number.abs();

  // Format to 8 decimal places
  final formattedNumber = number.toStringAsFixed(8);
  final parts = formattedNumber.split('.');

  final integerPart = parts[0];

  // Ensure decimal part is 8 digits
  String decimalPart = (parts.length > 1 ? parts[1] : '').padRight(8, '0').substring(0, 8);

  // Group as: 4 digits, 4 digits with comma
  String groupedDecimal = '${decimalPart.substring(0, 4)},${decimalPart.substring(4, 8)}';

  return '${isNegative ? '-' : ''}$integerPart.$groupedDecimal${symbol.isEmpty ? '' : ' $symbol'}';
}

String formatDepositAddress(String address, int sidechainNum) {
  // Prepend sidechain number
  String strDepositAddress = 's${sidechainNum.toString()}_';

  // Append destination
  strDepositAddress += address;
  strDepositAddress += '_';

  // Generate checksum (first 6 bytes of SHA-256 hash)
  List<int> bytes = utf8.encode(strDepositAddress);
  Digest digest = sha256.convert(bytes);
  String strHash = digest.toString();

  // Append checksum bits (first 6 characters of the SHA-256 hash in hex)
  strDepositAddress += strHash.substring(0, 6);

  return strDepositAddress;
}

double cleanAmount(double amount) {
  // clean the amount of any excess decimals! Cap it at 8, and let
  // the front-end be kinda stupid
  final cleanAmount = double.parse(amount.toStringAsFixed(8));

  return cleanAmount;
}

String formatBitcoinWithUnit(double btc, BitcoinUnit unit) {
  if (unit == BitcoinUnit.btc) {
    return formatBitcoin(btc);
  } else {
    final sats = btcToSatoshi(btc);
    return formatSatoshis(sats);
  }
}

String formatSatoshis(int sats) {
  if (sats == 0) {
    return '0 sats';
  }

  bool isNegative = sats < 0;
  sats = sats.abs();

  String satsStr = sats.toString();
  String formatted = '';

  int count = 0;
  for (int i = satsStr.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) {
      formatted = ' $formatted';
    }
    formatted = satsStr[i] + formatted;
    count++;
  }

  return '${isNegative ? '-' : ''}$formatted sats';
}

double parseAmountInUnit(String input, BitcoinUnit unit) {
  if (input.isEmpty) {
    return 0.0;
  }

  String cleanInput = input.replaceAll(' ', '').replaceAll(',', '');

  if (unit == BitcoinUnit.btc) {
    return double.tryParse(cleanInput) ?? 0.0;
  } else {
    final sats = int.tryParse(cleanInput) ?? 0;
    return satoshiToBTC(sats);
  }
}

int parseAmountToSatoshis(String input, BitcoinUnit unit) {
  if (input.isEmpty) {
    return 0;
  }

  String cleanInput = input.replaceAll(' ', '').replaceAll(',', '');

  if (unit == BitcoinUnit.btc) {
    final btc = double.tryParse(cleanInput) ?? 0.0;
    return btcToSatoshi(btc);
  } else {
    return int.tryParse(cleanInput) ?? 0;
  }
}
