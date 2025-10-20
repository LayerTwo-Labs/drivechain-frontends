import 'package:flutter/foundation.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/providers/settings_provider.dart';

/// Provider for formatting Bitcoin amounts based on user's unit preference
/// Views can listen to this provider directly for reactive updates
class FormatterProvider extends ChangeNotifier {
  final SettingsProvider _settingsProvider;

  FormatterProvider(this._settingsProvider) {
    _settingsProvider.addListener(notifyListeners);
  }

  BitcoinUnit get currentUnit => _settingsProvider.bitcoinUnit;

  /// Format satoshis according to the current user preference
  String formatSats(int sats) {
    return formatBitcoinWithUnit(satoshiToBTC(sats), currentUnit);
  }

  /// Format BTC according to the current user preference
  String formatBTC(double btc) {
    return formatBitcoinWithUnit(btc, currentUnit);
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
