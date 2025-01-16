import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _showQuotesKey = 'show_quotes';

  QuotesProvider(this._prefs) {
    // Clear any existing preference on app start
    // TODO: Remove this when settings page is implemented
    _prefs.remove(_showQuotesKey);
  }

  bool get showQuotes => _prefs.getBool(_showQuotesKey) ?? true;

  Future<void> setShowQuotes(bool value) async {
    await _prefs.setBool(_showQuotesKey, value);
    notifyListeners();
  }
}