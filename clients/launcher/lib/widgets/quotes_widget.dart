import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool showQuotes = true;

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
      final List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        quotes = List<Map<String, String>>.from(
          jsonData.map(
            (quote) => {
              'quote': quote['quote'] as String,
              'author': quote['author'] as String,
            },
          ),
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
    final quotesProvider = context.watch<QuotesProvider>();

    return FutureBuilder<bool>(
      future: quotesProvider.showQuotes,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data! || quotes.isEmpty) {
          return const SizedBox.shrink();
        }

        final quote = quotes[currentQuoteIndex];

        return Positioned(
          bottom: 32,
          right: 32,
          child: SizedBox(
            width: 350,
            child: SailCard(
              padding: false, // Remove default padding
              child: Stack(
                children: [
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 14),
                          onPressed: previousQuote,
                          color: Colors.grey[600],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '"${quote['quote']}"', // Using stored 'text' key from JSON parsing
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '- ${quote['author']}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          onPressed: nextQuote,
                          color: Colors.grey[600],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 14),
                      onPressed: () => quotesProvider.setShowQuotes(false),
                      color: Colors.grey[600],
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
