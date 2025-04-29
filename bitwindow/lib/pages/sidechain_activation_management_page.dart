import 'package:auto_route/annotations.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/sidechain_proposal_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainActivationManagementPage extends StatelessWidget {
  const SidechainActivationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SidechainActivationManagementViewModel>.reactive(
      viewModelBuilder: () => SidechainActivationManagementViewModel(),
      builder: (context, model, child) => const SidechainActivationManagementView(),
    );
  }
}

class SidechainActivationManagementViewModel extends BaseViewModel {
  final SidechainProvider sidechainProvider = GetIt.I.get<SidechainProvider>();

  List<SidechainOverview?> get activeSidechains =>
      sidechainProvider.sidechains.where((sidechain) => sidechain != null).toList();

  List<SidechainProposal> get sidechainProposals => sidechainProvider.sidechainProposals;

  SidechainActivationManagementViewModel() {
    sidechainProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    sidechainProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class SidechainActivationManagementView extends StatelessWidget {
  const SidechainActivationManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SidechainActivationManagementViewModel>.reactive(
      viewModelBuilder: () => SidechainActivationManagementViewModel(),
      builder: (context, model, child) => SailCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary12('Escrow Status (Active Sidechains)'),
            const SizedBox(height: SailStyleValues.padding08),
            Container(
              decoration: BoxDecoration(
                color: context.sailTheme.colors.background,
                border: Border.all(
                  color: context.sailTheme.colors.divider,
                  width: 1.0,
                ),
                borderRadius: SailStyleValues.borderRadius,
              ),
              height: 150,
              child: ActiveSidechainsTable(blocks: model.activeSidechains),
            ),
            const SizedBox(height: SailStyleValues.padding16),
            SailText.primary12('Pending Sidechain Proposals'),
            const SizedBox(height: SailStyleValues.padding08),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.sailTheme.colors.background,
                border: Border.all(
                  color: context.sailTheme.colors.divider,
                  width: 1.0,
                ),
                borderRadius: SailStyleValues.borderRadius,
              ),
              height: 150,
              child: PendingSidechainProposalsTable(proposals: model.sidechainProposals),
            ),
            SailSpacing(SailStyleValues.padding08),
            SailButton(
              onPressed: () async {
                await showSidechainProposalModal(context);
              },
              label: 'Create Sidechain Proposal',
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveSidechainsTable extends StatefulWidget {
  final List<SidechainOverview?> blocks;

  const ActiveSidechainsTable({
    super.key,
    required this.blocks,
  });

  @override
  State<ActiveSidechainsTable> createState() => _ActiveSidechainsTableState();
}

class _ActiveSidechainsTableState extends State<ActiveSidechainsTable> {
  String sortColumn = 'slot';
  bool sortAscending = true;
  List<SidechainOverview?> blocks = [];

  @override
  void initState() {
    super.initState();
    blocks = widget.blocks;
    sortBlocks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!listEquals(blocks, widget.blocks)) {
      blocks = widget.blocks;
      sortBlocks();
    }
  }

  void onSort(String column) {
    if (column == sortColumn) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortBlocks();
    setState(() {});
  }

  void sortBlocks() {
    blocks.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'slot':
          aValue = a?.info.slot;
          bValue = b?.info.slot;
          break;
        case 'name':
          aValue = a?.info.title;
          bValue = b?.info.title;
          break;
        case 'chaintipTxid':
          aValue = a?.info.chaintipTxid;
          bValue = b?.info.chaintipTxid;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => blocks[index]?.info.chaintipTxid ?? '',
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: '#'),
        const SailTableHeaderCell(name: 'Active'),
        const SailTableHeaderCell(name: 'Name'),
        const SailTableHeaderCell(name: 'CTIP TxID'),
      ],
      rowBuilder: (context, row, selected) {
        final sidechain = blocks[row];
        return [
          SailTableCell(value: '${sidechain?.info.slot}'),
          const SailTableCell(value: 'Yes'),
          SailTableCell(value: sidechain?.info.title ?? ''),
          SailTableCell(
            value: sidechain?.info.chaintipTxid.isEmpty ?? true ? 'N/A' : sidechain?.info.chaintipTxid ?? '',
          ),
        ];
      },
      rowCount: blocks.length,
      columnWidths: const [50, 100, 100, 500],
      sortColumnIndex: ['slot', 'active', 'name', 'chaintipTxid'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['slot', 'active', 'name', 'chaintipTxid'][columnIndex]);
      },
      onDoubleTap: (rowId) => showTransactionDetails(context, rowId),
      contextMenuItems: (rowId) {
        return [
          SailMenuItem(
            onSelected: () => showTransactionDetails(context, rowId),
            child: SailText.primary12('Show Chaintip Transaction'),
          ),
        ];
      },
    );
  }
}

Future<void> showSidechainActivationManagementModal(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return showDialog<void>(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
              maxHeight: size.height * 0.8,
            ),
            child: const SidechainActivationManagementPage(),
          ),
        ),
      );
    },
  );
}

class PendingSidechainProposalsTable extends StatefulWidget {
  final List<SidechainProposal> proposals;

  const PendingSidechainProposalsTable({
    super.key,
    required this.proposals,
  });

  @override
  State<PendingSidechainProposalsTable> createState() => _PendingSidechainProposalsTableState();
}

class _PendingSidechainProposalsTableState extends State<PendingSidechainProposalsTable> {
  String sortColumn = 'slot';
  bool sortAscending = true;
  List<SidechainProposal> proposals = [];

  @override
  void initState() {
    super.initState();
    proposals = widget.proposals;
    sortProposals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!listEquals(proposals, widget.proposals)) {
      proposals = widget.proposals;
      sortProposals();
    }
  }

  void onSort(String column) {
    if (column == sortColumn) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortProposals();
    setState(() {});
  }

  void sortProposals() {
    proposals.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'slot':
          aValue = a.slot;
          bValue = b.slot;
          break;
        case 'voteCount':
          aValue = a.voteCount;
          bValue = b.voteCount;
          break;
        /*case 'replacement':
          aValue = a.replacement;
          bValue = b.replacement;
          break;*/
        /*case 'title':
          aValue = a.title;
          bValue = b.title;
          break;*/
        /*case 'description':
          aValue = a.description;
          bValue = b.description;
          break;*/
        case 'age':
          aValue = a.proposalAge;
          bValue = b.proposalAge;
          break;
        case 'fails':
          aValue = a.proposalHeight;
          bValue = b.proposalHeight;
          break;
        case 'hash':
          aValue = a.dataHash;
          bValue = b.dataHash;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.proposals[index].slot.toString(),
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'Vote'),
        const SailTableHeaderCell(name: 'SC #'),
        const SailTableHeaderCell(name: 'Replacement'),
        const SailTableHeaderCell(name: 'Title'),
        const SailTableHeaderCell(name: 'Description'),
        const SailTableHeaderCell(name: 'Age'),
        const SailTableHeaderCell(name: 'Fails'),
        const SailTableHeaderCell(name: 'Hash'),
      ],
      rowBuilder: (context, row, selected) {
        final proposal = widget.proposals[row];
        return [
          SailTableCell(value: proposal.voteCount.toString()),
          SailTableCell(value: proposal.slot.toString()),
          const SailTableCell(value: 'Replacement'),
          SailTableCell(value: proposal.data.toString()),
          const SailTableCell(value: 'Description'),
          SailTableCell(value: proposal.proposalAge.toString()),
          SailTableCell(value: proposal.proposalHeight.toString()),
          SailTableCell(value: proposal.dataHash),
        ];
      },
      rowCount: widget.proposals.length,
      columnWidths: const [50, 50, 100, 100, 150, 50, 50, 200],
      sortColumnIndex: ['voteCount', 'slot', 'age', 'fails', 'hash'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['voteCount', 'slot', 'age', 'fails', 'hash'][columnIndex]);
      },
    );
  }
}
