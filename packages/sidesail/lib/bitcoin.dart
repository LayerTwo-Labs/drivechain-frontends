import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

double satoshiToBTC(int sats) {
  const int satoshiPerBitcoin = 100000000;
  return sats / satoshiPerBitcoin;
}

int btcToSatoshi(double btc) {
  const int satoshiPerBitcoin = 100000000;
  return (btc * satoshiPerBitcoin).toInt();
}

String formatBitcoin(num number) {
  return NumberFormat('#,##0.00000000', 'en_US').format(number).replaceAll(',', ' ');
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
