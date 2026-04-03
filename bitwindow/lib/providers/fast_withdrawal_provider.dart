import 'dart:convert';

import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';

enum FastWithdrawalStage {
  idle,
  requesting,
  awaitingPayment,
  sendingL2,
  completing,
  done,
  error,
}

class FastWithdrawalProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  TransactionProvider get _transactionsProvider => GetIt.I<TransactionProvider>();

  String get address => _transactionsProvider.address;

  // Server configuration
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

  // Stage tracking
  FastWithdrawalStage stage = FastWithdrawalStage.idle;
  String? errorMessage;

  // Withdrawal state (persists across tab switches)
  String? withdrawalHash;
  String? l2Address;
  String? l2Amount;
  String? l2Txid;
  String? l1Txid;
  int? serverFeeSats;

  // Form state
  String selectedServer = defaultServer;
  String layer2Chain = 'Thunder';

  void setSelectedServer(String server) {
    selectedServer = server;
    notifyListeners();
  }

  void setLayer2Chain(String chain) {
    layer2Chain = chain;
    notifyListeners();
  }

  /// Returns the SidechainRPC for the current layer2Chain, or null if not registered/connected.
  SidechainRPC? _getSidechainRPC() {
    try {
      if (layer2Chain == 'Thunder') {
        final rpc = GetIt.I.get<ThunderRPC>();
        return rpc.connected ? rpc : null;
      } else if (layer2Chain == 'BitNames') {
        final rpc = GetIt.I.get<BitnamesRPC>();
        return rpc.connected ? rpc : null;
      }
    } catch (_) {
      // Not registered
    }
    return null;
  }

  /// Whether the sidechain RPC for auto-send is available.
  bool get canAutoSend => _getSidechainRPC() != null;

  /// Request a fast withdrawal from the server.
  Future<void> requestWithdrawal(String amount) async {
    final amountValue = double.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      errorMessage = 'Amount must be greater than 0';
      notifyListeners();
      return;
    }

    if (address.isEmpty) {
      errorMessage = 'Address not loaded yet, please wait for enforcer to start and wallet to sync..';
      notifyListeners();
      return;
    }

    stage = FastWithdrawalStage.requesting;
    errorMessage = null;
    notifyListeners();

    try {
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

      if (result['server_l2_address']?['info'] == null) {
        log.i('HMMM: $result');
        final msg = result['error'] ?? jsonEncode(result);
        throw Exception('Withdrawal request failed: $msg');
      }

      withdrawalHash = result['hash'];
      serverFeeSats = result['server_fee_sats'] as int;
      l2Address = result['server_l2_address']['info'];
      l2Amount = (amountValue + serverFeeSats! / 100000000).toString();

      stage = FastWithdrawalStage.awaitingPayment;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      stage = FastWithdrawalStage.error;
      notifyListeners();
    }
  }

  /// Send L2 coins automatically and complete, or complete with a manual txid.
  /// If [manualTxid] is non-null, uses that txid directly (manual paste flow).
  /// If null, auto-sends via sidechain RPC.
  Future<void> sendL2AndComplete(String? manualTxid) async {
    if (withdrawalHash == null || l2Address == null || l2Amount == null) {
      errorMessage = 'No pending withdrawal to complete';
      notifyListeners();
      return;
    }

    String txid;

    if (manualTxid != null && manualTxid.trim().isNotEmpty) {
      // Manual paste flow
      txid = manualTxid.trim();
    } else {
      // Auto-send flow
      final rpc = _getSidechainRPC();
      if (rpc == null) {
        errorMessage = 'Sidechain RPC not connected — use manual paste instead';
        notifyListeners();
        return;
      }

      stage = FastWithdrawalStage.sendingL2;
      errorMessage = null;
      notifyListeners();

      try {
        final amount = double.parse(l2Amount!);
        txid = await rpc.sideSend(l2Address!, amount, false);
        l2Txid = txid;
        notifyListeners();
      } catch (e) {
        // Auto-send failed — stay in awaitingPayment so user can paste manually
        errorMessage = 'Auto-send failed: $e — you can paste the txid manually below';
        stage = FastWithdrawalStage.awaitingPayment;
        notifyListeners();
        return;
      }
    }

    // Now complete with the server
    stage = FastWithdrawalStage.completing;
    errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('$selectedServer/paid');
      final body = {
        'hash': withdrawalHash!,
        'txid': txid,
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

      l1Txid = responseData['message']['info'];
      l2Txid = txid;
      stage = FastWithdrawalStage.done;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      stage = FastWithdrawalStage.error;
      notifyListeners();
    }
  }

  void reset() {
    stage = FastWithdrawalStage.idle;
    errorMessage = null;
    withdrawalHash = null;
    l2Address = null;
    l2Amount = null;
    l2Txid = null;
    l1Txid = null;
    serverFeeSats = null;
    notifyListeners();
  }
}
