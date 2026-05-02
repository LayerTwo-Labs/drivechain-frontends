import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sail_ui/sail_ui.dart';

/// Full-width slim strip showing a rotating Bitcoin / liberty quote.
///
/// Quotes auto-advance every 5 minutes; user can navigate manually with the
/// prev/next arrows (which resets the rotation timer).
///
/// Quotes are loaded from `packages/sail_ui/assets/quotes.json` by default.
/// Tests can inject a custom list via [quotes] to bypass asset loading.
class QuoteBar extends StatefulWidget {
  final List<Map<String, String>>? quotes;

  const QuoteBar({super.key, this.quotes});

  @override
  State<QuoteBar> createState() => _QuoteBarState();
}

class _QuoteBarState extends State<QuoteBar> {
  static const Duration _rotationInterval = Duration(minutes: 5);

  List<_Quote> _quotes = const [];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.quotes != null) {
      final list = widget.quotes!.map(_Quote.fromMap).toList();
      if (list.isNotEmpty) {
        _quotes = list;
        _startTimer();
      }
    } else {
      _loadQuotes();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    try {
      final raw = await rootBundle.loadString(
        'packages/sail_ui/assets/quotes.json',
      );
      final list = (json.decode(raw) as List<dynamic>)
          .map(
            (e) => _Quote.fromMap(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList();

      if (!mounted || list.isEmpty) return;

      setState(() {
        _quotes = list;
      });
      _startTimer();
    } catch (_) {
      // On failure, bar simply stays empty — no crash.
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_rotationInterval, (_) {
      if (!mounted || _quotes.isEmpty) return;
      setState(() {
        _index = (_index + 1) % _quotes.length;
      });
    });
  }

  void _advance(int delta) {
    if (_quotes.isEmpty) return;
    setState(() {
      _index = (_index + delta) % _quotes.length;
      if (_index < 0) _index += _quotes.length;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final quote = _quotes.isEmpty ? null : _quotes[_index];

    return Container(
      constraints: const BoxConstraints(minHeight: 56, maxHeight: 72),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        border: Border.all(color: colors.border),
        borderRadius: SailStyleValues.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SailButton(
            key: const ValueKey('quote_bar_prev'),
            icon: SailSVGAsset.chevronLeft,
            variant: ButtonVariant.icon,
            small: true,
            iconHeight: 10,
            iconWidth: 10,
            padding: const EdgeInsets.all(4),
            onPressed: _quotes.isEmpty ? null : () async => _advance(-1),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: quote == null
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SailText.primary12(
                          quote.quote,
                          italic: true,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        SailText.secondary12(
                          '— ${quote.author}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
          SailButton(
            key: const ValueKey('quote_bar_next'),
            icon: SailSVGAsset.chevronRight,
            variant: ButtonVariant.icon,
            small: true,
            iconHeight: 10,
            iconWidth: 10,
            padding: const EdgeInsets.all(4),
            onPressed: _quotes.isEmpty ? null : () async => _advance(1),
          ),
        ],
      ),
    );
  }
}

class _Quote {
  final String quote;
  final String author;

  const _Quote({required this.quote, required this.author});

  factory _Quote.fromMap(Map<String, dynamic> map) {
    return _Quote(
      quote: (map['quote']?.toString()) ?? '',
      author: (map['author']?.toString()) ?? '',
    );
  }
}
