import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

/// ExplorerPage reads the chain: its blocks, its transactions, its addresses,
/// and the withdrawals it sends to the mainchain.
@RoutePage()
class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // A kept-alive tab that is not shown stops the refresh below it.
    final tabs = TabsRouterScope.of(context, watch: true)?.controller;
    return TickerMode(
      enabled: tabs == null || tabs.current.name == ExplorerRoute.name,
      child: QtPage(
        child: InlineTabBar(
          tabs: const [
            SingleTabItem(label: 'Chain', child: ChainExplorerTab()),
            SingleTabItem(label: 'Withdrawals', child: WithdrawalsTab()),
          ],
          initialIndex: 0,
        ),
      ),
    );
  }
}
