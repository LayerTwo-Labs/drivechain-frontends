// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/material.dart' as _i4;
import 'package:sail_ui/config/binaries.dart' as _i5;
import 'package:sail_ui/pages/log_page.dart' as _i1;
import 'package:sail_ui/pages/shutdown_page.dart' as _i2;

/// generated route for
/// [_i1.LogPage]
class LogRoute extends _i3.PageRouteInfo<LogRouteArgs> {
  LogRoute({
    _i4.Key? key,
    required String logPath,
    required String title,
    List<_i3.PageRouteInfo>? children,
  }) : super(
          LogRoute.name,
          args: LogRouteArgs(key: key, logPath: logPath, title: title),
          initialChildren: children,
        );

  static const String name = 'LogRoute';

  static _i3.PageInfo page = _i3.PageInfo(
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

  final _i4.Key? key;

  final String logPath;

  final String title;

  @override
  String toString() {
    return 'LogRouteArgs{key: $key, logPath: $logPath, title: $title}';
  }
}

/// generated route for
/// [_i2.ShuttingDownPage]
class ShuttingDownRoute extends _i3.PageRouteInfo<ShuttingDownRouteArgs> {
  ShuttingDownRoute({
    _i4.Key? key,
    required List<_i5.Binary> binaries,
    required _i4.VoidCallback onComplete,
    List<_i3.PageRouteInfo>? children,
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

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShuttingDownRouteArgs>();
      return _i2.ShuttingDownPage(
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

  final _i4.Key? key;

  final List<_i5.Binary> binaries;

  final _i4.VoidCallback onComplete;

  @override
  String toString() {
    return 'ShuttingDownRouteArgs{key: $key, binaries: $binaries, onComplete: $onComplete}';
  }
}
