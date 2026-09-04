import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// ExplorerPage reads the chain: its blocks, its transactions, its addresses,
/// and the withdrawals it sends to the mainchain.
@RoutePage()
class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: InlineTabBar(
        tabs: const [
          SingleTabItem(label: 'Chain', child: ChainExplorerTab()),
          SingleTabItem(label: 'Withdrawals', child: WithdrawalsTab()),
        ],
        initialIndex: 0,
      ),
    );
  }
}
