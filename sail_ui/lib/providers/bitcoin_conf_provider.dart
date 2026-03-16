import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

/// Abstract Bitcoin Core configuration provider.
/// BitWindow uses FrontendBitcoinConfProvider (file-based).
/// Thunder uses BackendBitcoinConfProvider (via BitcoinConfService RPC).
abstract class BitcoinConfProvider extends ChangeNotifier {
  bool get hasPrivateBitcoinConf;
  String? get configPath;
  BitcoinNetwork get network;
  String? get detectedDataDir;
  BitcoinConfig? get currentConfig;
  RootStackRouter get router;

  bool get networkSupportsSidechains;
  bool get isDemoMode;
  int get rpcPort;

  Future<void> loadConfig({bool isFirst = false});
  Future<void> updateNetwork(BitcoinNetwork newNetwork);
  Future<void> swapNetwork(BuildContext context, BitcoinNetwork newNetwork);
  Future<void> updateDataDir(String? dataDir, {BitcoinNetwork? forNetwork});
  Future<void> commitNetworkChange(BitcoinNetwork newNetwork);
  String getDefaultConfig();
  String getCurrentConfigContent();
  Future<void> writeConfig(String content);

  static Future<BitcoinConfProvider> create(RootStackRouter router) async {
    if (Environment.backendManagesBinaries) {
      return BackendBitcoinConfProvider.create(router);
    }
    return FrontendBitcoinConfProvider.create(router);
  }
}
