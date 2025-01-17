import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

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
                  onPressed: () {
                    viewModel.connectToServerDummy();
                  },
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
              onPressed: () {
                viewModel.requestWithdrawalDummy();
              },
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
                    // Placeholder for copying address to clipboard
                    // In real code, you'd copy `viewModel.invoiceAddress`
                  },
                  size: ButtonSize.regular,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mark Invoice as Paid
            SailButton.primary(
              'Invoice Paid',
              onPressed: () {
                viewModel.invoicePaidDummy();
              },
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

class ToolsPageViewModel extends BaseViewModel {
  /// Whether to use localhost for the debug server.
  bool useLocalhost = false;

  /// Simple boolean for dummy connection state.
  bool isConnected = false;

  /// Human-readable status: "Not Connected", "Connected", etc.
  String connectionStatus = 'Not Connected';

  /// Invoice status: "Awaiting Payment" or "Payment Complete"
  String invoiceStatus = 'Awaiting Payment';

  /// The text displayed after requesting withdrawal (fake invoice).
  String invoiceText = '';

  /// A final message displayed once the withdrawal is completed (fake).
  String finalMessage = '';

  /// Controllers for user input
  final TextEditingController mainchainAddressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentTxIdController = TextEditingController();

  void init() {
    // Initialize any required data
    amountController.text = '1.0 BTC';
  }

  void setUseLocalhost(bool value) {
    useLocalhost = value;
    notifyListeners();
  }

  /// Dummy method to connect/disconnect from server
  void connectToServerDummy() {
    // Flip the connection state to simulate connecting/disconnecting
    isConnected = !isConnected;
    connectionStatus = isConnected ? 'Connected' : 'Not Connected';
    notifyListeners();
  }

  /// Dummy method to request a fast withdrawal
  void requestWithdrawalDummy() {
    // Simulate receiving an invoice from the server
    invoiceText = 'Fast withdraw request received!\n'
        'Send L2 coins to [some-sidechain-address]\n'
        "Once paid, enter the L2 txid and press 'Invoice Paid'.";
    invoiceStatus = 'Awaiting Payment';
    notifyListeners();
  }

  /// Dummy method for marking the invoice as paid
  void invoicePaidDummy() {
    // Simulate server response that mainchain tx is broadcast
    invoiceStatus = 'Payment Complete';
    finalMessage = 'Withdraw complete!\n'
        'Mainchain payout txid: <dummy-txid>\n'
        'Amount: ${amountController.text}\n'
        'Destination: ${mainchainAddressController.text}\n';
    notifyListeners();
  }
}
