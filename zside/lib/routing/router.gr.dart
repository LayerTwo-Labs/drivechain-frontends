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

/// generated route for
/// [ZCashBillPage]
class ZCashBillRoute extends PageRouteInfo<void> {
  const ZCashBillRoute({List<PageRouteInfo>? children}) : super(ZCashBillRoute.name, initialChildren: children);

  static const String name = 'ZCashBillRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZCashBillPage();
    },
  );
}

/// generated route for
/// [ZCashMeltCastTabPage]
class ZCashMeltCastTabRoute extends PageRouteInfo<void> {
  const ZCashMeltCastTabRoute({List<PageRouteInfo>? children})
      : super(ZCashMeltCastTabRoute.name, initialChildren: children);

  static const String name = 'ZCashMeltCastTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZCashMeltCastTabPage();
    },
  );
}

/// generated route for
/// [ZCashOperationStatusesTabPage]
class ZCashOperationStatusesTabRoute extends PageRouteInfo<void> {
  const ZCashOperationStatusesTabRoute({List<PageRouteInfo>? children})
      : super(ZCashOperationStatusesTabRoute.name, initialChildren: children);

  static const String name = 'ZCashOperationStatusesTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZCashOperationStatusesTabPage();
    },
  );
}

/// generated route for
/// [ZCashRPCTabPage]
class ZCashRPCTabRoute extends PageRouteInfo<void> {
  const ZCashRPCTabRoute({List<PageRouteInfo>? children}) : super(ZCashRPCTabRoute.name, initialChildren: children);

  static const String name = 'ZCashRPCTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZCashRPCTabPage();
    },
  );
}

/// generated route for
/// [ZCashShieldDeshieldTabPage]
class ZCashShieldDeshieldTabRoute extends PageRouteInfo<void> {
  const ZCashShieldDeshieldTabRoute({List<PageRouteInfo>? children})
      : super(ZCashShieldDeshieldTabRoute.name, initialChildren: children);

  static const String name = 'ZCashShieldDeshieldTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZCashShieldDeshieldTabPage();
    },
  );
}

/// generated route for
/// [ZCashTransferTabPage]
class ZCashTransferTabRoute extends PageRouteInfo<void> {
  const ZCashTransferTabRoute({List<PageRouteInfo>? children})
      : super(ZCashTransferTabRoute.name, initialChildren: children);

  static const String name = 'ZCashTransferTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZCashTransferTabPage();
    },
  );
}
