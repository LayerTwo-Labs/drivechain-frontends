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

  // M4 data per sidechain slot
  Map<int, List<drivechainpb.WithdrawalBundle>> withdrawalBundlesBySidechain = {};
  List<m4pb.M4HistoryEntry> history = [];
  List<m4pb.M4Vote> votePreferences = [];
  bool isLoading = false;
  String? modelError;

  Timer? _pollTimer;
  bool _disposed = false;
  bool _settingVote = false;

  M4Provider() {
    _bitwindowRPC.addListener(_onBitwindowConnectionChanged);
    GetIt.I.get<BlockchainProvider>().addListener(_onNewBlock);
    _init();
  }

  Future<void> _init() async {
    if (_bitwindowRPC.connected) {
      await fetchAll();
    }
  }

  void _onBitwindowConnectionChanged() {
    if (_bitwindowRPC.connected) {
      fetchAll();
    }
  }

  void _onNewBlock() {
    fetchAll();
  }

  // Fetch M4 data for all active sidechains
  Future<void> fetchAll() async {
    if (_disposed || _settingVote) return;

    isLoading = true;
    modelError = null;
    notifyListeners();

    try {
      // Get list of active sidechains
      final sidechains = await _bitwindowRPC.drivechain.listSidechains();

      // Fetch withdrawal bundles for each active sidechain in parallel
      final bundleFutures = sidechains.map((sidechain) async {
        try {
          final bundles = await _bitwindowRPC.drivechain.listWithdrawals(
            sidechainId: sidechain.slot,
            startBlockHeight: 0,
            endBlockHeight: 999999999,
          );
          return MapEntry(sidechain.slot, bundles);
        } catch (e) {
          log.w('Failed to fetch withdrawal bundles for sidechain ${sidechain.slot}: $e');
          return MapEntry(sidechain.slot, <drivechainpb.WithdrawalBundle>[]);
        }
      });

      // Fetch history and vote preferences
      final results = await Future.wait([
        Future.wait(bundleFutures),
        _bitwindowRPC.m4.getM4History(limit: 10),
        _bitwindowRPC.m4.getVotePreferences(),
      ]);

      withdrawalBundlesBySidechain = Map.fromEntries(
        results[0] as List<MapEntry<int, List<drivechainpb.WithdrawalBundle>>>,
      );
      history = results[1] as List<m4pb.M4HistoryEntry>;
      votePreferences = results[2] as List<m4pb.M4Vote>;
      modelError = null;
    } catch (e) {
      log.e('Failed to fetch M4 data: $e');
      modelError = e.toString();
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // Get withdrawal bundles for a specific sidechain
  List<drivechainpb.WithdrawalBundle> getWithdrawalBundles(int sidechainSlot) {
    return withdrawalBundlesBySidechain[sidechainSlot] ?? [];
  }

  Future<void> setVotePreference({
    required int sidechainSlot,
    required String voteType,
    String? bundleHash,
  }) async {
    if (_disposed) return;
    _settingVote = true;
    try {
      await _bitwindowRPC.m4.setVotePreference(
        sidechainSlot: sidechainSlot,
        voteType: voteType,
        bundleHash: bundleHash,
      );

      // Only refresh vote preferences, not all data
      votePreferences = await _bitwindowRPC.m4.getVotePreferences();
      if (_disposed) return;
      modelError = null;
      notifyListeners();
    } catch (e) {
      log.e('Failed to set vote preference: $e');
      if (_disposed) return;
      modelError = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _settingVote = false;
    }
  }

  Future<m4pb.GenerateM4BytesResponse?> generateM4Bytes() async {
    if (_disposed) return null;
    try {
      final resp = await _bitwindowRPC.m4.generateM4Bytes();
      modelError = null;
      return resp;
    } catch (e) {
      log.e('Failed to generate M4 bytes: $e');
      if (_disposed) return null;
      modelError = e.toString();
      notifyListeners();
      return null;
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    stopPolling();
    _pollTimer = Timer.periodic(interval, (_) async {
      await fetchAll();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _bitwindowRPC.removeListener(_onBitwindowConnectionChanged);
    GetIt.I.get<BlockchainProvider>().removeListener(_onNewBlock);
    stopPolling();
    super.dispose();
  }
}
