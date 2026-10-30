// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [MarketCreationPage]
class MarketCreationRoute extends PageRouteInfo<void> {
  const MarketCreationRoute({List<PageRouteInfo>? children})
    : super(MarketCreationRoute.name, initialChildren: children);

  static const String name = 'MarketCreationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MarketCreationPage();
    },
  );
}

/// generated route for
/// [MarketDetailPage]
class MarketDetailRoute extends PageRouteInfo<MarketDetailRouteArgs> {
  MarketDetailRoute({
    Key? key,
    required String marketId,
    int? initialOutcomeIndex,
    List<PageRouteInfo>? children,
  }) : super(
         MarketDetailRoute.name,
         args: MarketDetailRouteArgs(
           key: key,
           marketId: marketId,
           initialOutcomeIndex: initialOutcomeIndex,
         ),
         rawPathParams: {'marketId': marketId},
         initialChildren: children,
       );

  static const String name = 'MarketDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MarketDetailRouteArgs>(
        orElse: () =>
            MarketDetailRouteArgs(marketId: pathParams.getString('marketId')),
      );
      return MarketDetailPage(
        key: args.key,
        marketId: args.marketId,
        initialOutcomeIndex: args.initialOutcomeIndex,
      );
    },
  );
}

class MarketDetailRouteArgs {
  const MarketDetailRouteArgs({
    this.key,
    required this.marketId,
    this.initialOutcomeIndex,
  });

  final Key? key;

  final String marketId;

  final int? initialOutcomeIndex;

  @override
  String toString() {
    return 'MarketDetailRouteArgs{key: $key, marketId: $marketId, initialOutcomeIndex: $initialOutcomeIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MarketDetailRouteArgs) return false;
    return key == other.key &&
        marketId == other.marketId &&
        initialOutcomeIndex == other.initialOutcomeIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^ marketId.hashCode ^ initialOutcomeIndex.hashCode;
}

/// generated route for
/// [MarketExplorerPage]
class MarketExplorerRoute extends PageRouteInfo<void> {
  const MarketExplorerRoute({List<PageRouteInfo>? children})
    : super(MarketExplorerRoute.name, initialChildren: children);

  static const String name = 'MarketExplorerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MarketExplorerPage();
    },
  );
}

/// generated route for
/// [MarketsTabPage]
class MarketsTabRoute extends PageRouteInfo<void> {
  const MarketsTabRoute({List<PageRouteInfo>? children})
    : super(MarketsTabRoute.name, initialChildren: children);

  static const String name = 'MarketsTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MarketsTabPage();
    },
  );
}

/// generated route for
/// [PortfolioPage]
class PortfolioRoute extends PageRouteInfo<void> {
  const PortfolioRoute({List<PageRouteInfo>? children})
    : super(PortfolioRoute.name, initialChildren: children);

  static const String name = 'PortfolioRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PortfolioPage();
    },
  );
}

/// generated route for
/// [VotingDashboardPage]
class VotingDashboardRoute extends PageRouteInfo<void> {
  const VotingDashboardRoute({List<PageRouteInfo>? children})
    : super(VotingDashboardRoute.name, initialChildren: children);

  static const String name = 'VotingDashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VotingDashboardPage();
    },
  );
}
