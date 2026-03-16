import 'package:flutter/foundation.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

/// Abstract Enforcer configuration provider.
/// BitWindow uses FrontendEnforcerConfProvider (file-based).
/// Thunder uses BackendEnforcerConfProvider (via EnforcerConfService RPC).
abstract class EnforcerConfProvider extends ChangeNotifier {
  EnforcerConfig? get currentConfig;
  String? get configPath;
  bool get nodeRpcDiffers;

  Map<String, String> getExpectedNodeRpcSettings();
  Future<void> syncNodeRpcFromBitcoinConf();
  String? getEsploraUrlForNetwork(BitcoinNetwork network);
  List<String> getCliArgs(BitcoinNetwork network);
  String getDefaultConfig();
  String getCurrentConfigContent();
  Future<void> writeConfig(String content);

  static Future<EnforcerConfProvider> create() async {
    if (Environment.backendManagesBinaries) {
      return BackendEnforcerConfProvider.create();
    }
    return FrontendEnforcerConfProvider.create();
  }
}
