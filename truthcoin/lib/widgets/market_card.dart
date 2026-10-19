import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';

/// Chance of an outcome, written in percent. One share pays one satoshi, so
/// the LMSR price of a share is also its chance.
String formatChance(double price) => '${(price * 100).round()}%';

/// The line under the top outcomes that names how many the card leaves out.
String moreOutcomesText(int count) => count == 1 ? '+ 1 more outcome' : '+ $count more outcomes';

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
      (o) => o.label.toLowerCase() == 'yes',
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

    // The tap target sits inside the card: the selection area of SailCard
    // wins a tap over a detector around it.
    return SailCard(
      padding: false,
      child: SailTappable(
        onTap: () async => onTap(),
        borderRadius: SailStyleValues.borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding20),
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              _header(theme),
              if (!market.isTrading)
                _closedPrices(theme)
              else if (_isBinary)
                _binaryButtons(theme)
              else
                _outcomeList(theme),
              _footer(formatter),
            ],
          ),
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
              SailText.primary22(
                formatChance(yes.currentPrice),
                bold: true,
                color: yes.currentPrice >= 0.5 ? theme.colors.success : theme.colors.text,
              ),
              SailText.secondary12(yes.label),
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
    return parts.join(' · ');
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
            label: 'Buy ${yes.label}',
            price: formatChance(yes.currentPrice),
            tone: OutcomeTone.yes,
            onTap: () => onTradeOutcome(yes.index),
          ),
        ),
        Expanded(
          child: OutcomeTradeButton(
            label: 'Buy ${no.label}',
            price: formatChance(no.currentPrice),
            tone: OutcomeTone.no,
            onTap: () => onTradeOutcome(no.index),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(MarketOutcome outcome) {
    return SailRow(
      spacing: SailStyleValues.padding10,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: SailText.primary13(outcome.label)),
        SailText.primary13(formatChance(outcome.currentPrice)),
      ],
    );
  }

  /// A closed market shows its last prices, and takes no trade.
  Widget _closedPrices(SailThemeData theme) {
    final outcomes = _outcomes;
    if (outcomes.isEmpty) return _pricePlaceholder(theme);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [for (final outcome in outcomes.take(3)) _priceRow(outcome)],
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

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        for (final outcome in byPrice.take(3)) _priceRow(outcome),
        if (byPrice.length > 3)
          SailTappable(
            onTap: () async => onTap(),
            child: SailText.secondary12(moreOutcomesText(byPrice.length - 3)),
          ),
        const SizedBox(height: SailStyleValues.padding04),
        SizedBox(
          width: double.infinity,
          child: SailButton(
            plainLabel: true,
            label: 'Trade',
            variant: ButtonVariant.secondary,
            onPressed: () async => onTap(),
          ),
        ),
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
            SailText.primary13(label, color: color),
            if (price != null) SailText.primary13(price!, color: color),
          ],
        ),
      ),
    );
  }
}
