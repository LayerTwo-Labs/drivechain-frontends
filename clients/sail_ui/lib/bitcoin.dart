import 'dart:convert';

import 'package:crypto/crypto.dart';

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
    return '0.0000,0000 $symbol';
  }

  // Ensure positive number and handle negatives
  bool isNegative = number < 0;
  number = number.abs();

  // Format to 8 decimal places and handle potential rounding
  final formattedNumber = number.toStringAsFixed(8);
  final parts = formattedNumber.split('.');

  // Handle integer part
  final integerPart = parts[0];

  // Handle decimal part with safety checks
  String formattedDecimal;
  if (parts.length < 2) {
    formattedDecimal = '0000,0000';
  } else {
    final decimalPart = parts[1].padRight(8, '0').substring(0, 8);
    formattedDecimal = '${decimalPart.substring(0, 4)},${decimalPart.substring(4)}';
  }

  return '${isNegative ? '-' : ''}$integerPart.$formattedDecimal $symbol';
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
