class BitcoinURI {
  final String address;
  final double? amount;
  final String? label;
  final String? message;
  final Map<String, String> extraParams;

  BitcoinURI({
    required this.address,
    this.amount,
    this.label,
    this.message,
    Map<String, String>? extraParams,
  }) : extraParams = extraParams ?? {};

  /// Parses a Bitcoin URI string according to BIP-0021
  /// Throws FormatException if URI is invalid
  static BitcoinURI parse(String uri) {
    if (!uri.toLowerCase().startsWith('bitcoin:')) {
      throw const FormatException('Not a bitcoin URI');
    }

    // Split the URI into address and query parts
    final parts = uri.substring(8).split('?');
    if (parts.isEmpty || parts[0].isEmpty) {
      throw const FormatException('No address specified');
    }

    final address = parts[0];
    final params = <String, String>{};

    // Parse query parameters if they exist
    if (parts.length > 1) {
      final queryParts = parts[1].split('&');
      for (final param in queryParts) {
        final keyValue = param.split('=');
        if (keyValue.length != 2) continue;

        // Check for required parameters we don't understand
        if (keyValue[0].startsWith('req-')) {
          throw FormatException('Required parameter not understood: ${keyValue[0]}');
        }

        params[Uri.decodeComponent(keyValue[0])] = Uri.decodeComponent(keyValue[1]);
      }
    }

    // Parse amount if present
    double? amount;
    if (params.containsKey('amount')) {
      try {
        amount = double.parse(params['amount']!);
      } catch (e) {
        throw const FormatException('Invalid amount format');
      }
    }

    return BitcoinURI(
      address: address,
      amount: amount,
      label: params['label'],
      message: params['message'],
      extraParams: params
        ..removeWhere(
          (key, _) => ['amount', 'label', 'message'].contains(key),
        ),
    );
  }

  /// Validates if a string could be a valid Bitcoin URI
  static bool isValidURI(String uri) {
    try {
      parse(uri);
      return true;
    } catch (_) {
      return false;
    }
  }
}
