import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/wallet/bitdrive_page.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/pages/wallet/wallet_hd.dart';
import 'package:bitwindow/pages/wallet/wallet_multisig_lounge.dart';
import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/pages/wallet/wallet_utxos.dart';
import 'package:bitwindow/providers/denial_provider.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class WalletPage extends StatelessWidget {
  DenialProvider get denialProvider => GetIt.I.get<DenialProvider>();
  BitwindowRPC get api => GetIt.I<BitwindowRPC>();
  static final GlobalKey<InlineTabBarState> tabKey = GlobalKey<InlineTabBarState>();
  static SendPageViewModel? _sendViewModel; // Static reference to view model

  const WalletPage({
    super.key,
  });

  static void handleBitcoinURI(BitcoinURI uri) {
    _sendViewModel?.handleBitcoinURI(uri);
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<SendPageViewModel>.reactive(
        viewModelBuilder: () {
          _sendViewModel = SendPageViewModel();
          // Store reference to be able to set it's values from outside this particular file
          return _sendViewModel!;
        },
        onViewModelReady: (model) => model.init(),
        onDispose: (model) => _sendViewModel = null,
        builder: (context, model, child) {
          // Create the list of regular tabs
          final List<TabItem> allTabs = [
            const SingleTabItem(
              label: 'Send',
              child: SendTab(),
            ),
            const SingleTabItem(
              label: 'Receive',
              child: ReceiveTab(),
            ),
            const SingleTabItem(
              label: 'Wallet Transactions',
              child: TransactionsTab(),
            ),
            MultiSelectTabItem(
              title: 'Tools',
              items: [
                TabItem(
                  label: 'Deniability',
                  child: DeniabilityTab(
                    newWindowIdentifier: model.applicationDir == null || model.logFile == null
                        ? null
                        : NewWindowIdentifier(
                            windowType: 'deniability',
                            applicationDir: model.applicationDir!,
                            logFile: model.logFile!,
                          ),
                  ),
                  onTap: () {
                    denialProvider.fetch();
                  },
                ),
                TabItem(
                  label: 'HD Wallet Explorer',
                  child: HDWalletTab(),
                ),
                TabItem(
                  label: 'BitDrive',
                  child: BitDriveTab(),
                ),
                TabItem(
                  label: 'Multisig Lounge',
                  child: MultisigLoungeTab(),
                ),
              ],
            ),
          ];

          return InlineTabBar(
            key: tabKey,
            tabs: allTabs,
            initialIndex: 0,
          );
        },
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SailText.primary13(
              label,
              monospace: true,
              color: context.sailTheme.colors.textTertiary,
            ),
          ),
          Expanded(
            child: SailText.secondary13(
              value,
              monospace: true,
            ),
          ),
        ],
      ),
    );
  }
}
