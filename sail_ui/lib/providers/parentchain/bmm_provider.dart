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

class BmmResult {
  final String hashLastMainBlock;

  // hashCreatedMerkleRoot/hashCreated in the testchain codebase
  final String? bmmBlockCreated;

  // hashConnected in the testchain codebase
  final String? bmmBlockSubmitted;

  // hashMerkleRoot/hashConnectedBlind in the testchain codebase
  final String? bmmBlockSubmittedBlind;

  final int ntxn; // number of transactions
  final int nfees; // total fees
  final String txid; // transaction ID
  final String? error; // error message, if any
  final String raw; // raw JSON string, empty means "Trying..."

  String get status {
    if (raw.isEmpty) return 'Trying...';
    if (error != null) return 'Error: $error';
    return 'Success';
  }

  BmmResult({
    required this.hashLastMainBlock,
    required this.bmmBlockCreated,
    required this.bmmBlockSubmitted,
    required this.bmmBlockSubmittedBlind,
    required this.ntxn,
    required this.nfees,
    required this.txid,
    this.error,
    required this.raw,
  });

  BmmResult copyWith({
    String? hashLastMainBlock,
    String? bmmBlockCreated,
    String? bmmBlockSubmitted,
    String? bmmBlockSubmittedBlind,
    int? ntxn,
    int? nfees,
    String? txid,
    String? error,
    String? raw,
  }) {
    return BmmResult(
      hashLastMainBlock: hashLastMainBlock ?? this.hashLastMainBlock,
      bmmBlockCreated: bmmBlockCreated ?? this.bmmBlockCreated,
      bmmBlockSubmitted: bmmBlockSubmitted ?? this.bmmBlockSubmitted,
      bmmBlockSubmittedBlind: bmmBlockSubmittedBlind ?? this.bmmBlockSubmittedBlind,
      ntxn: ntxn ?? this.ntxn,
      nfees: nfees ?? this.nfees,
      txid: txid ?? this.txid,
      error: error ?? this.error,
      raw: raw ?? this.raw,
    );
  }

  factory BmmResult.fromMap(Map<String, dynamic> map) {
    return BmmResult(
      hashLastMainBlock: map['hash_last_main_block'] ?? '',
      bmmBlockCreated: ifNonEmpty(map['bmm_block_created']),
      bmmBlockSubmitted: ifNonEmpty(map['bmm_block_submitted']),
      bmmBlockSubmittedBlind: ifNonEmpty(map['bmm_block_submitted_blind']),
      ntxn: map['ntxn'] ?? 0,
      nfees: map['nfees'] ?? 0,
      txid: map['txid'] ?? '',
      error: ifNonEmpty(map['error']),
      raw: jsonEncode(map),
    );
  }

  static BmmResult fromJson(Map<String, dynamic> json) => BmmResult.fromMap(json);
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'hash_last_main_block': hashLastMainBlock,
        'bmm_block_created': bmmBlockCreated,
        'bmm_block_submitted': bmmBlockSubmitted,
        'bmm_block_submitted_blind': bmmBlockSubmittedBlind,
        'ntxn': ntxn,
        'nfees': nfees,
        'txid': txid,
        'error': error,
      };

  static BmmResult empty() => BmmResult(
        hashLastMainBlock: '0000000000000000000000000000000000000000000000000000000000000000',
        bmmBlockCreated: null,
        bmmBlockSubmitted: null,
        bmmBlockSubmittedBlind: null,
        ntxn: 0,
        nfees: 0,
        txid: '',
        error: null,
        raw: '{}',
      );
}

String? ifNonEmpty(String input) {
  if (input.isEmpty || input.split('').every((element) => element == '0')) {
    return null;
  }

  return input;
}
