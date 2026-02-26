import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Provider for managing CoinShift swap state with polling.
class SwapProvider extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();
  CoinShiftRPC get _rpc => GetIt.I.get<CoinShiftRPC>();

  List<CoinShiftSwap> swaps = [];
  bool isLoading = false;
  String? error;
  Timer? _pollTimer;

  /// Get all swaps that are ready to claim
  List<CoinShiftSwap> get claimableSwaps => swaps.where((s) => s.state.isReadyToClaim).toList();

  /// Get all pending swaps
  List<CoinShiftSwap> get pendingSwaps => swaps.where((s) => s.state.isPending).toList();

  /// Get all swaps waiting for confirmations
  List<CoinShiftSwap> get waitingConfirmationsSwaps => swaps.where((s) => s.state.isWaitingConfirmations).toList();

  /// Get all completed swaps
  List<CoinShiftSwap> get completedSwaps => swaps.where((s) => s.state.isCompleted).toList();

  /// Get all active (non-completed, non-cancelled) swaps
  List<CoinShiftSwap> get activeSwaps => swaps.where((s) => !s.state.isCompleted && !s.state.isCancelled).toList();

  SwapProvider() {
    _startPolling();
  }

  void _startPolling() {
    // Initial fetch
    fetchSwaps();

    // Poll every 30 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchSwaps();
    });
  }

  /// Fetch all swaps from the RPC
  Future<void> fetchSwaps() async {
    if (!_rpc.connected) return;

    try {
      isLoading = true;
      error = null;

      final fetchedSwaps = await _rpc.listSwaps();
      swaps = fetchedSwaps;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to fetch swaps: $e');
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new swap
  Future<CoinShiftSwapCreateResult?> createSwap({
    required int l2AmountSats,
    required int l1AmountSats,
    required String l1RecipientAddress,
    required ParentChainType parentChain,
    String? l2Recipient,
    int? requiredConfirmations,
    required int feeSats,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _rpc.createSwap(
        l2AmountSats: l2AmountSats,
        l1AmountSats: l1AmountSats,
        l1RecipientAddress: l1RecipientAddress,
        parentChain: parentChain.value,
        l2Recipient: l2Recipient,
        requiredConfirmations: requiredConfirmations,
        feeSats: feeSats,
      );

      // Refresh the swaps list
      await fetchSwaps();

      return result;
    } catch (e) {
      log.e('Failed to create swap: $e');
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Claim a swap
  Future<String?> claimSwap(CoinShiftSwap swap, {String? l2ClaimerAddress}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final txid = await _rpc.claimSwap(swap.id, l2ClaimerAddress: l2ClaimerAddress);

      // Refresh the swaps list
      await fetchSwaps();

      return txid;
    } catch (e) {
      log.e('Failed to claim swap: $e');
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Get the status of a specific swap
  Future<CoinShiftSwap?> getSwapStatus(String swapId) async {
    try {
      return await _rpc.getSwapStatus(swapId);
    } catch (e) {
      log.e('Failed to get swap status: $e');
      return null;
    }
  }

  /// Update swap with L1 transaction information
  Future<void> updateSwapL1Txid({
    required String swapId,
    required String l1TxidHex,
    required int confirmations,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _rpc.updateSwapL1Txid(
        swapId: swapId,
        l1TxidHex: l1TxidHex,
        confirmations: confirmations,
      );

      // Refresh the swaps list
      await fetchSwaps();
    } catch (e) {
      log.e('Failed to update swap L1 txid: $e');
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  /// Manually refresh swaps
  Future<void> refresh() async {
    await fetchSwaps();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
