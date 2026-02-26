import 'package:coinshift/providers/swap_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

/// Widget for scheduling and creating swaps with advanced options.
class SwapSchedulerWidget extends StatelessWidget {
  const SwapSchedulerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SwapSchedulerViewModel>.reactive(
      viewModelBuilder: () => SwapSchedulerViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Create Swap',
          subtitle: 'Exchange L2 tokens for L1 Bitcoin',
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Chain selection
              _ChainSelector(model: model),

              // Amount inputs
              _AmountInputs(model: model),

              // Recipient configuration
              _RecipientConfig(model: model),

              // Advanced options
              _AdvancedOptions(model: model),

              // Action buttons
              _ActionButtons(model: model),
            ],
          ),
        );
      },
    );
  }
}

class _ChainSelector extends StatelessWidget {
  final SwapSchedulerViewModel model;

  const _ChainSelector({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary13('Parent Chain'),
        SailDropdownButton<ParentChainType>(
          value: model.selectedChain,
          items: ParentChainType.values
              .map(
                (chain) => SailDropdownItem<ParentChainType>(
                  value: chain,
                  label: chain.value,
                ),
              )
              .toList(),
          onChanged: (chain) {
            if (chain != null) {
              model.setChain(chain);
            }
          },
        ),
      ],
    );
  }
}

class _AmountInputs extends StatelessWidget {
  final SwapSchedulerViewModel model;

  const _AmountInputs({required this.model});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // L2 Amount (what you're offering)
          SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('L2 Amount (You Send)'),
              SailTextField(
                controller: model.l2AmountController,
                hintText: 'Amount in sats',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: 'sats',
              ),
            ],
          ),

          // L1 Amount (what you want)
          SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('L1 Amount (You Receive)'),
              SailTextField(
                controller: model.l1AmountController,
                hintText: 'Amount in sats',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: 'sats',
              ),
            ],
          ),

          // Exchange rate display
          if (model.hasValidAmounts)
            _ExchangeRateDisplay(
              l2Amount: model.l2Amount,
              l1Amount: model.l1Amount,
              formatter: formatter,
            ),
        ],
      ),
    );
  }
}

class _ExchangeRateDisplay extends StatelessWidget {
  final int l2Amount;
  final int l1Amount;
  final FormatterProvider formatter;

  const _ExchangeRateDisplay({
    required this.l2Amount,
    required this.l1Amount,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final rate = l1Amount > 0 ? l2Amount / l1Amount : 0.0;

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailRow(
        spacing: SailStyleValues.padding16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary12('Exchange Rate'),
          SailText.primary13(
            '1 L1 sat = ${rate.toStringAsFixed(4)} L2 sats',
            monospace: true,
          ),
        ],
      ),
    );
  }
}

class _RecipientConfig extends StatelessWidget {
  final SwapSchedulerViewModel model;

  const _RecipientConfig({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // L1 Recipient Address
        SailColumn(
          spacing: SailStyleValues.padding04,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('L1 Recipient Address'),
            SailTextField(
              controller: model.l1RecipientController,
              hintText: 'Bitcoin address to receive L1 funds',
            ),
          ],
        ),

        // Open swap toggle
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailCheckbox(
              value: model.isOpenSwap,
              onChanged: model.setOpenSwap,
            ),
            SailText.primary13('Open Swap'),
            SailText.secondary12('(Anyone can fill this swap)'),
          ],
        ),

        // L2 Recipient (only if not open swap)
        if (!model.isOpenSwap)
          SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('L2 Recipient (Optional)'),
              SailTextField(
                controller: model.l2RecipientController,
                hintText: 'Specific L2 address to claim the swap',
              ),
            ],
          ),
      ],
    );
  }
}

class _AdvancedOptions extends StatelessWidget {
  final SwapSchedulerViewModel model;

  const _AdvancedOptions({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsible advanced section
        InkWell(
          onTap: model.toggleAdvanced,
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Icon(
                model.showAdvanced ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: theme.colors.textSecondary,
              ),
              SailText.secondary13('Advanced Options'),
            ],
          ),
        ),

        if (model.showAdvanced) ...[
          // Required confirmations
          SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('Required Confirmations'),
              SailTextField(
                controller: model.confirmationsController,
                hintText: 'Number of L1 confirmations (default: 6)',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),

          // Fee
          SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('Transaction Fee'),
              SailTextField(
                controller: model.feeController,
                hintText: 'Fee in sats',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: 'sats',
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final SwapSchedulerViewModel model;

  const _ActionButtons({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SailButton(
          label: 'Clear',
          variant: ButtonVariant.ghost,
          onPressed: () async => model.clear(),
        ),
        SailButton(
          label: 'Create Swap',
          variant: ButtonVariant.primary,
          loading: model.isCreating,
          disabled: !model.canCreateSwap,
          onPressed: () async => await model.createSwap(),
        ),
      ],
    );
  }
}

class SwapSchedulerViewModel extends BaseViewModel {
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();

  final TextEditingController l2AmountController = TextEditingController();
  final TextEditingController l1AmountController = TextEditingController();
  final TextEditingController l1RecipientController = TextEditingController();
  final TextEditingController l2RecipientController = TextEditingController();
  final TextEditingController confirmationsController = TextEditingController();
  final TextEditingController feeController = TextEditingController();

  ParentChainType selectedChain = ParentChainType.btc;
  bool isOpenSwap = true;
  bool showAdvanced = false;
  bool isCreating = false;
  String? swapError;

  SwapSchedulerViewModel() {
    l2AmountController.addListener(notifyListeners);
    l1AmountController.addListener(notifyListeners);
    l1RecipientController.addListener(notifyListeners);
    l2RecipientController.addListener(notifyListeners);
    confirmationsController.addListener(notifyListeners);
    feeController.addListener(notifyListeners);

    // Set default values
    confirmationsController.text = '6';
    feeController.text = '1000';
  }

  int get l2Amount => int.tryParse(l2AmountController.text) ?? 0;
  int get l1Amount => int.tryParse(l1AmountController.text) ?? 0;
  int get fee => int.tryParse(feeController.text) ?? 1000;
  int? get requiredConfirmations => int.tryParse(confirmationsController.text);

  bool get hasValidAmounts => l2Amount > 0 && l1Amount > 0;

  bool get canCreateSwap {
    if (!hasValidAmounts) return false;
    if (l1RecipientController.text.isEmpty) return false;
    if (fee <= 0) return false;
    return true;
  }

  void setChain(ParentChainType chain) {
    selectedChain = chain;
    notifyListeners();
  }

  void setOpenSwap(bool value) {
    isOpenSwap = value;
    if (value) {
      l2RecipientController.clear();
    }
    notifyListeners();
  }

  void toggleAdvanced() {
    showAdvanced = !showAdvanced;
    notifyListeners();
  }

  void clear() {
    l2AmountController.clear();
    l1AmountController.clear();
    l1RecipientController.clear();
    l2RecipientController.clear();
    confirmationsController.text = '6';
    feeController.text = '1000';
    isOpenSwap = true;
    showAdvanced = false;
    swapError = null;
    notifyListeners();
  }

  Future<void> createSwap() async {
    if (!canCreateSwap) return;

    isCreating = true;
    swapError = null;
    notifyListeners();

    try {
      await _swapProvider.createSwap(
        parentChain: selectedChain,
        l1RecipientAddress: l1RecipientController.text,
        l1AmountSats: l1Amount,
        l2Recipient: isOpenSwap ? null : l2RecipientController.text,
        l2AmountSats: l2Amount,
        requiredConfirmations: requiredConfirmations,
        feeSats: fee,
      );

      // Clear form on success
      clear();
    } catch (e) {
      swapError = e.toString();
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    l2AmountController.dispose();
    l1AmountController.dispose();
    l1RecipientController.dispose();
    l2RecipientController.dispose();
    confirmationsController.dispose();
    feeController.dispose();
    super.dispose();
  }
}
