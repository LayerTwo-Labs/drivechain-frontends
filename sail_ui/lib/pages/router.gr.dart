// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i18;

import 'package:auto_route/auto_route.dart' as _i15;
import 'package:collection/collection.dart' as _i20;
import 'package:flutter/material.dart' as _i16;
import 'package:logger/logger.dart' as _i19;
import 'package:sail_ui/pages/bitcoin_conf_editor_page.dart' as _i2;
import 'package:sail_ui/pages/coming_soon_page.dart' as _i3;
import 'package:sail_ui/pages/console_tab_page.dart' as _i4;
import 'package:sail_ui/pages/create_wallet_page.dart' as _i10;
import 'package:sail_ui/pages/datadir_setup_page.dart' as _i5;
import 'package:sail_ui/pages/enforcer_conf_editor_page.dart' as _i6;
import 'package:sail_ui/pages/log_page.dart' as _i7;
import 'package:sail_ui/pages/network_switch_page.dart' as _i8;
import 'package:sail_ui/pages/sail_test_page.dart' as _i11;
import 'package:sail_ui/pages/shutdown_page.dart' as _i12;
import 'package:sail_ui/pages/sidechains/parent_chain_page.dart' as _i9;
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart' as _i13;
import 'package:sail_ui/pages/unlock_wallet_page.dart' as _i14;
import 'package:sail_ui/sail_ui.dart' as _i17;
import 'package:sail_ui/widgets/wallet_backup_restore.dart' as _i1;

/// generated route for
/// [_i1.BackupWalletPage]
class BackupWalletRoute extends _i15.PageRouteInfo<BackupWalletRouteArgs> {
  BackupWalletRoute({
    _i16.Key? key,
    String appName = 'wallet',
    List<_i15.PageRouteInfo>? children,
  }) : super(
         BackupWalletRoute.name,
         args: BackupWalletRouteArgs(key: key, appName: appName),
         rawPathParams: {'appName': appName},
         initialChildren: children,
       );

  static const String name = 'BackupWalletRoute';

  static _i15.PageInfo page = _i15.PageInfo(
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

  final _i16.Key? key;

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
class BitcoinConfEditorRoute extends _i15.PageRouteInfo<void> {
  const BitcoinConfEditorRoute({List<_i15.PageRouteInfo>? children})
    : super(BitcoinConfEditorRoute.name, initialChildren: children);

  static const String name = 'BitcoinConfEditorRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.BitcoinConfEditorPage();
    },
  );
}

/// generated route for
/// [_i3.ComingSoonPage]
class ComingSoonRoute extends _i15.PageRouteInfo<void> {
  const ComingSoonRoute({List<_i15.PageRouteInfo>? children})
    : super(ComingSoonRoute.name, initialChildren: children);

  static const String name = 'ComingSoonRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i3.ComingSoonPage();
    },
  );
}

/// generated route for
/// [_i4.ConsoleTabPage]
class ConsoleTabRoute extends _i15.PageRouteInfo<void> {
  const ConsoleTabRoute({List<_i15.PageRouteInfo>? children})
    : super(ConsoleTabRoute.name, initialChildren: children);

  static const String name = 'ConsoleTabRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i4.ConsoleTabPage();
    },
  );
}

/// generated route for
/// [_i5.DataDirSetupPage]
class DataDirSetupRoute extends _i15.PageRouteInfo<void> {
  const DataDirSetupRoute({List<_i15.PageRouteInfo>? children})
    : super(DataDirSetupRoute.name, initialChildren: children);

  static const String name = 'DataDirSetupRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i5.DataDirSetupPage();
    },
  );
}

/// generated route for
/// [_i6.EnforcerConfEditorPage]
class EnforcerConfEditorRoute extends _i15.PageRouteInfo<void> {
  const EnforcerConfEditorRoute({List<_i15.PageRouteInfo>? children})
    : super(EnforcerConfEditorRoute.name, initialChildren: children);

  static const String name = 'EnforcerConfEditorRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i6.EnforcerConfEditorPage();
    },
  );
}

/// generated route for
/// [_i7.LogPage]
class LogRoute extends _i15.PageRouteInfo<LogRouteArgs> {
  LogRoute({
    _i16.Key? key,
    required String logPath,
    required String title,
    _i17.BinaryType? binaryType,
    List<_i15.PageRouteInfo>? children,
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

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LogRouteArgs>();
      return _i7.LogPage(
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

  final _i16.Key? key;

  final String logPath;

  final String title;

  final _i17.BinaryType? binaryType;

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
/// [_i8.NetworkSwitchPage]
class NetworkSwitchRoute extends _i15.PageRouteInfo<void> {
  const NetworkSwitchRoute({List<_i15.PageRouteInfo>? children})
    : super(NetworkSwitchRoute.name, initialChildren: children);

  static const String name = 'NetworkSwitchRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i8.NetworkSwitchPage();
    },
  );
}

/// generated route for
/// [_i9.ParentChainPage]
class ParentChainRoute extends _i15.PageRouteInfo<void> {
  const ParentChainRoute({List<_i15.PageRouteInfo>? children})
    : super(ParentChainRoute.name, initialChildren: children);

  static const String name = 'ParentChainRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i9.ParentChainPage();
    },
  );
}

/// generated route for
/// [_i1.RestoreWalletPage]
class RestoreWalletRoute extends _i15.PageRouteInfo<RestoreWalletRouteArgs> {
  RestoreWalletRoute({
    _i16.Key? key,
    required _i18.Future<void> Function(_i19.Logger) bootBinaries,
    required List<_i17.Binary> binariesToStop,
    List<_i15.PageRouteInfo>? children,
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

  static _i15.PageInfo page = _i15.PageInfo(
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

  final _i16.Key? key;

  final _i18.Future<void> Function(_i19.Logger) bootBinaries;

  final List<_i17.Binary> binariesToStop;

  @override
  String toString() {
    return 'RestoreWalletRouteArgs{key: $key, bootBinaries: $bootBinaries, binariesToStop: $binariesToStop}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RestoreWalletRouteArgs) return false;
    return key == other.key &&
        const _i20.ListEquality<_i17.Binary>().equals(
          binariesToStop,
          other.binariesToStop,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i20.ListEquality<_i17.Binary>().hash(binariesToStop);
}

/// generated route for
/// [_i10.SailCreateWalletPage]
class SailCreateWalletRoute
    extends _i15.PageRouteInfo<SailCreateWalletRouteArgs> {
  SailCreateWalletRoute({
    _i16.Key? key,
    String appName = 'Drivechain',
    _i16.VoidCallback? onWalletCreated,
    _i16.VoidCallback? onBack,
    bool showFileRestore = false,
    _i16.Widget Function(_i16.BuildContext)? additionalRestoreOptionsBuilder,
    _i16.Widget Function(_i16.BuildContext, _i16.VoidCallback)?
    successActionsBuilder,
    _i10.WelcomeScreen initialScreen = _i10.WelcomeScreen.initial,
    required _i15.PageRouteInfo<Object?> homeRoute,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         SailCreateWalletRoute.name,
         args: SailCreateWalletRouteArgs(
           key: key,
           appName: appName,
           onWalletCreated: onWalletCreated,
           onBack: onBack,
           showFileRestore: showFileRestore,
           additionalRestoreOptionsBuilder: additionalRestoreOptionsBuilder,
           successActionsBuilder: successActionsBuilder,
           initialScreen: initialScreen,
           homeRoute: homeRoute,
         ),
         initialChildren: children,
       );

  static const String name = 'SailCreateWalletRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailCreateWalletRouteArgs>();
      return _i10.SailCreateWalletPage(
        key: args.key,
        appName: args.appName,
        onWalletCreated: args.onWalletCreated,
        onBack: args.onBack,
        showFileRestore: args.showFileRestore,
        additionalRestoreOptionsBuilder: args.additionalRestoreOptionsBuilder,
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
    this.successActionsBuilder,
    this.initialScreen = _i10.WelcomeScreen.initial,
    required this.homeRoute,
  });

  final _i16.Key? key;

  final String appName;

  final _i16.VoidCallback? onWalletCreated;

  final _i16.VoidCallback? onBack;

  final bool showFileRestore;

  final _i16.Widget Function(_i16.BuildContext)?
  additionalRestoreOptionsBuilder;

  final _i16.Widget Function(_i16.BuildContext, _i16.VoidCallback)?
  successActionsBuilder;

  final _i10.WelcomeScreen initialScreen;

  final _i15.PageRouteInfo<Object?> homeRoute;

  @override
  String toString() {
    return 'SailCreateWalletRouteArgs{key: $key, appName: $appName, onWalletCreated: $onWalletCreated, onBack: $onBack, showFileRestore: $showFileRestore, additionalRestoreOptionsBuilder: $additionalRestoreOptionsBuilder, successActionsBuilder: $successActionsBuilder, initialScreen: $initialScreen, homeRoute: $homeRoute}';
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
/// [_i11.SailTestPage]
class SailTestRoute extends _i15.PageRouteInfo<SailTestRouteArgs> {
  SailTestRoute({
    _i16.Key? key,
    required _i16.Widget child,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         SailTestRoute.name,
         args: SailTestRouteArgs(key: key, child: child),
         initialChildren: children,
       );

  static const String name = 'SailTestRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailTestRouteArgs>();
      return _i11.SailTestPage(key: args.key, child: args.child);
    },
  );
}

class SailTestRouteArgs {
  const SailTestRouteArgs({this.key, required this.child});

  final _i16.Key? key;

  final _i16.Widget child;

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
/// [_i12.ShutDownPage]
class ShutDownRoute extends _i15.PageRouteInfo<ShutDownRouteArgs> {
  ShutDownRoute({
    _i16.Key? key,
    required List<_i17.Binary> binaries,
    required _i18.Stream<_i17.ShutdownProgress> shutdownStream,
    required _i16.VoidCallback onComplete,
    _i16.VoidCallback? onForceKillRequested,
    List<_i15.PageRouteInfo>? children,
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

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShutDownRouteArgs>();
      return _i12.ShutDownPage(
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

  final _i16.Key? key;

  final List<_i17.Binary> binaries;

  final _i18.Stream<_i17.ShutdownProgress> shutdownStream;

  final _i16.VoidCallback onComplete;

  final _i16.VoidCallback? onForceKillRequested;

  @override
  String toString() {
    return 'ShutDownRouteArgs{key: $key, binaries: $binaries, shutdownStream: $shutdownStream, onComplete: $onComplete, onForceKillRequested: $onForceKillRequested}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShutDownRouteArgs) return false;
    return key == other.key &&
        const _i20.ListEquality<_i17.Binary>().equals(
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
      const _i20.ListEquality<_i17.Binary>().hash(binaries) ^
      shutdownStream.hashCode ^
      onComplete.hashCode ^
      onForceKillRequested.hashCode;
}

/// generated route for
/// [_i13.SidechainOverviewTabPage]
class SidechainOverviewTabRoute extends _i15.PageRouteInfo<void> {
  const SidechainOverviewTabRoute({List<_i15.PageRouteInfo>? children})
    : super(SidechainOverviewTabRoute.name, initialChildren: children);

  static const String name = 'SidechainOverviewTabRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i13.SidechainOverviewTabPage();
    },
  );
}

/// generated route for
/// [_i14.UnlockWalletPage]
class UnlockWalletRoute extends _i15.PageRouteInfo<void> {
  const UnlockWalletRoute({List<_i15.PageRouteInfo>? children})
    : super(UnlockWalletRoute.name, initialChildren: children);

  static const String name = 'UnlockWalletRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i14.UnlockWalletPage();
    },
  );
}
