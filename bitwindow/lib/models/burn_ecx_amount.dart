const burnEcxAddress = '1BitcoinEaterAddressDontSendf59kuE';
const burnEcxMinimumSats = 100000000000;
const burnEcxNetworks = {
  'alphanet': (name: 'Alphanet', creditDivisor: 100),
  'betanet': (name: 'Betanet', creditDivisor: 50),
};

int parseBurnAmount(String text) {
  final value = text.trim();
  if (!RegExp(r'^(?:[0-9]+|[1-9][0-9]{0,2}(?:,[0-9]{3})+)(?:\.[0-9]{1,8})?$').hasMatch(value)) {
    throw const FormatException('Enter an amount with at most 8 decimal places.');
  }
  final parts = value.replaceAll(',', '').split('.');
  final amount = int.tryParse('${parts.first}${(parts.length == 2 ? parts.last : '').padRight(8, '0')}');
  if (amount == null || amount < 0) {
    throw const FormatException('The amount is too large.');
  }
  return amount;
}

/// [unit] names the burned coin, e.g. "bECX" on betanet.
String formatBurnAmount(int amountSats, String unit, {bool compact = false}) =>
    _formatAmount(amountSats, 8, unit, compact: compact);

int calculateEcxCreditSats(int amountSats, int creditDivisor) =>
    amountSats ~/ creditDivisor + (amountSats % creditDivisor == 0 ? 0 : 1);

String formatEcxCredit(int amountSats, int creditDivisor, {bool compact = false}) =>
    _formatAmount(calculateEcxCreditSats(amountSats, creditDivisor), 8, 'ECX', compact: compact);

String _formatAmount(int amount, int decimals, String unit, {bool compact = false}) {
  final digits = amount.toString().padLeft(decimals + 1, '0');
  final whole = digits
      .substring(0, digits.length - decimals)
      .replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
  var fraction = digits.substring(digits.length - decimals);
  if (compact) {
    fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
  }
  return '$whole${fraction.isEmpty ? '' : '.$fraction'} $unit';
}
