import 'package:flutter/material.dart';
import 'package:launcher/providers/quotes_provider.dart';

class MockQuotesProvider extends ChangeNotifier implements QuotesProvider {
  bool _showQuotes = true;

  @override
  bool get showQuotes => _showQuotes;

  @override
  Future<void> setShowQuotes(bool show) async {
    _showQuotes = show;
    notifyListeners();
  }
}