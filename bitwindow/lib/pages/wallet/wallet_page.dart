import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/wallet/bitdrive_page.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/pages/wallet/wallet_hd.dart';
import 'package:bitwindow/pages/wallet/wallet_multisig_lounge.dart';
import 'package:bitwindow/pages/wallet/wallet_overview.dart';
import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/pages/wallet/wallet_utxos.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPageViewModel extends BaseViewModel {
  final HDWalletProvider _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
  final AddressBookProvider _addressBookProvider = GetIt.I.get<AddressBookProvider>();
  
  String get bip47PaymentCode => _hdWalletProvider.bip47PaymentCode;
  
  WalletPageViewModel() {
    _hdWalletProvider.addListener(_onHdWalletProviderChanged);
    // Ensure HD wallet is initialized
    if (!_hdWalletProvider.isInitialized) {
      _hdWalletProvider.init();
    }
  }
  
  void _onHdWalletProviderChanged() {
    // Add payment code to address book when it becomes available
    if (bip47PaymentCode.isNotEmpty) {
      _addPaymentCodeToAddressBook();
    }
    notifyListeners();
  }
  
  Future<void> _addPaymentCodeToAddressBook() async {
    try {
      // Check if payment code already exists in address book
      final existingEntries = _addressBookProvider.receiveEntries
          .where((entry) => entry.address == bip47PaymentCode)
          .toList();
      
      if (existingEntries.isEmpty) {
        await _addressBookProvider.createEntry(
          'BIP47 Payment Code',
          bip47PaymentCode,
          Direction.DIRECTION_RECEIVE,
        );
      }
    } catch (e) {
      // Silently fail if address book update fails - payment code will still be visible
    }
  }
  
  Future<void> copyPaymentCode(BuildContext context) async {
    if (bip47PaymentCode.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: bip47PaymentCode));
      if (context.mounted) {
        showSnackBar(context, 'BIP47 Payment Code copied to clipboard');
      }
    }
  }
  
  @override
  void dispose() {
    _hdWalletProvider.removeListener(_onHdWalletProviderChanged);
    super.dispose();
  }
}

@RoutePage()
class WalletPage extends StatelessWidget {
  TransactionProvider get transactionProvider => GetIt.I.get<TransactionProvider>();
  BitwindowRPC get bitwindowd => GetIt.I<BitwindowRPC>();
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
      child: ViewModelBuilder<WalletPageViewModel>.reactive(
        viewModelBuilder: () => WalletPageViewModel(),
        builder: (context, walletPageModel, child) {
          return ViewModelBuilder<SendPageViewModel>.reactive(
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
              label: 'Overview',
              child: OverviewTab(),
            ),
            const SingleTabItem(
              label: 'Send',
              child: SendTab(),
            ),
            const SingleTabItem(
              label: 'Receive',
              child: ReceiveTab(),
            ),
            const SingleTabItem(
              label: 'UTXOs',
              child: UTXOsTab(),
            ),
            MultiSelectTabItem(
              title: 'Tools',
              items: [
                TabItem(
                  label: 'Deniability',
                  child: DeniabilityTab(
                    newWindowButton: SubWindowTypes.deniability,
                  ),
                  onTap: () {
                    transactionProvider.fetch();
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
            endWidget: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                if (walletPageModel.bip47PaymentCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SailStyleValues.padding12,
                      vertical: SailStyleValues.padding04,
                    ),
                    decoration: BoxDecoration(
                      color: context.sailTheme.colors.background,
                      border: Border.all(color: context.sailTheme.colors.divider),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Tooltip(
                      message: 'Click to Copy',
                      child: InkWell(
                        onTap: () => walletPageModel.copyPaymentCode(context),
                        child: SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            SailText.primary12(
                              'BIP47 v3 Payment Code:',
                              bold: true,
                            ),
                            SailText.primary12(
                              walletPageModel.bip47PaymentCode,
                              monospace: true,
                            ),
                            const Icon(
                              Icons.copy,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Open Faucet Button
                SailButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse('https://node.drivechain.info/#/faucet'));
                  },
                  label: 'Open Faucet',
                ),
              ],
            ),
            );
          },
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
