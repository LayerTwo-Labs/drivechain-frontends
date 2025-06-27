import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/bitcoin.dart';

enum BMMStatus { idle, running, stopped, error }

class BMMProvider extends ChangeNotifier {
  final SidechainRPC sidechainRPC = GetIt.I.get<SidechainRPC>();

  BMMStatus status = BMMStatus.idle;
  double bidAmount = 0.0001;
  Duration interval = const Duration(seconds: 1);
  Timer? _timer;
  bool _isAttempting = false;

  final List<BmmResult> attempts = [];
  BmmResult? currentAttempt;
  String? error;

  bool get isMining => status == BMMStatus.running;

  void setBidAmount(double value) {
    bidAmount = value;
    notifyListeners();
  }

  void setInterval(Duration value) {
    interval = value;
    notifyListeners();
  }

  void startMining() {
    if (status == BMMStatus.running) return;
    status = BMMStatus.running;
    error = null;
    notifyListeners();
    _startTimer();
  }

  void stopMining() {
    status = BMMStatus.stopped;
    _timer?.cancel();
    currentAttempt = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    // Ensure at least 1 second between attempts
    final effectiveInterval = interval.inMilliseconds < 1000 ? const Duration(seconds: 1) : interval;
    _timer = Timer.periodic(effectiveInterval, (_) => makeAttempt());
  }

  Future<void> makeAttempt() async {
    // Skip if already attempting
    if (_isAttempting) return;
    _isAttempting = true;

    // Create a new attempt with empty raw to indicate "Trying..."
    final attempt = BmmResult(
      hashLastMainBlock: '',
      bmmBlockCreated: null,
      bmmBlockSubmitted: null,
      bmmBlockSubmittedBlind: null,
      ntxn: 0,
      nfees: 0,
      txid: '',
      raw: '', // Empty raw means "Trying..."
    );

    currentAttempt = attempt;
    attempts.insert(0, attempt);
    notifyListeners();

    try {
      // Convert bid amount to satoshis for the mine function
      final feeSats = btcToSatoshi(bidAmount);

      // Call the sidechain's mine function with the fee
      final result = await sidechainRPC.mine(feeSats);

      // Update the attempt with the result
      final index = attempts.indexOf(attempt);
      if (index != -1) {
        attempts[index] = result;
      }

      currentAttempt = attempts.isNotEmpty ? attempts.first : null;
      error = null;
      status = BMMStatus.running;
      notifyListeners();
    } catch (e) {
      final index = attempts.indexOf(attempt);
      if (index != -1) {
        final errorMessage = e.toString();
        attempts[index] = attempt.copyWith(
          error: errorMessage,
          raw: jsonEncode({'error': errorMessage}),
        );
      }

      currentAttempt = attempts.isNotEmpty ? attempts.first : null;
      error = e.toString();
      status = BMMStatus.error;
      notifyListeners();
    } finally {
      _isAttempting = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _isAttempting = false;
    super.dispose();
  }
}
