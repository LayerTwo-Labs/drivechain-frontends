import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:launcher/services/net.dart';

class ToolsPageViewModel extends BaseViewModel {
  final Net _net = Net();
  
  /// Whether to use localhost for the debug server.
  bool useLocalhost = false;

  /// Connection state
  bool get isConnected => _net.isConnected;

  /// Human-readable status: "Not Connected", "Connected", etc.
  String connectionStatus = 'Not Connected';

  /// Invoice status: "Awaiting Payment" or "Payment Complete"
  String invoiceStatus = 'Awaiting Payment';

  /// The text displayed after requesting withdrawal (invoice details).
  String invoiceText = '';

  /// The L2 address where payment should be sent
  String invoiceAddress = '';

  /// A final message displayed once the withdrawal is completed.
  String finalMessage = '';

  /// Controllers for user input
  final TextEditingController mainchainAddressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentTxIdController = TextEditingController();

  void init() {
    // Initialize with default amount
    amountController.text = '1.0';

    // Set up Net service listeners
    _net.connected.listen((_) {
      connectionStatus = 'Connected';
      notifyListeners();
    });

    _net.disconnected.listen((_) {
      connectionStatus = 'Not Connected';
      notifyListeners();
    });

    _net.connectionFailed.listen((error) {
      connectionStatus = 'Connection Failed: $error';
      notifyListeners();
    });

    _net.fastWithdrawInvoice.listen((event) {
      final (amount, destination) = event;
      invoiceAddress = destination;
      
      invoiceText = 'Fast withdraw request received! Invoice created:\n'
          'Send $amount L2 coins to $destination\n'
          'Once you have paid enter the L2 txid and hit invoice paid';
      
      invoiceStatus = 'Awaiting Payment';
      notifyListeners();
    });

    _net.fastWithdrawComplete.listen((event) {
      final (txid, amount, destination) = event;
      
      finalMessage = 'Withdraw complete!\n'
          'Mainchain payout txid:\n$txid\n'
          'Amount: $amount\n'
          'Destination: $destination';
      
      invoiceStatus = 'Payment Complete';
      notifyListeners();
    });

    // Enable debug printing if needed
    _net.printDebugNet = true;
  }

  void setUseLocalhost(bool value) {
    useLocalhost = value;
    notifyListeners();
  }

  /// Connect/disconnect from server
  Future<void> connectToServer() async {
    if (isConnected) {
      _net.disconnect();
    } else {
      final host = useLocalhost ? Net.serverLocalhost : Net.serverL2LGA;
      await _net.connect(host);
    }
  }

  /// Request a fast withdrawal
  Future<void> requestWithdrawal() async {
    if (!isConnected) {
      print('Not connected to server');
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;
    final destination = mainchainAddressController.text;

    await _net.requestFastWithdraw(amount, destination);
  }

  /// Mark the invoice as paid
  Future<void> invoicePaid() async {
    if (!isConnected) {
      print('Not connected to server');
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;
    final destination = mainchainAddressController.text;
    final txid = paymentTxIdController.text;

    await _net.invoicePaid(txid, amount, destination);
  }

  @override
  void dispose() {
    mainchainAddressController.dispose();
    amountController.dispose();
    paymentTxIdController.dispose();
    _net.dispose();
    super.dispose();
  }
}