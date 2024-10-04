// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [BlindMergedMiningTabPage]
class BlindMergedMiningTabRoute extends PageRouteInfo<void> {
  const BlindMergedMiningTabRoute({List<PageRouteInfo>? children})
      : super(
          BlindMergedMiningTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'BlindMergedMiningTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BlindMergedMiningTabPage();
    },
  );
}

/// generated route for
/// [DepositWithdrawTabPage]
class DepositWithdrawTabRoute extends PageRouteInfo<void> {
  const DepositWithdrawTabRoute({List<PageRouteInfo>? children})
      : super(
          DepositWithdrawTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'DepositWithdrawTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DepositWithdrawTabPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EthereumRPCTabPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LogPage]
class LogRoute extends PageRouteInfo<LogRouteArgs> {
  LogRoute({
    Key? key,
    required String name,
    required String logPath,
    List<PageRouteInfo>? children,
  }) : super(
          LogRoute.name,
          args: LogRouteArgs(
            key: key,
            name: name,
            logPath: logPath,
          ),
          initialChildren: children,
        );

  static const String name = 'LogRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LogRouteArgs>();
      return LogPage(
        key: args.key,
        name: args.name,
        logPath: args.logPath,
      );
    },
  );
}

class LogRouteArgs {
  const LogRouteArgs({
    this.key,
    required this.name,
    required this.logPath,
  });

  final Key? key;

  final String name;

  final String logPath;

  @override
  String toString() {
    return 'LogRouteArgs{key: $key, name: $name, logPath: $logPath}';
  }
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SailTestRouteArgs>();
      return SailTestPage(
        key: args.key,
        child: args.child,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsTabPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SidechainExplorerTabPage();
    },
  );
}

/// generated route for
/// [SidechainSendPage]
class SidechainSendRoute extends PageRouteInfo<void> {
  const SidechainSendRoute({List<PageRouteInfo>? children})
      : super(
          SidechainSendRoute.name,
          initialChildren: children,
        );

  static const String name = 'SidechainSendRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SidechainSendPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TestchainRPCTabPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TransferMainchainTabPage();
    },
  );
}

/// generated route for
/// [WithdrawalExplorerTabPage]
class WithdrawalExplorerTabRoute extends PageRouteInfo<void> {
  const WithdrawalExplorerTabRoute({List<PageRouteInfo>? children})
      : super(
          WithdrawalExplorerTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'WithdrawalExplorerTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WithdrawalExplorerTabPage();
    },
  );
}

/// generated route for
/// [ZCashBillPage]
class ZCashBillRoute extends PageRouteInfo<void> {
  const ZCashBillRoute({List<PageRouteInfo>? children})
      : super(
          ZCashBillRoute.name,
          initialChildren: children,
        );

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
      : super(
          ZCashMeltCastTabRoute.name,
          initialChildren: children,
        );

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
      : super(
          ZCashOperationStatusesTabRoute.name,
          initialChildren: children,
        );

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
  const ZCashRPCTabRoute({List<PageRouteInfo>? children})
      : super(
          ZCashRPCTabRoute.name,
          initialChildren: children,
        );

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
      : super(
          ZCashShieldDeshieldTabRoute.name,
          initialChildren: children,
        );

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
      : super(
          ZCashTransferTabRoute.name,
          initialChildren: children,
        );

  static const String name = 'ZCashTransferTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ZCashTransferTabPage();
    },
  );
}
