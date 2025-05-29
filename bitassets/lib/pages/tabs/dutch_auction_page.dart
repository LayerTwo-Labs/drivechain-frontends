import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class DutchAuctionTabPage extends StatelessWidget {
  const DutchAuctionTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final createAuctionKey = GlobalKey();

    return QtPage(
      child: ViewModelBuilder<DutchAuctionViewModel>.reactive(
        viewModelBuilder: () => DutchAuctionViewModel(),
        builder: (context, model, child) {
          return SingleChildScrollView(
            controller: scrollController,
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                SailCard(
                  title: 'Active Dutch Auctions',
                  subtitle: 'View all ongoing dutch auctions',
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    children: [
                      SailRow(
                        spacing: SailStyleValues.padding16,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: SailTextField(
                              hintText: 'Search auctions...',
                              controller: model.searchController,
                            ),
                          ),
                          SailButton(
                            label: 'Create New Auction',
                            onPressed: () async {
                              await Scrollable.ensureVisible(
                                createAuctionKey.currentContext!,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 300,
                        child: SailSkeletonizer(
                          description: 'Loading auctions...',
                          enabled: model.isLoading,
                          child: SailTable(
                            getRowId: (index) => model.filteredAuctions[index].id,
                            headerBuilder: (context) => [
                              SailTableHeaderCell(name: 'ID'),
                              SailTableHeaderCell(name: 'Base Asset'),
                              SailTableHeaderCell(name: 'Quote Asset'),
                              SailTableHeaderCell(name: 'Base Amount'),
                              SailTableHeaderCell(name: 'Current Price'),
                              SailTableHeaderCell(name: 'Status'),
                            ],
                            rowBuilder: (context, row, selected) {
                              final auction = model.filteredAuctions[row];
                              final shortId = '${auction.id.substring(0, 10)}..';
                              return [
                                SailTableCell(
                                  value: shortId,
                                  copyValue: auction.id,
                                ),
                                SailTableCell(value: auction.baseAsset),
                                SailTableCell(value: auction.quoteAsset),
                                SailTableCell(value: auction.baseAmount.toString()),
                                SailTableCell(value: auction.currentPrice?.toString() ?? 'N/A'),
                                SailTableCell(value: auction.status),
                              ];
                            },
                            contextMenuItems: (rowId) {
                              final auction = model.filteredAuctions.firstWhere((a) => a.id == rowId);
                              return [
                                SailMenuItem(
                                  onSelected: () async {
                                    await showAuctionDetails(context, auction);
                                  },
                                  child: SailText.primary12('Show Details'),
                                ),
                                SailMenuItem(
                                  onSelected: () async {
                                    await showBidDialog(context, auction, model);
                                  },
                                  child: SailText.primary12('Place Bid'),
                                ),
                              ];
                            },
                            rowCount: model.filteredAuctions.length,
                            columnWidths: const [120, 120, 120, 120, 120, 100],
                            drawGrid: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SailCard(
                  key: createAuctionKey,
                  title: 'Create Dutch Auction',
                  subtitle: 'Create a new dutch auction',
                  error: model.createError,
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    children: [
                      SailRow(
                        spacing: SailStyleValues.padding16,
                        children: [
                          Expanded(
                            child: SailTextField(
                              label: 'Base Asset ID',
                              hintText: 'Asset to auction',
                              controller: model.baseAssetController,
                            ),
                          ),
                          Expanded(
                            child: SailTextField(
                              label: 'Quote Asset ID',
                              hintText: 'Quote asset',
                              controller: model.quoteAssetController,
                            ),
                          ),
                        ],
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding16,
                        children: [
                          Expanded(
                            child: SailTextField(
                              label: 'Base Amount',
                              hintText: 'Amount to auction',
                              controller: model.baseAmountController,
                            ),
                          ),
                          Expanded(
                            child: SailTextField(
                              label: 'Start Block',
                              hintText: 'Block to start auction',
                              controller: model.startBlockController,
                            ),
                          ),
                        ],
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding16,
                        children: [
                          Expanded(
                            child: SailTextField(
                              label: 'Duration (blocks)',
                              hintText: 'Auction duration',
                              controller: model.durationController,
                            ),
                          ),
                          Expanded(
                            child: SailTextField(
                              label: 'Initial Price',
                              hintText: 'Starting price',
                              controller: model.initialPriceController,
                            ),
                          ),
                        ],
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding16,
                        children: [
                          Expanded(
                            child: SailTextField(
                              label: 'Final Price',
                              hintText: 'Ending price',
                              controller: model.finalPriceController,
                            ),
                          ),
                          Expanded(child: Container()), // Spacer
                        ],
                      ),
                      SailButton(
                        label: 'Create Auction',
                        onPressed: model.createLoading ? null : () => model.createDutchAuction(context),
                        loading: model.createLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> showAuctionDetails(BuildContext context, DutchAuctionEntry auction) async {
  await Future.microtask(() async {
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SailCard(
                title: 'Dutch Auction Details',
                subtitle: auction.id,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailRow(label: 'ID', value: auction.id),
                      DetailRow(label: 'Base Asset', value: auction.baseAsset),
                      DetailRow(label: 'Quote Asset', value: auction.quoteAsset),
                      DetailRow(label: 'Base Amount', value: auction.baseAmount.toString()),
                      DetailRow(label: 'Initial Price', value: auction.initialPrice.toString()),
                      DetailRow(label: 'Final Price', value: auction.finalPrice.toString()),
                      DetailRow(label: 'Start Block', value: auction.startBlock.toString()),
                      DetailRow(label: 'Duration', value: auction.duration.toString()),
                      DetailRow(label: 'Status', value: auction.status),
                      if (auction.currentPrice != null)
                        DetailRow(label: 'Current Price', value: auction.currentPrice.toString()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  });
}

Future<void> showBidDialog(BuildContext context, DutchAuctionEntry auction, DutchAuctionViewModel model) async {
  final bidController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SailCard(
            title: 'Place Bid',
            subtitle: 'Auction: ${auction.id.substring(0, 10)}...',
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                SailTextField(
                  label: 'Bid Size',
                  hintText: 'Amount to bid',
                  controller: bidController,
                ),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Expanded(
                      child: SailButton(
                        label: 'Cancel',
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ),
                    Expanded(
                      child: SailButton(
                        label: 'Place Bid',
                        onPressed: () async {
                          final bidSize = int.tryParse(bidController.text);
                          if (bidSize != null) {
                            Navigator.of(dialogContext).pop();
                            await model.placeBid(context, auction.id, bidSize);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
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
            width: 120,
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

class DutchAuctionViewModel extends BaseViewModel {
  final BalanceProvider balanceProvider = GetIt.I.get<BalanceProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();
  final BitAssetsRPC bitassetsRPC = GetIt.I.get<BitAssetsRPC>();
  final BitAssetsProvider bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController baseAssetController = TextEditingController();
  final TextEditingController quoteAssetController = TextEditingController();
  final TextEditingController baseAmountController = TextEditingController();
  final TextEditingController startBlockController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController initialPriceController = TextEditingController();
  final TextEditingController finalPriceController = TextEditingController();

  bool createLoading = false;
  String? createError;

  DutchAuctionViewModel() {
    searchController.addListener(notifyListeners);
    bitAssetsProvider.addListener(notifyListeners);
    bitAssetsProvider.fetch();
  }

  List<DutchAuctionEntry> get filteredAuctions {
    final searchText = searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return bitAssetsProvider.auctions;
    }

    return bitAssetsProvider.auctions.where((auction) {
      return auction.id.toLowerCase().contains(searchText) ||
          auction.baseAsset.toLowerCase().contains(searchText) ||
          auction.quoteAsset.toLowerCase().contains(searchText) ||
          auction.status.toLowerCase().contains(searchText);
    }).toList();
  }

  bool get isLoading => bitAssetsProvider.isLoadingAuctions;

  Future<void> createDutchAuction(BuildContext context) async {
    createError = null;

    // Validate inputs
    final baseAsset = baseAssetController.text.trim();
    final quoteAsset = quoteAssetController.text.trim();
    final baseAmount = int.tryParse(baseAmountController.text.trim());
    final startBlock = int.tryParse(startBlockController.text.trim());
    final duration = int.tryParse(durationController.text.trim());
    final initialPrice = int.tryParse(initialPriceController.text.trim());
    final finalPrice = int.tryParse(finalPriceController.text.trim());

    if (baseAsset.isEmpty ||
        quoteAsset.isEmpty ||
        baseAmount == null ||
        startBlock == null ||
        duration == null ||
        initialPrice == null ||
        finalPrice == null) {
      createError = 'All fields are required and must be valid numbers';
      notifyListeners();
      return;
    }

    createLoading = true;
    notifyListeners();

    try {
      final auctionId = await bitassetsRPC.dutchAuctionCreate(
        DutchAuctionParams(
          baseAsset: baseAsset,
          quoteAsset: quoteAsset,
          baseAmount: baseAmount,
          startBlock: startBlock,
          duration: duration,
          initialPrice: initialPrice,
          finalPrice: finalPrice,
        ),
      );

      if (context.mounted) {
        notificationProvider.add(
          title: 'Success',
          content: 'Dutch auction created successfully: $auctionId',
          dialogType: DialogType.success,
        );
      }

      // Clear form
      baseAssetController.clear();
      quoteAssetController.clear();
      baseAmountController.clear();
      startBlockController.clear();
      durationController.clear();
      initialPriceController.clear();
      finalPriceController.clear();

      // Refresh auctions
      await bitAssetsProvider.fetch();
    } catch (e) {
      createError = e.toString();
    } finally {
      createLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeBid(BuildContext context, String auctionId, int bidSize) async {
    try {
      final result = await bitassetsRPC.dutchAuctionBid(dutchAuctionId: auctionId, bidSize: bidSize);

      if (context.mounted) {
        notificationProvider.add(
          title: 'Success',
          content: 'Bid placed successfully. You will receive $result base asset',
          dialogType: DialogType.success,
        );
      }

      await bitAssetsProvider.fetch();
    } catch (e) {
      if (context.mounted) {
        notificationProvider.add(
          title: 'Error',
          content: 'Failed to place bid: $e',
          dialogType: DialogType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    baseAssetController.dispose();
    quoteAssetController.dispose();
    baseAmountController.dispose();
    startBlockController.dispose();
    durationController.dispose();
    initialPriceController.dispose();
    finalPriceController.dispose();
    bitAssetsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
