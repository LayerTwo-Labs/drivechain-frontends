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
