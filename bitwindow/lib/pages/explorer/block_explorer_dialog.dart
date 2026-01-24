import 'package:bitwindow/dialogs/merkle_tree_dialog.dart';
import 'package:bitwindow/pages/explorer/widgets/transaction_flow_diagram.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BlockExplorerDialog extends StatelessWidget {
  const BlockExplorerDialog({
    super.key,
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
          title: '# Blocks: ${model.blockchainProvider.syncProvider.mainchainSyncInfo?.progressCurrent.toInt()}',
          subtitle:
              'Last block time: ${model.blockchainProvider.syncProvider.mainchainSyncInfo?.lastBlockAt?.toDateTime().toLocal().format()}',
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
                          _BlockColumn(
                            block: block,
                            onDoubleTap: () => _showBlockDetails(context, block),
                          ),
                          if (adjustedIndex < model.blocks.length - 1) const _BlockConnector(),
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
                  const SailSpacing(SailStyleValues.padding16),
                  // Merkle Tree Viewer Button
                  SailButton(
                    label: 'View Merkle Tree',
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => MerkleTreeDialog(
                          initialTxids: block.txids,
                          expectedRoot: block.merkleRoot,
                        ),
                      );
                    },
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
      // the bitcoind rpc `getblock` returns a slightly
      // different data model than the bitwindowd rpc `listblocks`
      final converted = Block(
        hash: block.hash,
        height: block.height,
        blockTime: block.time,
        merkleRoot: block.merkleRoot,
        version: block.version,
        previousBlockHash: block.previousBlockHash,
        nonce: block.nonce,
        bits: block.bits,
        difficulty: block.difficulty,
        txids: block.txids,
        confirmations: block.confirmations,
        size: block.size,
        weight: block.weight,
        versionHex: block.versionHex,
        nextBlockHash: block.nextBlockHash,
        strippedSize: block.strippedSize,
      );
      await blockViewBuilder(converted);
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
        emptyPlaceholder: 'No transactions in block',
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

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> with SingleTickerProviderStateMixin {
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();

  late TabController _tabController;
  GetTransactionDetailsResponse? _details;
  String? error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTransaction();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransaction() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      error = null;
    });

    try {
      final details = await bitwindow.wallet.getTransactionDetails(widget.txid);

      if (!mounted) return;
      setState(() {
        _details = details;
        error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _details = null;
        error = 'Failed to load transaction: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
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
              : _details == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(SailStyleValues.padding16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SailText.primary13('Failed to load transaction details'),
                        if (error != null) SailText.secondary13(error!),
                        const SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          onPressed: _loadTransaction,
                          label: 'Retry',
                          variant: ButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: theme.colors.text,
                      unselectedLabelColor: theme.colors.textTertiary,
                      indicatorColor: theme.colors.info,
                      tabs: [
                        const Tab(text: 'Overview'),
                        Tab(text: 'Inputs (${_details!.inputs.length})'),
                        Tab(text: 'Outputs (${_details!.outputs.length})'),
                        const Tab(text: 'Hex'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _OverviewTab(details: _details!),
                          _InputsTab(inputs: _details!.inputs),
                          _OutputsTab(outputs: _details!.outputs),
                          _HexTab(hex: _details!.hex),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final GetTransactionDetailsResponse details;

  const _OverviewTab({required this.details});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Flow Diagram
          TransactionFlowDiagram(details: details),

          const SailSpacing(SailStyleValues.padding16),

          // Header Info
          SailText.primary13('Transaction Info'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(label: 'TXID', value: details.txid),
          DetailRow(label: 'Block Hash', value: details.blockhash.isEmpty ? 'Unconfirmed' : details.blockhash),
          DetailRow(label: 'Confirmations', value: '${details.confirmations}'),
          DetailRow(label: 'Version', value: '${details.version}'),
          DetailRow(label: 'Lock Time', value: '${details.locktime}'),

          const SailSpacing(SailStyleValues.padding16),

          // Size Info
          SailText.primary13('Size'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(label: 'Size', value: '${details.sizeBytes} bytes'),
          DetailRow(label: 'Virtual Size', value: '${details.vsizeVbytes} vbytes'),
          DetailRow(label: 'Weight', value: '${details.weightWu} WU'),

          const SailSpacing(SailStyleValues.padding16),

          // Fee Info
          SailText.primary13('Fee'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(label: 'Fee', value: formatter.formatSats(details.feeSats.toInt())),
          DetailRow(label: 'Fee Rate', value: '${details.feeRateSatVb.toStringAsFixed(2)} sat/vB'),

          const SailSpacing(SailStyleValues.padding16),

          // Totals
          SailText.primary13('Totals'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(label: 'Total Input', value: formatter.formatSats(details.totalInputSats.toInt())),
          DetailRow(label: 'Total Output', value: formatter.formatSats(details.totalOutputSats.toInt())),
        ],
      ),
    );
  }
}

class _InputsTab extends StatelessWidget {
  final List<TransactionInput> inputs;

  const _InputsTab({required this.inputs});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SailTable(
      getRowId: (i) => '${inputs[i].prevTxid}:${inputs[i].prevVout}',
      headerBuilder: (_) => [
        SailTableHeaderCell(name: '#'),
        SailTableHeaderCell(name: 'Amount'),
        SailTableHeaderCell(name: 'Address'),
        SailTableHeaderCell(name: 'Previous Output'),
        SailTableHeaderCell(name: 'Sequence'),
      ],
      rowBuilder: (_, i, _) {
        final input = inputs[i];
        final prevOutput = input.isCoinbase ? 'Coinbase' : '${input.prevTxid.substring(0, 8)}...:${input.prevVout}';

        return [
          SailTableCell(value: '${input.index}'),
          SailTableCell(
            value: input.isCoinbase ? 'N/A' : formatter.formatSats(input.valueSats.toInt()),
            monospace: true,
          ),
          SailTableCell(
            value: input.isCoinbase ? 'Coinbase' : (input.address.isEmpty ? 'Unknown' : input.address),
            monospace: true,
            copyValue: input.address,
          ),
          SailTableCell(
            value: prevOutput,
            monospace: true,
            copyValue: input.isCoinbase ? null : '${input.prevTxid}:${input.prevVout}',
          ),
          SailTableCell(value: '${input.sequence}', monospace: true),
        ];
      },
      rowCount: inputs.length,
      emptyPlaceholder: 'No inputs',
    );
  }
}

class _OutputsTab extends StatelessWidget {
  final List<TransactionOutput> outputs;

  const _OutputsTab({required this.outputs});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SailTable(
      getRowId: (i) => '${outputs[i].index}',
      headerBuilder: (_) => [
        SailTableHeaderCell(name: '#'),
        SailTableHeaderCell(name: 'Amount'),
        SailTableHeaderCell(name: 'Address'),
        SailTableHeaderCell(name: 'Type'),
      ],
      rowBuilder: (_, i, _) {
        final output = outputs[i];
        return [
          SailTableCell(value: '${output.index}'),
          SailTableCell(
            value: formatter.formatSats(output.valueSats.toInt()),
            monospace: true,
          ),
          SailTableCell(
            value: output.address.isEmpty
                ? (output.scriptType == 'nulldata' ? 'OP_RETURN' : 'Unknown')
                : output.address,
            monospace: true,
            copyValue: output.address.isNotEmpty ? output.address : null,
          ),
          SailTableCell(value: output.scriptType),
        ];
      },
      rowCount: outputs.length,
      emptyPlaceholder: 'No outputs',
    );
  }
}

class _HexTab extends StatelessWidget {
  final String hex;

  const _HexTab({required this.hex});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailText.primary13('Raw Transaction Hex'),
              SailButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: hex));
                  if (context.mounted) {
                    showSnackBar(context, 'Copied to clipboard');
                  }
                },
                label: 'Copy',
                small: true,
              ),
            ],
          ),
          const SailSpacing(SailStyleValues.padding08),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: context.sailTheme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadius,
              border: Border.all(color: context.sailTheme.colors.divider),
            ),
            child: SelectableText(
              hex.isEmpty ? 'No hex data available' : hex,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: context.sailTheme.colors.text,
              ),
            ),
          ),
        ],
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

class _BlockColumn extends StatelessWidget {
  final Block block;
  final VoidCallback onDoubleTap;

  const _BlockColumn({
    required this.block,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
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
            BlockValue(label: 'Hash', value: block.hash),
            BlockValue(label: 'Prev Hash', value: block.previousBlockHash),
            BlockValue(label: 'Merkle Root', value: block.merkleRoot),
            BlockValue(label: 'Bits', value: '0x${block.bits}'),
          ],
        ),
      ),
    );
  }
}

class _BlockConnector extends StatelessWidget {
  const _BlockConnector();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding04),
      child: Icon(
        Icons.chevron_left,
        size: 20,
        color: context.sailTheme.colors.textTertiary,
      ),
    );
  }
}
