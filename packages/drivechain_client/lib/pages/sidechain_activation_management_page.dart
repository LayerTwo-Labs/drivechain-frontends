import 'package:auto_route/annotations.dart';
import 'package:drivechain_client/pages/send_page.dart';
import 'package:drivechain_client/widgets/qt_page.dart';
import 'package:drivechain_client/widgets/qt_button.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:drivechain_client/providers/sidechain_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/pages/sidechain_proposal_page.dart';

@RoutePage()
class SidechainActivationManagementPage extends StatelessWidget {
  const SidechainActivationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SidechainActivationManagementViewModel>.reactive(
      viewModelBuilder: () => SidechainActivationManagementViewModel(),
      builder: (context, model, child) => QtPage(
        child: Column(
          children: [
            // ... (existing widgets)
            QtButton(
              onPressed: () => showSidechainProposalModal(context),
              child: SailText.primary13('Create Sidechain Proposal'),
            ),
            // ... (existing widgets)
          ],
        ),
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
            child: SailTable(
              headerBuilder: (context) => [
                SailTableHeaderCell(child: SailText.primary12('#')),
                SailTableHeaderCell(child: SailText.primary12('Active')),
                SailTableHeaderCell(child: SailText.primary12('Name')),
                SailTableHeaderCell(child: SailText.primary12('CTIP TxID')),
                //TODO: SailTableHeaderCell(child: SailText.primary12('CTIP Index')),
              ],
              rowBuilder: (context, row, selected) {
                final sidechain = model.activeSidechains[row];
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
              rowCount: model.activeSidechains.length,
              columnCount: 4, // TODO: 5
              columnWidths: const [50, 100, 100, 500],
            ),
          ),
          const SizedBox(height: SailStyleValues.padding15),
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
            child: SailTable(
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
              rowBuilder: (context, row, selected) => [
                // TODO: Get actual data
                SailTableCell(child: SailText.primary12('Row $row, Col 1')),
                SailTableCell(child: SailText.primary12('Row $row, Col 2')),
                SailTableCell(child: SailText.primary12('Row $row, Col 3')),
                SailTableCell(child: SailText.primary12('Row $row, Col 4')),
                SailTableCell(child: SailText.primary12('Row $row, Col 5')),
                SailTableCell(child: SailText.primary12('Row $row, Col 6')),
                SailTableCell(child: SailText.primary12('Row $row, Col 7')),
                SailTableCell(child: SailText.primary12('Row $row, Col 8')),
              ],
              rowCount: 10, // Example row count
              columnCount: 8,
              columnWidths: const [50, 50, 100, 100, 200, 50, 50, 200],
            ),
          ),
          const SizedBox(height: SailStyleValues.padding30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  QtButton(
                    onPressed: () {},
                    child: SailText.primary13('ACK'),
                  ),
                  const SizedBox(width: SailStyleValues.padding15),
                  QtButton(
                    onPressed: () {},
                    child: SailText.primary13('NACK'),
                  ),
                ],
              ),
              Row(
                children: [
                  QtButton(
                    onPressed: () {
                      showSnackBar(context, 'Not implemented');
                    },
                    child: SailText.primary13('Create Sidechain Proposal'),
                  ),
                  const SizedBox(width: SailStyleValues.padding15),
                  QtIconButton(
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

Future<void> showSidechainProposalModal(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: const SidechainProposalView(),
        ),
      );
    },
  );
}
