import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/providers/favorites_provider.dart';
import 'package:bitassets/providers/price_alert_provider.dart';
import 'package:bitassets/routing/router.dart';
import 'package:bitassets/settings/price_alerts_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class AuctionBrowserTabPage extends StatelessWidget {
  const AuctionBrowserTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<AuctionBrowserViewModel>.reactive(
        viewModelBuilder: () => AuctionBrowserViewModel(),
        builder: (context, model, child) {
          final theme = SailTheme.of(context);

          return SailColumn(
            spacing: SailStyleValues.padding16,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header with search and filters
              SailRow(
                spacing: SailStyleValues.padding16,
                children: [
                  // Search
                  Expanded(
                    flex: 2,
                    child: SailTextField(
                      hintText: 'Search by auction ID or asset...',
                      controller: model.searchController,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: SailSVG.icon(SailSVGAsset.iconSearch, width: 16),
                      ),
                    ),
                  ),

                  // Sort dropdown
                  SizedBox(
                    width: 180,
                    child: SailDropdownButton<AuctionSort>(
                      value: model.currentSort,
                      items: [
                        SailDropdownItem(value: AuctionSort.startBlockDesc, label: 'Newest First'),
                        SailDropdownItem(value: AuctionSort.startBlockAsc, label: 'Oldest First'),
                        SailDropdownItem(value: AuctionSort.priceDesc, label: 'Highest Price'),
                        SailDropdownItem(value: AuctionSort.priceAsc, label: 'Lowest Price'),
                        SailDropdownItem(value: AuctionSort.amountDesc, label: 'Largest Amount'),
                        SailDropdownItem(value: AuctionSort.amountAsc, label: 'Smallest Amount'),
                      ],
                      onChanged: (value) {
                        if (value != null) model.setSort(value);
                      },
                    ),
                  ),

                  // Refresh button
                  SailButton(
                    label: 'Refresh',
                    onPressed: () async => model.refresh(),
                  ),
                ],
              ),

              // Filter tabs
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  _FilterTab(
                    label: 'All',
                    count: model.allAuctions.length,
                    isActive: model.currentFilter == AuctionFilter.all,
                    onTap: () => model.setFilter(AuctionFilter.all),
                  ),
                  _FilterTab(
                    label: 'Active',
                    count: model.activeCount,
                    isActive: model.currentFilter == AuctionFilter.active,
                    onTap: () => model.setFilter(AuctionFilter.active),
                    color: theme.colors.success,
                  ),
                  _FilterTab(
                    label: 'Upcoming',
                    count: model.upcomingCount,
                    isActive: model.currentFilter == AuctionFilter.upcoming,
                    onTap: () => model.setFilter(AuctionFilter.upcoming),
                    color: theme.colors.info,
                  ),
                  _FilterTab(
                    label: 'Ended',
                    count: model.endedCount,
                    isActive: model.currentFilter == AuctionFilter.ended,
                    onTap: () => model.setFilter(AuctionFilter.ended),
                    color: theme.colors.textSecondary,
                  ),
                  const Spacer(),
                  SailText.secondary12('Current Block: ${model.currentBlock}'),
                ],
              ),

              // Auction table
              Expanded(
                child: SailCard(
                  title: 'Dutch Auctions',
                  subtitle: 'Browse and bid on asset auctions',
                  child: model.isLoading
                      ? const Center(child: SailCircularProgressIndicator())
                      : model.filteredAuctions.isEmpty
                      ? Center(
                          child: SailColumn(
                            spacing: SailStyleValues.padding16,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SailSVG.icon(SailSVGAsset.iconCalendar, width: 48),
                              const SizedBox(height: 8),
                              SailText.secondary13(
                                model.searchController.text.isNotEmpty
                                    ? 'No auctions match your search'
                                    : model.currentFilter == AuctionFilter.all
                                    ? 'No auctions yet'
                                    : 'No ${model.currentFilter.name} auctions',
                              ),
                              if (model.currentFilter == AuctionFilter.all && model.searchController.text.isEmpty)
                                SailText.secondary12('Create a Dutch auction to sell your assets'),
                              if (model.currentFilter == AuctionFilter.all && model.searchController.text.isEmpty)
                                SailButton(
                                  label: 'Create Auction',
                                  onPressed: () async {
                                    await AutoRouter.of(context).navigate(const DutchAuctionTabRoute());
                                  },
                                ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SailStyleValues.padding16,
                                vertical: SailStyleValues.padding08,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colors.backgroundSecondary,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 28), // Star column
                                  SizedBox(width: 70, child: SailText.secondary12('Status')),
                                  Expanded(flex: 2, child: SailText.secondary12('Auction ID')),
                                  Expanded(child: SailText.secondary12('Base Asset')),
                                  Expanded(child: SailText.secondary12('Quote Asset')),
                                  Expanded(child: SailText.secondary12('Amount', textAlign: TextAlign.right)),
                                  Expanded(child: SailText.secondary12('Price Range', textAlign: TextAlign.right)),
                                  Expanded(child: SailText.secondary12('Current', textAlign: TextAlign.right)),
                                  Expanded(child: SailText.secondary12('Duration')),
                                  const SizedBox(width: 110),
                                ],
                              ),
                            ),
                            // Table rows
                            Expanded(
                              child: ListView.builder(
                                itemCount: model.filteredAuctions.length,
                                itemBuilder: (context, index) {
                                  final auction = model.filteredAuctions[index];
                                  final status = model.getAuctionStatus(auction);
                                  return _AuctionRow(
                                    auction: auction,
                                    currentBlock: model.currentBlock,
                                    status: status,
                                    currentPrice: model.getCurrentPrice(auction),
                                    baseAssetName: model.getAssetName(auction.baseAsset),
                                    quoteAssetName: model.getAssetName(auction.quoteAsset),
                                    isFavorite: model.isFavorite(auction.baseAsset),
                                    hasAlert: model.hasAlertForAuction(auction.id),
                                    onCopyId: () => model.copyToClipboard(auction.id, context),
                                    onToggleFavorite: () => model.toggleFavorite(auction.baseAsset),
                                    onSetAlert: status == 'Active'
                                        ? () => model.showAlertDialog(context, auction)
                                        : null,
                                    onBid: status == 'Active' ? () => model.showBidDialog(context, auction) : null,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final tabColor = color ?? theme.colors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? tabColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: isActive ? tabColor : theme.colors.divider,
          ),
        ),
        child: SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailText.primary13(
              label,
              color: isActive ? tabColor : null,
              bold: isActive,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? tabColor : theme.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SailText.secondary12(
                count.toString(),
                color: isActive ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuctionRow extends StatelessWidget {
  final DutchAuctionEntry auction;
  final int currentBlock;
  final String status;
  final int currentPrice;
  final String baseAssetName;
  final String quoteAssetName;
  final bool isFavorite;
  final bool hasAlert;
  final VoidCallback onCopyId;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onSetAlert;
  final VoidCallback? onBid;

  const _AuctionRow({
    required this.auction,
    required this.currentBlock,
    required this.status,
    required this.currentPrice,
    required this.baseAssetName,
    required this.quoteAssetName,
    required this.isFavorite,
    required this.hasAlert,
    required this.onCopyId,
    required this.onToggleFavorite,
    this.onSetAlert,
    this.onBid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final statusColor = _getStatusColor(status, theme);
    final progress = _calculateProgress();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding16,
        vertical: SailStyleValues.padding12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Favorite star
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? theme.colors.orange : theme.colors.textSecondary,
              size: 18,
            ),
            onPressed: onToggleFavorite,
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),

          // Status
          SizedBox(
            width: 70,
            child: _StatusBadge(status: status, color: statusColor),
          ),

          // Auction ID
          Expanded(
            flex: 2,
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailText.primary13(
                    '${auction.id.substring(0, 16)}...',
                    monospace: true,
                  ),
                ),
                IconButton(
                  icon: SailSVG.icon(SailSVGAsset.iconCopy, width: 14),
                  onPressed: onCopyId,
                  tooltip: 'Copy ID',
                  iconSize: 14,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),

          // Base asset
          Expanded(
            child: SailText.primary13(baseAssetName),
          ),

          // Quote asset
          Expanded(
            child: SailText.primary13(quoteAssetName),
          ),

          // Amount
          Expanded(
            child: SailText.primary13(
              _formatAmount(auction.baseAmount),
              textAlign: TextAlign.right,
              monospace: true,
            ),
          ),

          // Price range
          Expanded(
            child: SailText.secondary12(
              '${_formatAmount(auction.finalPrice)} - ${_formatAmount(auction.initialPrice)}',
              textAlign: TextAlign.right,
              monospace: true,
            ),
          ),

          // Current price
          Expanded(
            child: SailText.primary13(
              status == 'Upcoming' ? '—' : _formatAmount(currentPrice),
              textAlign: TextAlign.right,
              monospace: true,
              bold: true,
            ),
          ),

          // Duration / Progress
          Expanded(
            child: SailColumn(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary12('${auction.duration} blocks'),
                if (status == 'Active')
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colors.divider,
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
              ],
            ),
          ),

          // Actions
          SizedBox(
            width: 110,
            child: SailRow(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Alert button
                if (onSetAlert != null)
                  IconButton(
                    icon: Icon(
                      hasAlert ? Icons.notifications_active : Icons.notifications_none,
                      color: hasAlert ? theme.colors.orange : theme.colors.textSecondary,
                      size: 18,
                    ),
                    onPressed: onSetAlert,
                    tooltip: hasAlert ? 'Edit price alert' : 'Set price alert',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                // Bid button
                if (onBid != null)
                  SailButton(
                    label: 'Bid',
                    small: true,
                    onPressed: () async => onBid!(),
                  )
                else if (status == 'Ended')
                  SailText.secondary12('Ended')
                else
                  SailText.secondary12('Not started'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, SailThemeData theme) {
    switch (status) {
      case 'Active':
        return theme.colors.success;
      case 'Upcoming':
        return theme.colors.info;
      case 'Ended':
        return theme.colors.textSecondary;
      default:
        return theme.colors.textSecondary;
    }
  }

  double _calculateProgress() {
    if (status != 'Active') return 0;
    final elapsed = currentBlock - auction.startBlock;
    return (elapsed / auction.duration).clamp(0.0, 1.0);
  }

  String _formatAmount(int amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(4)} BTC';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toString();
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: SailText.secondary12(
        status,
        color: color,
        bold: true,
      ),
    );
  }
}

class AuctionBrowserViewModel extends BaseViewModel {
  final BitAssetsProvider bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();
  final AssetAnalyticsProvider analyticsProvider = GetIt.I.get<AssetAnalyticsProvider>();
  final BitAssetsRPC rpc = GetIt.I.get<BitAssetsRPC>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();
  final FavoritesProvider favoritesProvider = GetIt.I.get<FavoritesProvider>();
  final PriceAlertProvider priceAlertProvider = GetIt.I.get<PriceAlertProvider>();

  final TextEditingController searchController = TextEditingController();

  int currentBlock = 0;

  AuctionBrowserViewModel() {
    bitAssetsProvider.addListener(notifyListeners);
    analyticsProvider.addListener(notifyListeners);
    favoritesProvider.addListener(notifyListeners);
    priceAlertProvider.addListener(notifyListeners);
    searchController.addListener(_onSearchChanged);
    _fetchCurrentBlock();
  }

  bool isFavorite(String assetHash) => favoritesProvider.isFavorite(assetHash);

  bool hasAlertForAuction(String auctionId) => priceAlertProvider.hasAlertForAuction(auctionId);

  Future<void> toggleFavorite(String assetHash) async {
    await favoritesProvider.toggleFavorite(assetHash);
  }

  Future<void> _fetchCurrentBlock() async {
    try {
      currentBlock = await rpc.getBlockCount();
      notifyListeners();
    } catch (_) {}
  }

  bool get isLoading => bitAssetsProvider.isLoadingAuctions;

  List<DutchAuctionEntry> get allAuctions => bitAssetsProvider.auctions;

  List<DutchAuctionEntry> get filteredAuctions {
    return analyticsProvider.getFilteredAuctions(allAuctions, currentBlock);
  }

  AuctionFilter get currentFilter => analyticsProvider.auctionFilter;
  AuctionSort get currentSort => analyticsProvider.auctionSort;

  int get activeCount => allAuctions.where((a) => getAuctionStatus(a) == 'Active').length;
  int get upcomingCount => allAuctions.where((a) => getAuctionStatus(a) == 'Upcoming').length;
  int get endedCount => allAuctions.where((a) => getAuctionStatus(a) == 'Ended').length;

  void _onSearchChanged() {
    analyticsProvider.setAuctionSearchQuery(searchController.text);
  }

  void setFilter(AuctionFilter filter) {
    analyticsProvider.setAuctionFilter(filter);
  }

  void setSort(AuctionSort sort) {
    analyticsProvider.setAuctionSort(sort);
  }

  String getAuctionStatus(DutchAuctionEntry auction) {
    return analyticsProvider.getAuctionStatus(auction, currentBlock);
  }

  int getCurrentPrice(DutchAuctionEntry auction) {
    return analyticsProvider.calculateCurrentPrice(auction, currentBlock);
  }

  String getAssetName(String assetId) {
    if (assetId == 'btc' || assetId.isEmpty) return 'BTC';
    final asset = bitAssetsProvider.entries.where((e) => e.hash == assetId).firstOrNull;
    return asset?.plaintextName ?? '${assetId.substring(0, 8)}...';
  }

  Future<void> refresh() async {
    await Future.wait([
      bitAssetsProvider.fetch(),
      _fetchCurrentBlock(),
    ]);
  }

  void copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    notificationProvider.add(
      title: 'Copied',
      content: 'Auction ID copied to clipboard',
      dialogType: DialogType.success,
    );
  }

  void showBidDialog(BuildContext context, DutchAuctionEntry auction) {
    final bidController = TextEditingController();
    final theme = SailTheme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colors.background,
          title: SailText.primary15('Bid on Auction'),
          content: SizedBox(
            width: 400,
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailText.secondary13('Auction:'),
                    Expanded(
                      child: SailText.primary13(
                        '${auction.id.substring(0, 20)}...',
                        monospace: true,
                      ),
                    ),
                  ],
                ),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailText.secondary13('Current Price:'),
                    SailText.primary13(
                      '${getCurrentPrice(auction)} sats per unit',
                      bold: true,
                    ),
                  ],
                ),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailText.secondary13('Available:'),
                    SailText.primary13(
                      '${auction.baseAmount} ${getAssetName(auction.baseAsset)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SailTextField(
                  hintText: 'Bid amount in ${getAssetName(auction.quoteAsset)}',
                  controller: bidController,
                  suffix: getAssetName(auction.quoteAsset),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: SailText.primary13('Cancel'),
            ),
            SailButton(
              label: 'Place Bid',
              onPressed: () async {
                final bidAmount = int.tryParse(bidController.text);
                if (bidAmount == null || bidAmount <= 0) {
                  notificationProvider.add(
                    title: 'Invalid Bid',
                    content: 'Please enter a valid bid amount',
                    dialogType: DialogType.error,
                  );
                  return;
                }

                try {
                  final received = await rpc.dutchAuctionBid(
                    dutchAuctionId: auction.id,
                    bidSize: bidAmount,
                  );

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }

                  notificationProvider.add(
                    title: 'Bid Successful',
                    content: 'Received $received ${getAssetName(auction.baseAsset)}',
                    dialogType: DialogType.success,
                  );

                  await refresh();
                } catch (e) {
                  notificationProvider.add(
                    title: 'Bid Failed',
                    content: e.toString(),
                    dialogType: DialogType.error,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog(BuildContext context, DutchAuctionEntry auction) {
    final theme = SailTheme.of(context);
    final priceController = TextEditingController();
    final existingAlert = priceAlertProvider.getAlertsForAuction(auction.id).firstOrNull;
    bool alertWhenBelow = existingAlert?.alertWhenBelow ?? true;

    if (existingAlert != null) {
      priceController.text = existingAlert.targetPrice.toString();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme.colors.background,
              title: SailText.primary15(existingAlert != null ? 'Edit Price Alert' : 'Set Price Alert'),
              content: SizedBox(
                width: 400,
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailText.secondary13('Auction:'),
                        Expanded(
                          child: SailText.primary13(
                            '${auction.id.substring(0, 20)}...',
                            monospace: true,
                          ),
                        ),
                      ],
                    ),
                    SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailText.secondary13('Current Price:'),
                        SailText.primary13(
                          '${getCurrentPrice(auction)} sats',
                          bold: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SailTextField(
                      label: 'Target Price (sats)',
                      hintText: 'Alert when price reaches this value',
                      controller: priceController,
                    ),
                    SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailText.secondary13('Alert when price:'),
                        _AlertTypeButton(
                          label: 'Drops below',
                          isSelected: alertWhenBelow,
                          onTap: () => setState(() => alertWhenBelow = true),
                        ),
                        _AlertTypeButton(
                          label: 'Rises above',
                          isSelected: !alertWhenBelow,
                          onTap: () => setState(() => alertWhenBelow = false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                if (existingAlert != null)
                  TextButton(
                    onPressed: () async {
                      await priceAlertProvider.removeAlert(auction.id);
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                      notificationProvider.add(
                        title: 'Alert Removed',
                        content: 'Price alert has been removed',
                        dialogType: DialogType.success,
                      );
                    },
                    child: SailText.primary13('Remove Alert', color: theme.colors.error),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: SailText.primary13('Cancel'),
                ),
                SailButton(
                  label: existingAlert != null ? 'Update Alert' : 'Set Alert',
                  onPressed: () async {
                    final targetPrice = int.tryParse(priceController.text);
                    if (targetPrice == null || targetPrice <= 0) {
                      notificationProvider.add(
                        title: 'Invalid Price',
                        content: 'Please enter a valid target price',
                        dialogType: DialogType.error,
                      );
                      return;
                    }

                    final alert = PriceAlert(
                      auctionId: auction.id,
                      assetId: auction.baseAsset,
                      targetPrice: targetPrice,
                      alertWhenBelow: alertWhenBelow,
                      enabled: true,
                      createdAt: DateTime.now(),
                    );

                    if (existingAlert != null) {
                      await priceAlertProvider.updateAlert(alert);
                    } else {
                      await priceAlertProvider.addAlert(alert);
                    }

                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    notificationProvider.add(
                      title: 'Alert Set',
                      content:
                          'You will be notified when price ${alertWhenBelow ? "drops below" : "rises above"} $targetPrice sats',
                      dialogType: DialogType.success,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    bitAssetsProvider.removeListener(notifyListeners);
    analyticsProvider.removeListener(notifyListeners);
    favoritesProvider.removeListener(notifyListeners);
    priceAlertProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class _AlertTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlertTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: SailStyleValues.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.primary : theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: isSelected ? theme.colors.primary : theme.colors.divider,
          ),
        ),
        child: SailText.primary12(
          label,
          color: isSelected ? Colors.white : null,
        ),
      ),
    );
  }
}
