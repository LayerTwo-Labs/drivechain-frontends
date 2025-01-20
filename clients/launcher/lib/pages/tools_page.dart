import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/env.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

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
          final tabsRouter = AutoTabsRouter.of(context);

          if (tabsRouter.activeIndex != 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              model.resetStartersTab();
            });
          }

          return InlineTabBar(
            tabs: [
              TabItem(
                label: 'Fast Withdrawal',
                icon: SailSVGAsset.iconWithdraw,
                child: WithdrawalTab(),
              ),
              TabItem(
                label: 'Starters',
                icon: SailSVGAsset.iconTabStarters,
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
                // Header section with improved spacing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary24('Starters'),
                    const SizedBox(height: 8),
                    SailText.secondary13(
                      'View and manage your wallet starters',
                      color: SailTheme.of(context).colors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: viewModel.loadStarters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: SailTheme.of(context).colors.error,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              SailText.secondary13(
                                'Error loading starters: ${snapshot.error}',
                                color: SailTheme.of(context).colors.error,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final starters = snapshot.data ?? [];
                    if (starters.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: SailTheme.of(context).colors.textSecondary,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              SailText.secondary13(
                                'No downloaded sidechains found',
                                color: SailTheme.of(context).colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: SailTheme.of(context).colors.divider,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2), // Starter column
                          1: FlexColumnWidth(4), // Mnemonic column
                          2: FixedColumnWidth(300), // Buttons column
                        },
                        children: [
                          // Header row with improved styling
                          TableRow(
                            decoration: BoxDecoration(
                              color: SailTheme.of(context).colors.formField,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SailText.primary15(
                                  'Starter',
                                  color: SailTheme.of(context).colors.text,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SailText.primary15(
                                  'Mnemonic',
                                  color: SailTheme.of(context).colors.text,
                                ),
                              ),
                              const SizedBox(), // Space for buttons
                            ],
                          ),
                          // Master starter row
                          ...starters.where((s) => s['name'] == 'Master').map((starter) {
                            final isRevealed = viewModel.isStarterRevealed(starter['name']);
                            final hasMnemonic = starter['mnemonic'] != null;

                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: SailTheme.of(context).colors.divider,
                                    width: 1,
                                  ),
                                ),
                              ),
                              children: [
                                // Starter name
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SailText.primary13(
                                    starter['name'] ?? 'Unknown',
                                    color: SailTheme.of(context).colors.text,
                                  ),
                                ),
                                // Mnemonic
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SailText.secondary13(
                                    hasMnemonic
                                        ? (isRevealed ? starter['mnemonic'] ?? '' : '••••••••••••')
                                        : 'No starter generated',
                                    color: hasMnemonic
                                        ? SailTheme.of(context).colors.text
                                        : SailTheme.of(context).colors.textSecondary,
                                  ),
                                ),
                                // Action buttons
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (hasMnemonic) ...[
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
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                          // Layer 1 divider and starters
                          if (starters.any((s) => s['name'] == 'Master')) ...[
                            TableRow(
                              decoration: BoxDecoration(
                                color: SailTheme.of(context).colors.formField,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                  child: SailText.primary15(
                                    'Layer 1',
                                    color: SailTheme.of(context).colors.text,
                                  ),
                                ),
                                Container(),
                                Container(),
                              ],
                            ),
                          ],
                          // L1 starter row
                          ...starters.where((s) => s['name'] == 'Layer 1' || s['chain_layer'] == 1).map((starter) {
                            final isRevealed = viewModel.isStarterRevealed(starter['name']);
                            final hasMnemonic = starter['mnemonic'] != null;

                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: SailTheme.of(context).colors.divider,
                                    width: 1,
                                  ),
                                ),
                              ),
                              children: [
                                // Starter name
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SailText.primary13(
                                    starter['name'] ?? 'Unknown',
                                    color: SailTheme.of(context).colors.text,
                                  ),
                                ),
                                // Mnemonic
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SailText.secondary13(
                                    hasMnemonic
                                        ? (isRevealed ? starter['mnemonic'] ?? '' : '••••••••••••')
                                        : 'No starter generated',
                                    color: hasMnemonic
                                        ? SailTheme.of(context).colors.text
                                        : SailTheme.of(context).colors.textSecondary,
                                  ),
                                ),
                                // Action buttons
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (hasMnemonic) ...[
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
                                        const SizedBox(width: 8),
                                        SailButton.secondary(
                                          'Delete Starter',
                                          onPressed: () async {
                                            try {
                                              if (starter['chain_layer'] == 1) {
                                                await viewModel.deleteL1Starter();
                                              } else {
                                                final sidechainSlot = starter['sidechain_slot'] as int?;
                                                if (sidechainSlot == null) {
                                                  throw Exception('Invalid sidechain slot');
                                                }
                                                await viewModel.deleteStarter(sidechainSlot);
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error deleting starter: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          size: ButtonSize.small,
                                        ),
                                      ] else ...[
                                        SailButton.primary(
                                          'Generate Starter',
                                          onPressed: () async {
                                            try {
                                              await viewModel.generateL1Starter();
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error generating starter: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          size: ButtonSize.small,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                          // Layer 2 divider
                          if (starters.any((s) => s['chain_layer'] == 2)) ...[
                            TableRow(
                              decoration: BoxDecoration(
                                color: SailTheme.of(context).colors.formField,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                  child: SailText.primary15(
                                    'Layer 2',
                                    color: SailTheme.of(context).colors.text,
                                  ),
                                ),
                                Container(),
                                Container(),
                              ],
                            ),
                          ],
                          // Sidechain starter rows
                          ...starters.where((s) => s['chain_layer'] == 2).map((starter) {
                            final isRevealed = viewModel.isStarterRevealed(starter['name']);
                            final sidechainSlot = starter['sidechain_slot'] as int?;
                            final hasMnemonic = starter['mnemonic'] != null;

                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: SailTheme.of(context).colors.divider,
                                    width: 1,
                                  ),
                                ),
                              ),
                              children: [
                                // Starter name
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SailText.primary13(
                                    starter['name'] ?? 'Unknown',
                                    color: SailTheme.of(context).colors.text,
                                  ),
                                ),
                                // Mnemonic
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SailText.secondary13(
                                    hasMnemonic
                                        ? (isRevealed ? starter['mnemonic'] ?? '' : '••••••••••••')
                                        : 'No starter generated',
                                    color: hasMnemonic
                                        ? SailTheme.of(context).colors.text
                                        : SailTheme.of(context).colors.textSecondary,
                                  ),
                                ),
                                // Action buttons
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (hasMnemonic) ...[
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
                                        const SizedBox(width: 8),
                                        SailButton.secondary(
                                          'Delete Starter',
                                          onPressed: () async {
                                            try {
                                              if (starter['chain_layer'] == 1) {
                                                await viewModel.deleteL1Starter();
                                              } else {
                                                final sidechainSlot = starter['sidechain_slot'] as int?;
                                                if (sidechainSlot == null) {
                                                  throw Exception('Invalid sidechain slot');
                                                }
                                                await viewModel.deleteStarter(sidechainSlot);
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error deleting starter: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          size: ButtonSize.small,
                                        ),
                                      ] else ...[
                                        SailButton.primary(
                                          'Generate Starter',
                                          onPressed: () async {
                                            try {
                                              await viewModel.generateStarter(sidechainSlot!);
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error generating starter: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
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
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ToolsPageViewModel extends BaseViewModel {
  final Set<String> _revealedStarters = {};
  final WalletService _walletService = GetIt.I.get<WalletService>();
  Map<String, dynamic>? _chainConfig;

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
    _loadChainConfig();
  }

  Future<void> _loadChainConfig() async {
    try {
      final config = await rootBundle.loadString('assets/chain_config.json');
      _chainConfig = jsonDecode(config) as Map<String, dynamic>;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chain config: $e');
    }
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

  Future<bool> _isBinaryDownloaded(Map<String, dynamic> chain) async {
    final appDir = await Environment.appDir();
    final chainName = chain['name'] as String;
    final assetsDir = Directory(path.join(appDir.path, 'assets'));
    final binaryPath = path.join(assetsDir.path, chainName.toLowerCase());
    return File(binaryPath).existsSync();
  }

  Future<List<Map<String, dynamic>>> loadStarters() async {
    if (_chainConfig == null) {
      return [];
    }

    final starters = <Map<String, dynamic>>[];
    final appDir = await Environment.appDir();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    final masterFile = File(path.join(walletDir.path, 'master_starter.json'));

    if (masterFile.existsSync()) {
      final content = await masterFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      starters.add(data);

      // Load L1 starter if master exists
      final l1File = File(path.join(walletDir.path, 'l1_starter.json'));
      if (l1File.existsSync()) {
        final l1Content = await l1File.readAsString();
        final l1Data = jsonDecode(l1Content) as Map<String, dynamic>;
        l1Data['chain_layer'] = 1; // Ensure chain_layer is set
        starters.add(l1Data);
      } else {
        // Find L1 chain from config
        final l1Chain = _chainConfig!['chains'].firstWhere(
          (chain) => chain['chain_layer'] == 1,
          orElse: () => {'name': 'Bitcoin Core'},
        );
        // Add placeholder for L1 starter
        starters.add({
          'name': l1Chain['name'] as String,
          'mnemonic': null,
          'chain_layer': 1,
        });
      }
    }

    final chains = _chainConfig!['chains'] as List<dynamic>;
    final l2Chains = chains.where((chain) => chain['chain_layer'] == 2).toList();

    for (final chain in l2Chains) {
      final isDownloaded = await _isBinaryDownloaded(chain);

      if (isDownloaded) {
        final chainName = chain['name'] as String;
        final sidechainSlot = chain['sidechain_slot'] as int?;

        if (sidechainSlot != null) {
          final starterFile = File(path.join(walletDir.path, 'sidechain_${sidechainSlot}_starter.json'));
          final starterExists = starterFile.existsSync();

          if (starterExists) {
            final content = await starterFile.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            data['sidechain_slot'] = sidechainSlot;
            data['chain_layer'] = 2; // Explicitly set chain layer
            starters.add(data);
          } else {
            // Add placeholder for chains without starters
            starters.add({
              'name': chainName,
              'sidechain_slot': sidechainSlot,
              'mnemonic': null,
              'chain_layer': 2, // Explicitly set chain layer
            });
          }
        }
      }
    }

    return starters;
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

  Future<void> generateStarter(int sidechainSlot) async {
    try {
      await _walletService.deriveSidechainStarter(sidechainSlot);
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating starter: $e');
      rethrow;
    }
  }

  Future<void> deleteStarter(int? sidechainSlot) async {
    if (sidechainSlot == null) return;

    try {
      final appDir = await Environment.appDir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      final starterFile = File(path.join(walletDir.path, 'sidechain_${sidechainSlot}_starter.json'));
      await starterFile.delete();
      // Force a rebuild of the starters list
      _revealedStarters.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting starter: $e');
      rethrow;
    }
  }

  Future<void> deleteL1Starter() async {
    try {
      final appDir = await Environment.appDir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      final l1File = File(path.join(walletDir.path, 'l1_starter.json'));
      await l1File.delete();
      // Force a rebuild of the starters list
      _revealedStarters.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting L1 starter: $e');
      rethrow;
    }
  }

  Future<void> generateL1Starter() async {
    try {
      await _walletService.deriveL1Starter();
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating L1 starter: $e');
      rethrow;
    }
  }
}
