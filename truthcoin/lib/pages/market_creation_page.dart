import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/market_creation.dart';
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
              plainLabel: true,
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
            SailText.secondary13('A market needs a question, one or more decisions, and a liquidity subsidy.'),
          ],
        ),
        _QuestionCard(model: model),
        _DecisionsCard(model: model),
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

class _DecisionsCard extends StatelessWidget {
  final MarketCreationViewModel model;

  const _DecisionsCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Decisions',
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        children: [
          SailDropdownButton<String>(
            value: null,
            variant: ButtonVariant.outline,
            large: true,
            hint: model.isLoadingSlots ? 'Decisions load' : 'Add Existing Decision',
            items: [
              for (final slot in model.addableSlots)
                SailDropdownItem<String>(
                  value: slot.slotIdHex,
                  // The closed button holds the id, so a long question never
                  // pushes the control past the card.
                  label: slot.slotIdHex,
                  child: SailText.primary13('${slot.slotIdHex}  ·  ${model.slotLabel(slot)}'),
                ),
            ],
            onChanged: (id) {
              if (id != null) model.addExistingDecision(id);
            },
          ),
          for (final slot in model.existingDecisions) _ExistingDecisionRow(model: model, slot: slot),
          if (model.slotError != null) SailInlineError(model.slotError!),
          if (model.periodsError != null) SailInlineError(model.periodsError!),
          for (final (index, draft) in model.newDecisions.indexed)
            _NewDecisionCard(key: ObjectKey(draft), model: model, number: index + 1, draft: draft),
          SailRow(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SailButton(
                plainLabel: true,
                label: 'Add New Decision',
                icon: SailSVGAsset.plus,
                variant: ButtonVariant.outline,
                onPressed: () async => model.addNewDecision(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExistingDecisionRow extends StatelessWidget {
  final MarketCreationViewModel model;
  final SlotListItem slot;

  const _ExistingDecisionRow({required this.model, required this.slot});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        left: SailStyleValues.padding12,
        right: SailStyleValues.padding04,
        top: SailStyleValues.padding04,
        bottom: SailStyleValues.padding04,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailRow(
        spacing: SailStyleValues.padding12,
        mainAxisSize: MainAxisSize.max,
        children: [
          SailText.secondary13('Existing decision'),
          SailText.primary13(slot.slotIdHex, monospace: true),
          Expanded(child: SailText.primary13(model.slotLabel(slot))),
          SailTooltip(
            message: 'Remove',
            child: SailButton(
              variant: ButtonVariant.icon,
              icon: SailSVGAsset.x,
              small: true,
              onPressed: () async => model.removeExistingDecision(slot.slotIdHex),
            ),
          ),
        ],
      ),
    );
  }
}

const double _decisionLabelWidth = 110;
const double _decisionRowBreakpoint = 420;

class _NewDecisionCard extends StatelessWidget {
  final MarketCreationViewModel model;
  final int number;
  final NewDecisionDraft draft;

  const _NewDecisionCard({super.key, required this.model, required this.number, required this.draft});

  /// The label sits left of the control, and above it on a narrow card.
  Widget _row(String label, Widget control) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _decisionRowBreakpoint) {
          return SailColumn(
            spacing: SailStyleValues.padding04,
            children: [SailText.secondary13(label), control],
          );
        }
        return SailRow(
          spacing: SailStyleValues.padding12,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: _decisionLabelWidth, child: SailText.secondary13(label)),
            Expanded(child: control),
          ],
        );
      },
    );
  }

  Widget _field(String label, TextEditingController controller, String hint) {
    return _row(
      label,
      SailTextField(
        controller: controller,
        hintText: hint,
        maxLines: 1,
        onChanged: (_) => model.onDecisionChanged(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final error = draft.isBlank ? null : draft.error;

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding10,
        children: [
          SailRow(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: SailText.primary13('New decision #$number', bold: true)),
              if (model.decisionCount > 1)
                SailTooltip(
                  message: 'Remove',
                  child: SailButton(
                    key: ValueKey('remove_new_decision_$number'),
                    variant: ButtonVariant.icon,
                    icon: SailSVGAsset.x,
                    small: true,
                    onPressed: () async => model.removeNewDecision(draft),
                  ),
                ),
            ],
          ),
          _row(
            'Period',
            SailDropdownButton<int>(
              value: draft.periodIndex,
              variant: ButtonVariant.outline,
              large: true,
              hint: model.isLoadingPeriods ? 'Periods load' : 'Pick a period',
              items: [
                for (final period in model.periods)
                  SailDropdownItem<int>(value: period.periodIndex, label: period.label),
              ],
              onChanged: (period) {
                if (period != null) model.setDecisionPeriod(draft, period);
              },
            ),
          ),
          _row(
            'Type',
            Wrap(
              spacing: SailStyleValues.padding08,
              runSpacing: SailStyleValues.padding04,
              children: [
                for (final type in NewDecisionType.values)
                  SailTabItem(
                    label: type.label,
                    isSelected: draft.type == type,
                    onTap: () => model.setDecisionType(draft, type),
                  ),
              ],
            ),
          ),
          _field('Header', draft.header, 'Decision-specific question'),
          ...switch (draft.type) {
            NewDecisionType.binary => [
              _field('Option 0 label', draft.option0Label, 'No / False'),
              _field('Option 1 label', draft.option1Label, 'Yes / True'),
            ],
            NewDecisionType.scaled => [
              _field('Min', draft.min, '0'),
              _field('Max', draft.max, '1'),
              _field('Increment', draft.increment, '1'),
            ],
            NewDecisionType.category => [
              _field('Option labels', draft.optionLabels, 'Red, Green, Blue'),
            ],
          },
          if (error != null) SailInlineError(error),
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
                plainLabel: true,
                label: 'Calculate cost',
                variant: ButtonVariant.secondary,
                small: true,
                disabled: !model.hasDimensions,
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
                plainLabel: true,
                label: 'Cancel',
                variant: ButtonVariant.secondary,
                onPressed: () async => AutoRouter.of(context).maybePop(),
              ),
              SailButton(
                plainLabel: true,
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
            if (model.listingFeeSats > 0)
              _CostRow(label: 'Decision listing', value: formatter.formatSats(model.listingFeeSats)),
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
  final TextEditingController liquidityController = TextEditingController(text: '100000');
  final TextEditingController betaController = TextEditingController(text: '7.0');
  final TextEditingController tradingFeeController = TextEditingController(text: '0.5');

  final List<String> existingDecisionIds = [];
  final List<NewDecisionDraft> newDecisions = [NewDecisionDraft()];

  List<OpenPeriod> periods = [];
  bool isLoadingPeriods = false;
  String? periodsError;

  LiquidityMethod liquidityMethod = LiquidityMethod.initialLiquidity;
  InitialLiquidityCalculation? liquidityPreview;

  /// Counts the cost calculations, so a late answer never wins.
  int _liquidityRequest = 0;
  bool isCreating = false;
  String? createError;

  /// Every claimed decision the node lists.
  List<SlotListItem> get claimedSlots => _votingProvider.slots.where((slot) => slot.decision != null).toList();

  bool get isLoadingSlots => _votingProvider.isLoading;
  String? get slotError => _votingProvider.error;

  /// The claimed decisions the author added, in the order of the picks.
  List<SlotListItem> get existingDecisions => [
    for (final id in existingDecisionIds) ...claimedSlots.where((slot) => slot.slotIdHex == id).take(1),
  ];

  /// Claimed decisions the picker still offers.
  List<SlotListItem> get addableSlots =>
      claimedSlots.where((slot) => !existingDecisionIds.contains(slot.slotIdHex)).toList();

  /// The new-decision cards the author filled in.
  List<NewDecisionDraft> get usedNewDecisions => newDecisions.where((draft) => !draft.isBlank).toList();

  bool get hasDimensions => existingDecisionIds.isNotEmpty || usedNewDecisions.isNotEmpty;

  /// Dimensions as the `DimensionInput` JSON array that market_create takes.
  String get dimensionInputs => jsonEncode([
    for (final id in existingDecisionIds) {'type': 'existing', 'id': id},
    for (final draft in usedNewDecisions) draft.toDimension(),
  ]);

  /// Sats the node charges to claim the new decisions, at the cheapest price
  /// of each picked period.
  int get listingFeeSats => usedNewDecisions.fold(0, (sum, draft) {
    final period = periods.where((p) => p.periodIndex == draft.periodIndex);
    return sum + (period.isEmpty ? 0 : period.first.cheapestSats);
  });

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
    loadPeriods();
  }

  Future<void> loadSlots() async {
    await _votingProvider.loadSlots();
  }

  Future<void> loadPeriods() async {
    isLoadingPeriods = true;
    periodsError = null;
    notifyListeners();
    try {
      periods = await _marketProvider.listOpenPeriods();
      if (periods.isNotEmpty) {
        for (final draft in newDecisions) {
          draft.periodIndex ??= periods.first.periodIndex;
        }
      }
    } catch (e) {
      periodsError = 'The open periods did not load: $e';
    }
    isLoadingPeriods = false;
    notifyListeners();
  }

  void addExistingDecision(String slotIdHex) {
    if (existingDecisionIds.contains(slotIdHex)) return;
    existingDecisionIds.add(slotIdHex);
    onLiquidityInputChanged();
  }

  void removeExistingDecision(String slotIdHex) {
    existingDecisionIds.remove(slotIdHex);
    onLiquidityInputChanged();
  }

  /// Existing and new decisions, the cards with no input too.
  int get decisionCount => existingDecisionIds.length + newDecisions.length;

  void removeNewDecision(NewDecisionDraft draft) {
    newDecisions.remove(draft);
    // The removed card still holds the controllers until the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => draft.dispose());
    onLiquidityInputChanged();
  }

  void addNewDecision() {
    newDecisions.add(NewDecisionDraft(periodIndex: periods.isEmpty ? null : periods.first.periodIndex));
    notifyListeners();
  }

  void setDecisionPeriod(NewDecisionDraft draft, int periodIndex) {
    draft.periodIndex = periodIndex;
    notifyListeners();
  }

  void setDecisionType(NewDecisionDraft draft, NewDecisionType type) {
    draft.type = type;
    onLiquidityInputChanged();
  }

  void onDecisionChanged() {
    onLiquidityInputChanged();
  }

  String get previewMeta {
    final count = existingDecisionIds.length + usedNewDecisions.length;
    final parts = <String>[
      switch (count) {
        0 => 'no decision yet',
        1 => '1 decision',
        _ => '$count decisions',
      },
    ];
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
    return subsidy == null ? null : subsidy + listingFeeSats + _networkFeeSats;
  }

  /// Outcomes of the market: the product of the outcomes of each dimension.
  int get outcomeCount {
    var count = 1;
    for (final id in existingDecisionIds) {
      final match = claimedSlots.where((slot) => slot.slotIdHex == id);
      final decision = match.isEmpty ? null : match.first.decision;
      count *= decision != null && decision.isCategory ? decision.categoryOptions.length : 2;
    }
    for (final draft in usedNewDecisions) {
      count *= draft.outcomeCount;
    }
    return count;
  }

  bool get canCreate {
    if (titleController.text.trim().isEmpty) return false;
    if (descriptionController.text.trim().isEmpty) return false;
    if (!hasDimensions) return false;
    if (usedNewDecisions.any((draft) => draft.error != null)) return false;

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

  /// An edit of beta, of the liquidity, or of a decision invalidates the last
  /// calculation, so the cost card never shows a figure for older inputs.
  void onLiquidityInputChanged() {
    _liquidityRequest++;
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
    final result = await _marketProvider.calculateInitialLiquidity(beta: beta, numOutcomes: outcomeCount);
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
    liquidityController.dispose();
    betaController.dispose();
    tradingFeeController.dispose();
    for (final draft in newDecisions) {
      draft.dispose();
    }
    super.dispose();
  }
}

enum LiquidityMethod { initialLiquidity, beta }
