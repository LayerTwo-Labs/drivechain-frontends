// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [ConsoleTabPage]
class ConsoleTabRoute extends PageRouteInfo<void> {
  const ConsoleTabRoute({List<PageRouteInfo>? children})
    : super(ConsoleTabRoute.name, initialChildren: children);

  static const String name = 'ConsoleTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConsoleTabPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [SailTestPage]
class SailTestRoute extends PageRouteInfo<SailTestRouteArgs> {
  SailTestRoute({
    Key? key,
    required Widget child,
    List<PageRouteInfo>? children,
  }) : super(
         SailTestRoute.name,
         args: SailTestRouteArgs(key: key, child: child),
         initialChildren: children,
       );

  static const String name = 'SailTestRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailTestRouteArgs>();
      return SailTestPage(key: args.key, child: args.child);
    },
  );
}

class SailTestRouteArgs {
  const SailTestRouteArgs({this.key, required this.child});

  final Key? key;

  final Widget child;

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
/// [SettingsTabPage]
class SettingsTabRoute extends PageRouteInfo<void> {
  const SettingsTabRoute({List<PageRouteInfo>? children})
    : super(SettingsTabRoute.name, initialChildren: children);

  static const String name = 'SettingsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsTabPage();
    },
  );
}
