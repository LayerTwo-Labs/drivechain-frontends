import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BlockExplorerDialog extends StatelessWidget {
  const BlockExplorerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 600),
        child: ViewModelBuilder<BlockExplorerViewModel>.reactive(
          viewModelBuilder: () => BlockExplorerViewModel(
            blockViewBuilder: (block) async {
              await _showBlockDetails(context, block);
            },
          ),
          onViewModelReady: (model) => model.init(),
          builder: (context, model, child) {
            return SailRawCard(
              title: '# Blocks: ${model.blockchainProvider.infoService.blockchainInfo.blocks}',
              subtitle:
                  'Last block time: ${DateTime.fromMillisecondsSinceEpoch(model.blockchainProvider.infoService.blockchainInfo.time * 1000).format()}',
              bottomPadding: false,
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
                      QtButton(
                        onPressed: () => model.searchBlock(model.searchController.text),
                        label: 'Search',
                        size: ButtonSize.small,
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
        ),
      ),
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
          borderRadius: BorderRadius.circular(8),
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
                    block.blockTime.toDateTime().format(),
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
          child: SailRawCard(
            title: 'Block Details',
            subtitle: '',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(context, 'Height', block.height.toString()),
                _buildDetailRow(context, 'Hash', block.hash),
                _buildDetailRow(context, 'Confirmations', block.confirmations.toString()),
                _buildDetailRow(context, 'Block Version', block.version.toString()),
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
                    borderRadius: BorderRadius.circular(8),
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
                      _buildDetailRow(context, 'Version', block.version.toString()),
                      _buildDetailRow(context, 'Previous Block Hash', block.previousBlockHash),
                      _buildDetailRow(context, 'Merkle Root', block.merkleRoot),
                      _buildDetailRow(context, 'Time', block.blockTime.seconds.toString()),
                      _buildDetailRow(context, 'Bits', '0x${block.bits}'),
                      _buildDetailRow(context, 'Nonce', block.nonce.toString()),
                    ],
                  ),
                ),
                const SailSpacing(SailStyleValues.padding16),
                _buildDetailRow(context, 'Median time', block.blockTime.seconds.toString()),
                _buildDetailRow(context, 'Next Block Hash', '0' * 64),
                _buildDetailRow(context, 'Chain Work', '${block.difficulty}'),
                const SailSpacing(SailStyleValues.padding16),
                SizedBox(
                  height: 300,
                  child: TransactionTable(
                    transactions: block.txids,
                    onTransactionSelected: (txid) => _showTransactionDetails(context, txid),
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

  void _showTransactionDetails(BuildContext context, String txid) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        txid: txid,
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

class TransactionTable extends StatefulWidget {
  final List<String> transactions;
  final void Function(String txid)? onTransactionSelected;

  const TransactionTable({
    super.key,
    required this.transactions,
    this.onTransactionSelected,
  });

  @override
  State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
  String sortColumn = 'n';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sortTransactions();
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
    widget.transactions.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'txid':
          aValue = a;
          bValue = b;
          break;
      }

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
        borderRadius: BorderRadius.circular(8),
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
        columnWidths: const [50, 500],
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

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      final tx = await bitwindow.bitcoind.getRawTransaction(widget.txid);
      if (mounted) {
        setState(() {
          transaction = tx;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SailRawCard(
          title: 'Transaction Details',
          subtitle: error ?? '',
          child: transaction == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(context, 'Hash', transaction!.txid),
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

  Widget _buildDecodedOutputsTable(BuildContext context) {
    return SizedBox(
      height: 200, // Fixed height for the table
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.sailTheme.colors.divider,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
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
          columnWidths: const [70, 300],
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
            borderRadius: BorderRadius.circular(8),
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
