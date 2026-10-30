import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Build facts of one app, from its generated `lib/gen/version.dart`.
class SidechainAppVersion {
  final String version;
  final String versionString;
  final String buildDate;
  final String commitFull;
  final String appName;

  const SidechainAppVersion({
    required this.version,
    required this.versionString,
    required this.buildDate,
    required this.commitFull,
    required this.appName,
  });
}

/// One chain tab in the top nav, between the homepage and the console.
class ShellTab {
  final String label;
  final PageRouteInfo route;

  /// The label in the command palette, when it differs from [label].
  final String? commandLabel;

  /// The source files whose code search hits open this tab.
  final List<String> sourceFiles;

  const ShellTab({required this.label, required this.route, this.commandLabel, this.sourceFiles = const []});
}

/// Describes one sidechain app that runs on the shared shell.
abstract class SidechainModule {
  Sidechain get chain;

  /// The short name in window titles, menus and labels, e.g. `Thunder`.
  String get appName;

  /// The name in the settings, the debug window and the conf file, e.g. `Big Block Covenant`.
  String get fullName => appName;

  SidechainAppVersion get version;

  /// Registers the router of the app under its own type and returns it.
  RootStackRouter registerRouter(GetIt getIt);

  /// Registers the typed RPC alias of the chain (e.g. `ThunderRPC`) and returns it.
  SidechainRPC registerRPC(GetIt getIt);

  /// Registers the providers that only this chain uses.
  Future<void> registerChainProviders(GetIt getIt, Directory applicationDir, Logger log) async {}

  /// Runs after the first frame of the main window.
  void onFirstFrame() {}

  /// The endpoints of the conf file for `signet`, `regtest` or `mainnet`.
  Map<String, String> confPorts(String network);

  /// The conf file that the app writes when none exists.
  String defaultConf(String network) => standardSidechainConf(appName, network, confPorts(network));

  /// The conf keys that the CLI preview leaves out.
  List<String> get confSkippedCliKeys => const ['network'];

  String confDir() => chain.datadir();

  bool get hasConfEditor => true;

  /// The widget ids of the homepage before the user changes it.
  List<String> get defaultHomepageWidgets;

  Map<String, HomepageWidgetInfo> get widgetCatalog;

  String get homeTabLabel => 'Overview';

  /// The source files, other than the homepage, whose code search hits open the homepage.
  List<String> get homepageSourceFiles => const [];

  List<ShellTab> get tabs => const [];

  List<Binary> get binariesToStop => [BitcoinCore(), Enforcer(), chain];
}
