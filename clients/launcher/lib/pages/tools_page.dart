import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'tools_page_view_model.dart';

@RoutePage()
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<ToolsPageViewModel>.reactive(
        viewModelBuilder: () => ToolsPageViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return InlineTabBar(
            tabs: [
              TabItem(
                label: 'Fast Withdrawal',
                icon: SailSVGAsset.iconWithdraw,
                child: WithdrawalTab(),
              ),
              TabItem(
                label: 'Faucet',
                icon: SailSVGAsset.iconCoins,
                child: FaucetTab(),
              ),
            ],
            initialIndex: 0,
          );
        },
      ),
    );
  }
}

class WithdrawalTab extends ViewModelWidget<ToolsPageViewModel> {
  const WithdrawalTab({super.key});

  @override
  Widget build(BuildContext context, ToolsPageViewModel viewModel) {
    return SailRawCard(
      padding: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SailText.primary24('Fast Withdrawal'),
            const SizedBox(height: 8),
            SailText.secondary13(
              'Quickly withdraw your funds to your mainchain wallet',
            ),
            const SizedBox(height: 24),

            // Connection Status
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: viewModel.isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                SailText.secondary13(viewModel.connectionStatus),
                const SizedBox(width: 24),
                Switch(
                  value: viewModel.useLocalhost,
                  onChanged: (value) {
                    viewModel.setUseLocalhost(value);
                  },
                ),
                const SizedBox(width: 8),
                SailText.secondary13('Use localhost (debug) server'),
                const SizedBox(width: 24),
                SailButton.secondary(
                  viewModel.isConnected ? 'Disconnect' : 'Connect',
                  onPressed: () => viewModel.connectToServer(),
                  size: ButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Withdrawal Details
            SailText.primary24('Withdrawal Details'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SailTextField(
                    controller: viewModel.mainchainAddressController,
                    hintText: 'Enter your Bitcoin address',
                    size: TextFieldSize.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SailTextField(
                    controller: viewModel.amountController,
                    hintText: '1.0 BTC',
                    size: TextFieldSize.small,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SailButton.primary(
              'Request Withdrawal',
              onPressed: () => viewModel.requestWithdrawal(),
              disabled: !viewModel.isConnected,
              size: ButtonSize.regular,
            ),
            const SizedBox(height: 24),

            // If an invoice is created, show it:
            if (viewModel.invoiceText.isNotEmpty) ...[
              SailText.primary15(viewModel.invoiceText),
              const SizedBox(height: 24),
            ],

            // Payment Details
            SailText.primary24('Payment Details'),
            const SizedBox(height: 8),
            SailText.secondary13(
              'Once you receive the invoice, complete the payment '
              'and enter the transaction ID',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SailTextField(
                    controller: viewModel.paymentTxIdController,
                    hintText: 'Enter the payment transaction ID',
                    size: TextFieldSize.small,
                  ),
                ),
                const SizedBox(width: 16),
                SailButton.secondary(
                  'Copy Address',
                  onPressed: () {
                    // TODO: Implement clipboard functionality
                  },
                  disabled: !viewModel.invoiceAddress.isNotEmpty,
                  size: ButtonSize.regular,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mark Invoice as Paid
            SailButton.primary(
              'Invoice Paid',
              onPressed: () => viewModel.invoicePaid(),
              disabled: !(viewModel.isConnected && viewModel.invoiceAddress.isNotEmpty),
              size: ButtonSize.regular,
            ),
            const SizedBox(height: 24),

            // Payment Status
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: viewModel.invoiceStatus == 'Awaiting Payment' ? Colors.orange : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                SailText.secondary13(viewModel.invoiceStatus),
              ],
            ),
            const SizedBox(height: 24),

            // Final result (if any)
            if (viewModel.finalMessage.isNotEmpty) ...[
              SailText.primary15(viewModel.finalMessage),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class FaucetTab extends ViewModelWidget<ToolsPageViewModel> {
  const FaucetTab({super.key});

  @override
  Widget build(BuildContext context, ToolsPageViewModel viewModel) {
    return SailRawCard(
      title: 'Faucet',
      subtitle: 'Get test coins from the faucet',
      child: Container(), // Add your faucet UI here
    );
  }
}
