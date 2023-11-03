// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    BlindMergedMiningTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BlindMergedMiningTabPage(),
      );
    },
    DashboardTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardTabPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    SailTestRoute.name: (routeData) {
      final args = routeData.argsAs<SailTestRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SailTestPage(
          key: args.key,
          child: args.child,
        ),
      );
    },
    SettingsTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsTabPage(),
      );
    },
    WithdrawalBundleTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WithdrawalBundleTabPage(),
      );
    },
  };
}

/// generated route for
/// [BlindMergedMiningTabPage]
class BlindMergedMiningTabRoute extends PageRouteInfo<void> {
  const BlindMergedMiningTabRoute({List<PageRouteInfo>? children})
      : super(
          BlindMergedMiningTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'BlindMergedMiningTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DashboardTabPage]
class DashboardTabRoute extends PageRouteInfo<void> {
  const DashboardTabRoute({List<PageRouteInfo>? children})
      : super(
          DashboardTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
          args: SailTestRouteArgs(
            key: key,
            child: child,
          ),
          initialChildren: children,
        );

  static const String name = 'SailTestRoute';

  static const PageInfo<SailTestRouteArgs> page = PageInfo<SailTestRouteArgs>(name);
}

class SailTestRouteArgs {
  const SailTestRouteArgs({
    this.key,
    required this.child,
  });

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
  const SettingsTabRoute({List<PageRouteInfo>? children})
      : super(
          SettingsTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [WithdrawalBundleTabPage]
class WithdrawalBundleTabRoute extends PageRouteInfo<void> {
  const WithdrawalBundleTabRoute({List<PageRouteInfo>? children})
      : super(
          WithdrawalBundleTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'WithdrawalBundleTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
