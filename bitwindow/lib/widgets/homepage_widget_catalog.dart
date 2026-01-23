import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:bitwindow/widgets/fast_withdrawal_tab.dart';
import 'package:bitwindow/widgets/network_stats_widget.dart';
import 'package:bitwindow/widgets/peers_table_widget.dart';
import 'package:bitwindow/widgets/traffic_graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  };

  static const _sidechainWidgetIds = {'fast_withdrawal', 'sidechains_compact'};

  static bool get _supportsSidechains => GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains;

  static HomepageWidgetInfo? getWidget(String id) {
    if (_sidechainWidgetIds.contains(id) && !_supportsSidechains) {
      return null;
    }
    return _widgets[id];
  }

  static List<HomepageWidgetInfo> getAllWidgets() {
    return _widgets.values.where((w) => !_sidechainWidgetIds.contains(w.id) || _supportsSidechains).toList();
  }

  static List<HomepageWidgetInfo> getFullWidthWidgets() {
    return _widgets.values
        .where((w) => w.size == WidgetSize.full && (!_sidechainWidgetIds.contains(w.id) || _supportsSidechains))
        .toList();
  }

  static List<HomepageWidgetInfo> getHalfWidthWidgets() {
    return _widgets.values
        .where((w) => w.size == WidgetSize.half && (!_sidechainWidgetIds.contains(w.id) || _supportsSidechains))
        .toList();
  }

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    if (_supportsSidechains) {
      return Map.from(_widgets);
    }
    return Map.fromEntries(_widgets.entries.where((e) => !_sidechainWidgetIds.contains(e.key)));
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
    return widgetInfo.builder(settings);
  }
}
