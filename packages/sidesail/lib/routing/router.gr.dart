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
    EthereumRPCTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EthereumRPCTabPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    NodeSettingsTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NodeSettingsTabPage(),
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
    SidechainExplorerTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SidechainExplorerTabPage(),
      );
    },
    TestchainRPCTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TestchainRPCTabPage(),
      );
    },
    TransferMainchainTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TransferMainchainTabPage(),
      );
    },
    WithdrawalBundleTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WithdrawalBundleTabPage(),
      );
    },
    ZCashCastTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ZCashCastTabPage(),
      );
    },
    ZCashRPCTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ZCashRPCTabPage(),
      );
    },
    ZCashShieldTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ZCashShieldTabPage(),
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
/// [EthereumRPCTabPage]
class EthereumRPCTabRoute extends PageRouteInfo<void> {
  const EthereumRPCTabRoute({List<PageRouteInfo>? children})
      : super(
          EthereumRPCTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'EthereumRPCTabRoute';

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
/// [NodeSettingsTabPage]
class NodeSettingsTabRoute extends PageRouteInfo<void> {
  const NodeSettingsTabRoute({List<PageRouteInfo>? children})
      : super(
          NodeSettingsTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'NodeSettingsTabRoute';

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
/// [SidechainExplorerTabPage]
class SidechainExplorerTabRoute extends PageRouteInfo<void> {
  const SidechainExplorerTabRoute({List<PageRouteInfo>? children})
      : super(
          SidechainExplorerTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'SidechainExplorerTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TestchainRPCTabPage]
class TestchainRPCTabRoute extends PageRouteInfo<void> {
  const TestchainRPCTabRoute({List<PageRouteInfo>? children})
      : super(
          TestchainRPCTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestchainRPCTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TransferMainchainTabPage]
class TransferMainchainTabRoute extends PageRouteInfo<void> {
  const TransferMainchainTabRoute({List<PageRouteInfo>? children})
      : super(
          TransferMainchainTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'TransferMainchainTabRoute';

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

/// generated route for
/// [ZCashCastTabPage]
class ZCashCastTabRoute extends PageRouteInfo<void> {
  const ZCashCastTabRoute({List<PageRouteInfo>? children})
      : super(
          ZCashCastTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'ZCashCastTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ZCashRPCTabPage]
class ZCashRPCTabRoute extends PageRouteInfo<void> {
  const ZCashRPCTabRoute({List<PageRouteInfo>? children})
      : super(
          ZCashRPCTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'ZCashRPCTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ZCashShieldTabPage]
class ZCashShieldTabRoute extends PageRouteInfo<void> {
  const ZCashShieldTabRoute({List<PageRouteInfo>? children})
      : super(
          ZCashShieldTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'ZCashShieldTabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ZCashWidgetTitle]
class ZCashWidgetTitle extends PageRouteInfo<ZCashWidgetTitleArgs> {
  ZCashWidgetTitle({
    Key? key,
    required void Function() depositNudgeAction,
    List<PageRouteInfo>? children,
  }) : super(
          ZCashWidgetTitle.name,
          args: ZCashWidgetTitleArgs(
            key: key,
            depositNudgeAction: depositNudgeAction,
          ),
          initialChildren: children,
        );

  static const String name = 'ZCashWidgetTitle';

  static const PageInfo<ZCashWidgetTitleArgs> page = PageInfo<ZCashWidgetTitleArgs>(name);
}

class ZCashWidgetTitleArgs {
  const ZCashWidgetTitleArgs({
    this.key,
    required this.depositNudgeAction,
  });

  final Key? key;

  final void Function() depositNudgeAction;

  @override
  String toString() {
    return 'ZCashWidgetTitleArgs{key: $key, depositNudgeAction: $depositNudgeAction}';
  }
}
