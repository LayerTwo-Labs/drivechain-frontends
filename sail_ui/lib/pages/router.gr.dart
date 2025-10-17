// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;

import 'package:auto_route/auto_route.dart' as _i6;
import 'package:collection/collection.dart' as _i10;
import 'package:flutter/material.dart' as _i7;
import 'package:sail_ui/pages/log_page.dart' as _i1;
import 'package:sail_ui/pages/shutdown_page.dart' as _i3;
import 'package:sail_ui/pages/sidechains/parent_chain_page.dart' as _i2;
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart' as _i4;
import 'package:sail_ui/pages/unlock_wallet_page.dart' as _i5;
import 'package:sail_ui/sail_ui.dart' as _i8;

/// generated route for
/// [_i1.LogPage]
class LogRoute extends _i6.PageRouteInfo<LogRouteArgs> {
  LogRoute({
    _i7.Key? key,
    required String logPath,
    required String title,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         LogRoute.name,
         args: LogRouteArgs(key: key, logPath: logPath, title: title),
         initialChildren: children,
       );

  static const String name = 'LogRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LogRouteArgs>();
      return _i1.LogPage(
        key: args.key,
        logPath: args.logPath,
        title: args.title,
      );
    },
  );
}

class LogRouteArgs {
  const LogRouteArgs({this.key, required this.logPath, required this.title});

  final _i7.Key? key;

  final String logPath;

  final String title;

  @override
  String toString() {
    return 'LogRouteArgs{key: $key, logPath: $logPath, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LogRouteArgs) return false;
    return key == other.key && logPath == other.logPath && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ logPath.hashCode ^ title.hashCode;
}

/// generated route for
/// [_i2.ParentChainPage]
class ParentChainRoute extends _i6.PageRouteInfo<void> {
  const ParentChainRoute({List<_i6.PageRouteInfo>? children})
    : super(ParentChainRoute.name, initialChildren: children);

  static const String name = 'ParentChainRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.ParentChainPage();
    },
  );
}

/// generated route for
/// [_i3.ShutDownPage]
class ShutDownRoute extends _i6.PageRouteInfo<ShutDownRouteArgs> {
  ShutDownRoute({
    _i7.Key? key,
    required List<_i8.Binary> binaries,
    required _i9.Stream<_i8.ShutdownProgress> shutdownStream,
    required _i7.VoidCallback onComplete,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         ShutDownRoute.name,
         args: ShutDownRouteArgs(
           key: key,
           binaries: binaries,
           shutdownStream: shutdownStream,
           onComplete: onComplete,
         ),
         initialChildren: children,
       );

  static const String name = 'ShutDownRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShutDownRouteArgs>();
      return _i3.ShutDownPage(
        key: args.key,
        binaries: args.binaries,
        shutdownStream: args.shutdownStream,
        onComplete: args.onComplete,
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
  });

  final _i7.Key? key;

  final List<_i8.Binary> binaries;

  final _i9.Stream<_i8.ShutdownProgress> shutdownStream;

  final _i7.VoidCallback onComplete;

  @override
  String toString() {
    return 'ShutDownRouteArgs{key: $key, binaries: $binaries, shutdownStream: $shutdownStream, onComplete: $onComplete}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShutDownRouteArgs) return false;
    return key == other.key &&
        const _i10.ListEquality().equals(binaries, other.binaries) &&
        shutdownStream == other.shutdownStream &&
        onComplete == other.onComplete;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i10.ListEquality().hash(binaries) ^
      shutdownStream.hashCode ^
      onComplete.hashCode;
}

/// generated route for
/// [_i4.SidechainOverviewTabPage]
class SidechainOverviewTabRoute extends _i6.PageRouteInfo<void> {
  const SidechainOverviewTabRoute({List<_i6.PageRouteInfo>? children})
    : super(SidechainOverviewTabRoute.name, initialChildren: children);

  static const String name = 'SidechainOverviewTabRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.SidechainOverviewTabPage();
    },
  );
}

/// generated route for
/// [_i5.UnlockWalletPage]
class UnlockWalletRoute extends _i6.PageRouteInfo<void> {
  const UnlockWalletRoute({List<_i6.PageRouteInfo>? children})
    : super(UnlockWalletRoute.name, initialChildren: children);

  static const String name = 'UnlockWalletRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.UnlockWalletPage();
    },
  );
}
