// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [DepositWithdrawTabPage]
class DepositWithdrawTabRoute extends PageRouteInfo<void> {
  const DepositWithdrawTabRoute({List<PageRouteInfo>? children})
      : super(DepositWithdrawTabRoute.name, initialChildren: children);

  static const String name = 'DepositWithdrawTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DepositWithdrawTabPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children}) : super(HomeRoute.name, initialChildren: children);

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
}

/// generated route for
/// [SettingsTabPage]
class SettingsTabRoute extends PageRouteInfo<void> {
  const SettingsTabRoute({List<PageRouteInfo>? children}) : super(SettingsTabRoute.name, initialChildren: children);

  static const String name = 'SettingsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsTabPage();
    },
  );
}

/// generated route for
/// [SidechainOverviewTabPage]
class SidechainOverviewTabRoute extends PageRouteInfo<void> {
  const SidechainOverviewTabRoute({List<PageRouteInfo>? children})
      : super(SidechainOverviewTabRoute.name, initialChildren: children);

  static const String name = 'SidechainOverviewTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SidechainOverviewTabPage();
    },
  );
}
