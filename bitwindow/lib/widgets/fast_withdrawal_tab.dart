import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FastWithdrawalTab extends StatelessWidget {
  const FastWithdrawalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FastWithdrawalTabViewModel>.reactive(
      viewModelBuilder: () => FastWithdrawalTabViewModel(),
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: FastWithdrawalForm(),
        );
      },
    );
  }
}

class FastWithdrawalForm extends ViewModelWidget<FastWithdrawalTabViewModel> {
  const FastWithdrawalForm({super.key});

  @override
  Widget build(BuildContext context, FastWithdrawalTabViewModel viewModel) {
    final theme = SailTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Form
        if (!viewModel.isCompleted) ...[
          if (viewModel.withdrawalHash == null) ...[
            // Initial withdrawal form
            _buildWithdrawalForm(viewModel, theme.colors),
          ] else ...[
            // Payment instructions and completion form
            _buildPaymentSection(viewModel, theme.colors),
          ],
        ] else ...[
          // Success state
          _buildSuccessSection(viewModel),
        ],
      ],
    );
  }

  Widget _buildWithdrawalForm(FastWithdrawalTabViewModel viewModel, SailColor theme) {
    return SailCard(
      title: 'Fast Withdrawal',
      subtitle: 'Quickly withdraw L2 coins to your L1-wallet',
      padding: true,
      error: viewModel.errorMessage,
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding16,
        children: [
          // Amount input with paste button
          SailTextField(
            label: 'Withdraw amount (BTC)',
            controller: viewModel.amountController,
            hintText: 'How much do you want to withdraw?',
            suffixWidget: PasteButton(
              onPaste: (text) => viewModel.amountController.text = text,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('From L2'),
              const SizedBox(height: 8),
              SailDropdownButton(
                items: ['Thunder', 'BitNames'].map((chain) => SailDropdownItem(label: chain, value: chain)).toList(),
                value: viewModel.layer2Chain,
                onChanged: (dynamic value) {
                  viewModel.setLayer2Chain(value as String);
                },
              ),
            ],
          ),

          // Server and L2 Chain selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary13('Using fast withdrawal server'),
                    const SizedBox(height: 8),
                    SailDropdownButton(
                      items: FastWithdrawalTabViewModel.fastWithdrawalServers
                          .map((e) => SailDropdownItem(label: e['name']!, value: e['url']!))
                          .toList(),
                      value: viewModel.selectedServer,
                      onChanged: (dynamic value) {
                        viewModel.setSelectedServer(value as String);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit button
          SailButton(
            label: 'Request Withdrawal',
            onPressed: () => viewModel.requestWithdrawal(),
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(FastWithdrawalTabViewModel viewModel, SailColor theme) {
    return SailCard(
      title: 'Complete withdrawal',
      subtitle: 'Send funds to the info below to complete the withdrawal',
      error: viewModel.errorMessage,
      widgetHeaderEnd: SailButton(
        label: 'Cancel Withdrawal',
        onPressed: () async {
          viewModel.resetState();
        },
        variant: ButtonVariant.destructive,
      ),
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding16,
        children: [
          // Payment instructions
          if (viewModel.paymentMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.border),
              ),
              child: SailColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: SailStyleValues.padding08,
                children: [
                  SailText.primary13('Send L2 ${viewModel.layer2Chain} Coins to the info below'),
                  SailTextField(
                    controller: TextEditingController(
                      text: viewModel.paymentMessage!['amount'],
                    ),
                    hintText: 'Amount',
                    readOnly: true,
                    suffixWidget: CopyButton(text: viewModel.paymentMessage!['amount']),
                  ),
                  SailTextField(
                    controller: TextEditingController(text: viewModel.paymentMessage!['address']),
                    hintText: 'L2 address',
                    readOnly: true,
                    suffixWidget: CopyButton(text: viewModel.paymentMessage!['address']),
                  ),
                ],
              ),
            ),
          ],

          // Payment completion form
          Row(
            children: [
              Expanded(
                child: SailTextField(
                  label: 'Paste the L2 txid here to complete the withdrawal',
                  controller: viewModel.paymentTxIdController,
                  hintText: 'Paste L2 payment txid',
                  suffixWidget: PasteButton(
                    onPaste: (text) => viewModel.paymentTxIdController.text = text,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SailButton(
                label: 'Complete Withdrawal',
                onPressed: () => viewModel.completeWithdrawal(),
                variant: ButtonVariant.primary,
              ),
            ],
          ),

          // Withdrawal Hash display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary13('Withdrawal Hash:'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SailText.primary13(viewModel.withdrawalHash!),
                    ),
                    CopyButton(text: viewModel.withdrawalHash!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessSection(FastWithdrawalTabViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SailColorScheme.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SailColorScheme.green),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          Icon(Icons.check_circle, color: SailColorScheme.green, size: 48),
          SailText.primary24('Withdrawal Completed'),
          const SizedBox(height: 8),
          SailText.secondary13(
            'Coins are on their way to your L1-wallet and should show up in your unconfirmed balance soon.',
          ),
          SailText.secondary13('TXID: ${viewModel.successMessage}'),
          const SizedBox(height: 16),
          SailButton(
            label: 'Start New Withdrawal',
            onPressed: () async {
              viewModel.resetState();
            },
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}

class FastWithdrawalTabViewModel extends BaseViewModel {
  final Logger log = GetIt.I.get<Logger>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();

  String get address => transactionsProvider.address;

  // Fast withdrawal server configuration
  static const List<Map<String, String>> fastWithdrawalServers = [
    {
      'name': 'fw1.drivechain.info (L2L #1)',
      'url': 'https://fw1.drivechain.info',
    },
    {
      'name': 'fw2.drivechain.info (L2L #2)',
      'url': 'https://fw2.drivechain.info',
    },
  ];

  static String get defaultServer => fastWithdrawalServers[0]['url']!;

  // Form state
  String selectedServer = defaultServer;
  String layer2Chain = 'Thunder';
  String amount = '';
  String? withdrawalHash;
  String paymentTxid = '';
  Map<String, dynamic>? paymentMessage;
  String successMessage = '';
  String errorMessage = '';
  bool isCompleted = false;

  // Clipboard states
  Map<String, bool> copiedStates = {};

  // Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentTxIdController = TextEditingController();

  void setSelectedServer(String server) {
    selectedServer = server;
    notifyListeners();
  }

  void setLayer2Chain(String chain) {
    layer2Chain = chain;
    notifyListeners();
  }

  void clearError() {
    errorMessage = '';
    notifyListeners();
  }

  Future<void> pasteFromClipboard(TextEditingController controller) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        controller.text = data!.text!;
        notifyListeners();
      }
    } catch (error) {
      log.e('could not paste from clipboard: $error');
    }
  }

  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      copiedStates['hash'] = true;
      notifyListeners();

      // Reset copied state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        copiedStates['hash'] = false;
        notifyListeners();
      });
    } catch (error) {
      log.e('could not copy to clipboard: $error');
    }
  }

  Future<void> requestWithdrawal() async {
    try {
      errorMessage = '';

      // Validate inputs
      final amountValue = double.tryParse(amountController.text);
      if (amountValue == null || amountValue <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      if (address.isEmpty) {
        throw Exception('Address not loaded yet, please wait for enforcer to start and wallet to sync..');
      }

      // Make actual API call
      final url = Uri.parse('$selectedServer/withdraw');
      final body = {
        'withdrawal_destination': address,
        'withdrawal_amount': amountValue.toString(),
        'layer_2_chain_name': layer2Chain,
      };

      log.i('requesting withdrawal from $url with params: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] != 'success') {
        throw Exception(responseData['error'] ?? 'Withdrawal request failed');
      }

      final result = responseData['data'];

      // Handle the response
      if (result['server_l2_address']?['info'] == null) {
        log.i('HMMM: $result');
        final errorMessage = result['error'] ?? jsonEncode(result);
        throw Exception('Withdrawal request failed: $errorMessage');
      }

      withdrawalHash = result['hash'];
      final totalAmount = (amountValue + (result['server_fee_sats'] as int) / 100000000).toString();
      paymentMessage = {
        'amount': totalAmount,
        'address': result['server_l2_address']['info'],
      };

      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> completeWithdrawal() async {
    try {
      errorMessage = '';

      if (paymentTxIdController.text.trim().isEmpty) {
        throw Exception('Please enter your L2 payment transaction ID');
      }

      // Make actual API call
      final url = Uri.parse('$selectedServer/paid');
      final body = {
        'hash': withdrawalHash!,
        'txid': paymentTxIdController.text.trim(),
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] != 'success') {
        throw Exception(responseData['error'] ?? 'Payment notification failed');
      }

      successMessage = responseData['message']['info'];
      isCompleted = true;

      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  void resetState() {
    amountController.clear();
    paymentTxIdController.clear();
    withdrawalHash = null;
    paymentMessage = null;
    successMessage = '';
    errorMessage = '';
    isCompleted = false;
    copiedStates.clear();
    notifyListeners();
  }
}
