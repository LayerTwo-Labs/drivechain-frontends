// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [BitcoinConfEditorPage]
class BitcoinConfEditorRoute extends PageRouteInfo<void> {
  const BitcoinConfEditorRoute({List<PageRouteInfo>? children})
    : super(BitcoinConfEditorRoute.name, initialChildren: children);

  static const String name = 'BitcoinConfEditorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BitcoinConfEditorPage();
    },
  );
}

/// generated route for
/// [CashCheckPage]
class CashCheckRoute extends PageRouteInfo<void> {
  const CashCheckRoute({List<PageRouteInfo>? children})
    : super(CashCheckRoute.name, initialChildren: children);

  static const String name = 'CashCheckRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CashCheckPage();
    },
  );
}

/// generated route for
/// [CashCheckSuccessPage]
class CashCheckSuccessRoute extends PageRouteInfo<CashCheckSuccessRouteArgs> {
  CashCheckSuccessRoute({
    Key? key,
    required String txid,
    int? amountSats,
    List<PageRouteInfo>? children,
  }) : super(
         CashCheckSuccessRoute.name,
         args: CashCheckSuccessRouteArgs(
           key: key,
           txid: txid,
           amountSats: amountSats,
         ),
         rawPathParams: {'txid': txid},
         rawQueryParams: {'amount': amountSats},
         initialChildren: children,
       );

  static const String name = 'CashCheckSuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<CashCheckSuccessRouteArgs>(
        orElse: () => CashCheckSuccessRouteArgs(
          txid: pathParams.getString('txid'),
          amountSats: queryParams.optInt('amount'),
        ),
      );
      return CashCheckSuccessPage(
        key: args.key,
        txid: args.txid,
        amountSats: args.amountSats,
      );
    },
  );
}

class CashCheckSuccessRouteArgs {
  const CashCheckSuccessRouteArgs({
    this.key,
    required this.txid,
    this.amountSats,
  });

  final Key? key;

  final String txid;

  final int? amountSats;

  @override
  String toString() {
    return 'CashCheckSuccessRouteArgs{key: $key, txid: $txid, amountSats: $amountSats}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CashCheckSuccessRouteArgs) return false;
    return key == other.key &&
        txid == other.txid &&
        amountSats == other.amountSats;
  }

  @override
  int get hashCode => key.hashCode ^ txid.hashCode ^ amountSats.hashCode;
}

/// generated route for
/// [CheckDetailPage]
class CheckDetailRoute extends PageRouteInfo<CheckDetailRouteArgs> {
  CheckDetailRoute({
    Key? key,
    required int checkId,
    List<PageRouteInfo>? children,
  }) : super(
         CheckDetailRoute.name,
         args: CheckDetailRouteArgs(key: key, checkId: checkId),
         rawPathParams: {'id': checkId},
         initialChildren: children,
       );

  static const String name = 'CheckDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CheckDetailRouteArgs>(
        orElse: () => CheckDetailRouteArgs(checkId: pathParams.getInt('id')),
      );
      return CheckDetailPage(key: args.key, checkId: args.checkId);
    },
  );
}

class CheckDetailRouteArgs {
  const CheckDetailRouteArgs({this.key, required this.checkId});

  final Key? key;

  final int checkId;

  @override
  String toString() {
    return 'CheckDetailRouteArgs{key: $key, checkId: $checkId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckDetailRouteArgs) return false;
    return key == other.key && checkId == other.checkId;
  }

  @override
  int get hashCode => key.hashCode ^ checkId.hashCode;
}

/// generated route for
/// [ConfigureHomePage]
class ConfigureHomeRoute extends PageRouteInfo<void> {
  const ConfigureHomeRoute({List<PageRouteInfo>? children})
    : super(ConfigureHomeRoute.name, initialChildren: children);

  static const String name = 'ConfigureHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConfigureHomePage();
    },
  );
}

/// generated route for
/// [ConsolePage]
class ConsoleRoute extends PageRouteInfo<void> {
  const ConsoleRoute({List<PageRouteInfo>? children})
    : super(ConsoleRoute.name, initialChildren: children);

  static const String name = 'ConsoleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConsolePage();
    },
  );
}

/// generated route for
/// [CpuMiningPage]
class CpuMiningRoute extends PageRouteInfo<void> {
  const CpuMiningRoute({List<PageRouteInfo>? children})
    : super(CpuMiningRoute.name, initialChildren: children);

  static const String name = 'CpuMiningRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CpuMiningPage();
    },
  );
}

/// generated route for
/// [CreateAnotherWalletPage]
class CreateAnotherWalletRoute extends PageRouteInfo<void> {
  const CreateAnotherWalletRoute({List<PageRouteInfo>? children})
    : super(CreateAnotherWalletRoute.name, initialChildren: children);

  static const String name = 'CreateAnotherWalletRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateAnotherWalletPage();
    },
  );
}

/// generated route for
/// [CreateCheckPage]
class CreateCheckRoute extends PageRouteInfo<void> {
  const CreateCheckRoute({List<PageRouteInfo>? children})
    : super(CreateCheckRoute.name, initialChildren: children);

  static const String name = 'CreateCheckRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateCheckPage();
    },
  );
}

/// generated route for
/// [CreateTimestampPage]
class CreateTimestampRoute extends PageRouteInfo<void> {
  const CreateTimestampRoute({List<PageRouteInfo>? children})
    : super(CreateTimestampRoute.name, initialChildren: children);

  static const String name = 'CreateTimestampRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateTimestampPage();
    },
  );
}

/// generated route for
/// [CreateWalletPage]
class CreateWalletRoute extends PageRouteInfo<CreateWalletRouteArgs> {
  CreateWalletRoute({
    Key? key,
    WelcomeScreen initalScreen = WelcomeScreen.initial,
    List<PageRouteInfo>? children,
  }) : super(
         CreateWalletRoute.name,
         args: CreateWalletRouteArgs(key: key, initalScreen: initalScreen),
         initialChildren: children,
       );

  static const String name = 'CreateWalletRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateWalletRouteArgs>(
        orElse: () => const CreateWalletRouteArgs(),
      );
      return CreateWalletPage(key: args.key, initalScreen: args.initalScreen);
    },
  );
}

class CreateWalletRouteArgs {
  const CreateWalletRouteArgs({
    this.key,
    this.initalScreen = WelcomeScreen.initial,
  });

  final Key? key;

  final WelcomeScreen initalScreen;

  @override
  String toString() {
    return 'CreateWalletRouteArgs{key: $key, initalScreen: $initalScreen}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateWalletRouteArgs) return false;
    return key == other.key && initalScreen == other.initalScreen;
  }

  @override
  int get hashCode => key.hashCode ^ initalScreen.hashCode;
}

/// generated route for
/// [LearnPage]
class LearnRoute extends PageRouteInfo<void> {
  const LearnRoute({List<PageRouteInfo>? children})
    : super(LearnRoute.name, initialChildren: children);

  static const String name = 'LearnRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LearnPage();
    },
  );
}

/// generated route for
/// [M4ExplorerPage]
class M4ExplorerRoute extends PageRouteInfo<void> {
  const M4ExplorerRoute({List<PageRouteInfo>? children})
    : super(M4ExplorerRoute.name, initialChildren: children);

  static const String name = 'M4ExplorerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const M4ExplorerPage();
    },
  );
}

/// generated route for
/// [NetworkStatisticsPage]
class NetworkStatisticsRoute extends PageRouteInfo<void> {
  const NetworkStatisticsRoute({List<PageRouteInfo>? children})
    : super(NetworkStatisticsRoute.name, initialChildren: children);

  static const String name = 'NetworkStatisticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NetworkStatisticsPage();
    },
  );
}

/// generated route for
/// [OverviewPage]
class OverviewRoute extends PageRouteInfo<void> {
  const OverviewRoute({List<PageRouteInfo>? children})
    : super(OverviewRoute.name, initialChildren: children);

  static const String name = 'OverviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OverviewPage();
    },
  );
}

/// generated route for
/// [RemoveEncryptionPage]
class RemoveEncryptionRoute extends PageRouteInfo<void> {
  const RemoveEncryptionRoute({List<PageRouteInfo>? children})
    : super(RemoveEncryptionRoute.name, initialChildren: children);

  static const String name = 'RemoveEncryptionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RemoveEncryptionPage();
    },
  );
}

/// generated route for
/// [RootPage]
class RootRoute extends PageRouteInfo<void> {
  const RootRoute({List<PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RootPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [SidechainActivationManagementPage]
class SidechainActivationManagementRoute extends PageRouteInfo<void> {
  const SidechainActivationManagementRoute({List<PageRouteInfo>? children})
    : super(SidechainActivationManagementRoute.name, initialChildren: children);

  static const String name = 'SidechainActivationManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SidechainActivationManagementPage();
    },
  );
}

/// generated route for
/// [SidechainProposalPage]
class SidechainProposalRoute extends PageRouteInfo<void> {
  const SidechainProposalRoute({List<PageRouteInfo>? children})
    : super(SidechainProposalRoute.name, initialChildren: children);

  static const String name = 'SidechainProposalRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SidechainProposalPage();
    },
  );
}

/// generated route for
/// [SidechainsPage]
class SidechainsRoute extends PageRouteInfo<void> {
  const SidechainsRoute({List<PageRouteInfo>? children})
    : super(SidechainsRoute.name, initialChildren: children);

  static const String name = 'SidechainsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SidechainsPage();
    },
  );
}

/// generated route for
/// [SuccessPage]
class SuccessRoute extends PageRouteInfo<SuccessRouteArgs> {
  SuccessRoute({
    Key? key,
    required String title,
    String? subtitle,
    List<PageRouteInfo>? children,
  }) : super(
         SuccessRoute.name,
         args: SuccessRouteArgs(key: key, title: title, subtitle: subtitle),
         initialChildren: children,
       );

  static const String name = 'SuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SuccessRouteArgs>();
      return SuccessPage(
        key: args.key,
        title: args.title,
        subtitle: args.subtitle,
      );
    },
  );
}

class SuccessRouteArgs {
  const SuccessRouteArgs({this.key, required this.title, this.subtitle});

  final Key? key;

  final String title;

  final String? subtitle;

  @override
  String toString() {
    return 'SuccessRouteArgs{key: $key, title: $title, subtitle: $subtitle}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SuccessRouteArgs) return false;
    return key == other.key &&
        title == other.title &&
        subtitle == other.subtitle;
  }

  @override
  int get hashCode => key.hashCode ^ title.hashCode ^ subtitle.hashCode;
}

/// generated route for
/// [TimestampDetailPage]
class TimestampDetailRoute extends PageRouteInfo<TimestampDetailRouteArgs> {
  TimestampDetailRoute({
    Key? key,
    required int timestampId,
    List<PageRouteInfo>? children,
  }) : super(
         TimestampDetailRoute.name,
         args: TimestampDetailRouteArgs(key: key, timestampId: timestampId),
         initialChildren: children,
       );

  static const String name = 'TimestampDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TimestampDetailRouteArgs>();
      return TimestampDetailPage(key: args.key, timestampId: args.timestampId);
    },
  );
}

class TimestampDetailRouteArgs {
  const TimestampDetailRouteArgs({this.key, required this.timestampId});

  final Key? key;

  final int timestampId;

  @override
  String toString() {
    return 'TimestampDetailRouteArgs{key: $key, timestampId: $timestampId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TimestampDetailRouteArgs) return false;
    return key == other.key && timestampId == other.timestampId;
  }

  @override
  int get hashCode => key.hashCode ^ timestampId.hashCode;
}

/// generated route for
/// [VerifyTimestampPage]
class VerifyTimestampRoute extends PageRouteInfo<void> {
  const VerifyTimestampRoute({List<PageRouteInfo>? children})
    : super(VerifyTimestampRoute.name, initialChildren: children);

  static const String name = 'VerifyTimestampRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VerifyTimestampPage();
    },
  );
}

/// generated route for
/// [WalletPage]
class WalletRoute extends PageRouteInfo<void> {
  const WalletRoute({List<PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WalletPage();
    },
  );
}
