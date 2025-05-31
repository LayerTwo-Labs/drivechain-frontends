import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BlockExplorerDialog extends StatelessWidget {
  final NewWindowIdentifier? newWindowIdentifier;

  const BlockExplorerDialog({
    super.key,
    required this.newWindowIdentifier,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BlockExplorerViewModel>.reactive(
      viewModelBuilder: () => BlockExplorerViewModel(
        blockViewBuilder: (block) async {
          await _showBlockDetails(context, block);
        },
      ),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return SailCard(
          title: '# Blocks: ${model.blockchainProvider.infoProvider.mainchainSyncInfo?.blocks}',
          subtitle:
              'Last block time: ${model.blockchainProvider.infoProvider.mainchainSyncInfo?.lastBlockAt?.toDateTime().toLocal().format()}',
          bottomPadding: false,
          inSeparateWindow: newWindowIdentifier != null,
          newWindowIdentifier: newWindowIdentifier,
          child: Column(
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: model.searchController,
                      hintText: 'Enter a block height or hash',
                    ),
                  ),
                  SailButton(
                    onPressed: () => model.searchBlock(model.searchController.text),
                    label: 'Search',
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
              SailSpacing(SailStyleValues.padding16),
              Expanded(
                child: SizedBox(
                  width: 1200, // Match dialog max width
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: model.scrollController,
                    key: PageStorageKey('block_list'),
                    reverse: true,
                    itemCount: model.blocks.length + (model.isLoadingMoreBlocks ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (model.isLoadingMoreBlocks && index == 0) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        );
                      }
                      final adjustedIndex = model.isLoadingMoreBlocks ? index - 1 : index;
                      final block = model.blocks[adjustedIndex];
                      return Row(
                        children: [
                          _buildBlockColumn(context, block),
                          if (adjustedIndex < model.blocks.length - 1) _buildBlockConnector(context),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SailSpacing(SailStyleValues.padding16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockColumn(BuildContext context, Block block) {
    return GestureDetector(
      onDoubleTap: () => _showBlockDetails(context, block),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        decoration: BoxDecoration(
          color: context.sailTheme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(
            color: context.sailTheme.colors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.sailTheme.colors.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Block height as header
            Container(
              padding: const EdgeInsets.only(bottom: SailStyleValues.padding08),
              margin: const EdgeInsets.only(bottom: SailStyleValues.padding08),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.sailTheme.colors.divider,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.primary13(
                    '${block.height}',
                    monospace: true,
                    color: context.sailTheme.colors.info,
                  ),
                  SailText.secondary13(
                    block.blockTime.toDateTime().toLocal().format(),
                    monospace: true,
                  ),
                ],
              ),
            ),
            // Block details
            _buildValue(context, 'Hash', block.hash),
            _buildValue(context, 'Prev Hash', block.previousBlockHash),
            _buildValue(context, 'Merkle Root', block.merkleRoot),
            _buildValue(context, 'Bits', '0x${block.bits}'),
          ],
        ),
      ),
    );
  }

  Widget _buildValue(BuildContext context, String label, String value) {
    return Container(
      height: 60,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SailText.primary13(
            label,
            monospace: true,
            color: context.sailTheme.colors.textTertiary,
          ),
          SailText.secondary13(
            value,
            monospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockConnector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding04),
      child: Icon(
        Icons.chevron_left,
        size: 20,
        color: context.sailTheme.colors.textTertiary,
      ),
    );
  }

  Future<void> _showBlockDetails(BuildContext context, Block block) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'Block Details',
            subtitle: '',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'Height', value: block.height.toString()),
                  DetailRow(label: 'Hash', value: block.hash),
                  DetailRow(label: 'Confirmations', value: block.confirmations.toString()),
                  DetailRow(label: 'Block Version', value: block.version.toString()),
                  SailSpacing(SailStyleValues.padding16),
                  Container(
                    padding: const EdgeInsets.only(
                      left: SailStyleValues.padding16,
                      right: SailStyleValues.padding16,
                      top: SailStyleValues.padding04,
                      bottom: SailStyleValues.padding08,
                    ),
                    decoration: BoxDecoration(
                      color: context.sailTheme.colors.backgroundSecondary,
                      borderRadius: SailStyleValues.borderRadius,
                      border: Border.all(
                        color: context.sailTheme.colors.divider,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.sailTheme.colors.shadow.withValues(alpha: 0.1),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: context.sailTheme.colors.shadow.withValues(alpha: 0.1),
                          offset: const Offset(0, -1),
                          blurRadius: 1,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary13('Block Header'),
                        SailSpacing(SailStyleValues.padding08),
                        DetailRow(label: 'Version', value: block.version.toString()),
                        DetailRow(label: 'Previous Block Hash', value: block.previousBlockHash),
                        DetailRow(label: 'Merkle Root', value: block.merkleRoot),
                        DetailRow(label: 'Time', value: block.blockTime.seconds.toString()),
                        DetailRow(label: 'Bits', value: '0x${block.bits}'),
                        DetailRow(label: 'Nonce', value: block.nonce.toString()),
                      ],
                    ),
                  ),
                  const SailSpacing(SailStyleValues.padding16),
                  DetailRow(label: 'Median time', value: block.blockTime.seconds.toString()),
                  DetailRow(label: 'Next Block Hash', value: '0' * 64),
                  DetailRow(label: 'Chain Work', value: '${block.difficulty}'),
                  const SailSpacing(SailStyleValues.padding16),
                  SizedBox(
                    height: 300,
                    child: TXIDTransactionTable(
                      transactions: block.txids,
                      onTransactionSelected: (txid) => showTransactionDetails(context, txid),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

class BlockExplorerViewModel extends BaseViewModel {
  final MainchainRPC mainchain = GetIt.I.get<MainchainRPC>();
  final BlockchainProvider blockchainProvider = GetIt.I.get<BlockchainProvider>();
  final searchController = TextEditingController();
  late final ScrollController scrollController;
  final BitwindowRPC bitwindow = GetIt.I.get<BitwindowRPC>();

  final Future<void> Function(Block) blockViewBuilder;

  BlockExplorerViewModel({required this.blockViewBuilder}) {
    blockchainProvider.addListener(notifyListeners);
    searchController.addListener(_onSearch);
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.8) {
        loadMoreBlocks();
      }
    });
  }

  void _onSearch() {
    final search = searchController.text.trim();
    if (search.isEmpty) return;

    // If enter is pressed
    if (search.endsWith('\n')) {
      searchController.text = search.substring(0, search.length - 1);
      searchBlock(search.substring(0, search.length - 1));
    }
  }

  Future<void> searchBlock(String query) async {
    try {
      final block = await bitwindow.bitcoind.getBlock(
        height: int.tryParse(query),
        hash: int.tryParse(query) == null ? query : null,
      );
      await blockViewBuilder(block);
    } catch (e) {
      // Show error dialog
    }
  }

  List<Block> get blocks {
    return blockchainProvider.blocks;
  }

  Future<void> init() async {
    await blockchainProvider.fetch();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    blockchainProvider.removeListener(notifyListeners);
    super.dispose();
  }

  void loadMoreBlocks() {
    blockchainProvider.loadMoreBlocks();
  }

  bool get isLoadingMoreBlocks => blockchainProvider.isLoadingMoreBlocks;
}

class BlockTransaction {
  final int index;
  final String txid;

  const BlockTransaction({
    required this.index,
    required this.txid,
  });
}

class TXIDTransactionTable extends StatefulWidget {
  final List<String> transactions;
  final void Function(String txid)? onTransactionSelected;

  const TXIDTransactionTable({
    super.key,
    required this.transactions,
    this.onTransactionSelected,
  });

  @override
  State<TXIDTransactionTable> createState() => _TXIDTransactionTableState();
}

class _TXIDTransactionTableState extends State<TXIDTransactionTable> {
  String sortColumn = 'txid';
  bool sortAscending = true;
  late List<String> sortedTransactions;

  @override
  void initState() {
    super.initState();
    sortedTransactions = List.from(widget.transactions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sortTransactions();
  }

  @override
  void didUpdateWidget(TXIDTransactionTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.transactions, widget.transactions)) {
      sortedTransactions = List.from(widget.transactions);
      sortTransactions();
    }
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortTransactions();
    });
  }

  void sortTransactions() {
    if (sortColumn == 'n') {
      // Don't sort when sorting by index
      return;
    }

    sortedTransactions.sort((a, b) {
      String aValue = a;
      String bValue = b;
      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.sailTheme.colors.info,
          width: 1,
        ),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: SailTable(
        backgroundColor: context.sailTheme.colors.background,
        altBackgroundColor: context.sailTheme.colors.backgroundSecondary,
        getRowId: (index) => widget.transactions[index],
        onDoubleTap: widget.onTransactionSelected != null ? (rowId) => widget.onTransactionSelected!(rowId) : null,
        headerBuilder: (context) => [
          SailTableHeaderCell(
            name: 'n',
            onSort: () => onSort('n'),
          ),
          SailTableHeaderCell(
            name: 'txid',
            onSort: () => onSort('txid'),
          ),
        ],
        rowBuilder: (context, index, selected) => [
          SailTableCell(value: index.toString()),
          SailTableCell(value: widget.transactions[index]),
        ],
        rowCount: widget.transactions.length,
      ),
    );
  }
}

class TransactionDetailsDialog extends StatefulWidget {
  final String txid;

  const TransactionDetailsDialog({
    super.key,
    required this.txid,
  });

  @override
  State<TransactionDetailsDialog> createState() => _TransactionDetailsDialogState();
}

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> {
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();

  GetRawTransactionResponse? transaction;
  String? error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTransaction() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      error = null;
    });

    try {
      final tx = await bitwindow.bitcoind.getRawTransaction(widget.txid);

      if (!mounted) return;
      setState(() {
        transaction = tx;
        error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        transaction = null;
        error = 'Failed to load transaction: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SailCard(
          title: 'Transaction Details',
          subtitle: widget.txid,
          error: error,
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(SailStyleValues.padding16),
                    child: CircularProgressIndicator(),
                  ),
                )
              : transaction == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(SailStyleValues.padding16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SailText.primary13('Failed to load transaction details'),
                            if (error != null) SailText.secondary13(error!),
                            SailButton(
                              onPressed: _loadTransaction,
                              label: 'Retry',
                              variant: ButtonVariant.primary,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(context, '# Inputs', '${transaction!.inputs.length}'),
                          _buildDetailRow(context, '# Outputs', '${transaction!.outputs.length}'),
                          _buildDetailRow(context, 'Size', '${transaction!.size} bytes'),
                          _buildDetailRow(context, 'Virtual Size', '${transaction!.vsize} vbytes'),
                          _buildDetailRow(context, 'Weight', '${transaction!.weight} wu'),
                          _buildDetailRow(context, 'Block Hash', transaction!.blockhash),
                          _buildDetailRow(context, 'Confirmations', '${transaction!.confirmations}'),
                          _buildDetailRow(context, 'Lock Time', '${transaction!.locktime}'),
                          if (transaction!.inputs.any((input) => input.coinbase.isNotEmpty))
                            SailText.primary13('This is a coinbase transaction.'),
                          const SailSpacing(SailStyleValues.padding16),
                          SailText.primary13('Decoded from transaction outputs:'),
                          const SailSpacing(SailStyleValues.padding08),
                          _buildDecodedOutputsTable(context),
                          const SailSpacing(SailStyleValues.padding16),
                          BorderedSection(
                            title: 'Transaction To String:',
                            child: SailText.secondary13(
                              transaction!.toString(),
                            ),
                          ),
                          const SailSpacing(SailStyleValues.padding16),
                          BorderedSection(
                            title: 'Raw Transaction Hex',
                            child: SailText.secondary13(
                              transaction!.tx.hex,
                              monospace: true,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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
              color: context.sailTheme.colors.inactiveNavText,
            ),
          ),
          Expanded(
            child: SailText.secondary13(
              value,
              monospace: true,
              color: context.sailTheme.colors.inactiveNavText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecodedOutputsTable(BuildContext context) {
    return SizedBox(
      height: 200, // Fixed height for the table
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.sailTheme.colors.divider,
            width: 1,
          ),
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: SailTable(
          backgroundColor: context.sailTheme.colors.background,
          altBackgroundColor: context.sailTheme.colors.backgroundSecondary,
          getRowId: (index) => '${transaction!.outputs[index].vout}',
          headerBuilder: (context) => [
            SailTableHeaderCell(name: 'Type'),
            SailTableHeaderCell(name: 'Details'),
          ],
          rowBuilder: (context, index, selected) {
            final output = transaction!.outputs[index];
            return [
              SailTableCell(value: output.scriptPubKey.type),
              SailTableCell(value: output.scriptSig.asm),
            ];
          },
          rowCount: transaction!.outputs.length,
        ),
      ),
    );
  }
}

class BorderedSection extends StatelessWidget {
  final String title;
  final Widget child;

  const BorderedSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13(title),
        const SailSpacing(SailStyleValues.padding08),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.sailTheme.colors.divider,
              width: 1,
            ),
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            child: child,
          ),
        ),
      ],
    );
  }
}

Future<void> showTransactionDetails(BuildContext context, String txid) async {
  // Ensure we're running on a new frame
  await Future.microtask(() async {
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            // You can handle pop result here if needed
          },
          child: TransactionDetailsDialog(
            txid: txid,
          ),
        );
      },
    );
  });
}
