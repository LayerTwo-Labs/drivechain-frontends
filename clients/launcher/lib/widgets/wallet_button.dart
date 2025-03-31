import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launcher/widgets/wallet_button_model.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class _TokenListItem extends StatelessWidget {
  final String name;
  final String amount;
  final String value;

  const _TokenListItem({
    required this.name,
    required this.amount,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SailSVG.icon(
                SailSVGAsset.iconCoins,
                color: theme.colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13(name),
                SailText.secondary12(amount),
              ],
            ),
          ),
          SailText.primary13(value),
        ],
      ),
    );
  }
}

class WalletButton extends StatefulWidget {
  const WalletButton({super.key});

  @override
  State<WalletButton> createState() => _WalletButtonState();
}

class _WalletButtonState extends State<WalletButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  Future<void> _showModal() async {
    // Remove existing overlay if any
    await _removeOverlay();

    // Create and insert new overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: ViewModelBuilder<WalletButtonModel>.reactive(
          viewModelBuilder: () => WalletButtonModel(),
          builder: (context, viewModel, child) => CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              color: SailTheme.of(context).colors.backgroundSecondary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailText.primary13('Wallet'),
                        SailButton(
                          variant: ButtonVariant.secondary,
                          onPressed: _removeOverlay,
                          label: '',
                          icon: SailSVGAsset.iconClose,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Balance section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SailText.secondary12('Total Balance'),
                        const SizedBox(height: 8),
                        ListenableBuilder(
                          listenable: viewModel,
                          builder: (context, _) {
                            return SailText.primary24(
                              '${viewModel.totalBalance.toStringAsFixed(8)} BTC',
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: SailButton(
                                label: 'Receive',
                                variant: ButtonVariant.primary,
                                onPressed: () async {
                                  await launchUrl(Uri.parse('https://drivechain.live'));
                                },
                                icon: SailSVGAsset.iconReceive,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: SailTheme.of(context).colors.formFieldBorder,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TabBar(
                            indicatorColor: SailTheme.of(context).colors.primary,
                            labelColor: SailTheme.of(context).colors.text,
                            unselectedLabelColor: SailTheme.of(context).colors.textSecondary,
                            indicatorWeight: 2,
                            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            unselectedLabelStyle: const TextStyle(fontSize: 13),
                            tabs: const [
                              Tab(text: 'Tokens'),
                              Tab(text: 'BitAssets'),
                              Tab(text: 'Activity'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: TabBarView(
                            children: [
                              ListenableBuilder(
                                listenable: viewModel,
                                builder: (context, _) => _buildTokenList(viewModel),
                              ),
                              // BitAssets tab
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SailSVG.icon(
                                        SailSVGAsset.iconCoins,
                                        color: SailTheme.of(context).colors.textSecondary,
                                      ),
                                      const SizedBox(height: 8),
                                      SailText.secondary13('No BitAssets yet'),
                                    ],
                                  ),
                                ),
                              ),
                              // Activity tab
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SailSVG.icon(
                                        SailSVGAsset.iconTransactions,
                                        color: SailTheme.of(context).colors.textSecondary,
                                      ),
                                      const SizedBox(height: 8),
                                      SailText.secondary13('No recent activity'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Address section
                  if (viewModel.address != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SailTheme.of(context).colors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.secondary12('BitWindow Address'),
                                const SizedBox(height: 4),
                                SailText.primary12(
                                  viewModel.address!,
                                  monospace: true,
                                ),
                              ],
                            ),
                          ),
                          if (viewModel.address != null)
                            SailButton(
                              label: 'Copy Address',
                              variant: ButtonVariant.secondary,
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: viewModel.address!));
                              },
                              icon: SailSVGAsset.iconCopy,
                            ),
                        ],
                      ),
                    ),
                  SailButton(
                    label: 'Open Faucet In Browser',
                    variant: ButtonVariant.link,
                    onPressed: () async {
                      await launchUrl(Uri.parse('https://drivechain.live'));
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (context.mounted && mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  Future<void> _removeOverlay() async {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildTokenList(WalletButtonModel viewModel) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.balances.isEmpty) {
      return Center(
        child: SailColumn(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SailSVG.icon(
              SailSVGAsset.iconCoins,
              color: SailTheme.of(context).colors.textSecondary,
            ),
            const SizedBox(height: 8),
            SailText.secondary13('No connected wallets'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: viewModel.balances.map((balance) {
        return SailPadding(
          padding: const EdgeInsets.only(bottom: SailStyleValues.padding08),
          child: _TokenListItem(
            name: balance.name,
            amount:
                '${balance.confirmedBalance.toStringAsFixed(8)} BTC${balance.unconfirmedBalance > 0 ? '\n(${balance.unconfirmedBalance.toStringAsFixed(8)} unconfirmed)' : ''}',
            value: '',
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SailButton(
        label: 'Wallet',
        variant: ButtonVariant.secondary,
        onPressed: () async {
          if (_overlayEntry == null) {
            await _showModal();
          } else {
            await _removeOverlay();
          }
        },
        icon: SailSVGAsset.iconWallet,
      ),
    );
  }
}
