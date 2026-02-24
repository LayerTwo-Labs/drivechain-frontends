import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/market_provider.dart';

@RoutePage()
class MarketCreationPage extends StatelessWidget {
  const MarketCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MarketCreationViewModel>.reactive(
      viewModelBuilder: () => MarketCreationViewModel(),
      builder: (context, model, child) {
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
                    child: SailText.primary20('Create New Market', bold: true),
                  ),
                ],
              ),

              // Stepper
              Expanded(
                child: _buildStepper(context, model),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepper(BuildContext context, MarketCreationViewModel model) {
    return SailCard(
      child: Stepper(
        currentStep: model.currentStep,
        onStepContinue: model.canContinue ? () => model.nextStep(context) : null,
        onStepCancel: model.currentStep > 0 ? model.previousStep : null,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                if (model.currentStep > 0)
                  SailButton(
                    label: 'Back',
                    onPressed: () async => details.onStepCancel?.call(),
                  ),
                SailButton(
                  label: model.currentStep == 4 ? 'Create Market' : 'Continue',
                  onPressed: model.canContinue ? () async => details.onStepContinue?.call() : null,
                  disabled: !model.canContinue,
                  loading: model.isCreating,
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basic Info'),
            subtitle: const Text('Title and description'),
            content: _buildBasicInfoStep(context, model),
            isActive: model.currentStep >= 0,
            state: model.currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Dimensions'),
            subtitle: const Text('Market outcomes'),
            content: _buildDimensionsStep(context, model),
            isActive: model.currentStep >= 1,
            state: model.currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Liquidity'),
            subtitle: const Text('LMSR parameters'),
            content: _buildLiquidityStep(context, model),
            isActive: model.currentStep >= 2,
            state: model.currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Trading Fee'),
            subtitle: const Text('Fee percentage'),
            content: _buildTradingFeeStep(context, model),
            isActive: model.currentStep >= 3,
            state: model.currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Review'),
            subtitle: const Text('Confirm and create'),
            content: _buildReviewStep(context, model),
            isActive: model.currentStep >= 4,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(BuildContext context, MarketCreationViewModel model) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary13('Title *'),
        SailTextField(
          controller: model.titleController,
          hintText: 'e.g., Will BTC reach \$100k by Q2 2026?',
          maxLines: 1,
        ),
        const SizedBox(height: 8),
        SailText.secondary13('Description *'),
        SailTextField(
          controller: model.descriptionController,
          hintText: 'Detailed description of the market and resolution criteria...',
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        SailText.secondary13('Tags (comma-separated)'),
        SailTextField(
          controller: model.tagsController,
          hintText: 'e.g., bitcoin, crypto, 2026',
        ),
      ],
    );
  }

  Widget _buildDimensionsStep(BuildContext context, MarketCreationViewModel model) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary13('Market Type'),
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            _TypeButton(
              label: 'Binary',
              description: 'Yes/No outcome',
              isSelected: model.marketType == MarketType.binary,
              onTap: () => model.setMarketType(MarketType.binary),
            ),
            _TypeButton(
              label: 'Categorical',
              description: 'Multiple outcomes',
              isSelected: model.marketType == MarketType.categorical,
              onTap: () => model.setMarketType(MarketType.categorical),
            ),
            _TypeButton(
              label: 'Custom',
              description: 'Decision slots',
              isSelected: model.marketType == MarketType.custom,
              onTap: () => model.setMarketType(MarketType.custom),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (model.marketType == MarketType.binary) ...[
          SailText.secondary13('This creates a market with Yes/No outcomes based on a single decision slot.'),
          const SizedBox(height: 8),
          SailText.secondary13('Decision Slot ID'),
          SailTextField(
            controller: model.dimensionsController,
            hintText: 'e.g., 004008',
          ),
        ] else if (model.marketType == MarketType.categorical) ...[
          SailText.secondary13('Enter slot IDs for categorical outcomes.'),
          const SizedBox(height: 8),
          SailText.secondary13('Slot IDs (comma-separated)'),
          SailTextField(
            controller: model.dimensionsController,
            hintText: 'e.g., 004008,004009,004010',
          ),
        ] else ...[
          SailText.secondary13('Enter custom dimension specification using bracket notation.'),
          const SizedBox(height: 8),
          SailText.secondary13('Dimensions'),
          SailTextField(
            controller: model.dimensionsController,
            hintText: 'e.g., [004008] or [[004008,004009]]',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SailColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12('Dimension Syntax:', bold: true),
                SailText.secondary12('[slot_id] - Binary outcome from single slot'),
                SailText.secondary12('[s1,s2,s3] - Combined binary slots'),
                SailText.secondary12('[[s1,s2,s3]] - Categorical from related slots'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLiquidityStep(BuildContext context, MarketCreationViewModel model) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, _) => SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13('Liquidity Method'),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: _MethodButton(
                  label: 'Initial Liquidity',
                  description: 'Recommended',
                  isSelected: model.liquidityMethod == LiquidityMethod.initialLiquidity,
                  onTap: () => model.setLiquidityMethod(LiquidityMethod.initialLiquidity),
                ),
              ),
              Expanded(
                child: _MethodButton(
                  label: 'Beta (Advanced)',
                  description: 'LMSR parameter',
                  isSelected: model.liquidityMethod == LiquidityMethod.beta,
                  onTap: () => model.setLiquidityMethod(LiquidityMethod.beta),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (model.liquidityMethod == LiquidityMethod.initialLiquidity) ...[
            SailText.secondary13('Initial Liquidity (sats)'),
            SailTextField(
              controller: model.liquidityController,
              hintText: 'e.g., 100000 (0.001 BTC)',
              textFieldType: TextFieldType.number,
            ),
            SailText.secondary12(
              'Higher liquidity means lower price impact per trade.',
            ),
          ] else ...[
            SailText.secondary13('Beta (LMSR liquidity parameter)'),
            SailTextField(
              controller: model.betaController,
              hintText: 'e.g., 7.0',
              textFieldType: TextFieldType.bitcoin,
            ),
            SailText.secondary12(
              'Beta controls price sensitivity. β = liquidity / ln(num_outcomes)',
            ),
          ],
          if (model.liquidityPreview != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SailColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary12('Preview:', bold: true),
                  SailText.secondary12(
                    'Required liquidity: ${formatter.formatSats(model.liquidityPreview!.initialLiquiditySats)}',
                  ),
                  SailText.secondary12(
                    'Min treasury: ${formatter.formatSats(model.liquidityPreview!.minTreasurySats)}',
                  ),
                  SailText.secondary12('Outcomes: ${model.liquidityPreview!.numOutcomes}'),
                  SailText.secondary12('Beta: ${model.liquidityPreview!.beta.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          SailButton(
            label: 'Calculate Preview',
            small: true,
            onPressed: () async => model.calculateLiquidityPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingFeeStep(BuildContext context, MarketCreationViewModel model) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary13('Trading Fee (%)'),
        SailTextField(
          controller: model.tradingFeeController,
          hintText: 'e.g., 0.5',
          textFieldType: TextFieldType.bitcoin,
        ),
        SailText.secondary12(
          'Fee charged on each trade. Goes to the market creator. '
          'Typical values: 0.5% - 2%',
        ),
        const SizedBox(height: 16),
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            _FeePreset(
              label: '0.5%',
              isSelected: model.tradingFeeController.text == '0.5',
              onTap: () => model.setTradingFee(0.5),
            ),
            _FeePreset(
              label: '1%',
              isSelected: model.tradingFeeController.text == '1',
              onTap: () => model.setTradingFee(1.0),
            ),
            _FeePreset(
              label: '2%',
              isSelected: model.tradingFeeController.text == '2',
              onTap: () => model.setTradingFee(2.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context, MarketCreationViewModel model) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12('Review your market before creating:'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SailColumn(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewRow(label: 'Title', value: model.titleController.text),
              _ReviewRow(
                label: 'Description',
                value: model.descriptionController.text.length > 100
                    ? '${model.descriptionController.text.substring(0, 100)}...'
                    : model.descriptionController.text,
              ),
              _ReviewRow(label: 'Tags', value: model.tagsController.text.isEmpty ? 'None' : model.tagsController.text),
              _ReviewRow(label: 'Type', value: model.marketType.name),
              _ReviewRow(label: 'Dimensions', value: model.effectiveDimensions),
              _ReviewRow(
                label: model.liquidityMethod == LiquidityMethod.beta ? 'Beta' : 'Liquidity',
                value: model.liquidityMethod == LiquidityMethod.beta
                    ? model.betaController.text
                    : '${model.liquidityController.text} sats',
              ),
              _ReviewRow(label: 'Trading Fee', value: '${model.tradingFeeController.text}%'),
            ],
          ),
        ),
        if (model.createError != null) ...[
          const SizedBox(height: 8),
          SailText.secondary12(model.createError!, color: theme.colors.error),
        ],
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colors.primary.withOpacity(0.1) : theme.colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? theme.colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: SailColumn(
            children: [
              SailText.primary13(label, bold: isSelected),
              SailText.secondary12(description),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodButton({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.primary.withOpacity(0.1) : theme.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: SailColumn(
          children: [
            SailText.primary13(label, bold: isSelected),
            SailText.secondary12(description),
          ],
        ),
      ),
    );
  }
}

class _FeePreset extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeePreset({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.primary.withOpacity(0.2) : theme.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colors.primary : Colors.transparent,
          ),
        ),
        child: SailText.primary13(label, bold: isSelected),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: SailText.secondary13(label),
        ),
        Expanded(
          child: SailText.primary13(value),
        ),
      ],
    );
  }
}

enum MarketType { binary, categorical, custom }

enum LiquidityMethod { initialLiquidity, beta }

class MarketCreationViewModel extends BaseViewModel {
  final MarketProvider _marketProvider = GetIt.I.get<MarketProvider>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController dimensionsController = TextEditingController();
  final TextEditingController liquidityController = TextEditingController(text: '100000');
  final TextEditingController betaController = TextEditingController(text: '7.0');
  final TextEditingController tradingFeeController = TextEditingController(text: '0.5');

  int currentStep = 0;
  MarketType marketType = MarketType.binary;
  LiquidityMethod liquidityMethod = LiquidityMethod.initialLiquidity;
  InitialLiquidityCalculation? liquidityPreview;
  bool isCreating = false;
  String? createError;

  String get effectiveDimensions {
    final input = dimensionsController.text.trim();
    if (input.isEmpty) return '';

    switch (marketType) {
      case MarketType.binary:
        return '[$input]';
      case MarketType.categorical:
        final slots = input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
        return '[[${slots.join(',')}]]';
      case MarketType.custom:
        return input;
    }
  }

  bool get canContinue {
    switch (currentStep) {
      case 0:
        return titleController.text.trim().isNotEmpty && descriptionController.text.trim().isNotEmpty;
      case 1:
        return dimensionsController.text.trim().isNotEmpty;
      case 2:
        return liquidityMethod == LiquidityMethod.beta
            ? (double.tryParse(betaController.text) ?? 0) > 0
            : (int.tryParse(liquidityController.text) ?? 0) > 0;
      case 3:
        return (double.tryParse(tradingFeeController.text) ?? 0) > 0;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void setMarketType(MarketType type) {
    marketType = type;
    dimensionsController.clear();
    notifyListeners();
  }

  void setLiquidityMethod(LiquidityMethod method) {
    liquidityMethod = method;
    liquidityPreview = null;
    notifyListeners();
  }

  void setTradingFee(double fee) {
    tradingFeeController.text = fee.toString();
    notifyListeners();
  }

  Future<void> calculateLiquidityPreview() async {
    final beta = liquidityMethod == LiquidityMethod.beta ? double.tryParse(betaController.text) ?? 7.0 : 7.0;

    liquidityPreview = await _marketProvider.calculateInitialLiquidity(
      beta: beta,
      dimensions: effectiveDimensions.isNotEmpty ? effectiveDimensions : null,
    );
    notifyListeners();
  }

  void nextStep(BuildContext context) {
    if (currentStep < 4) {
      currentStep++;
      notifyListeners();
    } else {
      createMarket(context);
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  Future<void> createMarket(BuildContext context) async {
    isCreating = true;
    createError = null;
    notifyListeners();

    final tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    final txid = await _marketProvider.createMarket(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dimensions: effectiveDimensions,
      feeSats: 1000,
      beta: liquidityMethod == LiquidityMethod.beta ? double.tryParse(betaController.text) : null,
      initialLiquidity: liquidityMethod == LiquidityMethod.initialLiquidity
          ? int.tryParse(liquidityController.text)
          : null,
      tradingFee: (double.tryParse(tradingFeeController.text) ?? 0.5) / 100,
      tags: tags.isNotEmpty ? tags : null,
    );

    isCreating = false;

    if (txid != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Market created: ${txid.substring(0, 16)}...')),
        );
        AutoRouter.of(context).maybePop();
      }
    } else {
      createError = _marketProvider.error ?? 'Failed to create market';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    dimensionsController.dispose();
    liquidityController.dispose();
    betaController.dispose();
    tradingFeeController.dispose();
    super.dispose();
  }
}
