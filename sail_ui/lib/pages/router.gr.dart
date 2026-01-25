// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i17;

import 'package:auto_route/auto_route.dart' as _i14;
import 'package:collection/collection.dart' as _i19;
import 'package:flutter/material.dart' as _i15;
import 'package:logger/logger.dart' as _i18;
import 'package:sail_ui/pages/bitcoin_conf_editor_page.dart' as _i2;
import 'package:sail_ui/pages/console_tab_page.dart' as _i3;
import 'package:sail_ui/pages/create_wallet_page.dart' as _i9;
import 'package:sail_ui/pages/datadir_setup_page.dart' as _i4;
import 'package:sail_ui/pages/enforcer_conf_editor_page.dart' as _i5;
import 'package:sail_ui/pages/log_page.dart' as _i6;
import 'package:sail_ui/pages/network_switch_page.dart' as _i7;
import 'package:sail_ui/pages/sail_test_page.dart' as _i10;
import 'package:sail_ui/pages/shutdown_page.dart' as _i11;
import 'package:sail_ui/pages/sidechains/parent_chain_page.dart' as _i8;
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart' as _i12;
import 'package:sail_ui/pages/unlock_wallet_page.dart' as _i13;
import 'package:sail_ui/sail_ui.dart' as _i16;
import 'package:sail_ui/widgets/wallet_backup_restore.dart' as _i1;

/// generated route for
/// [_i1.BackupWalletPage]
class BackupWalletRoute extends _i14.PageRouteInfo<BackupWalletRouteArgs> {
  BackupWalletRoute({
    _i15.Key? key,
    String appName = 'wallet',
    List<_i14.PageRouteInfo>? children,
  }) : super(
         BackupWalletRoute.name,
         args: BackupWalletRouteArgs(key: key, appName: appName),
         rawPathParams: {'appName': appName},
         initialChildren: children,
       );

  static const String name = 'BackupWalletRoute';

  static _i14.PageInfo page = _i14.PageInfo(
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

  final _i15.Key? key;

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
class BitcoinConfEditorRoute extends _i14.PageRouteInfo<void> {
  const BitcoinConfEditorRoute({List<_i14.PageRouteInfo>? children})
    : super(BitcoinConfEditorRoute.name, initialChildren: children);

  static const String name = 'BitcoinConfEditorRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i2.BitcoinConfEditorPage();
    },
  );
}

/// generated route for
/// [_i3.ConsoleTabPage]
class ConsoleTabRoute extends _i14.PageRouteInfo<void> {
  const ConsoleTabRoute({List<_i14.PageRouteInfo>? children})
    : super(ConsoleTabRoute.name, initialChildren: children);

  static const String name = 'ConsoleTabRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i3.ConsoleTabPage();
    },
  );
}

/// generated route for
/// [_i4.DataDirSetupPage]
class DataDirSetupRoute extends _i14.PageRouteInfo<void> {
  const DataDirSetupRoute({List<_i14.PageRouteInfo>? children})
    : super(DataDirSetupRoute.name, initialChildren: children);

  static const String name = 'DataDirSetupRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i4.DataDirSetupPage();
    },
  );
}

/// generated route for
/// [_i5.EnforcerConfEditorPage]
class EnforcerConfEditorRoute extends _i14.PageRouteInfo<void> {
  const EnforcerConfEditorRoute({List<_i14.PageRouteInfo>? children})
    : super(EnforcerConfEditorRoute.name, initialChildren: children);

  static const String name = 'EnforcerConfEditorRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i5.EnforcerConfEditorPage();
    },
  );
}

/// generated route for
/// [_i6.LogPage]
class LogRoute extends _i14.PageRouteInfo<LogRouteArgs> {
  LogRoute({
    _i15.Key? key,
    required String logPath,
    required String title,
    _i16.BinaryType? binaryType,
    List<_i14.PageRouteInfo>? children,
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

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LogRouteArgs>();
      return _i6.LogPage(
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

  final _i15.Key? key;

  final String logPath;

  final String title;

  final _i16.BinaryType? binaryType;

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
/// [_i7.NetworkSwitchPage]
class NetworkSwitchRoute extends _i14.PageRouteInfo<void> {
  const NetworkSwitchRoute({List<_i14.PageRouteInfo>? children})
    : super(NetworkSwitchRoute.name, initialChildren: children);

  static const String name = 'NetworkSwitchRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i7.NetworkSwitchPage();
    },
  );
}

/// generated route for
/// [_i8.ParentChainPage]
class ParentChainRoute extends _i14.PageRouteInfo<void> {
  const ParentChainRoute({List<_i14.PageRouteInfo>? children})
    : super(ParentChainRoute.name, initialChildren: children);

  static const String name = 'ParentChainRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i8.ParentChainPage();
    },
  );
}

/// generated route for
/// [_i1.RestoreWalletPage]
class RestoreWalletRoute extends _i14.PageRouteInfo<RestoreWalletRouteArgs> {
  RestoreWalletRoute({
    _i15.Key? key,
    required _i17.Future<void> Function(_i18.Logger) bootBinaries,
    required List<_i16.Binary> binariesToStop,
    List<_i14.PageRouteInfo>? children,
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

  static _i14.PageInfo page = _i14.PageInfo(
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

  final _i15.Key? key;

  final _i17.Future<void> Function(_i18.Logger) bootBinaries;

  final List<_i16.Binary> binariesToStop;

  @override
  String toString() {
    return 'RestoreWalletRouteArgs{key: $key, bootBinaries: $bootBinaries, binariesToStop: $binariesToStop}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RestoreWalletRouteArgs) return false;
    return key == other.key &&
        const _i19.ListEquality<_i16.Binary>().equals(
          binariesToStop,
          other.binariesToStop,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i19.ListEquality<_i16.Binary>().hash(binariesToStop);
}

/// generated route for
/// [_i9.SailCreateWalletPage]
class SailCreateWalletRoute
    extends _i14.PageRouteInfo<SailCreateWalletRouteArgs> {
  SailCreateWalletRoute({
    _i15.Key? key,
    String appName = 'Drivechain',
    _i15.VoidCallback? onWalletCreated,
    _i15.VoidCallback? onBack,
    bool showFileRestore = false,
    _i15.Widget Function(_i15.BuildContext)? additionalRestoreOptionsBuilder,
    _i15.Widget Function(_i15.BuildContext, _i15.VoidCallback)?
    successActionsBuilder,
    _i9.WelcomeScreen initialScreen = _i9.WelcomeScreen.initial,
    required _i14.PageRouteInfo<Object?> homeRoute,
    List<_i14.PageRouteInfo>? children,
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

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailCreateWalletRouteArgs>();
      return _i9.SailCreateWalletPage(
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
    this.initialScreen = _i9.WelcomeScreen.initial,
    required this.homeRoute,
  });

  final _i15.Key? key;

  final String appName;

  final _i15.VoidCallback? onWalletCreated;

  final _i15.VoidCallback? onBack;

  final bool showFileRestore;

  final _i15.Widget Function(_i15.BuildContext)?
  additionalRestoreOptionsBuilder;

  final _i15.Widget Function(_i15.BuildContext, _i15.VoidCallback)?
  successActionsBuilder;

  final _i9.WelcomeScreen initialScreen;

  final _i14.PageRouteInfo<Object?> homeRoute;

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
/// [_i10.SailTestPage]
class SailTestRoute extends _i14.PageRouteInfo<SailTestRouteArgs> {
  SailTestRoute({
    _i15.Key? key,
    required _i15.Widget child,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         SailTestRoute.name,
         args: SailTestRouteArgs(key: key, child: child),
         initialChildren: children,
       );

  static const String name = 'SailTestRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailTestRouteArgs>();
      return _i10.SailTestPage(key: args.key, child: args.child);
    },
  );
}

class SailTestRouteArgs {
  const SailTestRouteArgs({this.key, required this.child});

  final _i15.Key? key;

  final _i15.Widget child;

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
/// [_i11.ShutDownPage]
class ShutDownRoute extends _i14.PageRouteInfo<ShutDownRouteArgs> {
  ShutDownRoute({
    _i15.Key? key,
    required List<_i16.Binary> binaries,
    required _i17.Stream<_i16.ShutdownProgress> shutdownStream,
    required _i15.VoidCallback onComplete,
    _i15.VoidCallback? onForceKillRequested,
    List<_i14.PageRouteInfo>? children,
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

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShutDownRouteArgs>();
      return _i11.ShutDownPage(
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

  final _i15.Key? key;

  final List<_i16.Binary> binaries;

  final _i17.Stream<_i16.ShutdownProgress> shutdownStream;

  final _i15.VoidCallback onComplete;

  final _i15.VoidCallback? onForceKillRequested;

  @override
  String toString() {
    return 'ShutDownRouteArgs{key: $key, binaries: $binaries, shutdownStream: $shutdownStream, onComplete: $onComplete, onForceKillRequested: $onForceKillRequested}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShutDownRouteArgs) return false;
    return key == other.key &&
        const _i19.ListEquality<_i16.Binary>().equals(
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
      const _i19.ListEquality<_i16.Binary>().hash(binaries) ^
      shutdownStream.hashCode ^
      onComplete.hashCode ^
      onForceKillRequested.hashCode;
}

/// generated route for
/// [_i12.SidechainOverviewTabPage]
class SidechainOverviewTabRoute extends _i14.PageRouteInfo<void> {
  const SidechainOverviewTabRoute({List<_i14.PageRouteInfo>? children})
    : super(SidechainOverviewTabRoute.name, initialChildren: children);

  static const String name = 'SidechainOverviewTabRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i12.SidechainOverviewTabPage();
    },
  );
}

/// generated route for
/// [_i13.UnlockWalletPage]
class UnlockWalletRoute extends _i14.PageRouteInfo<void> {
  const UnlockWalletRoute({List<_i14.PageRouteInfo>? children})
    : super(UnlockWalletRoute.name, initialChildren: children);

  static const String name = 'UnlockWalletRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i13.UnlockWalletPage();
    },
  );
}
