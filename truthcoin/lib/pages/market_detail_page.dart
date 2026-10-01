import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/address_position.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/widgets/market_card.dart';
import 'package:truthcoin/widgets/price_chart.dart';

const double _panelWidth = 348;

/// Miner fee of one trade, as the node counts it.
const int _tradeMinerFeeSats = 1000;

/// Below this width the trade panel sits under the market, not beside it.
const double _twoColumnWidth = 900;

/// Below this width the range buttons move under the price.
const double _priceHeaderWidth = 520;

enum TradeMode { buy, sell }

@RoutePage()
class MarketDetailPage extends StatelessWidget {
  final String marketId;

  /// Outcome the market grid asks for. The panel selects it at startup.
  final int? initialOutcomeIndex;

  const MarketDetailPage({
    super.key,
    @PathParam('marketId') required this.marketId,
    this.initialOutcomeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MarketDetailViewModel>.reactive(
      viewModelBuilder: () => MarketDetailViewModel(
        marketId: marketId,
        initialOutcomeIndex: initialOutcomeIndex,
      ),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        if (model.isLoading) {
          return QtPage(
            child: Center(
              child: SailSkeletonizer(
                enabled: true,
                description: 'Market loads',
                child: SailText.primary15('Market loads'),
              ),
            ),
          );
        }

        final market = model.market;
        if (market == null) {
          return QtPage(
            child: Center(
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SailText.primary15(model.marketError ?? 'Market not found'),
                  SailButton(
                    label: 'Try again',
                    small: true,
                    onPressed: () async => model.load(),
                  ),
                ],
              ),
            ),
          );
        }

        final content = [
          _BackRow(model: model),
          _MarketHeaderCard(market: market),
          _PriceCard(model: model, market: market),
          _OutcomePricesCard(model: model, market: market),
          _MarketTabs(model: model, market: market),
        ];
        final panel = [
          _TradePanel(model: model, market: market),
          _MarketFactsCard(market: market),
        ];

        return QtPage(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _twoColumnWidth) {
                return SingleChildScrollView(
                  child: SailColumn(
                    spacing: SailStyleValues.padding12,
                    children: [...content, ...panel],
                  ),
                );
              }

              return SailRow(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: SailColumn(spacing: SailStyleValues.padding12, children: content),
                    ),
                  ),
                  SizedBox(
                    width: _panelWidth,
                    child: SingleChildScrollView(
                      child: SailColumn(spacing: SailStyleValues.padding12, children: panel),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _BackRow extends StatelessWidget {
  final MarketDetailViewModel model;

  const _BackRow({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding04,
      mainAxisSize: MainAxisSize.max,
      children: [
        SailButton(
          label: '←  Markets',
          variant: ButtonVariant.link,
          small: true,
          // The page sits in the Markets tab stack, so the nearest router
          // owns it, not the root one.
          onPressed: () async => AutoRouter.of(context).maybePop(),
        ),
        const Spacer(),
        SailButton(
          label: 'Refresh',
          variant: ButtonVariant.secondary,
          small: true,
          loading: model.isLoading,
          onPressed: () async => model.load(),
        ),
      ],
    );
  }
}

class _MarketHeaderCard extends StatelessWidget {
  final MarketData market;

  const _MarketHeaderCard({required this.market});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I.get<FormatterProvider>();

    return SailCard(
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailRow(
          spacing: SailStyleValues.padding12,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colors.backgroundSecondary,
                borderRadius: SailStyleValues.borderRadius,
              ),
              child: SailText.primary15(marketInitials(market.title), bold: true),
            ),
            Expanded(
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                children: [
                  SailText.primary22(market.title, bold: true),
                  Wrap(
                    spacing: SailStyleValues.padding10,
                    runSpacing: SailStyleValues.padding04,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SailBadge(
                        market.marketState.displayName,
                        tone: market.isTrading ? SailBadgeTone.success : SailBadgeTone.neutral,
                      ),
                      SailText.secondary12('${formatter.formatSats(market.totalVolumeSats)} volume'),
                      SailText.secondary12('·'),
                      SailText.secondary12('created at block ${market.createdAtHeight}'),
                      if (market.expiresAt != null) ...[
                        SailText.secondary12('·'),
                        SailText.secondary12('ends at block ${market.expiresAt}'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomePricesCard extends StatelessWidget {
  final MarketDetailViewModel model;
  final MarketData market;

  const _OutcomePricesCard({required this.model, required this.market});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I.get<FormatterProvider>();
    final outcomes = model.orderedOutcomes;

    return SailCard(
      title: 'Outcome prices',
      subtitle: 'The LMSR price of a share is also the chance of the outcome.',
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => _SideScroll(
          minWidth: 560,
          child: SailColumn(
            spacing: SailStyleValues.padding12,
            children: [
              for (final outcome in outcomes)
                SailRow(
                  spacing: SailStyleValues.padding12,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 160,
                      child: SailText.primary14(
                        outcome.name,
                        bold: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: _PriceBar(
                        fraction: outcome.currentPrice.clamp(0, 1).toDouble(),
                        color: theme.colors.success,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: SailText.primary13(formatChance(outcome.currentPrice), bold: true),
                    ),
                    SizedBox(
                      width: 110,
                      child: SailText.secondary12(formatter.formatSats(outcome.volumeSats)),
                    ),
                    OutcomeTradeButton(
                      label: model.selectedOutcome?.index == outcome.index ? 'Selected' : 'Trade',
                      price: formatChance(outcome.currentPrice),
                      tone: OutcomeTone.yes,
                      onTap: () => model.selectOutcome(outcome),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets a wide table scroll sideways inside a narrow window.
class _SideScroll extends StatelessWidget {
  final double minWidth;
  final Widget child;

  const _SideScroll({required this.minWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= minWidth) return child;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: child),
        );
      },
    );
  }
}

class _PriceBar extends StatelessWidget {
  final double fraction;
  final Color color;

  const _PriceBar({required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadiusSmall,
            ),
          ),
          Container(
            height: 6,
            width: constraints.maxWidth * fraction,
            decoration: BoxDecoration(
              color: color,
              borderRadius: SailStyleValues.borderRadiusSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  final MarketData market;

  const _RulesCard({required this.market});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I.get<FormatterProvider>();

    return SailCard(
      title: 'Resolution',
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailColumn(
          spacing: SailStyleValues.padding12,
          children: [
            SailText.primary13(market.description),
            const SailSeparator(),
            Wrap(
              spacing: SailStyleValues.padding25,
              runSpacing: SailStyleValues.padding12,
              children: [
                _Fact(label: 'Decision slots', value: market.decisionSlots.join(', ')),
                _Fact(label: 'Liquidity β', value: market.beta.toStringAsFixed(1)),
                _Fact(label: 'Trading fee', value: market.tradingFeePercent),
                _Fact(label: 'Treasury', value: formatter.formatBTC(market.treasury)),
                _Fact(label: 'Creator', value: market.marketMaker),
              ],
            ),
            if (market.tags.isNotEmpty)
              Wrap(
                spacing: SailStyleValues.padding08,
                runSpacing: SailStyleValues.padding04,
                children: [for (final tag in market.tags) SailBadge(tag)],
              ),
            if (market.resolution != null)
              SailAlert(
                variant: SailAlertVariant.info,
                title: 'Resolved',
                description: market.resolution!.summary,
              ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: SailColumn(
        spacing: SailStyleValues.padding04,
        children: [
          SailText.secondary12(label),
          SailText.primary14(
            value.isEmpty ? '—' : value,
            bold: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HoldersCard extends StatelessWidget {
  final MarketDetailViewModel model;

  const _HoldersCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I.get<FormatterProvider>();
    final positions = model.positions;

    return SailCard(
      title: 'Your positions in this market',
      subtitle: positions.isEmpty ? 'This wallet holds no share of this market.' : null,
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailColumn(
          spacing: SailStyleValues.padding08,
          children: [
            if (model.positionsError != null) SailInlineError(model.positionsError!),
            _SideScroll(
              minWidth: 640,
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                children: [
                  if (positions.isNotEmpty)
                    SailRow(
                      spacing: SailStyleValues.padding12,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(flex: 3, child: SailText.secondary12('Address')),
                        Expanded(flex: 2, child: SailText.secondary12('Outcome')),
                        Expanded(flex: 2, child: SailText.secondary12('Shares')),
                        Expanded(flex: 2, child: SailText.secondary12('Average price')),
                        Expanded(flex: 2, child: SailText.secondary12('Value')),
                        Expanded(flex: 2, child: SailText.secondary12('Profit')),
                      ],
                    ),
                  for (final holder in positions)
                    SailRow(
                      spacing: SailStyleValues.padding12,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SailText.primary13(holder.address, monospace: true),
                        ),
                        Expanded(flex: 2, child: SailText.primary13(holder.position.outcomeName, bold: true)),
                        Expanded(flex: 2, child: SailText.primary13('${holder.position.shares}')),
                        Expanded(
                          flex: 2,
                          child: SailText.primary13(formatChance(holder.position.avgPurchasePrice)),
                        ),
                        Expanded(
                          flex: 2,
                          child: SailText.primary13(formatter.formatSats(holder.position.currentValueSats)),
                        ),
                        Expanded(
                          flex: 2,
                          child: SailText.primary13(
                            holder.position.pnlDisplay,
                            bold: true,
                            color: holder.position.isProfit
                                ? SailTheme.of(context).colors.success
                                : SailTheme.of(context).colors.error,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradePanel extends StatelessWidget {
  final MarketDetailViewModel model;
  final MarketData market;

  const _TradePanel({required this.model, required this.market});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I.get<FormatterProvider>();

    if (!market.isTrading) {
      return SailCard(
        title: 'Trading closed',
        child: SailText.secondary13('The market state is ${market.marketState.displayName}.'),
      );
    }

    return SailCard(
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailColumn(
          spacing: SailStyleValues.padding12,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SailTabItem(
                    label: 'Buy',
                    isSelected: model.tradeMode == TradeMode.buy,
                    onTap: () => model.setTradeMode(TradeMode.buy),
                  ),
                ),
                Expanded(
                  child: SailTabItem(
                    label: 'Sell',
                    isSelected: model.tradeMode == TradeMode.sell,
                    onTap: () => model.setTradeMode(TradeMode.sell),
                  ),
                ),
              ],
            ),
            _OutcomeSelector(model: model),
            if (model.tradeMode == TradeMode.buy)
              ..._buyFields(context, formatter)
            else
              ..._sellFields(context, formatter),
          ],
        ),
      ),
    );
  }

  List<Widget> _buyFields(BuildContext context, FormatterProvider formatter) {
    final preview = model.preview;
    final outcome = model.selectedOutcome;

    return [
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: SailText.secondary12('Shares')),
          SailText.secondary12('balance ${formatter.formatBTC(model.walletBalance)}'),
        ],
      ),
      SailTextField(
        controller: model.sharesController,
        hintText: 'Shares to buy',
        textFieldType: TextFieldType.number,
        onChanged: (_) => model.updatePreview(),
      ),
      if (model.previewError != null) SailInlineError(model.previewError!),
      if (model.buyCostsTooMuch)
        SailAlert(
          variant: SailAlertVariant.warning,
          description: 'The total cost is above the wallet balance.',
        ),
      if (preview != null)
        _SummaryBox(
          rows: [
            ('Shares', '${preview.shares}'),
            ('Cost', formatter.formatSats(preview.costSats)),
            ('Trading fee', formatter.formatSats(preview.feeSats)),
            ('Total cost', formatter.formatSats(preview.totalCostSats)),
            ('Price after trade', formatChance(preview.postTradePrice)),
          ],
        ),
      SizedBox(
        width: double.infinity,
        child: SailButton(
          label: outcome == null ? 'Buy' : 'Buy ${outcome.name}',
          loading: model.isExecuting,
          disabled: preview == null || model.buyCostsTooMuch,
          onPressed: () async => model.executeBuy(context),
        ),
      ),
      SailText.secondary12('The LMSR market maker moves the price with the trade size.'),
    ];
  }

  List<Widget> _sellFields(BuildContext context, FormatterProvider formatter) {
    final preview = model.sellPreview;
    final outcome = model.selectedOutcome;

    return [
      SailText.secondary12('Seller address'),
      if (model.walletAddresses.isEmpty)
        SailText.primary13('The wallet reports no address.')
      else
        SailDropdownButton<String>(
          value: model.sellerAddress,
          items: [
            for (final address in model.walletAddresses)
              SailDropdownItem<String>(value: address, label: address, monospace: true),
          ],
          onChanged: (address) {
            if (address != null) model.setSellerAddress(address);
          },
        ),
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: SailText.secondary12('Shares')),
          SailText.secondary12('you hold ${model.sellerShares}'),
        ],
      ),
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SailTextField(
              controller: model.sellSharesController,
              hintText: 'Shares to sell',
              textFieldType: TextFieldType.number,
              onChanged: (_) => model.updateSellPreview(),
            ),
          ),
          SailButton(
            label: 'Max',
            variant: ButtonVariant.secondary,
            small: true,
            disabled: model.sellerShares <= 0,
            onPressed: () async => model.sellEverything(),
          ),
        ],
      ),
      if (model.sellError != null) SailInlineError(model.sellError!),
      if (preview != null)
        _SummaryBox(
          rows: [
            ('Gross proceeds', formatter.formatSats(preview.proceedsSats)),
            ('Trading fee', formatter.formatSats(preview.tradingFeeSats)),
            ('Net proceeds', formatter.formatSats(preview.netProceedsSats)),
            ('Price after trade', formatChance(preview.newPrice)),
          ],
        ),
      SizedBox(
        width: double.infinity,
        child: SailButton(
          label: outcome == null ? 'Sell' : 'Sell ${outcome.name}',
          variant: ButtonVariant.destructive,
          loading: model.isExecuting,
          disabled: preview == null || model.sellShares > model.sellerShares,
          onPressed: () async => model.executeSell(context),
        ),
      ),
      if (model.sellShares > model.sellerShares)
        SailAlert(
          variant: SailAlertVariant.warning,
          description: 'The address holds fewer shares than the sell asks for.',
        ),
    ];
  }
}

class _OutcomeSelector extends StatelessWidget {
  final MarketDetailViewModel model;

  const _OutcomeSelector({required this.model});

  @override
  Widget build(BuildContext context) {
    final outcomes = model.orderedOutcomes;

    if (outcomes.length == 2) {
      return SailRow(
        spacing: SailStyleValues.padding10,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (final outcome in outcomes)
            Expanded(
              child: _OutcomeChoice(
                outcome: outcome,
                selected: model.selectedOutcome?.index == outcome.index,
                tone: outcome.name.toLowerCase() == 'no' ? OutcomeTone.no : OutcomeTone.yes,
                onTap: () => model.selectOutcome(outcome),
              ),
            ),
        ],
      );
    }

    return SailColumn(
      spacing: SailStyleValues.padding04,
      children: [
        SailText.secondary12('Outcome'),
        SailDropdownButton<int>(
          value: model.selectedOutcome?.index,
          items: [
            for (final outcome in outcomes)
              SailDropdownItem<int>(
                value: outcome.index,
                label: '${outcome.name}  ${formatChance(outcome.currentPrice)}',
              ),
          ],
          onChanged: (index) {
            if (index == null) return;
            model.selectOutcome(outcomes.firstWhere((o) => o.index == index));
          },
        ),
        SailText.secondary12(
          'Chance ${model.selectedOutcome == null ? '—' : formatChance(model.selectedOutcome!.currentPrice)}',
        ),
      ],
    );
  }
}

class _OutcomeChoice extends StatelessWidget {
  final MarketOutcome outcome;
  final bool selected;
  final OutcomeTone tone;
  final VoidCallback onTap;

  const _OutcomeChoice({
    required this.outcome,
    required this.selected,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final color = tone == OutcomeTone.yes ? theme.colors.success : theme.colors.error;

    return SailTappable(
      onTap: () async => onTap(),
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : theme.colors.background,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: selected ? color : theme.colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: SailColumn(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.primary15(outcome.name, bold: true, color: selected ? color : theme.colors.text),
            SailText.secondary12(formatChance(outcome.currentPrice)),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final List<(String, String)> rows;

  const _SummaryBox({required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          for (final row in rows)
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: SailText.secondary12(row.$1)),
                SailText.primary13(row.$2, bold: true),
              ],
            ),
        ],
      ),
    );
  }
}

class _MarketFactsCard extends StatelessWidget {
  final MarketData market;

  const _MarketFactsCard({required this.market});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I.get<FormatterProvider>();

    return SailCard(
      title: 'Market',
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailColumn(
          spacing: SailStyleValues.padding08,
          children: [
            _FactRow(label: 'State', value: market.marketState.displayName),
            _FactRow(label: 'Outcomes', value: '${market.outcomes.length}'),
            _FactRow(label: 'Liquidity', value: formatter.formatBTC(market.liquidity)),
            _FactRow(label: 'Volume', value: formatter.formatSats(market.totalVolumeSats)),
            _FactRow(label: 'Created at block', value: '${market.createdAtHeight}'),
            _FactRow(label: 'Market id', value: market.shortId),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;

  const _FactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: SailText.secondary13(label)),
        SailText.primary13(value, bold: true),
      ],
    );
  }
}

/// The headline price of the market, with the chart of the readings the app
/// recorded. The node serves no price history, so the series starts empty.
class _PriceCard extends StatefulWidget {
  final MarketDetailViewModel model;
  final MarketData market;

  const _PriceCard({required this.model, required this.market});

  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  PriceRange _range = PriceRange.day;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final history = GetIt.I.get<PriceHistoryProvider>();
    final outcomes = widget.model.orderedOutcomes;
    if (outcomes.isEmpty) {
      return SailCard(child: SailText.secondary13('The node reports no outcome price.'));
    }

    // The chart follows the outcome the page selects, so a categorical
    // market charts the row the trade panel holds.
    final selected = widget.model.selectedOutcome;
    final lead = selected != null && outcomes.any((outcome) => outcome.index == selected.index)
        ? outcomes.firstWhere((outcome) => outcome.index == selected.index)
        : outcomes.firstWhere(
            (outcome) => shortOutcomeLabel(outcome.name).toLowerCase() == 'yes',
            orElse: () => outcomes.last,
          );
    final other = outcomes.length == 2 ? outcomes.firstWhere((outcome) => outcome != lead) : null;
    final seriesKey = '${widget.market.marketId}:${lead.index}';

    return SailCard(
      child: ListenableBuilder(
        listenable: history,
        builder: (context, _) {
          final change = history.dayChangePoints(seriesKey);

          final priceBlock = SailColumn(
            spacing: SailStyleValues.padding04,
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SailText.primary24(
                    '${shortOutcomeLabel(lead.name)} ${formatChance(lead.currentPrice)}',
                    bold: true,
                    color: lead.currentPrice >= 0.5 ? theme.colors.success : theme.colors.text,
                  ),
                  if (change != null && change.abs() >= 1)
                    SailText.primary13(
                      '${change > 0 ? '+' : ''}${change.round()} pts today',
                      bold: true,
                      color: change > 0 ? theme.colors.success : theme.colors.error,
                    ),
                ],
              ),
              SailText.secondary12(
                other == null
                    ? 'created at block ${widget.market.createdAtHeight}'
                    : '${shortOutcomeLabel(other.name)} ${formatChance(other.currentPrice)}  ·  created at block ${widget.market.createdAtHeight}',
              ),
            ],
          );

          final ranges = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SailToggleGroup<PriceRange>(
              items: [
                for (final range in PriceRange.values) SailToggleGroupItem(value: range, label: range.label),
              ],
              values: [_range],
              singleChoice: true,
              onChanged: (values) => setState(() => _range = values.isEmpty ? _range : values.first),
            ),
          );

          final chart = PriceChart(
            points: history.seriesFor(seriesKey, range: _range),
            color: lead.currentPrice >= 0.5 ? theme.colors.success : theme.colors.error,
          );

          return LayoutBuilder(
            builder: (context, constraints) => SailColumn(
              spacing: SailStyleValues.padding12,
              children: [
                if (constraints.maxWidth < _priceHeaderWidth) ...[
                  priceBlock,
                  ranges,
                ] else
                  SailRow(
                    spacing: SailStyleValues.padding12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [priceBlock, const Spacer(), ranges],
                  ),
                chart,
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _MarketTab { rules, holders }

/// The market page sections, one at a time, as the design shows them.
class _MarketTabs extends StatefulWidget {
  final MarketDetailViewModel model;
  final MarketData market;

  const _MarketTabs({required this.model, required this.market});

  @override
  State<_MarketTabs> createState() => _MarketTabsState();
}

class _MarketTabsState extends State<_MarketTabs> {
  _MarketTab _tab = _MarketTab.rules;

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SailToggleGroup<_MarketTab>(
            items: const [
              SailToggleGroupItem(value: _MarketTab.rules, label: 'Rules'),
              SailToggleGroupItem(value: _MarketTab.holders, label: 'Holders'),
            ],
            values: [_tab],
            singleChoice: true,
            onChanged: (values) => setState(() => _tab = values.isEmpty ? _tab : values.first),
          ),
        ),
        switch (_tab) {
          _MarketTab.rules => _RulesCard(market: widget.market),
          _MarketTab.holders => _HoldersCard(model: widget.model),
        },
      ],
    );
  }
}

class MarketDetailViewModel extends BaseViewModel {
  final String marketId;
  final int? initialOutcomeIndex;
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();
  final BalanceProvider _balanceProvider = GetIt.I.get<BalanceProvider>();
  final TruthcoinRPC _rpc = GetIt.I.get<TruthcoinRPC>();

  final TextEditingController sharesController = TextEditingController();
  final TextEditingController sellSharesController = TextEditingController();

  /// The market of this page only. Two detail pages can sit in one stack, so
  /// the page never reads the shared selection of the provider.
  MarketData? market;
  bool get isLoading => _marketProvider.isLoading;
  String? marketError;

  MarketOutcome? selectedOutcome;
  TradeMode tradeMode = TradeMode.buy;
  TradePreview? preview;
  String? previewError;
  MarketSellResponse? sellPreview;
  String? sellError;
  bool isExecuting = false;

  /// Counts the preview requests, so a late answer never wins.
  int _previewRequest = 0;
  int _sellPreviewRequest = 0;

  /// Positions of the wallet in this market, one entry per address.
  List<AddressPosition> positions = [];
  String? positionsError;

  /// Addresses of this wallet. A sell spends the shares of one of them.
  List<String> walletAddresses = [];
  String? sellerAddress;

  double get walletBalance => _balanceProvider.balance;

  /// Shares the seller address holds in the selected outcome.
  int get sellerShares {
    final outcome = selectedOutcome;
    if (outcome == null) return 0;
    final match = positions.where(
      (p) => p.address == sellerAddress && p.position.outcomeIndex == outcome.index,
    );
    return match.isEmpty ? 0 : match.first.position.shares;
  }

  /// True when the buy costs more than the wallet holds.
  bool get buyCostsTooMuch {
    final total = preview?.totalCostSats;
    if (total == null) return false;
    // The wallet pays the market cost and the miner fee of the trade.
    return satoshiToBTC(total + _tradeMinerFeeSats) > walletBalance;
  }

  int get shares => int.tryParse(sharesController.text) ?? 0;
  int get sellShares => int.tryParse(sellSharesController.text) ?? 0;

  List<MarketOutcome> get orderedOutcomes {
    final outcomes = [...?market?.outcomes];
    outcomes.sort((a, b) => a.displayIndex.compareTo(b.displayIndex));
    return outcomes;
  }

  MarketDetailViewModel({required this.marketId, this.initialOutcomeIndex});

  void init() {
    _marketProvider.addListener(_onProviderChange);
    _balanceProvider.addListener(_onProviderChange);
    load();
  }

  Future<void> load() async {
    market = null;
    marketError = null;
    selectedOutcome = null;
    positions = [];
    _previewRequest++;
    _sellPreviewRequest++;
    preview = null;
    previewError = null;
    sellPreview = null;
    sellError = null;
    sharesController.clear();
    sellSharesController.clear();
    notifyListeners();

    await loadWalletAddresses();
    await loadMarket();
  }

  void _onProviderChange() {
    // A trade reloads the market, so a page that already holds one takes the
    // fresh entry. A page whose own load failed keeps its error state.
    final fresh = _marketProvider.marketDetails[marketId];
    if (market != null && fresh != null && !identical(fresh, market)) {
      market = fresh;
      // The selection names an outcome of the old snapshot, so it reads the
      // same index in the new one.
      final index = selectedOutcome?.index;
      if (index != null) {
        for (final outcome in fresh.outcomes) {
          if (outcome.index == index) {
            selectedOutcome = outcome;
            break;
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> loadMarket() async {
    // The call answers its own result, so a failed load of another market
    // never hides this one.
    final loaded = await _marketProvider.loadMarket(marketId);
    market = loaded;
    marketError = loaded == null ? _marketProvider.error ?? 'Market not found' : null;

    final outcomes = orderedOutcomes;
    if (outcomes.isNotEmpty) {
      selectedOutcome = outcomes.firstWhere(
        (o) => o.index == initialOutcomeIndex,
        orElse: () => _defaultOutcome(outcomes),
      );
    }
    notifyListeners();

    await loadPositions();
  }

  /// Yes leads a binary market. Any other market leads with the best price.
  MarketOutcome _defaultOutcome(List<MarketOutcome> outcomes) {
    final yes = outcomes.where((o) => o.name.toLowerCase() == 'yes');
    if (outcomes.length == 2 && yes.isNotEmpty) return yes.first;
    return outcomes.reduce((a, b) => b.currentPrice > a.currentPrice ? b : a);
  }

  Future<void> loadWalletAddresses() async {
    try {
      walletAddresses = await _rpc.getWalletAddresses();
    } catch (e) {
      walletAddresses = [];
      positionsError = 'Failed to read the wallet addresses: $e';
      notifyListeners();
      return;
    }

    // The read worked, so an error of an older try stops here.
    positionsError = null;
    sellerAddress = walletAddresses.isEmpty ? null : walletAddresses.first;
    notifyListeners();
  }

  void setSellerAddress(String address) {
    sellerAddress = address;
    sellSharesController.clear();
    sellPreview = null;
    notifyListeners();
  }

  /// Put every share the address holds into the sell field.
  Future<void> sellEverything() async {
    if (sellerShares <= 0) return;
    sellSharesController.text = '$sellerShares';
    await updateSellPreview();
  }

  /// Reads the position of every wallet address in this market. The node
  /// scopes market_positions to one address.
  Future<void> loadPositions() async {
    if (walletAddresses.isEmpty) {
      // The address error of loadWalletAddresses stands.
      positions = [];
      notifyListeners();
      return;
    }

    final collected = <AddressPosition>[];

    for (final address in walletAddresses) {
      try {
        final response = await _rpc.marketPositions(address: address, marketId: marketId);
        for (final position in UserHoldings.fromJson(response).positions) {
          collected.add(AddressPosition(address, position));
        }
      } catch (e) {
        positions = [];
        positionsError = 'Failed to load the positions of $address: $e';
        notifyListeners();
        return;
      }
    }

    positions = collected;
    positionsError = null;
    notifyListeners();
  }

  void setTradeMode(TradeMode mode) {
    tradeMode = mode;
    notifyListeners();
  }

  void selectOutcome(MarketOutcome outcome) {
    _previewRequest++;
    _sellPreviewRequest++;
    selectedOutcome = outcome;
    preview = null;
    sellPreview = null;
    previewError = null;
    sellError = null;
    notifyListeners();
  }

  Future<void> updatePreview() async {
    if (selectedOutcome == null || shares <= 0) {
      _previewRequest++;
      preview = null;
      previewError = null;
      notifyListeners();
      return;
    }

    // Drop the old quote at once. A stale quote must never arm the button
    // while the new one loads.
    final request = ++_previewRequest;
    preview = null;
    previewError = null;
    notifyListeners();

    final result = await _marketProvider.buySharesPreview(
      marketId: marketId,
      outcomeIndex: selectedOutcome!.index,
      shares: shares,
    );
    if (request != _previewRequest) return;

    if (result.hasError) {
      preview = null;
      previewError = result.error;
    } else {
      preview = result;
      previewError = null;
    }

    notifyListeners();
  }

  Future<void> updateSellPreview() async {
    final address = sellerAddress ?? '';
    if (selectedOutcome == null || sellShares <= 0 || address.isEmpty) {
      _sellPreviewRequest++;
      sellPreview = null;
      sellError = null;
      notifyListeners();
      return;
    }

    final request = ++_sellPreviewRequest;
    sellPreview = null;
    sellError = null;
    notifyListeners();

    final result = await _marketProvider.sellSharesPreview(
      marketId: marketId,
      outcomeIndex: selectedOutcome!.index,
      shares: sellShares,
      sellerAddress: address,
    );
    if (request != _sellPreviewRequest) return;

    sellPreview = result;
    sellError = result == null ? 'The node gave no sell preview' : null;
    notifyListeners();
  }

  Future<void> executeBuy(BuildContext context) async {
    if (selectedOutcome == null || shares <= 0 || preview == null) return;

    isExecuting = true;
    notifyListeners();

    // The node rejects a buy without a cost limit. max_cost caps the market
    // charge, so it holds the previewed cost and a 2 percent slippage step.
    // The node pays its own miner fee, which max_cost never covers.
    final limit = preview!.totalCostSats + (preview!.totalCostSats ~/ 50).clamp(1, 1 << 30);
    final txid = await _marketProvider.buyShares(
      marketId: marketId,
      outcomeIndex: selectedOutcome!.index,
      shares: shares,
      maxCost: limit,
    );

    isExecuting = false;

    if (txid != null) {
      sharesController.clear();
      preview = null;
      await loadPositions();
      if (context.mounted) {
        showSailToast(context, 'Bought shares: ${_shortTxid(txid)}', variant: SailToastVariant.success);
      }
    } else if (context.mounted) {
      showSailToast(
        context,
        _marketProvider.error ?? 'The buy failed',
        variant: SailToastVariant.destructive,
      );
    }

    notifyListeners();
  }

  Future<void> executeSell(BuildContext context) async {
    final address = sellerAddress ?? '';
    if (selectedOutcome == null || sellShares <= 0 || address.isEmpty || sellPreview == null) return;

    isExecuting = true;
    notifyListeners();

    final net = sellPreview!.netProceedsSats;
    final txid = await _marketProvider.sellShares(
      marketId: marketId,
      outcomeIndex: selectedOutcome!.index,
      shares: sellShares,
      sellerAddress: address,
      minProceeds: (net - (net ~/ 50).clamp(1, 1 << 30)).clamp(0, net),
    );

    isExecuting = false;

    if (txid != null) {
      sellSharesController.clear();
      sellPreview = null;
      await loadPositions();
      if (context.mounted) {
        showSailToast(context, 'Sold shares: ${_shortTxid(txid)}', variant: SailToastVariant.success);
      }
    } else if (context.mounted) {
      showSailToast(
        context,
        _marketProvider.error ?? 'The sell failed',
        variant: SailToastVariant.destructive,
      );
    }

    notifyListeners();
  }

  String _shortTxid(String txid) => txid.length > 16 ? txid.substring(0, 16) : txid;

  @override
  void dispose() {
    _marketProvider.removeListener(_onProviderChange);
    _balanceProvider.removeListener(_onProviderChange);
    sharesController.dispose();
    sellSharesController.dispose();
    super.dispose();
  }
}
