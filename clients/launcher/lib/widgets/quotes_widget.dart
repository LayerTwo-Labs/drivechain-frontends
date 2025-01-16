import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/providers/quotes_provider.dart';
import 'package:provider/provider.dart';
import 'package:sail_ui/sail_ui.dart';

class QuotesWidget extends StatefulWidget {
  const QuotesWidget({super.key});

  @override
  State<QuotesWidget> createState() => _QuotesWidgetState();
}

class _QuotesWidgetState extends State<QuotesWidget> {
  List<Map<String, String>> quotes = [];
  int currentQuoteIndex = 0;
  Timer? quoteTimer;

  @override
  void initState() {
    super.initState();
    loadQuotes();
    // Change quote every 30 seconds
    quoteTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (quotes.isEmpty) return;
      setState(() {
        currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
      });
    });
  }

  @override
  void dispose() {
    quoteTimer?.cancel();
    super.dispose();
  }

  Future<void> loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quotes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        quotes = List<Map<String, String>>.from(
          jsonData['quotes'].map((quote) => {
                'text': quote['text'] as String,
                'author': quote['author'] as String,
              }),
        );
      });
    } catch (e) {
      debugPrint('Error loading quotes: $e');
    }
  }

  void nextQuote() {
    if (quotes.isEmpty) return;
    setState(() {
      currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
    });
  }

  void previousQuote() {
    if (quotes.isEmpty) return;
    setState(() {
      currentQuoteIndex = (currentQuoteIndex - 1 + quotes.length) % quotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add a setting in the settings page to enable/disable quotes using QuotesProvider
    final quotesProvider = context.watch<QuotesProvider>();
    
    if (quotes.isEmpty || !quotesProvider.showQuotes) {
      return const SizedBox.shrink();
    }

    final quote = quotes[currentQuoteIndex];

    return Positioned(
      bottom: 32,
      left: 32,
      right: 32,
      child: SailRawCard(
        padding: true,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: previousQuote,
                        color: Colors.grey[600],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '"${quote['text']}"',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '- ${quote['author']}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: nextQuote,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => quotesProvider.setShowQuotes(false),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}