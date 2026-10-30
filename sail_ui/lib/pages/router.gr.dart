// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i25;
import 'dart:io' as _i29;

import 'package:auto_route/auto_route.dart' as _i22;
import 'package:collection/collection.dart' as _i27;
import 'package:flutter/foundation.dart' as _i28;
import 'package:flutter/material.dart' as _i23;
import 'package:logger/logger.dart' as _i26;
import 'package:sail_ui/pages/bitcoin_conf_editor_page.dart' as _i2;
import 'package:sail_ui/pages/coming_soon_page.dart' as _i4;
import 'package:sail_ui/pages/console_tab_page.dart' as _i5;
import 'package:sail_ui/pages/create_wallet_page.dart' as _i12;
import 'package:sail_ui/pages/datadir_setup_page.dart' as _i6;
import 'package:sail_ui/pages/enforcer_conf_editor_page.dart' as _i7;
import 'package:sail_ui/pages/log_page.dart' as _i9;
import 'package:sail_ui/pages/network_switch_page.dart' as _i10;
import 'package:sail_ui/pages/sail_test_page.dart' as _i13;
import 'package:sail_ui/pages/shutdown_page.dart' as _i14;
import 'package:sail_ui/pages/sidechains/bmm_page.dart' as _i3;
import 'package:sail_ui/pages/sidechains/explorer/explorer_page.dart' as _i8;
import 'package:sail_ui/pages/sidechains/parent_chain_page.dart' as _i11;
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart' as _i19;
import 'package:sail_ui/pages/unlock_wallet_page.dart' as _i21;
import 'package:sail_ui/sail_ui.dart' as _i24;
import 'package:sail_ui/shell/sidechain_conf_editor_page.dart' as _i15;
import 'package:sail_ui/shell/sidechain_configure_homepage_page.dart' as _i16;
import 'package:sail_ui/shell/sidechain_home_page.dart' as _i17;
import 'package:sail_ui/shell/sidechain_homepage.dart' as _i18;
import 'package:sail_ui/shell/sidechain_settings_page.dart' as _i20;
import 'package:sail_ui/widgets/wallet_backup_restore.dart' as _i1;

/// generated route for
/// [_i1.BackupWalletPage]
class BackupWalletRoute extends _i22.PageRouteInfo<BackupWalletRouteArgs> {
  BackupWalletRoute({
    _i23.Key? key,
    String appName = 'wallet',
    List<_i22.PageRouteInfo>? children,
  }) : super(
         BackupWalletRoute.name,
         args: BackupWalletRouteArgs(key: key, appName: appName),
         rawPathParams: {'appName': appName},
         initialChildren: children,
       );

  static const String name = 'BackupWalletRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<BackupWalletRouteArgs>(
        orElse: () => BackupWalletRouteArgs(
          appName: pathParams.getString('appName', 'wallet'),
        ),
      );
      return _i1.BackupWalletPage(key: args.key, appName: args.appName);
    },
  );
}

class BackupWalletRouteArgs {
  const BackupWalletRouteArgs({this.key, this.appName = 'wallet'});

  final _i23.Key? key;

  final String appName;

  @override
  String toString() {
    return 'BackupWalletRouteArgs{key: $key, appName: $appName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BackupWalletRouteArgs) return false;
    return key == other.key && appName == other.appName;
  }

  @override
  int get hashCode => key.hashCode ^ appName.hashCode;
}

/// generated route for
/// [_i2.BitcoinConfEditorPage]
class BitcoinConfEditorRoute extends _i22.PageRouteInfo<void> {
  const BitcoinConfEditorRoute({List<_i22.PageRouteInfo>? children})
    : super(BitcoinConfEditorRoute.name, initialChildren: children);

  static const String name = 'BitcoinConfEditorRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.BitcoinConfEditorPage();
    },
  );
}

/// generated route for
/// [_i3.BmmPage]
class BmmRoute extends _i22.PageRouteInfo<void> {
  const BmmRoute({List<_i22.PageRouteInfo>? children})
    : super(BmmRoute.name, initialChildren: children);

  static const String name = 'BmmRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i3.BmmPage();
    },
  );
}

/// generated route for
/// [_i4.ComingSoonPage]
class ComingSoonRoute extends _i22.PageRouteInfo<ComingSoonRouteArgs> {
  ComingSoonRoute({
    _i23.Key? key,
    required _i22.RootStackRouter router,
    required String message,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         ComingSoonRoute.name,
         args: ComingSoonRouteArgs(key: key, router: router, message: message),
         initialChildren: children,
       );

  static const String name = 'ComingSoonRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ComingSoonRouteArgs>();
      return _i4.ComingSoonPage(
        key: args.key,
        router: args.router,
        message: args.message,
      );
    },
  );
}

class ComingSoonRouteArgs {
  const ComingSoonRouteArgs({
    this.key,
    required this.router,
    required this.message,
  });

  final _i23.Key? key;

  final _i22.RootStackRouter router;

  final String message;

  @override
  String toString() {
    return 'ComingSoonRouteArgs{key: $key, router: $router, message: $message}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ComingSoonRouteArgs) return false;
    return key == other.key &&
        router == other.router &&
        message == other.message;
  }

  @override
  int get hashCode => key.hashCode ^ router.hashCode ^ message.hashCode;
}

/// generated route for
/// [_i5.ConsoleTabPage]
class ConsoleTabRoute extends _i22.PageRouteInfo<void> {
  const ConsoleTabRoute({List<_i22.PageRouteInfo>? children})
    : super(ConsoleTabRoute.name, initialChildren: children);

  static const String name = 'ConsoleTabRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i5.ConsoleTabPage();
    },
  );
}

/// generated route for
/// [_i6.DataDirSetupPage]
class DataDirSetupRoute extends _i22.PageRouteInfo<DataDirSetupRouteArgs> {
  DataDirSetupRoute({
    _i23.Key? key,
    required _i24.BitcoinNetwork network,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         DataDirSetupRoute.name,
         args: DataDirSetupRouteArgs(key: key, network: network),
         initialChildren: children,
       );

  static const String name = 'DataDirSetupRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DataDirSetupRouteArgs>();
      return _i6.DataDirSetupPage(key: args.key, network: args.network);
    },
  );
}

class DataDirSetupRouteArgs {
  const DataDirSetupRouteArgs({this.key, required this.network});

  final _i23.Key? key;

  final _i24.BitcoinNetwork network;

  @override
  String toString() {
    return 'DataDirSetupRouteArgs{key: $key, network: $network}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DataDirSetupRouteArgs) return false;
    return key == other.key && network == other.network;
  }

  @override
  int get hashCode => key.hashCode ^ network.hashCode;
}

/// generated route for
/// [_i7.EnforcerConfEditorPage]
class EnforcerConfEditorRoute extends _i22.PageRouteInfo<void> {
  const EnforcerConfEditorRoute({List<_i22.PageRouteInfo>? children})
    : super(EnforcerConfEditorRoute.name, initialChildren: children);

  static const String name = 'EnforcerConfEditorRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i7.EnforcerConfEditorPage();
    },
  );
}

/// generated route for
/// [_i8.ExplorerPage]
class ExplorerRoute extends _i22.PageRouteInfo<void> {
  const ExplorerRoute({List<_i22.PageRouteInfo>? children})
    : super(ExplorerRoute.name, initialChildren: children);

  static const String name = 'ExplorerRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i8.ExplorerPage();
    },
  );
}

/// generated route for
/// [_i9.LogPage]
class LogRoute extends _i22.PageRouteInfo<LogRouteArgs> {
  LogRoute({
    _i23.Key? key,
    required String logPath,
    required String title,
    _i24.BinaryType? binaryType,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         LogRoute.name,
         args: LogRouteArgs(
           key: key,
           logPath: logPath,
           title: title,
           binaryType: binaryType,
         ),
         initialChildren: children,
       );

  static const String name = 'LogRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LogRouteArgs>();
      return _i9.LogPage(
        key: args.key,
        logPath: args.logPath,
        title: args.title,
        binaryType: args.binaryType,
      );
    },
  );
}

class LogRouteArgs {
  const LogRouteArgs({
    this.key,
    required this.logPath,
    required this.title,
    this.binaryType,
  });

  final _i23.Key? key;

  final String logPath;

  final String title;

  final _i24.BinaryType? binaryType;

  @override
  String toString() {
    return 'LogRouteArgs{key: $key, logPath: $logPath, title: $title, binaryType: $binaryType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LogRouteArgs) return false;
    return key == other.key &&
        logPath == other.logPath &&
        title == other.title &&
        binaryType == other.binaryType;
  }

  @override
  int get hashCode =>
      key.hashCode ^ logPath.hashCode ^ title.hashCode ^ binaryType.hashCode;
}

/// generated route for
/// [_i10.NetworkSwitchPage]
class NetworkSwitchRoute extends _i22.PageRouteInfo<void> {
  const NetworkSwitchRoute({List<_i22.PageRouteInfo>? children})
    : super(NetworkSwitchRoute.name, initialChildren: children);

  static const String name = 'NetworkSwitchRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i10.NetworkSwitchPage();
    },
  );
}

/// generated route for
/// [_i11.ParentChainPage]
class ParentChainRoute extends _i22.PageRouteInfo<void> {
  const ParentChainRoute({List<_i22.PageRouteInfo>? children})
    : super(ParentChainRoute.name, initialChildren: children);

  static const String name = 'ParentChainRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.ParentChainPage();
    },
  );
}

/// generated route for
/// [_i1.RestoreWalletPage]
class RestoreWalletRoute extends _i22.PageRouteInfo<RestoreWalletRouteArgs> {
  RestoreWalletRoute({
    _i23.Key? key,
    required _i25.Future<void> Function(_i26.Logger) bootBinaries,
    required List<_i24.Binary> binariesToStop,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         RestoreWalletRoute.name,
         args: RestoreWalletRouteArgs(
           key: key,
           bootBinaries: bootBinaries,
           binariesToStop: binariesToStop,
         ),
         initialChildren: children,
       );

  static const String name = 'RestoreWalletRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RestoreWalletRouteArgs>();
      return _i1.RestoreWalletPage(
        key: args.key,
        bootBinaries: args.bootBinaries,
        binariesToStop: args.binariesToStop,
      );
    },
  );
}

class RestoreWalletRouteArgs {
  const RestoreWalletRouteArgs({
    this.key,
    required this.bootBinaries,
    required this.binariesToStop,
  });

  final _i23.Key? key;

  final _i25.Future<void> Function(_i26.Logger) bootBinaries;

  final List<_i24.Binary> binariesToStop;

  @override
  String toString() {
    return 'RestoreWalletRouteArgs{key: $key, bootBinaries: $bootBinaries, binariesToStop: $binariesToStop}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RestoreWalletRouteArgs) return false;
    return key == other.key &&
        const _i27.ListEquality<_i24.Binary>().equals(
          binariesToStop,
          other.binariesToStop,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i27.ListEquality<_i24.Binary>().hash(binariesToStop);
}

/// generated route for
/// [_i12.SailCreateWalletPage]
class SailCreateWalletRoute
    extends _i22.PageRouteInfo<SailCreateWalletRouteArgs> {
  SailCreateWalletRoute({
    _i28.Key? key,
    String appName = 'Drivechain',
    _i28.VoidCallback? onWalletCreated,
    _i28.VoidCallback? onBack,
    bool showFileRestore = false,
    _i23.Widget Function(_i23.BuildContext)? additionalRestoreOptionsBuilder,
    _i25.Future<void> Function(_i29.File)? onRestoreFromFile,
    _i23.Widget Function(_i23.BuildContext, _i28.VoidCallback)?
    successActionsBuilder,
    _i12.WelcomeScreen initialScreen = _i12.WelcomeScreen.initial,
    required _i22.PageRouteInfo<Object?> homeRoute,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         SailCreateWalletRoute.name,
         args: SailCreateWalletRouteArgs(
           key: key,
           appName: appName,
           onWalletCreated: onWalletCreated,
           onBack: onBack,
           showFileRestore: showFileRestore,
           additionalRestoreOptionsBuilder: additionalRestoreOptionsBuilder,
           onRestoreFromFile: onRestoreFromFile,
           successActionsBuilder: successActionsBuilder,
           initialScreen: initialScreen,
           homeRoute: homeRoute,
         ),
         initialChildren: children,
       );

  static const String name = 'SailCreateWalletRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailCreateWalletRouteArgs>();
      return _i12.SailCreateWalletPage(
        key: args.key,
        appName: args.appName,
        onWalletCreated: args.onWalletCreated,
        onBack: args.onBack,
        showFileRestore: args.showFileRestore,
        additionalRestoreOptionsBuilder: args.additionalRestoreOptionsBuilder,
        onRestoreFromFile: args.onRestoreFromFile,
        successActionsBuilder: args.successActionsBuilder,
        initialScreen: args.initialScreen,
        homeRoute: args.homeRoute,
      );
    },
  );
}

class SailCreateWalletRouteArgs {
  const SailCreateWalletRouteArgs({
    this.key,
    this.appName = 'Drivechain',
    this.onWalletCreated,
    this.onBack,
    this.showFileRestore = false,
    this.additionalRestoreOptionsBuilder,
    this.onRestoreFromFile,
    this.successActionsBuilder,
    this.initialScreen = _i12.WelcomeScreen.initial,
    required this.homeRoute,
  });

  final _i28.Key? key;

  final String appName;

  final _i28.VoidCallback? onWalletCreated;

  final _i28.VoidCallback? onBack;

  final bool showFileRestore;

  final _i23.Widget Function(_i23.BuildContext)?
  additionalRestoreOptionsBuilder;

  final _i25.Future<void> Function(_i29.File)? onRestoreFromFile;

  final _i23.Widget Function(_i23.BuildContext, _i28.VoidCallback)?
  successActionsBuilder;

  final _i12.WelcomeScreen initialScreen;

  final _i22.PageRouteInfo<Object?> homeRoute;

  @override
  String toString() {
    return 'SailCreateWalletRouteArgs{key: $key, appName: $appName, onWalletCreated: $onWalletCreated, onBack: $onBack, showFileRestore: $showFileRestore, additionalRestoreOptionsBuilder: $additionalRestoreOptionsBuilder, onRestoreFromFile: $onRestoreFromFile, successActionsBuilder: $successActionsBuilder, initialScreen: $initialScreen, homeRoute: $homeRoute}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SailCreateWalletRouteArgs) return false;
    return key == other.key &&
        appName == other.appName &&
        onWalletCreated == other.onWalletCreated &&
        onBack == other.onBack &&
        showFileRestore == other.showFileRestore &&
        initialScreen == other.initialScreen &&
        homeRoute == other.homeRoute;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      appName.hashCode ^
      onWalletCreated.hashCode ^
      onBack.hashCode ^
      showFileRestore.hashCode ^
      initialScreen.hashCode ^
      homeRoute.hashCode;
}

/// generated route for
/// [_i13.SailTestPage]
class SailTestRoute extends _i22.PageRouteInfo<SailTestRouteArgs> {
  SailTestRoute({
    _i23.Key? key,
    required _i23.Widget child,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         SailTestRoute.name,
         args: SailTestRouteArgs(key: key, child: child),
         initialChildren: children,
       );

  static const String name = 'SailTestRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailTestRouteArgs>();
      return _i13.SailTestPage(key: args.key, child: args.child);
    },
  );
}

class SailTestRouteArgs {
  const SailTestRouteArgs({this.key, required this.child});

  final _i23.Key? key;

  final _i23.Widget child;

  @override
  String toString() {
    return 'SailTestRouteArgs{key: $key, child: $child}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SailTestRouteArgs) return false;
    return key == other.key && child == other.child;
  }

  @override
  int get hashCode => key.hashCode ^ child.hashCode;
}

/// generated route for
/// [_i14.ShutDownPage]
class ShutDownRoute extends _i22.PageRouteInfo<ShutDownRouteArgs> {
  ShutDownRoute({
    _i23.Key? key,
    required List<_i24.Binary> binaries,
    required _i25.Stream<_i24.ShutdownProgress> shutdownStream,
    required _i23.VoidCallback onComplete,
    _i23.VoidCallback? onForceKillRequested,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         ShutDownRoute.name,
         args: ShutDownRouteArgs(
           key: key,
           binaries: binaries,
           shutdownStream: shutdownStream,
           onComplete: onComplete,
           onForceKillRequested: onForceKillRequested,
         ),
         initialChildren: children,
       );

  static const String name = 'ShutDownRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShutDownRouteArgs>();
      return _i14.ShutDownPage(
        key: args.key,
        binaries: args.binaries,
        shutdownStream: args.shutdownStream,
        onComplete: args.onComplete,
        onForceKillRequested: args.onForceKillRequested,
      );
    },
  );
}

class ShutDownRouteArgs {
  const ShutDownRouteArgs({
    this.key,
    required this.binaries,
    required this.shutdownStream,
    required this.onComplete,
    this.onForceKillRequested,
  });

  final _i23.Key? key;

  final List<_i24.Binary> binaries;

  final _i25.Stream<_i24.ShutdownProgress> shutdownStream;

  final _i23.VoidCallback onComplete;

  final _i23.VoidCallback? onForceKillRequested;

  @override
  String toString() {
    return 'ShutDownRouteArgs{key: $key, binaries: $binaries, shutdownStream: $shutdownStream, onComplete: $onComplete, onForceKillRequested: $onForceKillRequested}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShutDownRouteArgs) return false;
    return key == other.key &&
        const _i27.ListEquality<_i24.Binary>().equals(
          binaries,
          other.binaries,
        ) &&
        shutdownStream == other.shutdownStream &&
        onComplete == other.onComplete &&
        onForceKillRequested == other.onForceKillRequested;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i27.ListEquality<_i24.Binary>().hash(binaries) ^
      shutdownStream.hashCode ^
      onComplete.hashCode ^
      onForceKillRequested.hashCode;
}

/// generated route for
/// [_i15.SidechainConfEditorPage]
class SidechainConfEditorRoute extends _i22.PageRouteInfo<void> {
  const SidechainConfEditorRoute({List<_i22.PageRouteInfo>? children})
    : super(SidechainConfEditorRoute.name, initialChildren: children);

  static const String name = 'SidechainConfEditorRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i15.SidechainConfEditorPage();
    },
  );
}

/// generated route for
/// [_i16.SidechainConfigureHomepagePage]
class SidechainConfigureHomepageRoute extends _i22.PageRouteInfo<void> {
  const SidechainConfigureHomepageRoute({List<_i22.PageRouteInfo>? children})
    : super(SidechainConfigureHomepageRoute.name, initialChildren: children);

  static const String name = 'SidechainConfigureHomepageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i16.SidechainConfigureHomepagePage();
    },
  );
}

/// generated route for
/// [_i17.SidechainHomePage]
class SidechainHomeRoute extends _i22.PageRouteInfo<void> {
  const SidechainHomeRoute({List<_i22.PageRouteInfo>? children})
    : super(SidechainHomeRoute.name, initialChildren: children);

  static const String name = 'SidechainHomeRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i17.SidechainHomePage();
    },
  );
}

/// generated route for
/// [_i18.SidechainHomepagePage]
class SidechainHomepageRoute extends _i22.PageRouteInfo<void> {
  const SidechainHomepageRoute({List<_i22.PageRouteInfo>? children})
    : super(SidechainHomepageRoute.name, initialChildren: children);

  static const String name = 'SidechainHomepageRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i18.SidechainHomepagePage();
    },
  );
}

/// generated route for
/// [_i19.SidechainOverviewTabPage]
class SidechainOverviewTabRoute extends _i22.PageRouteInfo<void> {
  const SidechainOverviewTabRoute({List<_i22.PageRouteInfo>? children})
    : super(SidechainOverviewTabRoute.name, initialChildren: children);

  static const String name = 'SidechainOverviewTabRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i19.SidechainOverviewTabPage();
    },
  );
}

/// generated route for
/// [_i20.SidechainSettingsPage]
class SidechainSettingsRoute extends _i22.PageRouteInfo<void> {
  const SidechainSettingsRoute({List<_i22.PageRouteInfo>? children})
    : super(SidechainSettingsRoute.name, initialChildren: children);

  static const String name = 'SidechainSettingsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i20.SidechainSettingsPage();
    },
  );
}

/// generated route for
/// [_i21.UnlockWalletPage]
class UnlockWalletRoute extends _i22.PageRouteInfo<void> {
  const UnlockWalletRoute({List<_i22.PageRouteInfo>? children})
    : super(UnlockWalletRoute.name, initialChildren: children);

  static const String name = 'UnlockWalletRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i21.UnlockWalletPage();
    },
  );
}
