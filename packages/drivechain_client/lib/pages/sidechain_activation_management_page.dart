import 'package:auto_route/annotations.dart';
import 'package:drivechain_client/pages/send_page.dart';
import 'package:drivechain_client/widgets/qt_page.dart';
import 'package:drivechain_client/widgets/qt_button.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SidechainActivationManagementModal extends StatelessWidget {
  const SidechainActivationManagementModal({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 480,
      width: 600,
      child: QtPage(
        child: Padding(
          padding: EdgeInsets.all(SailStyleValues.padding08),
          child: SidechainActivationManagementView(),
        ),
      ),
    );
  }
}

class SidechainActivationManagementView extends StatelessWidget {
  const SidechainActivationManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              SailTableHeaderCell(child: SailText.primary12('CTIP Index')),
            ],
            rowBuilder: (context, row, selected) => [
              SailTableCell(child: SailText.primary12('Row $row, Col 1')),
              SailTableCell(child: SailText.primary12('Row $row, Col 2')),
              SailTableCell(child: SailText.primary12('Row $row, Col 3')),
              SailTableCell(child: SailText.primary12('Row $row, Col 4')),
              SailTableCell(child: SailText.primary12('Row $row, Col 5')),
            ],
            rowCount: 10, // Example row count
            columnCount: 5,
            columnWidths: const [50, 50, 100, 200, 100],
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
                  onPressed: () {},
                  child: SailText.primary13('Create Sidechain Proposal'),
                ),
                const SizedBox(width: SailStyleValues.padding15),
                QtIconButton(
                  icon: const Icon(Icons.question_mark_rounded, size: 13),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showSidechainActivationManagementModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.1,
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(4.0),
          child: const SidechainActivationManagementModal(),
        ),
      );
    },
  );
}
