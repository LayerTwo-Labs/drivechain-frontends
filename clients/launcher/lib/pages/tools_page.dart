import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:launcher/services/wallet_service.dart';
import 'package:launcher/env.dart';
import 'package:launcher/widgets/welcome_modal.dart';

@RoutePage()
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<ToolsPageViewModel>.reactive(
        viewModelBuilder: () => GetIt.I.get<ToolsPageViewModel>(),
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
                label: 'Starters',
                icon: SailSVGAsset.iconCoins,
                child: StartersTab(),
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

class StartersTab extends ViewModelWidget<ToolsPageViewModel> {
  const StartersTab({super.key});

  @override
  Widget build(BuildContext context, ToolsPageViewModel viewModel) {
    return SailRawCard(
      padding: true,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary24('Starters'),
                const SizedBox(height: 8),
                SailText.secondary13(
                  'View and manage your wallet starters',
                ),
                const SizedBox(height: 24),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: viewModel.loadStarters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: SailText.secondary13(
                          'Error loading starters: ${snapshot.error}',
                          color: Colors.red,
                        ),
                      );
                    }

                    final starters = snapshot.data ?? [];
                    if (starters.isEmpty) {
                      return Center(
                        child: SailText.secondary13('No starters found'),
                      );
                    }

                    return Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2), // Starter column
                        1: FlexColumnWidth(4), // Mnemonic column
                        2: FixedColumnWidth(200), // Buttons column
                      },
                      children: [
                        // Header row
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SailText.primary15('Starter'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SailText.primary15('Mnemonic'),
                            ),
                            const SizedBox(), // Space for buttons
                          ],
                        ),
                        // Data rows
                        ...starters.map((starter) {
                          final isRevealed = viewModel.isStarterRevealed(starter['name']);
                          return TableRow(
                            children: [
                              // Starter name
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SailText.secondary13(starter['name'] ?? 'Unknown'),
                              ),
                              // Mnemonic
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SailText.secondary13(
                                  isRevealed ? starter['mnemonic'] ?? '' : '••••••••••••',
                                ),
                              ),
                              // Action buttons
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (!isRevealed)
                                      SailButton.secondary(
                                        'Reveal',
                                        onPressed: () => viewModel.toggleStarterReveal(starter['name'], true),
                                        size: ButtonSize.small,
                                      )
                                    else ...[
                                      SailButton.secondary(
                                        'Copy',
                                        onPressed: () => viewModel.copyStarterMnemonic(starter['mnemonic']),
                                        size: ButtonSize.small,
                                      ),
                                      const SizedBox(width: 8),
                                      SailButton.secondary(
                                        'Hide',
                                        onPressed: () => viewModel.toggleStarterReveal(starter['name'], false),
                                        size: ButtonSize.small,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SailButton.secondary(
              'Delete Starters',
              onPressed: () => _showDeleteConfirmation(context),
              size: ButtonSize.regular,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SailTheme.of(context).colors.backgroundSecondary,
        title: SailText.primary20(
          'Delete Wallet Starters',
          color: Colors.white,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.secondary13(
              'Are you sure you want to delete all wallet starters? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            SailText.primary13(
              'WARNING: If you have not stored your master mnemonic phrase, you will not be able to regenerate your sidechain starters.',
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SailButton.secondary(
            'Return',
            onPressed: () => Navigator.of(context).pop(false),
            size: ButtonSize.regular,
          ),
          SailButton.primary(
            'Delete',
            onPressed: () => Navigator.of(context).pop(true),
            size: ButtonSize.regular,
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteWalletStarters(context);
    }
  }

  Future<void> _deleteWalletStarters(BuildContext context) async {
    try {
      final appDir = await Environment.datadir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      
      if (walletDir.existsSync()) {
        await walletDir.delete(recursive: true);
      }

      if (!context.mounted) return;

      // Navigate to overview page
      AutoTabsRouter.of(context).setActiveIndex(0);

      // Show welcome modal
      await showWelcomeModal(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting wallet starters: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ToolsPageViewModel extends BaseViewModel {
  final WalletService _walletService = GetIt.I.get<WalletService>();
  final Set<String> _revealedStarters = {};

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

  void resetStartersTab() {
    _revealedStarters.clear();
    notifyListeners();
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

  Future<List<Map<String, dynamic>>> loadStarters() async {
    try {
      final appDir = await Environment.datadir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      
      if (!walletDir.existsSync()) {
        return [];
      }

      final starters = <Map<String, dynamic>>[];
      
      // First load master starter if it exists
      final masterFile = File(path.join(walletDir.path, 'master_starter.json'));
      if (masterFile.existsSync()) {
        final content = await masterFile.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        starters.add(data);
      }

      // Then load sidechain starters
      final files = walletDir.listSync();
      
      for (final file in files) {
        if (file.path.endsWith('_starter.json') && !file.path.endsWith('master_starter.json')) {
          final content = await (file as File).readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;
          starters.add(data);
        }
      }

      return starters;
    } catch (e, stackTrace) {
      debugPrint('Error loading starters: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  bool isStarterRevealed(String? starterName) {
    return starterName != null && _revealedStarters.contains(starterName);
  }

  void toggleStarterReveal(String? starterName, bool reveal) {
    if (starterName == null) return;
    
    if (reveal) {
      _revealedStarters.add(starterName);
    } else {
      _revealedStarters.remove(starterName);
    }
    notifyListeners();
  }

  Future<void> copyStarterMnemonic(String? mnemonic) async {
    if (mnemonic == null) return;
    await Clipboard.setData(ClipboardData(text: mnemonic));
  }
}
