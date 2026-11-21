import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/sidechain_proposal_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SidechainActivationManagementPage extends StatelessWidget {
  const SidechainActivationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();
    final theme = SailTheme.of(context);

    if (!confProvider.networkSupportsSidechains) {
      return SailScaffold(
        backgroundColor: theme.colors.background,
        appBar: SailAppBar.build(context, title: SailText.primary20('Sidechain Activation')),
        body: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding16),
          child: SailCard(
            title: 'Sidechain Activation',
            subtitle: 'Not available on this network',
            child: Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailText.primary20('Unlock Sidechain Activation with BIP300'),
                  const SailSpacing(SailStyleValues.padding20),
                  SailText.secondary13(
                    'Sidechain activation is only available on Drivechain-enabled networks (eCash and Signet). '
                    'These networks implement BIP300, which enables trustless two-way pegged sidechains.',
                  ),
                  const SailSpacing(SailStyleValues.padding20),
                  SailText.primary15('What is Sidechain Activation?'),
                  const SailSpacing(SailStyleValues.padding08),
                  SailText.secondary13(
                    'As a miner, you can propose new sidechains and vote on sidechain proposals. '
                    'Once a proposal receives enough votes, the sidechain becomes active and users can deposit funds.',
                  ),
                  const SailSpacing(SailStyleValues.padding20),
                  SailText.primary15('How to Enable'),
                  const SailSpacing(SailStyleValues.padding08),
                  SailText.secondary13(
                    '1. Go to Settings\n'
                    '2. Switch to "eCash" or "Signet" network\n'
                    '3. Restart BitWindow\n'
                    '4. Return here to manage sidechain proposals',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SailScaffold(
      backgroundColor: theme.colors.background,
      appBar: SailAppBar.build(context, title: SailText.primary20('Sidechain Activation')),
      body: ViewModelBuilder<SidechainActivationManagementViewModel>.reactive(
        viewModelBuilder: () => SidechainActivationManagementViewModel(),
        builder: (context, model, child) => const SidechainActivationManagementView(),
      ),
    );
  }
}

class SidechainActivationManagementViewModel extends BaseViewModel {
  final SidechainProvider sidechainProvider = GetIt.I.get<SidechainProvider>();

  List<SidechainOverview?> get activeSidechains =>
      sidechainProvider.sidechains.where((sidechain) => sidechain != null).toList();

  List<SidechainProposal> get sidechainProposals => sidechainProvider.sidechainProposals;

  Set<int> get activeSlots => {for (final sidechain in activeSidechains) sidechain!.info.slot};

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
      builder: (context, model, child) => Padding(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary12('Escrow Status (Active Sidechains)'),
                        const SizedBox(height: SailStyleValues.padding08),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.sailTheme.colors.background,
                              border: Border.all(
                                color: context.sailTheme.colors.divider,
                                width: 1.0,
                              ),
                              borderRadius: context.sailTheme.chrome.radius,
                            ),
                            child: ActiveSidechainsTable(blocks: model.activeSidechains),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SailStyleValues.padding16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary12('Pending Sidechain Proposals'),
                        const SizedBox(height: SailStyleValues.padding08),
                        Expanded(
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.sailTheme.colors.background,
                              border: Border.all(
                                color: context.sailTheme.colors.divider,
                                width: 1.0,
                              ),
                              borderRadius: context.sailTheme.chrome.radius,
                            ),
                            child: PendingSidechainProposalsTable(
                              proposals: model.sidechainProposals,
                              activeSlots: model.activeSlots,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SailStyleValues.padding16),
            SailButton(
              label: 'Propose New Sidechain',
              onPressed: () async => await showSidechainProposalModal(context),
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
  static const columns = ['slot', 'active', 'name', 'chaintipTxid'];

  String sortColumn = 'slot';
  bool sortAscending = true;

  Comparable<Object> sortValue(SidechainOverview? sidechain) {
    return switch (sortColumn) {
      'name' => sidechain?.info.title ?? '',
      'chaintipTxid' => sidechain?.info.chaintipTxid ?? '',
      _ => sidechain?.info.slot ?? -1,
    } as Comparable<Object>;
  }

  void onSort(String column) {
    setState(() {
      if (column == sortColumn) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
    });
  }

  String chaintipTxid(String rowId) =>
      widget.blocks.firstWhere((s) => '${s?.info.slot}' == rowId, orElse: () => null)?.info.chaintipTxid ?? '';

  @override
  Widget build(BuildContext context) {
    final blocks = [...widget.blocks]
      ..sort((a, b) => sortAscending ? sortValue(a).compareTo(sortValue(b)) : sortValue(b).compareTo(sortValue(a)));

    return SailTable(
      getRowId: (index) => '${blocks[index]?.info.slot}',
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
      emptyPlaceholder: 'No active sidechains',
      sortColumnIndex: columns.indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) => onSort(columns[columnIndex]),
      onDoubleTap: (rowId) => showTransactionDetails(context, chaintipTxid(rowId)),
      contextMenuItems: (rowId) {
        return [
          SailMenuItem(
            onSelected: () => showTransactionDetails(context, chaintipTxid(rowId)),
            child: SailText.primary12('Show Chaintip Transaction'),
          ),
        ];
      },
    );
  }
}

Future<void> showSidechainActivationManagementModal(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return showThemedDialog<void>(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: SailModal(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.8,
            maxHeight: size.height * 0.8,
          ),
          child: const SidechainActivationManagementPage(),
        ),
      );
    },
  );
}

class PendingSidechainProposalsTable extends StatefulWidget {
  final List<SidechainProposal> proposals;
  final Set<int> activeSlots;

  const PendingSidechainProposalsTable({
    super.key,
    required this.proposals,
    required this.activeSlots,
  });

  @override
  State<PendingSidechainProposalsTable> createState() => _PendingSidechainProposalsTableState();
}

class _PendingSidechainProposalsTableState extends State<PendingSidechainProposalsTable> {
  static const columns = ['voteCount', 'slot', 'replacement', 'title', 'description', 'age', 'height', 'hash'];

  String sortColumn = 'slot';
  bool sortAscending = true;

  bool isReplacement(SidechainProposal proposal) => widget.activeSlots.contains(proposal.slot);

  Comparable<Object> sortValue(SidechainProposal proposal) {
    return switch (sortColumn) {
      'voteCount' => proposal.voteCount,
      'replacement' => isReplacement(proposal) ? 1 : 0,
      'title' => proposal.title,
      'description' => proposal.description,
      'age' => proposal.proposalAge,
      'height' => proposal.proposalHeight,
      'hash' => proposal.dataHash,
      _ => proposal.slot,
    } as Comparable<Object>;
  }

  void onSort(String column) {
    setState(() {
      if (column == sortColumn) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final proposals = [...widget.proposals]
      ..sort((a, b) => sortAscending ? sortValue(a).compareTo(sortValue(b)) : sortValue(b).compareTo(sortValue(a)));

    return SailTable(
      getRowId: (index) => proposals[index].slot.toString(),
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'Vote'),
        const SailTableHeaderCell(name: 'SC #'),
        const SailTableHeaderCell(name: 'Replacement'),
        const SailTableHeaderCell(name: 'Title'),
        const SailTableHeaderCell(name: 'Description'),
        const SailTableHeaderCell(name: 'Age'),
        const SailTableHeaderCell(name: 'Height'),
        const SailTableHeaderCell(name: 'Hash'),
      ],
      rowBuilder: (context, row, selected) {
        final proposal = proposals[row];
        return [
          SailTableCell(value: proposal.voteCount.toString()),
          SailTableCell(value: proposal.slot.toString()),
          SailTableCell(value: isReplacement(proposal) ? 'Yes' : 'No'),
          SailTableCell(value: proposal.title),
          SailTableCell(value: proposal.description),
          SailTableCell(value: proposal.proposalAge.toString()),
          SailTableCell(value: proposal.proposalHeight.toString()),
          SailTableCell(value: proposal.dataHash),
        ];
      },
      rowCount: proposals.length,
      emptyPlaceholder: 'No pending sidechain proposals',
      sortColumnIndex: columns.indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) => onSort(columns[columnIndex]),
    );
  }
}
