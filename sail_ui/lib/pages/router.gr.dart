// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:sail_ui/config/binaries.dart' as _i7;
import 'package:sail_ui/pages/log_page.dart' as _i1;
import 'package:sail_ui/pages/shutdown_page.dart' as _i3;
import 'package:sail_ui/pages/sidechains/parent_chain_page.dart' as _i2;
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart' as _i4;

/// generated route for
/// [_i1.LogPage]
class LogRoute extends _i5.PageRouteInfo<LogRouteArgs> {
  LogRoute({
    _i6.Key? key,
    required String logPath,
    required String title,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          LogRoute.name,
          args: LogRouteArgs(key: key, logPath: logPath, title: title),
          initialChildren: children,
        );

  static const String name = 'LogRoute';

  static _i5.PageInfo page = _i5.PageInfo(
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

  final _i6.Key? key;

  final String logPath;

  final String title;

  @override
  String toString() {
    return 'LogRouteArgs{key: $key, logPath: $logPath, title: $title}';
  }
}

/// generated route for
/// [_i2.ParentChainPage]
class ParentChainRoute extends _i5.PageRouteInfo<void> {
  const ParentChainRoute({List<_i5.PageRouteInfo>? children}) : super(ParentChainRoute.name, initialChildren: children);

  static const String name = 'ParentChainRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.ParentChainPage();
    },
  );
}

/// generated route for
/// [_i3.ShuttingDownPage]
class ShuttingDownRoute extends _i5.PageRouteInfo<ShuttingDownRouteArgs> {
  ShuttingDownRoute({
    _i6.Key? key,
    required List<_i7.Binary> binaries,
    required _i6.VoidCallback onComplete,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          ShuttingDownRoute.name,
          args: ShuttingDownRouteArgs(
            key: key,
            binaries: binaries,
            onComplete: onComplete,
          ),
          initialChildren: children,
        );

  static const String name = 'ShuttingDownRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShuttingDownRouteArgs>();
      return _i3.ShuttingDownPage(
        key: args.key,
        binaries: args.binaries,
        onComplete: args.onComplete,
      );
    },
  );
}

class ShuttingDownRouteArgs {
  const ShuttingDownRouteArgs({
    this.key,
    required this.binaries,
    required this.onComplete,
  });

  final _i6.Key? key;

  final List<_i7.Binary> binaries;

  final _i6.VoidCallback onComplete;

  @override
  String toString() {
    return 'ShuttingDownRouteArgs{key: $key, binaries: $binaries, onComplete: $onComplete}';
  }
}

/// generated route for
/// [_i4.SidechainOverviewTabPage]
class SidechainOverviewTabRoute extends _i5.PageRouteInfo<void> {
  const SidechainOverviewTabRoute({List<_i5.PageRouteInfo>? children})
      : super(SidechainOverviewTabRoute.name, initialChildren: children);

  static const String name = 'SidechainOverviewTabRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.SidechainOverviewTabPage();
    },
  );
}
