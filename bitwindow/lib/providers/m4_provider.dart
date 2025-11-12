import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart' as drivechainpb;
import 'package:sail_ui/gen/m4/v1/m4.pb.dart' as m4pb;
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class M4Provider extends ChangeNotifier {
  final Logger log = Logger(level: Level.debug);
  final BitwindowRPC _bitwindowRPC = GetIt.I.get<BitwindowRPC>();

  List<drivechainpb.WithdrawalBundle> withdrawalBundles = [];
  List<m4pb.M4HistoryEntry> history = [];
  List<m4pb.M4Vote> votePreferences = [];
  bool isLoading = false;
  String? modelError;

  Timer? _pollTimer;

  M4Provider() {
    _bitwindowRPC.addListener(_onBitwindowConnectionChanged);
    GetIt.I.get<BlockchainProvider>().addListener(_onNewBlock);
    _init();
  }

  Future<void> _init() async {
    if (_bitwindowRPC.connected) {
      await fetch();
    }
  }

  void _onBitwindowConnectionChanged() {
    if (_bitwindowRPC.connected) {
      fetch();
    }
  }

  void _onNewBlock() {
    fetch();
  }

  Future<void> fetch() async {
    isLoading = true;
    modelError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _bitwindowRPC.drivechain.listWithdrawals(
          sidechainId: 0,
          startBlockHeight: 0,
          endBlockHeight: 999999999,
        ),
        _bitwindowRPC.m4.getM4History(limit: 10),
        _bitwindowRPC.m4.getVotePreferences(),
      ]);

      withdrawalBundles = results[0] as List<drivechainpb.WithdrawalBundle>;
      history = results[1] as List<m4pb.M4HistoryEntry>;
      votePreferences = results[2] as List<m4pb.M4Vote>;
      modelError = null;
    } catch (e) {
      log.e('Failed to fetch M4 data: $e');
      modelError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setVotePreference({
    required int sidechainSlot,
    required String voteType,
    String? bundleHash,
  }) async {
    try {
      await _bitwindowRPC.m4.setVotePreference(
        sidechainSlot: sidechainSlot,
        voteType: voteType,
        bundleHash: bundleHash,
      );

      await fetch();
      modelError = null;
      notifyListeners();
    } catch (e) {
      log.e('Failed to set vote preference: $e');
      modelError = e.toString();
      notifyListeners();
    }
  }

  Future<m4pb.GenerateM4BytesResponse?> generateM4Bytes() async {
    try {
      final resp = await _bitwindowRPC.m4.generateM4Bytes();
      modelError = null;
      return resp;
    } catch (e) {
      log.e('Failed to generate M4 bytes: $e');
      modelError = e.toString();
      notifyListeners();
      return null;
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    stopPolling();
    _pollTimer = Timer.periodic(interval, (_) async {
      await fetch();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _bitwindowRPC.removeListener(_onBitwindowConnectionChanged);
    GetIt.I.get<BlockchainProvider>().removeListener(_onNewBlock);
    stopPolling();
    super.dispose();
  }
}
