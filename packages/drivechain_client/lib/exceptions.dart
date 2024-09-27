class WalletException implements Exception {
  final String message;
  WalletException(this.message);
  @override
  String toString() => 'WalletException: $message';
}

class BitcoindException implements Exception {
  final String message;
  BitcoindException(this.message);
  @override
  String toString() => 'BitcoindException: $message';
}

class DrivechainException implements Exception {
  final String message;
  DrivechainException(this.message);
  @override
  String toString() => 'DrivechainException: $message';
}
