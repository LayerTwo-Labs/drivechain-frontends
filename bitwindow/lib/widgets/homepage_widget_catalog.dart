import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:bitwindow/widgets/fast_withdrawal_tab.dart';
import 'package:bitwindow/widgets/network_stats_widget.dart';
import 'package:bitwindow/widgets/peers_table_widget.dart';
import 'package:bitwindow/widgets/traffic_graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class HomepageWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'fireplace_stats': HomepageWidgetInfo(
      id: 'fireplace_stats',
      name: 'Dashboard Stats',
      description: 'Bitcoin price and network statistics',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconSuccess,
      builder: (_) => const FireplaceStats(),
    ),
    'coin_news': HomepageWidgetInfo(
      id: 'coin_news',
      name: 'Coin News',
      description: 'Latest news from the blockchain',
      size: WidgetSize.half,
      icon: SailSVGAsset.newspaper,
      builder: (_) => ViewModelBuilder<CoinNewsViewModel>.reactive(
        viewModelBuilder: () => CoinNewsViewModel(),
        builder: (context, newsModel, child) {
          return const CoinNewsView();
        },
      ),
    ),
    'coin_news_large': HomepageWidgetInfo(
      id: 'coin_news_large',
      name: 'Coin News (Large)',
      description: 'Dual-column news display',
      size: WidgetSize.full,
      icon: SailSVGAsset.newspaper,
      builder: (_) => ViewModelBuilder<CoinNewsLargeViewModel>.reactive(
        viewModelBuilder: () => CoinNewsLargeViewModel(),
        builder: (context, newsModel, child) {
          return const CoinNewsLargeView();
        },
      ),
    ),
    'latest_transactions': HomepageWidgetInfo(
      id: 'latest_transactions',
      name: 'Latest Transactions',
      description: 'Recent blockchain transactions',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconTransactions,
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
      description: 'Recently mined blocks',
      size: WidgetSize.half,
      icon: SailSVGAsset.blocks,
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
    'fast_withdrawal': HomepageWidgetInfo(
      id: 'fast_withdrawal',
      name: 'Fast Withdrawal',
      description: 'Quick L2 to L1 withdrawals',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconSend,
      builder: (_) => ViewModelBuilder<FastWithdrawalTabViewModel>.reactive(
        viewModelBuilder: () => FastWithdrawalTabViewModel(),
        builder: (context, viewModel, child) {
          return const FastWithdrawalTab();
        },
      ),
    ),
    'sidechains_compact': HomepageWidgetInfo(
      id: 'sidechains_compact',
      name: 'Sidechains',
      description: 'Compact sidechain overview',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconSidechains,
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
    'deniability': HomepageWidgetInfo(
      id: 'deniability',
      name: 'Deniability',
      description: 'UTXO deniability management',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconWallet,
      builder: (_) => SizedBox(
        height: 300,
        child: const DeniabilityTab(newWindowButton: null),
      ),
    ),
    'block_explorer': HomepageWidgetInfo(
      id: 'block_explorer',
      name: 'Block Explorer',
      description: 'Browse blockchain blocks and transactions',
      size: WidgetSize.full,
      icon: SailSVGAsset.blocks,
      builder: (_) => SizedBox(
        height: 500,
        child: const BlockExplorerDialog(),
      ),
    ),
    'graffiti_explorer': HomepageWidgetInfo(
      id: 'graffiti_explorer',
      name: 'Graffiti Explorer',
      description: 'Browse blockchain graffiti and OP_RETURN data',
      size: WidgetSize.full,
      icon: SailSVGAsset.sprayCan,
      builder: (_) => SizedBox(
        height: 500,
        child: const GraffitiExplorerView(),
      ),
    ),
    'network_traffic': HomepageWidgetInfo(
      id: 'network_traffic',
      name: 'Network Traffic',
      description: 'Real-time bandwidth graph',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconNetwork,
      builder: (_) => ListenableBuilder(
        listenable: GetIt.I.get<NetworkProvider>(),
        builder: (context, child) => const TrafficGraphWidget(),
      ),
    ),
    'network_stats': HomepageWidgetInfo(
      id: 'network_stats',
      name: 'Network Stats',
      description: 'Peer connections and bandwidth summary',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconGlobe,
      builder: (_) => ListenableBuilder(
        listenable: GetIt.I.get<NetworkProvider>(),
        builder: (context, child) => const NetworkStatsWidget(),
      ),
    ),
    'peers_table': HomepageWidgetInfo(
      id: 'peers_table',
      name: 'Connected Peers',
      description: 'List of connected network peers',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconPeers,
      builder: (_) => SizedBox(
        height: 400,
        child: const PeersTableWidget(),
      ),
    ),
    'recent_actions': HomepageWidgetInfo(
      id: 'recent_actions',
      name: 'Recent Actions',
      description: 'Recent sidechain activity',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconTransactions,
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
  };

  static const _sidechainWidgetIds = {'fast_withdrawal', 'sidechains_compact'};

  static bool get _supportsSidechains => GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains;

  static HomepageWidgetInfo? getWidget(String id) {
    return _widgets[id];
  }

  static List<HomepageWidgetInfo> getAllWidgets() {
    return _widgets.values.toList();
  }

  static List<HomepageWidgetInfo> getFullWidthWidgets() {
    return _widgets.values.where((w) => w.size == WidgetSize.full).toList();
  }

  static List<HomepageWidgetInfo> getHalfWidthWidgets() {
    return _widgets.values.where((w) => w.size == WidgetSize.half).toList();
  }

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    return Map.from(_widgets);
  }

  static Widget buildWidget(String id, {Map<String, dynamic> settings = const {}}) {
    final widgetInfo = getWidget(id);
    if (widgetInfo == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('Widget not found: $id'),
        ),
      );
    }

    // Show greyed-out placeholder for sidechain widgets on mainnet
    if (_sidechainWidgetIds.contains(id) && !_supportsSidechains) {
      return _buildDisabledSidechainWidget(widgetInfo);
    }

    return widgetInfo.builder(settings);
  }

  static Widget _buildDisabledSidechainWidget(HomepageWidgetInfo widgetInfo) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              AutoRouter.of(context).push(
                ComingSoonRoute(
                  router: GetIt.I.get<AppRouter>(),
                  message: 'Terribly sorry, but this is not available on mainnet yet.',
                ),
              );
            },
            child: Opacity(
              opacity: 0.5,
              child: SailCard(
                title: widgetInfo.name,
                subtitle: 'Not available on this network',
                child: Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SailText.primary15('Unlock with BIP300'),
                      const SailSpacing(SailStyleValues.padding12),
                      SailText.secondary13(
                        'This feature requires Forknet or Signet network. '
                        'Switch networks in Settings to unlock sidechain functionality.',
                      ),
                      const SailSpacing(SailStyleValues.padding12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colors.backgroundSecondary,
                          borderRadius: SailStyleValues.borderRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SailSVG.fromAsset(
                              widgetInfo.icon,
                              color: theme.colors.textTertiary,
                              width: 16,
                            ),
                            const SizedBox(width: 8),
                            SailText.secondary12(widgetInfo.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
          avatar: _getAvatarForSidechain(action.sidechainSlot),
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

  Widget _getAvatarForSidechain(int slot) {
    final assetName = switch (slot) {
      2 => 'bitnames',
      4 => 'bitassets',
      9 => 'thunder',
      13 => 'truthcoin',
      98 => 'zside',
      99 => 'photon',
      _ => 'thunder', // fallback
    };
    return Image.asset(
      'packages/sail_ui/assets/pngs/$assetName.png',
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
      'deposit' => '+ ${_formatBTC(action.amountSatoshi)} BTC',
      'withdrawal' => '- ${_formatBTC(action.amountSatoshi)} BTC',
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
    if (number < 1000) return number.toString();
    return '${(number / 1000).toStringAsFixed(0)} ${number % 1000}'.trim();
  }
}
