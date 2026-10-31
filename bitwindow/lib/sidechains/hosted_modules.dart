import 'package:auto_route/auto_route.dart';
import 'package:bitassets/bitassets_module.dart';
import 'package:bitnames/bitnames_module.dart';
import 'package:coinshift/coinshift_module.dart';
import 'package:photon/photon_module.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:thunder/thunder_module.dart';
import 'package:truthcoin/truthcoin_module.dart';
import 'package:zside/zside_module.dart';

/// The sidechains that BitWindow opens inside its own window.
final List<SidechainModule> hostedModules = [
  ThunderModule(),
  BitnamesModule(),
  BitAssetsModule(),
  TruthcoinModule(),
  ZSideModule(),
  PhotonModule(),
  CoinShiftModule(),
];

SidechainModule? hostedModuleFor(Binary chain) {
  for (final module in hostedModules) {
    if (module.chain.type == chain.type) {
      return module;
    }
  }
  return null;
}

SidechainModule? hostedModuleByKey(String registryKey) {
  for (final module in hostedModules) {
    if (module.chain.registryKey == registryKey) {
      return module;
    }
  }
  return null;
}

/// The tab routes of every hosted chain, under the host route.
List<AutoRoute> hostedTabRoutes() => shellTabRouteConfig([for (final module in hostedModules) ...module.tabRoutes]);

/// The pages of every hosted chain that open on top of BitWindow.
List<AutoRoute> hostedPageRoutes() => [for (final module in hostedModules) ...module.pageRoutes];
