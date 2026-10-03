import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/mining/mining_tab.dart';
import 'package:bitwindow/pages/mining/pools_tab.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Mining runs on eCash only, so other networks show the Pools tab alone.
bool minesHere() {
  return GetIt.I.get<BitcoinConfProvider>().network == BitcoinNetwork.BITCOIN_NETWORK_ECASH;
}

@RoutePage()
class MiningPage extends StatelessWidget {
  const MiningPage({super.key});

  static const String miningSubtabLabel = 'Mining';
  static const String poolsSubtabLabel = 'Pools';

  static final GlobalKey<InlineTabBarState> tabKey = GlobalKey<InlineTabBarState>();

  /// The stratum URL of a pool to fill into the custom pool form. The Mining
  /// tab reads it and sets it back to null.
  static final ValueNotifier<String?> requestedPoolUrl = ValueNotifier(null);

  /// The tab a caller asked for before the page mounted. The next build opens
  /// it.
  static String? _pendingSubtab;

  @visibleForTesting
  static String? get pendingSubtab => _pendingSubtab;

  /// Opens a tab by label. A page that is not on screen yet opens the tab as
  /// it arrives.
  static void openSubtab(String label) {
    final state = tabKey.currentState;
    if (state == null) {
      _pendingSubtab = label;
      return;
    }
    final index = state.widget.tabs.indexWhere((tab) => tab.label == label);
    if (index < 0) {
      return;
    }
    state.setIndex(index, null);
  }

  /// Opens the Mining tab with the custom pool form filled for [stratumUrl].
  static void mineAt(String stratumUrl) {
    requestedPoolUrl.value = stratumUrl;
    openSubtab(miningSubtabLabel);
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingSubtab case final label?) {
      _pendingSubtab = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => openSubtab(label));
    }
    return QtPage(
      child: InlineTabBar(
        key: tabKey,
        tabs: [
          if (minesHere()) const SingleTabItem(label: miningSubtabLabel, child: MiningTab()),
          const SingleTabItem(label: poolsSubtabLabel, child: PoolsTab()),
        ],
      ),
    );
  }
}
