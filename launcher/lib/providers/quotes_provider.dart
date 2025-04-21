import 'package:flutter/material.dart';
import 'package:sail_ui/settings/secure_store.dart';

class QuotesProvider extends ChangeNotifier {
  final KeyValueStore _store;
  static const String _showQuotesKey = 'show_quotes';

  QuotesProvider(this._store) {
    // Clear any existing preference on app start
    _store.delete(_showQuotesKey);
  }

  Future<bool> get showQuotes async {
    final value = await _store.getString(_showQuotesKey);
    return value == 'true';
  }

  Future<void> setShowQuotes(bool value) async {
    await _store.setString(_showQuotesKey, value.toString());
    notifyListeners();
  }
}
