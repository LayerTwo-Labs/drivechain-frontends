import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';

@RoutePage()
class MarketDetailPage extends StatelessWidget {
  final String marketId;

  const MarketDetailPage({super.key, @PathParam('marketId') required this.marketId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MarketDetailViewModel>.reactive(
      viewModelBuilder: () => MarketDetailViewModel(marketId: marketId),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        if (model.isLoading) {
          return QtPage(
            child: Center(
              child: SailSkeletonizer(
                enabled: true,
                description: 'Loading market...',
                child: SailText.primary15('Loading...'),
              ),
            ),
          );
        }

        if (model.marketError != null || model.market == null) {
          return QtPage(
            child: Center(
              child: SailColumn(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailText.primary15(model.marketError ?? 'Market not found'),
                  const SizedBox(height: 16),
                  SailButton(
                    label: 'Go Back',
                    onPressed: () async => AutoRouter.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          );
        }

        final market = model.market!;

        return QtPage(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Header
              SailRow(
                spacing: SailStyleValues.padding12,
                children: [
                  SailButton(
                    label: '← Back',
                    small: true,
                    onPressed: () async => AutoRouter.of(context).maybePop(),
                  ),
                  Expanded(
                    child: SailText.primary20(market.title, bold: true),
                  ),
                  _StateChip(state: market.marketState),
                ],
              ),

              // Description and metadata
              SailCard(
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary13(market.description),
                    const SizedBox(height: 8),
                    SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        ...market.tags.map((tag) => _TagChip(tag: tag)),
                      ],
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: SailRow(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Outcomes
                    Expanded(
                      flex: 3,
                      child: _OutcomesSection(model: model, market: market),
                    ),
                    // Right: Trading panel
                    Expanded(
                      flex: 2,
                      child: _TradingPanel(model: model, market: market),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OutcomesSection extends StatelessWidget {
  final MarketDetailViewModel model;
  final MarketData market;

  const _OutcomesSection({required this.model, required this.market});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SailCard(
      title: 'Outcomes',
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailColumn(
          spacing: SailStyleValues.padding12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...market.outcomes.map(
              (outcome) => _OutcomeBar(
                outcome: outcome,
                isSelected: model.selectedOutcome?.index == outcome.index,
                onTap: () => model.selectOutcome(outcome),
              ),
            ),
            const SizedBox(height: 16),
            SailRow(
              spacing: SailStyleValues.padding16,
              children: [
                _StatBox(
                  label: 'Volume',
                  value: formatter.formatSats(market.totalVolumeSats),
                ),
                _StatBox(
                  label: 'Liquidity',
                  value: market.liquidity.toStringAsFixed(2),
                ),
                _StatBox(
                  label: 'Trading Fee',
                  value: market.tradingFeePercent,
                ),
              ],
            ),
            if (market.decisionSlots.isNotEmpty) ...[
              const SizedBox(height: 16),
              SailText.secondary12('Decision Slots: ${market.decisionSlots.join(", ")}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _TradingPanel extends StatelessWidget {
  final MarketDetailViewModel model;
  final MarketData market;

  const _TradingPanel({required this.model, required this.market});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    if (!market.isTrading) {
      return SailCard(
        title: 'Trading Closed',
        child: SailColumn(
          children: [
            SailText.secondary15('This market is ${market.state}'),
            if (market.resolution != null) ...[
              const SizedBox(height: 16),
              SailText.primary15('Resolution:', bold: true),
              SailText.secondary13(market.resolution!.summary),
            ],
          ],
        ),
      );
    }

    return SailCard(
      title: 'Trade',
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailColumn(
          spacing: SailStyleValues.padding12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outcome selector
            SailText.secondary12('Outcome'),
            SailDropdownButton<int?>(
              value: model.selectedOutcome?.index,
              items: market.outcomes
                  .map(
                    (o) => SailDropdownItem<int?>(
                      value: o.index,
                      label: '${o.name} (${o.probabilityPercent})',
                    ),
                  )
                  .toList(),
              onChanged: (index) {
                if (index != null) {
                  final outcome = market.outcomes.firstWhere((o) => o.index == index);
                  model.selectOutcome(outcome);
                }
              },
            ),

            // Shares input
            const SizedBox(height: 8),
            SailText.secondary12('Shares'),
            SailTextField(
              controller: model.sharesController,
              hintText: 'Enter number of shares',
              textFieldType: TextFieldType.number,
              onChanged: (_) => model.updatePreview(),
            ),

            // Preview
            if (model.preview != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _PreviewRow(
                      label: 'Est. Cost',
                      value: formatter.formatSats(model.preview!.costSats),
                    ),
                    _PreviewRow(
                      label: 'Trading Fee',
                      value: formatter.formatSats(model.preview!.feeSats),
                    ),
                    _PreviewRow(
                      label: 'Total Cost',
                      value: formatter.formatSats(model.preview!.totalCostSats),
                      bold: true,
                    ),
                    _PreviewRow(
                      label: 'New Price',
                      value: '${(model.preview!.postTradePrice * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
            ],

            if (model.previewError != null) ...[
              const SizedBox(height: 8),
              SailText.secondary12(model.previewError!, color: theme.colors.error),
            ],

            // Action buttons
            const SizedBox(height: 16),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailButton(
                    label: 'Preview',
                    onPressed: () async => model.updatePreview(),
                    disabled: model.selectedOutcome == null || model.shares <= 0,
                  ),
                ),
                Expanded(
                  child: SailButton(
                    label: 'Buy Shares',
                    onPressed: () async => model.executeBuy(context),
                    disabled: model.selectedOutcome == null || model.shares <= 0 || model.preview == null,
                    loading: model.isExecuting,
                  ),
                ),
              ],
            ),

            // Sell button
            const SizedBox(height: 8),
            SailButton(
              label: 'Sell Shares',
              onPressed: () async => model.openSellDialog(context),
              disabled: model.selectedOutcome == null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final MarketState state;

  const _StateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    Color bgColor;
    switch (state) {
      case MarketState.trading:
        bgColor = theme.colors.success.withValues(alpha: 0.2);
      case MarketState.ossified:
        bgColor = theme.colors.info.withValues(alpha: 0.2);
      case MarketState.cancelled:
      case MarketState.invalid:
        bgColor = theme.colors.error.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SailText.primary13(state.displayName),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SailText.secondary12(tag),
    );
  }
}

class _OutcomeBar extends StatelessWidget {
  final MarketOutcome outcome;
  final bool isSelected;
  final VoidCallback onTap;

  const _OutcomeBar({
    required this.outcome,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final probability = outcome.probability.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.primary.withValues(alpha: 0.1) : theme.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: SailColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SailText.primary15(outcome.name, bold: true),
                SailText.primary15(outcome.probabilityPercent, bold: true),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: probability,
                backgroundColor: theme.colors.background,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        SailText.primary15(value, bold: true),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SailText.secondary13(label),
        bold ? SailText.primary13(value, bold: true) : SailText.secondary13(value),
      ],
    );
  }
}

class MarketDetailViewModel extends BaseViewModel {
  final String marketId;
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();
  final TextEditingController sharesController = TextEditingController();

  MarketData? get market => _marketProvider.selectedMarket;
  bool get isLoading => _marketProvider.isLoading;
  String? get marketError => _marketProvider.error;

  MarketOutcome? selectedOutcome;
  TradePreview? preview;
  String? previewError;
  bool isExecuting = false;

  int get shares => int.tryParse(sharesController.text) ?? 0;

  MarketDetailViewModel({required this.marketId});

  void init() {
    _marketProvider.addListener(_onProviderChange);
    loadMarket();
  }

  void _onProviderChange() {
    notifyListeners();
  }

  Future<void> loadMarket() async {
    await _marketProvider.loadMarket(marketId);
    if (market != null && market!.outcomes.isNotEmpty) {
      selectedOutcome = market!.outcomes.first;
      notifyListeners();
    }
  }

  void selectOutcome(MarketOutcome outcome) {
    selectedOutcome = outcome;
    preview = null;
    previewError = null;
    notifyListeners();
  }

  Future<void> updatePreview() async {
    if (selectedOutcome == null || shares <= 0) {
      preview = null;
      previewError = null;
      notifyListeners();
      return;
    }

    preview = await _marketProvider.buySharesPreview(
      marketId: marketId,
      outcomeIndex: selectedOutcome!.index,
      shares: shares,
    );

    if (preview!.hasError) {
      previewError = preview!.error;
      preview = null;
    } else {
      previewError = null;
    }

    notifyListeners();
  }

  Future<void> executeBuy(BuildContext context) async {
    if (selectedOutcome == null || shares <= 0 || preview == null) return;

    isExecuting = true;
    notifyListeners();

    final txid = await _marketProvider.buyShares(
      marketId: marketId,
      outcomeIndex: selectedOutcome!.index,
      shares: shares,
    );

    isExecuting = false;

    if (txid != null) {
      sharesController.clear();
      preview = null;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase successful: ${txid.substring(0, 16)}...')),
        );
      }
    }

    notifyListeners();
  }

  Future<void> openSellDialog(BuildContext context) async {
    // Show sell dialog
    if (selectedOutcome == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _SellDialog(
        marketId: marketId,
        outcome: selectedOutcome!,
        marketProvider: _marketProvider,
      ),
    );

    if (result == true) {
      await loadMarket();
    }
  }

  @override
  void dispose() {
    _marketProvider.removeListener(_onProviderChange);
    sharesController.dispose();
    super.dispose();
  }
}

class _SellDialog extends StatefulWidget {
  final String marketId;
  final MarketOutcome outcome;
  final MarketProvider marketProvider;

  const _SellDialog({
    required this.marketId,
    required this.outcome,
    required this.marketProvider,
  });

  @override
  State<_SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<_SellDialog> {
  final TextEditingController sharesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  MarketSellResponse? preview;
  bool isLoading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return AlertDialog(
      title: Text('Sell ${widget.outcome.name} Shares'),
      content: SizedBox(
        width: 400,
        child: ListenableBuilder(
          listenable: formatter,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary12('Seller Address'),
              const SizedBox(height: 4),
              SailTextField(
                controller: addressController,
                hintText: 'Your address holding the shares',
              ),
              const SizedBox(height: 12),
              SailText.secondary12('Shares to Sell'),
              const SizedBox(height: 4),
              SailTextField(
                controller: sharesController,
                hintText: 'Number of shares',
                textFieldType: TextFieldType.number,
              ),
              if (preview != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _PreviewRow(
                        label: 'Gross Proceeds',
                        value: formatter.formatSats(preview!.proceedsSats),
                      ),
                      _PreviewRow(
                        label: 'Trading Fee',
                        value: formatter.formatSats(preview!.tradingFeeSats),
                      ),
                      _PreviewRow(
                        label: 'Net Proceeds',
                        value: formatter.formatSats(preview!.netProceedsSats),
                        bold: true,
                      ),
                      _PreviewRow(
                        label: 'New Price',
                        value: preview!.newPricePercent,
                      ),
                    ],
                  ),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 8),
                SailText.secondary12(error!, color: theme.colors.error),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _previewSell,
          child: const Text('Preview'),
        ),
        ElevatedButton(
          onPressed: preview != null ? _executeSell : null,
          child: isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Sell'),
        ),
      ],
    );
  }

  Future<void> _previewSell() async {
    final shares = int.tryParse(sharesController.text) ?? 0;
    final address = addressController.text.trim();

    if (shares <= 0 || address.isEmpty) {
      setState(() => error = 'Enter valid shares and address');
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    preview = await widget.marketProvider.sellSharesPreview(
      marketId: widget.marketId,
      outcomeIndex: widget.outcome.index,
      shares: shares,
      sellerAddress: address,
    );

    setState(() {
      isLoading = false;
      if (preview == null) {
        error = 'Failed to get preview';
      }
    });
  }

  Future<void> _executeSell() async {
    final shares = int.tryParse(sharesController.text) ?? 0;
    final address = addressController.text.trim();

    if (shares <= 0 || address.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    final txid = await widget.marketProvider.sellShares(
      marketId: widget.marketId,
      outcomeIndex: widget.outcome.index,
      shares: shares,
      sellerAddress: address,
    );

    setState(() => isLoading = false);

    if (txid != null && mounted) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => error = widget.marketProvider.error ?? 'Sell failed');
    }
  }

  @override
  void dispose() {
    sharesController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
