import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';

// Keeps the hardware-wallet list warm: enumerated on launch and every 5s, so a
// device picker can show them the instant the user starts a transaction.
class HwiProvider extends ChangeNotifier {
  final log = GetIt.I.get<Logger>();

  List<wmpb.HardwareDevice> devices = [];
  String? error;

  // Set true around a PIN/sign interaction so the poll never opens the device
  // mid-flow (which would disrupt a pending prompt).
  bool suspended = false;

  bool _isFetching = false;
  Timer? _timer;

  HwiProvider() {
    _startTimer();
    fetch();
  }

  Future<void> fetch() async {
    if (_isFetching || suspended) return;
    _isFetching = true;
    try {
      final d = await GetIt.I.get<OrchestratorRPC>().wallet.enumerateHardwareDevices();
      if (!listEquals(d, devices)) {
        devices = d;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      error = '$e';
    } finally {
      _isFetching = false;
    }
  }

  void _startTimer() {
    if (Environment.isInTest) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
