import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

import 'hash_calculator_page.dart';
import 'multisig_lounge_page.dart';
import 'proof_of_funds_page.dart';

@RoutePage()
class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: InlineTabBar(
        tabs: const [
          TabItem(
            label: 'Hash Calculator',
            icon: SailSVGAsset.iconCoins, // TODO change icons
            child: HashCalculatorPage(),
          ),
          TabItem(
            label: 'Multisig Lounge',
            icon: SailSVGAsset.iconCoins, // TODO change icons
            child: MultisigLoungePage(),
          ),
          TabItem(
            label: 'Proof of Funds',
            icon: SailSVGAsset.iconCoins,
            child: ProofOfFundsPage(),
          ),
        ],
        initialIndex: 0,
      ),
    );
  }
}