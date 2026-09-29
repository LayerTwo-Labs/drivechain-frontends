import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';

/// Chance of an outcome, written in percent. One share pays one satoshi, so
/// the LMSR price of a share is also its chance.
String formatChance(double price) => '${(price * 100).round()}%';

/// Two letters that stand for the market, taken from the title.
String marketInitials(String title) {
  final words = title.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  final letters = words.map((w) => w[0].toUpperCase()).take(2).join();
  return letters.isEmpty ? '?' : letters;
}

/// A market in the grid, with the outcome prices the node reports.
class MarketCard extends StatelessWidget {
  final MarketSummary market;

  /// Full market data. The card shows prices as soon as it arrives.
  final MarketData? detail;

  final VoidCallback onTap;
  final void Function(int outcomeIndex) onTradeOutcome;

  const MarketCard({
    super.key,
    required this.market,
    required this.detail,
    required this.onTap,
    required this.onTradeOutcome,
  });

  List<MarketOutcome> get _outcomes {
    final outcomes = [...?detail?.outcomes];
    outcomes.sort((a, b) => a.displayIndex.compareTo(b.displayIndex));
    return outcomes;
  }

  bool get _isBinary => market.outcomeCount == 2;

  MarketOutcome? get _yesOutcome {
    final outcomes = _outcomes;
    if (outcomes.length != 2) return null;
    return outcomes.firstWhere(
      (o) => o.name.toLowerCase() == 'yes',
      orElse: () => outcomes.last,
    );
  }

  MarketOutcome? get _noOutcome {
    final outcomes = _outcomes;
    if (outcomes.length != 2) return null;
    final yes = _yesOutcome;
    return outcomes.firstWhere((o) => o != yes, orElse: () => outcomes.first);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I.get<FormatterProvider>();

    return SailTappable(
      onTap: () async => onTap(),
      borderRadius: SailStyleValues.borderRadius,
      child: SailCard(
        child: SailColumn(
          spacing: SailStyleValues.padding12,
          children: [
            _header(theme),
            if (!market.isTrading)
              _closedPrices(theme)
            else if (_isBinary)
              _binaryButtons(theme)
            else
              _outcomeList(theme),
            const SailSeparator(),
            _footer(formatter),
          ],
        ),
      ),
    );
  }

  Widget _header(SailThemeData theme) {
    final yes = _yesOutcome;

    return SailRow(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colors.backgroundSecondary,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SailText.secondary13(marketInitials(market.title), bold: true),
        ),
        Expanded(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            children: [
              SailText.primary15(market.title, bold: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              SailText.secondary12(_metaLine()),
            ],
          ),
        ),
        if (_isBinary && yes != null)
          SailColumn(
            spacing: 0,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SailText.primary24(
                formatChance(yes.currentPrice),
                bold: true,
                color: yes.currentPrice >= 0.5 ? theme.colors.success : theme.colors.text,
              ),
              SailText.secondary12(yes.name),
            ],
          ),
      ],
    );
  }

  String _metaLine() {
    final parts = <String>['${market.outcomeCount} outcomes'];
    if (detail != null) {
      parts.add('β ${detail!.beta.toStringAsFixed(1)}');
      parts.add('fee ${detail!.tradingFeePercent}');
    }
    return parts.join('  ·  ');
  }

  Widget _binaryButtons(SailThemeData theme) {
    final yes = _yesOutcome;
    final no = _noOutcome;
    if (yes == null || no == null) {
      return SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _pricePlaceholder(theme)),
          Expanded(child: _pricePlaceholder(theme)),
        ],
      );
    }

    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: OutcomeTradeButton(
            label: 'Buy ${yes.name}',
            price: formatChance(yes.currentPrice),
            tone: OutcomeTone.yes,
            onTap: () => onTradeOutcome(yes.index),
          ),
        ),
        Expanded(
          child: OutcomeTradeButton(
            label: 'Buy ${no.name}',
            price: formatChance(no.currentPrice),
            tone: OutcomeTone.no,
            onTap: () => onTradeOutcome(no.index),
          ),
        ),
      ],
    );
  }

  /// A closed market shows its last prices, and takes no trade.
  Widget _closedPrices(SailThemeData theme) {
    final outcomes = _outcomes;
    if (outcomes.isEmpty) return _pricePlaceholder(theme);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        for (final outcome in outcomes.take(3))
          SailRow(
            spacing: SailStyleValues.padding10,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SailText.primary14(outcome.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SailText.primary13(formatChance(outcome.currentPrice), bold: true),
            ],
          ),
      ],
    );
  }

  Widget _pricePlaceholder(SailThemeData theme) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailText.secondary12('price loads'),
    );
  }

  Widget _outcomeList(SailThemeData theme) {
    final outcomes = _outcomes;
    if (outcomes.isEmpty) {
      return SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          _pricePlaceholder(theme),
          _pricePlaceholder(theme),
        ],
      );
    }

    final byPrice = [...outcomes]..sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
    final top = byPrice.take(3).toList();

    return SailColumn(
      spacing: SailStyleValues.padding10,
      children: [
        for (final outcome in top)
          SailRow(
            spacing: SailStyleValues.padding10,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SailText.primary14(outcome.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SailText.primary13(formatChance(outcome.currentPrice), bold: true),
              OutcomeTradeButton(
                label: 'Yes',
                tone: OutcomeTone.yes,
                onTap: () => onTradeOutcome(outcome.index),
              ),
            ],
          ),
        if (byPrice.length > 3) SailText.secondary12('${byPrice.length - 3} more outcomes'),
      ],
    );
  }

  Widget _footer(FormatterProvider formatter) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: SailText.secondary12('${formatter.formatSats(market.volumeSats)} volume'),
        ),
        SailBadge(
          market.marketState.displayName,
          tone: switch (market.marketState) {
            MarketState.trading => SailBadgeTone.success,
            MarketState.ossified => SailBadgeTone.neutral,
            MarketState.cancelled || MarketState.invalid => SailBadgeTone.destructive,
          },
        ),
        SailText.secondary12('block ${market.createdAtHeight}'),
      ],
    );
  }
}

enum OutcomeTone { yes, no }

/// A tinted button that buys one outcome.
class OutcomeTradeButton extends StatelessWidget {
  final String label;
  final String? price;
  final OutcomeTone tone;
  final VoidCallback onTap;

  const OutcomeTradeButton({
    super.key,
    required this.label,
    required this.tone,
    required this.onTap,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final color = tone == OutcomeTone.yes ? theme.colors.success : theme.colors.error;

    return SailTappable(
      onTap: () async => onTap(),
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: SailRow(
          spacing: SailStyleValues.padding04,
          children: [
            SailText.primary13(label, bold: true, color: color),
            if (price != null) SailText.primary13(price!, bold: true, color: color),
          ],
        ),
      ),
    );
  }
}
