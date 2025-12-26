// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i10;

import 'package:auto_route/auto_route.dart' as _i7;
import 'package:collection/collection.dart' as _i11;
import 'package:flutter/material.dart' as _i8;
import 'package:sail_ui/pages/create_wallet_page.dart' as _i3;
import 'package:sail_ui/pages/log_page.dart' as _i1;
import 'package:sail_ui/pages/shutdown_page.dart' as _i4;
import 'package:sail_ui/pages/sidechains/parent_chain_page.dart' as _i2;
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart' as _i5;
import 'package:sail_ui/pages/unlock_wallet_page.dart' as _i6;
import 'package:sail_ui/sail_ui.dart' as _i9;

/// generated route for
/// [_i1.LogPage]
class LogRoute extends _i7.PageRouteInfo<LogRouteArgs> {
  LogRoute({
    _i8.Key? key,
    required String logPath,
    required String title,
    _i9.BinaryType? binaryType,
    List<_i7.PageRouteInfo>? children,
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

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LogRouteArgs>();
      return _i1.LogPage(
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

  final _i8.Key? key;

  final String logPath;

  final String title;

  final _i9.BinaryType? binaryType;

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
/// [_i2.ParentChainPage]
class ParentChainRoute extends _i7.PageRouteInfo<void> {
  const ParentChainRoute({List<_i7.PageRouteInfo>? children})
    : super(ParentChainRoute.name, initialChildren: children);

  static const String name = 'ParentChainRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.ParentChainPage();
    },
  );
}

/// generated route for
/// [_i3.SailCreateWalletPage]
class SailCreateWalletRoute
    extends _i7.PageRouteInfo<SailCreateWalletRouteArgs> {
  SailCreateWalletRoute({
    _i8.Key? key,
    String appName = 'Drivechain',
    _i8.VoidCallback? onWalletCreated,
    _i8.VoidCallback? onBack,
    bool showFileRestore = false,
    _i8.Widget Function(_i8.BuildContext)? additionalRestoreOptionsBuilder,
    _i8.Widget Function(_i8.BuildContext, _i8.VoidCallback)?
    successActionsBuilder,
    _i3.WelcomeScreen initialScreen = _i3.WelcomeScreen.initial,
    List<_i7.PageRouteInfo>? children,
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
         ),
         initialChildren: children,
       );

  static const String name = 'SailCreateWalletRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailCreateWalletRouteArgs>(
        orElse: () => const SailCreateWalletRouteArgs(),
      );
      return _i3.SailCreateWalletPage(
        key: args.key,
        appName: args.appName,
        onWalletCreated: args.onWalletCreated,
        onBack: args.onBack,
        showFileRestore: args.showFileRestore,
        additionalRestoreOptionsBuilder: args.additionalRestoreOptionsBuilder,
        successActionsBuilder: args.successActionsBuilder,
        initialScreen: args.initialScreen,
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
    this.initialScreen = _i3.WelcomeScreen.initial,
  });

  final _i8.Key? key;

  final String appName;

  final _i8.VoidCallback? onWalletCreated;

  final _i8.VoidCallback? onBack;

  final bool showFileRestore;

  final _i8.Widget Function(_i8.BuildContext)? additionalRestoreOptionsBuilder;

  final _i8.Widget Function(_i8.BuildContext, _i8.VoidCallback)?
  successActionsBuilder;

  final _i3.WelcomeScreen initialScreen;

  @override
  String toString() {
    return 'SailCreateWalletRouteArgs{key: $key, appName: $appName, onWalletCreated: $onWalletCreated, onBack: $onBack, showFileRestore: $showFileRestore, additionalRestoreOptionsBuilder: $additionalRestoreOptionsBuilder, successActionsBuilder: $successActionsBuilder, initialScreen: $initialScreen}';
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
        initialScreen == other.initialScreen;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      appName.hashCode ^
      onWalletCreated.hashCode ^
      onBack.hashCode ^
      showFileRestore.hashCode ^
      initialScreen.hashCode;
}

/// generated route for
/// [_i4.ShutDownPage]
class ShutDownRoute extends _i7.PageRouteInfo<ShutDownRouteArgs> {
  ShutDownRoute({
    _i8.Key? key,
    required List<_i9.Binary> binaries,
    required _i10.Stream<_i9.ShutdownProgress> shutdownStream,
    required _i8.VoidCallback onComplete,
    _i8.VoidCallback? onForceKillRequested,
    List<_i7.PageRouteInfo>? children,
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

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShutDownRouteArgs>();
      return _i4.ShutDownPage(
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

  final _i8.Key? key;

  final List<_i9.Binary> binaries;

  final _i10.Stream<_i9.ShutdownProgress> shutdownStream;

  final _i8.VoidCallback onComplete;

  final _i8.VoidCallback? onForceKillRequested;

  @override
  String toString() {
    return 'ShutDownRouteArgs{key: $key, binaries: $binaries, shutdownStream: $shutdownStream, onComplete: $onComplete, onForceKillRequested: $onForceKillRequested}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShutDownRouteArgs) return false;
    return key == other.key &&
        const _i11.ListEquality<_i9.Binary>().equals(
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
      const _i11.ListEquality<_i9.Binary>().hash(binaries) ^
      shutdownStream.hashCode ^
      onComplete.hashCode ^
      onForceKillRequested.hashCode;
}

/// generated route for
/// [_i5.SidechainOverviewTabPage]
class SidechainOverviewTabRoute extends _i7.PageRouteInfo<void> {
  const SidechainOverviewTabRoute({List<_i7.PageRouteInfo>? children})
    : super(SidechainOverviewTabRoute.name, initialChildren: children);

  static const String name = 'SidechainOverviewTabRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i5.SidechainOverviewTabPage();
    },
  );
}

/// generated route for
/// [_i6.UnlockWalletPage]
class UnlockWalletRoute extends _i7.PageRouteInfo<void> {
  const UnlockWalletRoute({List<_i7.PageRouteInfo>? children})
    : super(UnlockWalletRoute.name, initialChildren: children);

  static const String name = 'UnlockWalletRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.UnlockWalletPage();
    },
  );
}
