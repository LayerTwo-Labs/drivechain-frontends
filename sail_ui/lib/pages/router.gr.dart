// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:auto_route/auto_route.dart' as _i5;
import 'package:collection/collection.dart' as _i9;
import 'package:flutter/material.dart' as _i6;
import 'package:sail_ui/pages/log_page.dart' as _i1;
import 'package:sail_ui/pages/shutdown_page.dart' as _i3;
import 'package:sail_ui/pages/sidechains/parent_chain_page.dart' as _i2;
import 'package:sail_ui/pages/unlock_wallet_page.dart' as _i4;
import 'package:sail_ui/sail_ui.dart' as _i7;

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
class ParentChainRoute extends _i5.PageRouteInfo<void> {
  const ParentChainRoute({List<_i5.PageRouteInfo>? children})
    : super(ParentChainRoute.name, initialChildren: children);

  static const String name = 'ParentChainRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.ParentChainPage();
    },
  );
}

/// generated route for
/// [_i3.ShutDownPage]
class ShutDownRoute extends _i5.PageRouteInfo<ShutDownRouteArgs> {
  ShutDownRoute({
    _i6.Key? key,
    required List<_i7.Binary> binaries,
    required _i8.Stream<_i7.ShutdownProgress> shutdownStream,
    required _i6.VoidCallback onComplete,
    List<_i5.PageRouteInfo>? children,
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

  static _i5.PageInfo page = _i5.PageInfo(
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

  final _i6.Key? key;

  final List<_i7.Binary> binaries;

  final _i8.Stream<_i7.ShutdownProgress> shutdownStream;

  final _i6.VoidCallback onComplete;

  @override
  String toString() {
    return 'ShutDownRouteArgs{key: $key, binaries: $binaries, shutdownStream: $shutdownStream, onComplete: $onComplete}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShutDownRouteArgs) return false;
    return key == other.key &&
        const _i9.ListEquality<_i7.Binary>().equals(binaries, other.binaries) &&
        shutdownStream == other.shutdownStream &&
        onComplete == other.onComplete;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i9.ListEquality<_i7.Binary>().hash(binaries) ^
      shutdownStream.hashCode ^
      onComplete.hashCode;
}

/// generated route for
/// [_i4.UnlockWalletPage]
class UnlockWalletRoute extends _i5.PageRouteInfo<UnlockWalletRouteArgs> {
  UnlockWalletRoute({
    _i6.Key? key,
    _i8.Future<void> Function(_i7.EncryptionProvider)? onUnlock,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         UnlockWalletRoute.name,
         args: UnlockWalletRouteArgs(key: key, onUnlock: onUnlock),
         initialChildren: children,
       );

  static const String name = 'UnlockWalletRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UnlockWalletRouteArgs>(
        orElse: () => const UnlockWalletRouteArgs(),
      );
      return _i4.UnlockWalletPage(key: args.key, onUnlock: args.onUnlock);
    },
  );
}

class UnlockWalletRouteArgs {
  const UnlockWalletRouteArgs({this.key, this.onUnlock});

  final _i6.Key? key;

  final _i8.Future<void> Function(_i7.EncryptionProvider)? onUnlock;

  @override
  String toString() {
    return 'UnlockWalletRouteArgs{key: $key, onUnlock: $onUnlock}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UnlockWalletRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}
