import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:bitwindow/widgets/fee_coinnews.dart';
import 'package:bitwindow/widgets/fast_withdrawal_tab.dart';
import 'package:bitwindow/widgets/mempool_widget.dart';
import 'package:bitwindow/widgets/network_stats_widget.dart';
import 'package:bitwindow/widgets/peers_table_widget.dart';
import 'package:bitwindow/widgets/traffic_graph_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class HomepageWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'quote_bar': HomepageWidgetInfo(
      id: 'quote_bar',
      name: 'Quotes',
      sizes: [WidgetSize.bar],
      group: 'News',
      builder: (_) => const QuoteBar(),
    ),
    'coin_news': HomepageWidgetInfo(
      id: 'coin_news',
      name: 'Coin News',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'News',
      builder: (size) => size == WidgetSize.full
          ? ViewModelBuilder<FeeCoinNewsLargeViewModel>.reactive(
              viewModelBuilder: () => FeeCoinNewsLargeViewModel(),
              builder: (context, newsModel, child) => const FeeCoinNewsLargeView(),
            )
          : ViewModelBuilder<FeeCoinNewsViewModel>.reactive(
              viewModelBuilder: () => FeeCoinNewsViewModel(),
              builder: (context, newsModel, child) => const FeeCoinNewsView(),
            ),
    ),
    'hacker_coin_news': HomepageWidgetInfo(
      id: 'hacker_coin_news',
      name: 'Hacker Coin News',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'News',
      builder: (size) => size == WidgetSize.full
          ? ViewModelBuilder<CoinNewsLargeViewModel>.reactive(
              viewModelBuilder: () => CoinNewsLargeViewModel(),
              builder: (context, newsModel, child) => const CoinNewsLargeView(),
            )
          : ViewModelBuilder<CoinNewsViewModel>.reactive(
              viewModelBuilder: () => CoinNewsViewModel(),
              builder: (context, newsModel, child) => const CoinNewsView(),
            ),
    ),
    'fireplace_stats': HomepageWidgetInfo(
      id: 'fireplace_stats',
      name: 'Dashboard Stats',
      sizes: [WidgetSize.full],
      group: 'Chain',
      builder: (_) => const FireplaceStats(),
    ),
    'latest_transactions': HomepageWidgetInfo(
      id: 'latest_transactions',
      name: 'Latest Transactions',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'Chain',
      builder: (_) => ViewModelBuilder<TransactionsViewModel>.reactive(
        viewModelBuilder: () => TransactionsViewModel(),
        builder: (context, model, child) {
          return SailCard(
            bottomPadding: false,
            title: 'Latest Transactions',
            error: model.hasErrorForKey('blockchain') ? model.error('blockchain').toString() : null,
            child: SizedBox(
              height: 300,
              child: LatestTransactionTable(
                entries: model.recentTransactions,
              ),
            ),
          );
        },
      ),
    ),
    'latest_blocks': HomepageWidgetInfo(
      id: 'latest_blocks',
      name: 'Latest Blocks',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'Chain',
      builder: (_) => ViewModelBuilder<TransactionsViewModel>.reactive(
        viewModelBuilder: () => TransactionsViewModel(),
        builder: (context, model, child) {
          return SailCard(
            title: 'Latest Blocks',
            bottomPadding: false,
            child: SizedBox(
              height: 300,
              child: LatestBlocksTable(
                blocks: model.recentBlocks,
              ),
            ),
          );
        },
      ),
    ),
    'mempool': HomepageWidgetInfo(
      id: 'mempool',
      name: 'Mempool',
      sizes: [WidgetSize.full],
      group: 'Chain',
      builder: (_) => const MempoolWidget(),
    ),
    'block_explorer': HomepageWidgetInfo(
      id: 'block_explorer',
      name: 'Block Explorer',
      sizes: [WidgetSize.full],
      group: 'Chain',
      builder: (_) => SizedBox(
        height: 500,
        child: const BlockExplorerDialog(),
      ),
    ),
    'graffiti_explorer': HomepageWidgetInfo(
      id: 'graffiti_explorer',
      name: 'Graffiti Explorer',
      sizes: [WidgetSize.full],
      group: 'Chain',
      builder: (_) => SizedBox(
        height: 500,
        child: const GraffitiExplorerView(),
      ),
    ),
    'network_traffic': HomepageWidgetInfo(
      id: 'network_traffic',
      name: 'Network Traffic',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'Network',
      builder: (_) => ListenableBuilder(
        listenable: GetIt.I.get<NetworkProvider>(),
        builder: (context, child) => const TrafficGraphWidget(),
      ),
    ),
    'network_stats': HomepageWidgetInfo(
      id: 'network_stats',
      name: 'Network Stats',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'Network',
      builder: (_) => ListenableBuilder(
        listenable: GetIt.I.get<NetworkProvider>(),
        builder: (context, child) => const NetworkStatsWidget(),
      ),
    ),
    'peers_table': HomepageWidgetInfo(
      id: 'peers_table',
      name: 'Connected Peers',
      sizes: [WidgetSize.full],
      group: 'Network',
      builder: (_) => SizedBox(
        height: 400,
        child: const PeersTableWidget(),
      ),
    ),
    'sidechains_compact': HomepageWidgetInfo(
      id: 'sidechains_compact',
      name: 'Sidechains',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'Wallet and sidechains',
      builder: (_) => ViewModelBuilder<SidechainsViewModel>.reactive(
        viewModelBuilder: () => SidechainsViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 300,
            child: SidechainsList(
              smallVersion: true,
            ),
          );
        },
      ),
    ),
    'recent_actions': HomepageWidgetInfo(
      id: 'recent_actions',
      name: 'Recent Actions',
      sizes: [WidgetSize.half, WidgetSize.full],
      group: 'Wallet and sidechains',
      builder: (_) => ViewModelBuilder<RecentActionsViewModel>.reactive(
        viewModelBuilder: () => RecentActionsViewModel(),
        builder: (context, viewModel, child) {
          return RecentActionsCard(
            title: 'Recent Actions',
            subtitle: viewModel.subtitle,
            actions: viewModel.actions,
          );
        },
      ),
    ),
    'deniability': HomepageWidgetInfo(
      id: 'deniability',
      name: 'Deniability',
      sizes: [WidgetSize.full],
      group: 'Wallet and sidechains',
      builder: (_) => SizedBox(
        height: 300,
        child: const DeniabilityTab(newWindowButton: null),
      ),
    ),
    'fast_withdrawal': HomepageWidgetInfo(
      id: 'fast_withdrawal',
      name: 'Fast Withdrawal',
      sizes: [WidgetSize.full],
      group: 'Wallet and sidechains',
      builder: (_) => const FastWithdrawalTab(),
    ),
  };

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    return Map.from(_widgets);
  }
}

/// ViewModel for Recent Actions widget that fetches from the API in demo mode
class RecentActionsViewModel extends BaseViewModel {
  BitwindowRPC get _rpc => GetIt.I.get<BitwindowRPC>();

  List<ActionEntry> actions = [];
  String? subtitle;

  RecentActionsViewModel() {
    _fetchActions();
  }

  Future<void> _fetchActions() async {
    try {
      final response = await _rpc.drivechain.listRecentActions(limit: 10);

      actions = response.actions.map((action) {
        return ActionEntry(
          avatar: SidechainActionAvatar(slot: action.sidechainSlot),
          title: _getTitleForAction(action.actionType),
          subtitle: action.sidechainName,
          value: _getValueForAction(action),
        );
      }).toList();

      subtitle = response.subtitle.isNotEmpty ? response.subtitle : null;
      notifyListeners();
    } catch (e) {
      // If API fails (e.g., not in demo mode), show empty list
      actions = [];
      subtitle = null;
      notifyListeners();
    }
  }

  String _getTitleForAction(String actionType) {
    return switch (actionType) {
      'deposit' => 'Deposit',
      'withdrawal' => 'Withdrawal Executed',
      'withdrawal_ack' => 'Withdrawal Ack',
      'sidechain_proposal' => 'New Sidechain Proposal',
      'sidechain_ack' => 'Sidechain Ack',
      _ => actionType,
    };
  }

  String _getValueForAction(dynamic action) {
    return switch (action.actionType) {
      'deposit' => '+ ${_formatBTC(action.amountSatoshi)} ${activeTicker.symbol}',
      'withdrawal' => '- ${_formatBTC(action.amountSatoshi)} ${activeTicker.symbol}',
      'withdrawal_ack' => '${_formatNumber(action.ackCount)} / ${_formatNumber(action.ackTotal)} acks',
      'sidechain_proposal' => '${action.ackCount}/${action.ackTotal} acks',
      'sidechain_ack' => action.extraInfo,
      _ => '',
    };
  }

  String _formatBTC(int satoshi) {
    final btc = satoshi / 100000000;
    return btc.toStringAsFixed(btc < 1 ? 6 : 4);
  }

  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    }
    return '${(number / 1000).toStringAsFixed(0)} ${number % 1000}'.trim();
  }
}

/// The 40 px picture of the sidechain in [slot], decoded at its display size.
class SidechainActionAvatar extends StatelessWidget {
  const SidechainActionAvatar({super.key, required this.slot});

  final int slot;

  @override
  Widget build(BuildContext context) {
    final assetName = switch (slot) {
      2 => 'bitnames',
      4 => 'bitassets',
      9 => 'thunder',
      13 => 'truthcoin',
      98 => 'zside',
      99 => 'photon',
      _ => 'thunder', // fallback
    };
    final pixels = (40 * MediaQuery.devicePixelRatioOf(context)).ceil();
    return Image(
      image: ResizeImage(
        AssetImage('packages/sail_ui/assets/pngs/$assetName.png'),
        width: pixels,
        height: pixels,
        policy: ResizeImagePolicy.fit,
      ),
      width: 40,
      height: 40,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SailTheme.of(context).colors.backgroundSecondary,
        ),
      ),
    );
  }
}
