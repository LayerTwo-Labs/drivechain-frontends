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

  void _showModal() {
    // Remove existing overlay if any
    _removeOverlay();

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
                        SailScaleButton(
                          style: SailButtonStyle.secondary,
                          onPressed: _removeOverlay,
                          child: Builder(
                            builder: (context) {
                              final theme = SailTheme.of(context);
                              return SailSVG.icon(
                                SailSVGAsset.iconClose,
                                color: theme.colors.text,
                              );
                            },
                          ),
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
                            Expanded(
                              child: SailScaleButton(
                                style: SailButtonStyle.primary,
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final theme = SailTheme.of(context);
                                        return SailSVG.icon(
                                          SailSVGAsset.iconSend,
                                          color: theme.colors.background,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    SailText.background12('Send'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SailScaleButton(
                                style: SailButtonStyle.primary,
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final theme = SailTheme.of(context);
                                        return SailSVG.icon(
                                          SailSVGAsset.iconReceive,
                                          color: theme.colors.background,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    SailText.background12('Receive'),
                                  ],
                                ),
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
                            SailScaleButton(
                              style: SailButtonStyle.secondary,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: viewModel.address!));
                              },
                              child: Builder(
                                builder: (context) {
                                  final theme = SailTheme.of(context);
                                  return SailSVG.icon(
                                    SailSVGAsset.iconCopy,
                                    color: theme.colors.text,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  SailButton.primary(
                    'Open Faucet In Browser',
                    onPressed: () {
                      launchUrl(Uri.parse('https://drivechain.live'));
                    },
                    size: ButtonSize.regular,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildTokenList(WalletButtonModel viewModel) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.balances.isEmpty) {
      return Center(
        child: Column(
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
        return _TokenListItem(
          name: balance.name,
          amount: '${balance.confirmedBalance.toStringAsFixed(8)} BTC',
          value: balance.unconfirmedBalance > 0 ? '(${balance.unconfirmedBalance.toStringAsFixed(8)} unconfirmed)' : '',
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SailScaleButton(
        style: SailButtonStyle.secondary,
        onPressed: () {
          if (_overlayEntry == null) {
            _showModal();
          } else {
            _removeOverlay();
          }
        },
        child: Tooltip(
          message: 'Wallet',
          child: SailPadding(
            padding: const EdgeInsets.only(
              right: SailStyleValues.padding10,
            ),
            child: Builder(
              builder: (context) {
                final theme = SailTheme.of(context);
                return SailSVG.fromAsset(
                  SailSVGAsset.iconWallet,
                  height: 20,
                  color: theme.colors.text,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
