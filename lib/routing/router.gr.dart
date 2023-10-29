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
    WithdrawalBundleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WithdrawalBundlePage(),
      );
    },
    WithdrawalRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WithdrawalPage(),
      );
    },
  };
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
/// [WithdrawalBundlePage]
class WithdrawalBundleRoute extends PageRouteInfo<void> {
  const WithdrawalBundleRoute({List<PageRouteInfo>? children})
      : super(
          WithdrawalBundleRoute.name,
          initialChildren: children,
        );

  static const String name = 'WithdrawalBundleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [WithdrawalPage]
class WithdrawalRoute extends PageRouteInfo<void> {
  const WithdrawalRoute({List<PageRouteInfo>? children})
      : super(
          WithdrawalRoute.name,
          initialChildren: children,
        );

  static const String name = 'WithdrawalRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
