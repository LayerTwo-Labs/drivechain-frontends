// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

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

/// generated route for
/// [ZSideBillPage]
class ZSideBillRoute extends PageRouteInfo<void> {
  const ZSideBillRoute({List<PageRouteInfo>? children})
    : super(ZSideBillRoute.name, initialChildren: children);

  static const String name = 'ZSideBillRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZSideBillPage();
    },
  );
}

/// generated route for
/// [ZSideMeltCastTabPage]
class ZSideMeltCastTabRoute extends PageRouteInfo<void> {
  const ZSideMeltCastTabRoute({List<PageRouteInfo>? children})
    : super(ZSideMeltCastTabRoute.name, initialChildren: children);

  static const String name = 'ZSideMeltCastTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZSideMeltCastTabPage();
    },
  );
}

/// generated route for
/// [ZSideRPCTabPage]
class ZSideRPCTabRoute extends PageRouteInfo<void> {
  const ZSideRPCTabRoute({List<PageRouteInfo>? children})
    : super(ZSideRPCTabRoute.name, initialChildren: children);

  static const String name = 'ZSideRPCTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZSideRPCTabPage();
    },
  );
}

/// generated route for
/// [ZSideShieldDeshieldTabPage]
class ZSideShieldDeshieldTabRoute extends PageRouteInfo<void> {
  const ZSideShieldDeshieldTabRoute({List<PageRouteInfo>? children})
    : super(ZSideShieldDeshieldTabRoute.name, initialChildren: children);

  static const String name = 'ZSideShieldDeshieldTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZSideShieldDeshieldTabPage();
    },
  );
}

/// generated route for
/// [ZSideTransferTabPage]
class ZSideTransferTabRoute extends PageRouteInfo<void> {
  const ZSideTransferTabRoute({List<PageRouteInfo>? children})
    : super(ZSideTransferTabRoute.name, initialChildren: children);

  static const String name = 'ZSideTransferTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZSideTransferTabPage();
    },
  );
}
