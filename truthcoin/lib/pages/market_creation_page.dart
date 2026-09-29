import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';
import 'package:truthcoin/widgets/market_card.dart';

const double _panelWidth = 380;

/// Below this width the preview sits under the form, not beside it.
const double _twoColumnWidth = 900;
const int _networkFeeSats = 1000;

@RoutePage()
class MarketCreationPage extends StatelessWidget {
  const MarketCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MarketCreationViewModel>.reactive(
      viewModelBuilder: () => MarketCreationViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        final panel = [
          _PreviewCard(model: model),
          _CostCard(model: model),
          const _NextStepsCard(),
        ];

        return QtPage(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _twoColumnWidth) {
                return SingleChildScrollView(
                  child: SailColumn(
                    spacing: SailStyleValues.padding12,
                    children: [
                      _FormColumn(model: model),
                      ...panel,
                    ],
                  ),
                );
              }

              return SailRow(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SingleChildScrollView(child: _FormColumn(model: model)),
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

class _FormColumn extends StatelessWidget {
  final MarketCreationViewModel model;

  const _FormColumn({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      children: [
        SailRow(
          spacing: SailStyleValues.padding04,
          mainAxisSize: MainAxisSize.max,
          children: [
            SailButton(
              label: '←  Markets',
              variant: ButtonVariant.link,
              small: true,
              onPressed: () async => AutoRouter.of(context).maybePop(),
            ),
          ],
        ),
        SailColumn(
          spacing: SailStyleValues.padding04,
          children: [
            SailText.primary24('Create a market', bold: true),
            SailText.secondary13('A market needs a question, one decision slot, and a liquidity subsidy.'),
          ],
        ),
        _QuestionCard(model: model),
        _OutcomesCard(model: model),
        _LiquidityCard(model: model),
        _ActionRow(model: model),
      ],
    );
  }
}

/// Puts its children in a row on a wide card, and in a column on a narrow one.
class _Responsive extends StatelessWidget {
  final double breakpoint;
  final double spacing;
  final List<Widget> children;

  const _Responsive({required this.breakpoint, required this.spacing, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return SailColumn(spacing: spacing, children: children);
        }
        return SailRow(
          spacing: spacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [for (final child in children) Expanded(child: child)],
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final MarketCreationViewModel model;

  const _QuestionCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Question',
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        children: [
          SailTextField(
            controller: model.titleController,
            label: 'Title',
            hintText: 'Will the coin price close above 200,000 dollars on 31 December 2027?',
            maxLines: 1,
            onChanged: (_) => model.onFormChanged(),
          ),
          SailTextField(
            controller: model.descriptionController,
            label: 'Resolution text',
            hintText: 'State the source and the exact condition a voter reads.',
            maxLines: 4,
            onChanged: (_) => model.onFormChanged(),
          ),
        ],
      ),
    );
  }
}

class _OutcomesCard extends StatelessWidget {
  final MarketCreationViewModel model;

  const _OutcomesCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Outcomes',
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        children: [
          Wrap(
            spacing: SailStyleValues.padding08,
            runSpacing: SailStyleValues.padding04,
            children: [
              SailTabItem(
                label: 'Yes / No',
                isSelected: model.marketType == MarketType.binary,
                onTap: () => model.setMarketType(MarketType.binary),
              ),
              SailTabItem(
                label: 'Many outcomes',
                isSelected: model.marketType == MarketType.categorical,
                onTap: () => model.setMarketType(MarketType.categorical),
              ),
              SailTabItem(
                label: 'Custom',
                isSelected: model.marketType == MarketType.custom,
                onTap: () => model.setMarketType(MarketType.custom),
              ),
            ],
          ),
          if (model.marketType != MarketType.custom) ...[
            SailText.secondary12('Decision slot'),
            SailDropdownButton<String>(
              value: model.selectedSlotId,
              variant: ButtonVariant.outline,
              large: true,
              hint: model.isLoadingSlots ? 'Slots load' : 'Pick a slot',
              items: [
                for (final slot in model.claimedSlots)
                  SailDropdownItem<String>(
                    value: slot.slotIdHex,
                    // The trigger holds the id, so a long question never
                    // pushes the control past the card.
                    triggerChild: SailText.primary13(slot.slotIdHex, monospace: true),
                    child: SailText.primary13('${slot.slotIdHex}  ·  ${model.slotLabel(slot)}'),
                  ),
              ],
              onChanged: (id) {
                if (id != null) model.selectSlot(id);
              },
            ),
            if (model.slotError != null) SailInlineError(model.slotError!),
          ],
          SailTextField(
            controller: model.dimensionsController,
            label: model.marketType == MarketType.custom ? model.dimensionLabel : 'Or type a slot id',
            hintText: model.dimensionHint,
            onChanged: (_) => model.onSlotTextChanged(),
          ),
          if (model.typedSlotError != null)
            SailInlineError(model.typedSlotError!)
          else
            SailText.secondary12(model.dimensionHelp),
          if (model.marketType == MarketType.binary)
            _Responsive(
              breakpoint: 420,
              spacing: SailStyleValues.padding10,
              children: const [
                _StartPrice(label: 'Yes', tone: OutcomeTone.yes),
                _StartPrice(label: 'No', tone: OutcomeTone.no),
              ],
            ),
        ],
      ),
    );
  }
}

class _StartPrice extends StatelessWidget {
  final String label;
  final OutcomeTone tone;

  const _StartPrice({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final color = tone == OutcomeTone.yes ? theme.colors.success : theme.colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: SailText.primary13(label, bold: true, color: color)),
          SailText.primary13('starts at 50%', color: color),
        ],
      ),
    );
  }
}

class _LiquidityCard extends StatelessWidget {
  final MarketCreationViewModel model;

  const _LiquidityCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Liquidity and fee',
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        children: [
          Wrap(
            spacing: SailStyleValues.padding08,
            runSpacing: SailStyleValues.padding04,
            children: [
              SailTabItem(
                label: 'Initial liquidity',
                isSelected: model.liquidityMethod == LiquidityMethod.initialLiquidity,
                onTap: () => model.setLiquidityMethod(LiquidityMethod.initialLiquidity),
              ),
              SailTabItem(
                label: 'Liquidity β',
                isSelected: model.liquidityMethod == LiquidityMethod.beta,
                onTap: () => model.setLiquidityMethod(LiquidityMethod.beta),
              ),
            ],
          ),
          _Responsive(
            breakpoint: 620,
            spacing: SailStyleValues.padding12,
            children: [
              model.liquidityMethod == LiquidityMethod.initialLiquidity
                  ? SailTextField(
                      controller: model.liquidityController,
                      label: 'Initial liquidity (${activeTicker.subunit})',
                      hintText: '100000',
                      textFieldType: TextFieldType.number,
                      onChanged: (_) => model.onLiquidityInputChanged(),
                    )
                  : SailTextField(
                      controller: model.betaController,
                      label: 'Liquidity β',
                      hintText: '7.0',
                      textFieldType: TextFieldType.bitcoin,
                      onChanged: (_) => model.onLiquidityInputChanged(),
                    ),
              SailTextField(
                controller: model.tradingFeeController,
                label: 'Trading fee (%)',
                hintText: '0.5',
                textFieldType: TextFieldType.bitcoin,
                onChanged: (_) => model.onFormChanged(),
              ),
              SailButton(
                label: 'Calculate cost',
                variant: ButtonVariant.secondary,
                small: true,
                disabled: model.effectiveDimensions.isEmpty,
                onPressed: () async => model.calculateLiquidityPreview(),
              ),
            ],
          ),
          SailText.secondary12(
            model.liquidityMethod == LiquidityMethod.initialLiquidity
                ? 'More liquidity moves the price less per trade.'
                : 'β = liquidity / ln(number of outcomes).',
          ),
          Wrap(
            spacing: SailStyleValues.padding08,
            runSpacing: SailStyleValues.padding04,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SailText.secondary12('Fee presets'),
              for (final preset in const [0.5, 1.0, 2.0])
                SailTabItem(
                  label: '$preset%',
                  isSelected: model.tradingFeePercent == preset,
                  onTap: () => model.setTradingFee(preset),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final MarketCreationViewModel model;

  const _ActionRow({required this.model});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I.get<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, _) => SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          if (model.createError != null) SailInlineError(model.createError!),
          Wrap(
            spacing: SailStyleValues.padding12,
            runSpacing: SailStyleValues.padding08,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: SailColumn(
                  spacing: SailStyleValues.padding04,
                  children: [
                    SailText.primary15(
                      model.totalCostSats == null
                          ? 'Total cost unknown'
                          : 'Total cost ${formatter.formatSats(model.totalCostSats!)}',
                      bold: true,
                    ),
                    SailText.secondary12(
                      model.totalCostSats == null
                          ? 'press calculate cost to read the subsidy'
                          : 'subsidy plus the network fee',
                    ),
                  ],
                ),
              ),
              SailButton(
                label: 'Cancel',
                variant: ButtonVariant.secondary,
                onPressed: () async => AutoRouter.of(context).maybePop(),
              ),
              SailButton(
                label: 'Create market',
                loading: model.isCreating,
                disabled: !model.canCreate,
                onPressed: () async => model.createMarket(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final MarketCreationViewModel model;

  const _PreviewCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final title = model.titleController.text.trim();

    return SailCard(
      title: 'Preview',
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        children: [
          SailRow(
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
                child: SailText.secondary13(
                  title.isEmpty ? '?' : marketInitials(title),
                  bold: true,
                ),
              ),
              Expanded(
                child: SailColumn(
                  spacing: SailStyleValues.padding04,
                  children: [
                    SailText.primary15(
                      title.isEmpty ? 'Your question shows here' : title,
                      bold: true,
                    ),
                    SailText.secondary12(model.previewMeta),
                  ],
                ),
              ),
            ],
          ),
          const SailSeparator(),
          SailRow(
            spacing: SailStyleValues.padding08,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: SailText.secondary12('0 volume')),
              SailBadge('new'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final MarketCreationViewModel model;

  const _CostCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I.get<FormatterProvider>();
    final preview = model.liquidityPreview;

    return SailCard(
      title: 'Cost',
      subtitle: preview == null ? 'Press calculate cost to read the subsidy.' : null,
      child: ListenableBuilder(
        listenable: formatter,
        builder: (context, _) => SailColumn(
          spacing: SailStyleValues.padding08,
          children: [
            _CostRow(
              label: 'Liquidity subsidy',
              value: model.subsidySats == null ? '—' : formatter.formatSats(model.subsidySats!),
            ),
            if (preview != null) ...[
              _CostRow(label: 'Minimum treasury', value: formatter.formatSats(preview.minTreasurySats)),
              _CostRow(label: 'Outcomes', value: '${preview.numOutcomes}'),
              _CostRow(label: 'Liquidity β', value: preview.beta.toStringAsFixed(2)),
            ],
            _CostRow(label: 'Network fee', value: formatter.formatSats(_networkFeeSats)),
            const SailSeparator(),
            _CostRow(
              label: 'Total',
              value: model.totalCostSats == null ? '—' : formatter.formatSats(model.totalCostSats!),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _CostRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: SailText.secondary13(label)),
        bold ? SailText.primary15(value, bold: true) : SailText.primary13(value, bold: true),
      ],
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'The market opens as soon as the block confirms.',
      'A trade moves the price of every outcome.',
      'Voters answer the decision slot in its period.',
      'The market pays out after the tally.',
    ];

    return SailCard(
      title: 'What happens next',
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          for (final (index, step) in steps.indexed)
            SailRow(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SailBadge('${index + 1}'),
                Expanded(child: SailText.secondary12(step)),
              ],
            ),
        ],
      ),
    );
  }
}

class MarketCreationViewModel extends BaseViewModel {
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();
  final VotingProvider _votingProvider = GetIt.I.get<VotingProvider>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dimensionsController = TextEditingController();
  final TextEditingController liquidityController = TextEditingController(text: '100000');
  final TextEditingController betaController = TextEditingController(text: '7.0');
  final TextEditingController tradingFeeController = TextEditingController(text: '0.5');

  MarketType marketType = MarketType.binary;
  String? selectedSlotId;
  LiquidityMethod liquidityMethod = LiquidityMethod.initialLiquidity;
  InitialLiquidityCalculation? liquidityPreview;

  /// Counts the cost calculations, so a late answer never wins.
  int _liquidityRequest = 0;
  bool isCreating = false;
  String? createError;

  /// Dimensions in the bracket notation calculate_initial_liquidity takes.
  /// Empty when a dimension claims a new decision, which has no ID yet.
  String get effectiveDimensions {
    final input = dimensionsController.text.trim();
    if (input.isEmpty) return '';

    switch (marketType) {
      case MarketType.binary:
        return '[$input]';
      case MarketType.categorical:
        return '[[$input]]';
      case MarketType.custom:
        final dimensions = (jsonDecode(dimensionInputs) as List).cast<Map>();
        if (dimensions.any((d) => d['type'] != 'existing')) {
          return '';
        }
        return '[${dimensions.map((d) => d['id']).join(',')}]';
    }
  }

  /// Dimensions as the `DimensionInput` JSON array that market_create takes.
  String get dimensionInputs {
    final input = dimensionsController.text.trim();
    if (input.isEmpty) {
      return '[]';
    }

    try {
      final decoded = jsonDecode(input);
      if (decoded is Map) {
        return jsonEncode([decoded]);
      }
      if (decoded is List && decoded.every((d) => d is Map)) {
        return input;
      }
    } on FormatException {
      // Not JSON, so the input holds decision IDs.
    }

    final ids = input.split(RegExp(r'[\s,\[\]]+')).where((id) => id.isNotEmpty);
    return jsonEncode([
      for (final id in ids) {'type': 'existing', 'id': id},
    ]);
  }

  /// Slots the node reports, filtered to the ones that carry a decision.
  /// Slots the node reports, filtered to the decisions the market type takes.
  List<SlotListItem> get claimedSlots => _votingProvider.slots.where((slot) {
    final decision = slot.decision;
    if (decision == null) return false;
    return switch (marketType) {
      MarketType.binary => decision.isBinary,
      MarketType.categorical => decision.isCategory,
      MarketType.custom => true,
    };
  }).toList();

  bool get isLoadingSlots => _votingProvider.isLoading;
  String? get slotError => _votingProvider.error;

  /// The loaded slot that the typed id names, or null when the node lists no
  /// decision with that id.
  SlotListItem? get typedSlot {
    final id = dimensionsController.text.trim();
    if (id.isEmpty) return null;
    final match = _votingProvider.slots.where((slot) => slot.slotIdHex == id);
    return match.isEmpty ? null : match.first;
  }

  /// True when a dimension asks the node to claim a new decision. The node
  /// charges a tiered listing fee for such a claim, and this form reads no
  /// fee, so it never sends that market.
  bool get claimsNewDecision {
    final decoded = jsonDecode(dimensionInputs);
    if (decoded is! List) return false;
    return decoded.any((dimension) => dimension is Map && dimension['type'] != 'existing');
  }

  /// Why the dimension input does not fit, or null when it fits.
  String? get typedSlotError {
    if (claimsNewDecision) {
      return 'This form takes a claimed decision. Claim the decision first, then name its id.';
    }
    if (marketType == MarketType.custom) return null;

    final id = dimensionsController.text.trim();
    if (id.isEmpty) return null;

    if (_votingProvider.slots.isEmpty) {
      // Without the list the kind of the id stays unknown, and an unknown
      // kind decides the outcomes and the subsidy of the market.
      return 'The decision list did not load. Press refresh before you create a market.';
    }

    final slot = typedSlot;
    if (slot?.decision == null) {
      return 'The node lists no claimed decision with the id $id.';
    }

    final decision = slot!.decision!;
    if (marketType == MarketType.binary && !decision.isBinary) {
      final kind = decision.isCategory ? 'category' : 'scaled';
      return 'Slot $id carries a $kind decision. Pick another tab.';
    }
    if (marketType == MarketType.categorical && !decision.isCategory) {
      return 'Slot $id carries no category decision. Pick another tab.';
    }
    return null;
  }

  String slotLabel(SlotListItem slot) {
    final decision = slot.decision;
    if (decision == null) return slot.state.displayName;
    final kind = decision.isScaled
        ? 'scaled'
        : decision.isCategory
        ? 'category'
        : 'binary';
    return '${decision.question} ($kind)';
  }

  void init() {
    _votingProvider.addListener(notifyListeners);
    loadSlots();
  }

  Future<void> loadSlots() async {
    await _votingProvider.loadSlots();
  }

  void selectSlot(String slotIdHex) {
    selectedSlotId = slotIdHex;
    dimensionsController.text = slotIdHex;
    onLiquidityInputChanged();
  }

  /// The text field wins when the typed id leaves the picked slot.
  void onSlotTextChanged() {
    if (dimensionsController.text.trim() != selectedSlotId) {
      selectedSlotId = null;
    }
    onLiquidityInputChanged();
  }

  String get dimensionLabel => switch (marketType) {
    MarketType.binary => 'Decision slot id',
    MarketType.categorical => 'Category decision id',
    MarketType.custom => 'Dimensions',
  };

  String get dimensionHint => switch (marketType) {
    MarketType.binary => '004008',
    MarketType.categorical => '004008',
    MarketType.custom => '004008,004009',
  };

  String get dimensionHelp => switch (marketType) {
    MarketType.binary => 'One binary slot gives a Yes outcome and a No outcome.',
    MarketType.categorical => 'One category decision gives one outcome per option.',
    MarketType.custom => 'Name every slot id, or paste a DimensionInput JSON array.',
  };

  String get previewMeta {
    final slot = dimensionsController.text.trim();
    final parts = <String>[slot.isEmpty ? 'no slot yet' : 'slot $slot'];
    if (liquidityMethod == LiquidityMethod.beta) {
      parts.add('β ${betaController.text}');
    }
    parts.add('fee ${tradingFeeController.text}%');
    return parts.join('  ·  ');
  }

  double get tradingFeePercent => double.tryParse(tradingFeeController.text) ?? 0;

  /// Satoshis the author pays into the market maker. The figure comes from
  /// the same input that market_create submits. Beta mode knows the figure
  /// only after the node calculates it.
  int? get subsidySats {
    if (liquidityMethod == LiquidityMethod.initialLiquidity) {
      return int.tryParse(liquidityController.text) ?? 0;
    }
    return liquidityPreview?.initialLiquiditySats;
  }

  int? get totalCostSats {
    final subsidy = subsidySats;
    return subsidy == null ? null : subsidy + _networkFeeSats;
  }

  bool get canCreate {
    if (titleController.text.trim().isEmpty) return false;
    if (descriptionController.text.trim().isEmpty) return false;

    final input = dimensionsController.text.trim();
    if (input.isEmpty) return false;
    if (marketType == MarketType.categorical && !RegExp(r'^[0-9a-fA-F]+$').hasMatch(input)) {
      return false;
    }
    if (typedSlotError != null) return false;
    if (claimsNewDecision) return false;

    if (liquidityMethod == LiquidityMethod.beta) {
      if ((double.tryParse(betaController.text) ?? 0) <= 0) return false;
      // The node derives the subsidy from beta. A market goes out only after
      // the author reads that cost.
      if (liquidityPreview == null) return false;
    } else if ((int.tryParse(liquidityController.text) ?? 0) <= 0) {
      return false;
    }

    return tradingFeePercent > 0;
  }

  void onFormChanged() {
    notifyListeners();
  }

  /// An edit of beta, of the liquidity, or of a slot invalidates the last
  /// calculation, so the cost card never shows a figure for older inputs.
  void onLiquidityInputChanged() {
    _liquidityRequest++;
    liquidityPreview = null;
    notifyListeners();
  }

  void setMarketType(MarketType type) {
    marketType = type;
    dimensionsController.clear();
    selectedSlotId = null;
    liquidityPreview = null;
    notifyListeners();
  }

  void setLiquidityMethod(LiquidityMethod method) {
    liquidityMethod = method;
    onLiquidityInputChanged();
  }

  void setTradingFee(double fee) {
    tradingFeeController.text = fee.toString();
    notifyListeners();
  }

  Future<void> calculateLiquidityPreview() async {
    final beta = liquidityMethod == LiquidityMethod.beta ? double.tryParse(betaController.text) ?? 7.0 : 7.0;

    final request = ++_liquidityRequest;
    final result = await _marketProvider.calculateInitialLiquidity(
      beta: beta,
      dimensions: effectiveDimensions.isNotEmpty ? effectiveDimensions : null,
    );
    if (request != _liquidityRequest) return;

    liquidityPreview = result;
    createError = result == null ? 'The node gave no liquidity calculation' : null;
    notifyListeners();
  }

  Future<void> createMarket(BuildContext context) async {
    isCreating = true;
    createError = null;
    notifyListeners();

    final txid = await _marketProvider.createMarket(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dimensions: dimensionInputs,
      feeSats: _networkFeeSats,
      beta: liquidityMethod == LiquidityMethod.beta ? double.tryParse(betaController.text) : null,
      initialLiquidity: liquidityMethod == LiquidityMethod.initialLiquidity
          ? int.tryParse(liquidityController.text)
          : null,
      tradingFee: tradingFeePercent / 100,
    );

    isCreating = false;

    if (txid != null) {
      if (context.mounted) {
        showSailToast(
          context,
          'Market created: ${txid.length > 16 ? txid.substring(0, 16) : txid}',
          variant: SailToastVariant.success,
        );
        await AutoRouter.of(context).maybePop();
      }
    } else {
      createError = _marketProvider.error ?? 'The market creation failed';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _votingProvider.removeListener(notifyListeners);
    titleController.dispose();
    descriptionController.dispose();
    dimensionsController.dispose();
    liquidityController.dispose();
    betaController.dispose();
    tradingFeeController.dispose();
    super.dispose();
  }
}

enum MarketType { binary, categorical, custom }

enum LiquidityMethod { initialLiquidity, beta }
