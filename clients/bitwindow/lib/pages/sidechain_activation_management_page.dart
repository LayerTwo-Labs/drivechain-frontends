import 'package:auto_route/annotations.dart';
import 'package:bitwindow/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:bitwindow/pages/sidechain_proposal_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/widgets/qt_button.dart';
import 'package:bitwindow/widgets/qt_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/containers/qt_page.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainActivationManagementPage extends StatelessWidget {
  const SidechainActivationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SidechainActivationManagementViewModel>.reactive(
      viewModelBuilder: () => SidechainActivationManagementViewModel(),
      builder: (context, model, child) => QtPage(
        child: SidechainActivationManagementView(),
      ),
    );
  }
}

class SidechainActivationManagementViewModel extends BaseViewModel {
  final SidechainProvider sidechainProvider = GetIt.I.get<SidechainProvider>();

  List<ListSidechainsResponse_Sidechain> get activeSidechains => sidechainProvider.sidechains
      .where((sidechain) => sidechain != null)
      .cast<ListSidechainsResponse_Sidechain>()
      .toList();

  List<SidechainProposal> get sidechainProposals => sidechainProvider.sidechainProposals;

  SidechainActivationManagementViewModel() {
    sidechainProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    sidechainProvider.removeListener(notifyListeners);
    super.dispose();
  }

  // TODO: Implement the actual API call to ACK the sidechain
  void ack(BuildContext context) {
    showSnackBar(context, 'ACK not implemented');
  }

  // TODO: Implement the actual API call to NACK the sidechain
  void nack(BuildContext context) {
    showSnackBar(context, 'NACK not implemented');
  }
}

class SidechainActivationManagementView extends StatelessWidget {
  const SidechainActivationManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SidechainActivationManagementViewModel>.reactive(
      viewModelBuilder: () => SidechainActivationManagementViewModel(),
      builder: (context, model, child) => Column(
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
              borderRadius: BorderRadius.circular(4.0),
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
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: 150,
            child: PendingSidechainProposalsTable(proposals: model.sidechainProposals),
          ),
          const SizedBox(height: SailStyleValues.padding32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  QtButton(
                    onPressed: () => model.ack(context),
                    child: SailText.primary13('ACK'),
                  ),
                  const SizedBox(width: SailStyleValues.padding16),
                  QtButton(
                    onPressed: () => model.nack(context),
                    child: SailText.primary13('NACK'),
                  ),
                ],
              ),
              Row(
                children: [
                  QtButton(
                    onPressed: () {
                      showSidechainProposalModal(context);
                    },
                    child: SailText.primary13('Create Sidechain Proposal'),
                  ),
                  const SizedBox(width: SailStyleValues.padding16),
                  QtIconButton(
                    tooltip: 'What is this?',
                    icon: const Icon(Icons.question_mark_rounded, size: 13),
                    onPressed: () {
                      showSnackBar(context, 'Not implemented');
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActiveSidechainsTable extends StatefulWidget {
  final List<ListSidechainsResponse_Sidechain> blocks;

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
  List<ListSidechainsResponse_Sidechain> blocks = [];

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
          aValue = a.slot;
          bValue = b.slot;
          break;
        case 'name':
          aValue = a.title;
          bValue = b.title;
          break;
        case 'chaintipTxid':
          aValue = a.chaintipTxid;
          bValue = b.chaintipTxid;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => blocks[index].slot.toString(),
      headerBuilder: (context) => [
        SailTableHeaderCell(child: SailText.primary12('#')),
        SailTableHeaderCell(child: SailText.primary12('Active')),
        SailTableHeaderCell(child: SailText.primary12('Name')),
        SailTableHeaderCell(child: SailText.primary12('CTIP TxID')),
        //TODO: SailTableHeaderCell(child: SailText.primary12('CTIP Index')),
      ],
      rowBuilder: (context, row, selected) {
        // TODO: Revise the data, it's not yet clear what is what. The columns is taken straight from
        // drivechain-qt and might not be available in the API.
        final sidechain = blocks[row];
        return [
          SailTableCell(child: SailText.primary12('${sidechain.slot}')),
          SailTableCell(child: SailText.primary12('Yes')),
          SailTableCell(child: SailText.primary12(sidechain.title)),
          SailTableCell(
            child: SailText.primary12(sidechain.chaintipTxid.isEmpty ? 'N/A' : sidechain.chaintipTxid),
          ),
          //TODO: SailTableCell(child: SailText.primary12('TODO')),
        ];
      },
      rowCount: blocks.length,
      columnWidths: const [50, 100, 100, 500],
      sortColumnIndex: ['slot', 'active', 'name', 'chaintipTxid'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['slot', 'active', 'name', 'chaintipTxid'][columnIndex]);
      },
    );
  }
}

Future<void> showSidechainActivationManagementModal(BuildContext context) {
  return showAdaptiveDialog<void>(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.1,
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(4.0),
          child: const SidechainActivationManagementPage(),
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
        SailTableHeaderCell(child: SailText.primary12('Vote')),
        SailTableHeaderCell(child: SailText.primary12('SC #')),
        SailTableHeaderCell(child: SailText.primary12('Replacement')),
        SailTableHeaderCell(child: SailText.primary12('Title')),
        SailTableHeaderCell(child: SailText.primary12('Description')),
        SailTableHeaderCell(child: SailText.primary12('Age')),
        SailTableHeaderCell(child: SailText.primary12('Fails')),
        SailTableHeaderCell(child: SailText.primary12('Hash')),
      ],
      rowBuilder: (context, row, selected) {
        final proposal = widget.proposals[row];
        // TODO: Revise the data, it's not yet clear what is what. The columns is taken straight from
        // drivechain-qt and might not be available in the API.
        return [
          SailTableCell(child: SailText.primary12(proposal.voteCount.toString())),
          SailTableCell(child: SailText.primary12(proposal.slot.toString())),
          SailTableCell(child: SailText.primary12('Replacement')),
          SailTableCell(child: SailText.primary12(proposal.data.toString())),
          SailTableCell(child: SailText.primary12('Description')),
          SailTableCell(child: SailText.primary12(proposal.proposalAge.toString())),
          SailTableCell(child: SailText.primary12(proposal.proposalHeight.toString())),
          SailTableCell(child: SailText.primary12(proposal.dataHash)),
        ];
      },
      rowCount: widget.proposals.length,
      columnWidths: const [50, 50, 100, 100, 200, 50, 50, 200],
      sortColumnIndex: ['voteCount', 'slot', 'age', 'fails', 'hash'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['voteCount', 'slot', 'age', 'fails', 'hash'][columnIndex]);
      },
    );
  }
}
