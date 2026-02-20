import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:coinshift/widgets/swap/parent_chain_selector.dart';

/// Create swap widget based on coinshift-rs create.rs
class SwapCard extends StatelessWidget {
  const SwapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder<SwapCardViewModel>.reactive(
      viewModelBuilder: () => SwapCardViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Create Swap (L2 → L1)',
          error: model.swapError,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              children: [
                // Description
                SailText.secondary12(
                  'You offer L2 (sidechain) coins and request L1. Set where you want to receive L1, then who gets your L2 and the amounts.',
                  color: theme.colors.textSecondary,
                ),
                const Divider(),

                // What you want (L1) section
                SailText.primary13('What you want (L1)', bold: true),

                // Parent Chain Selector
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailText.secondary13('Parent chain:'),
                    Expanded(
                      child: ParentChainSelector(
                        value: model.parentChain,
                        onChanged: model.setParentChain,
                      ),
                    ),
                  ],
                ),

                // L1 Recipient Address
                SailTextField(
                  controller: model.l1AddressController,
                  hintText: 'Where you receive the L1 coins (e.g. bc1...)',
                  label: 'Your L1 address',
                ),

                // L1 Amount (receiving)
                NumericField(
                  label: 'Amount you want (${model.parentChain.value})',
                  controller: model.l1AmountController,
                  hintText: 'e.g. 100000 sats',
                  suffixWidget: SailText.secondary12('sats'),
                ),

                const SizedBox(height: SailStyleValues.padding08),

                // What you offer (L2) section
                SailText.primary13('What you offer (L2)', bold: true),

                // Open swap checkbox
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailCheckbox(
                      value: model.isOpenSwap,
                      onChanged: (value) => model.setOpenSwap(value),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => model.setOpenSwap(!model.isOpenSwap),
                        child: SailText.secondary13(
                          'Open swap — anyone can fill (no specific claimer)',
                        ),
                      ),
                    ),
                  ],
                ),

                // L2 Claimer Address (only shown when not open swap)
                if (!model.isOpenSwap) ...[
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      Expanded(
                        child: SailTextField(
                          controller: model.l2ClaimerController,
                          hintText: 'Who can claim (sends L1, then gets L2)',
                          label: 'L2 claimer address',
                        ),
                      ),
                      SailButton(
                        label: 'Use My Address',
                        small: true,
                        variant: ButtonVariant.secondary,
                        onPressed: () async => await model.useMyAddress(),
                      ),
                    ],
                  ),
                ],

                // L2 Amount (sending)
                NumericField(
                  label: 'L2 amount you offer',
                  controller: model.l2AmountController,
                  hintText: 'e.g. 100000 sats',
                  suffixWidget: SailText.secondary12('sats'),
                ),

                const SizedBox(height: SailStyleValues.padding08),

                // Options section
                SailText.primary13('Options', bold: true),

                // Required confirmations
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Expanded(
                      child: NumericField(
                        label: 'Required L1 confirmations',
                        controller: model.confirmationsController,
                        hintText: 'leave empty for default',
                      ),
                    ),
                    SailText.secondary12(
                      '(default: ${model.defaultConfirmations})',
                    ),
                  ],
                ),

                const Divider(),

                // Create Swap Button
                SailButton(
                  label: 'Create Swap',
                  disabled: !model.canCreateSwap,
                  loading: model.isLoading,
                  onPressed: () async => await model.createSwap(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SwapCardViewModel extends BaseViewModel {
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();
  CoinShiftRPC get _rpc => GetIt.I.get<CoinShiftRPC>();

  final TextEditingController l2AmountController = TextEditingController();
  final TextEditingController l1AmountController = TextEditingController();
  final TextEditingController l1AddressController = TextEditingController();
  final TextEditingController l2ClaimerController = TextEditingController();
  final TextEditingController confirmationsController = TextEditingController();

  ParentChainType parentChain = ParentChainType.signet;
  bool isOpenSwap = false;
  bool isLoading = false;
  String? swapError;

  int get defaultConfirmations => switch (parentChain) {
    ParentChainType.btc => 6,
    ParentChainType.bch => 6,
    ParentChainType.ltc => 6,
    ParentChainType.signet => 1,
    ParentChainType.regtest => 1,
  };

  bool get canCreateSwap {
    final l2Amount = int.tryParse(l2AmountController.text) ?? 0;
    final l1Amount = int.tryParse(l1AmountController.text) ?? 0;
    final hasL1Address = l1AddressController.text.isNotEmpty;
    final hasL2Claimer = isOpenSwap || l2ClaimerController.text.isNotEmpty;

    return l2Amount > 0 && l1Amount > 0 && hasL1Address && hasL2Claimer;
  }

  void setParentChain(ParentChainType chain) {
    parentChain = chain;
    notifyListeners();
  }

  void setOpenSwap(bool value) {
    isOpenSwap = value;
    if (value) {
      l2ClaimerController.clear();
    }
    notifyListeners();
  }

  Future<void> useMyAddress() async {
    try {
      final address = await _rpc.getSideAddress();
      l2ClaimerController.text = address;
      notifyListeners();
    } catch (e) {
      swapError = 'Failed to get address: $e';
      notifyListeners();
    }
  }

  Future<void> createSwap(BuildContext context) async {
    final l2Amount = int.tryParse(l2AmountController.text) ?? 0;
    final l1Amount = int.tryParse(l1AmountController.text) ?? 0;

    if (l2Amount <= 0 || l1Amount <= 0) {
      swapError = 'Invalid amounts';
      notifyListeners();
      return;
    }

    isLoading = true;
    swapError = null;
    notifyListeners();

    try {
      final confirmations = int.tryParse(confirmationsController.text);

      final result = await _swapProvider.createSwap(
        l2AmountSats: l2Amount,
        l1AmountSats: l1Amount,
        l1RecipientAddress: l1AddressController.text,
        parentChain: parentChain,
        l2Recipient: isOpenSwap ? null : l2ClaimerController.text,
        requiredConfirmations: confirmations,
        feeSats: 1000, // Default fee
      );

      if (result != null) {
        // Clear the form
        l2AmountController.clear();
        l1AmountController.clear();
        l1AddressController.clear();
        l2ClaimerController.clear();
        confirmationsController.clear();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Swap created: ${result.txid}')),
          );
        }
      } else {
        swapError = _swapProvider.error ?? 'Failed to create swap';
      }
    } catch (e) {
      swapError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    l2AmountController.dispose();
    l1AmountController.dispose();
    l1AddressController.dispose();
    l2ClaimerController.dispose();
    confirmationsController.dispose();
    super.dispose();
  }
}
