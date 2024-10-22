// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i2;
import 'package:flutter/material.dart' as _i3;
import 'package:sail_ui/pages/log_page.dart' as _i1;

/// generated route for
/// [_i1.SailLogPage]
class SailLogRoute extends _i2.PageRouteInfo<SailLogRouteArgs> {
  SailLogRoute({
    _i3.Key? key,
    required String name,
    required String logPath,
    List<_i2.PageRouteInfo>? children,
  }) : super(
          SailLogRoute.name,
          args: SailLogRouteArgs(
            key: key,
            name: name,
            logPath: logPath,
          ),
          initialChildren: children,
        );

  static const String name = 'SailLogRoute';

  static _i2.PageInfo page = _i2.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailLogRouteArgs>();
      return _i1.SailLogPage(
        key: args.key,
        name: args.name,
        logPath: args.logPath,
      );
    },
  );
}

class SailLogRouteArgs {
  const SailLogRouteArgs({
    this.key,
    required this.name,
    required this.logPath,
  });

  final _i3.Key? key;

  final String name;

  final String logPath;

  @override
  String toString() {
    return 'SailLogRouteArgs{key: $key, name: $name, logPath: $logPath}';
  }
}
