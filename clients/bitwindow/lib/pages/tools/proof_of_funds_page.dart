import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:bitwindow/pages/tools/proof_of_funds_viewmodel.dart';

@RoutePage()
class ProofOfFundsPage extends StatelessWidget {
  const ProofOfFundsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProofOfFundsViewModel>.reactive(
      viewModelBuilder: () => ProofOfFundsViewModel(),
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SailStyleValues.padding16),
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generate Proof of Funds
                SailRawCard(
                  title: 'Generate Proof of Funds',
                  subtitle: 'Create a proof of funds file from your unspent outputs',
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailTextField(
                        controller: viewModel.fileOutController,
                        label: 'Output File Path',
                        hintText: 'Enter path to save the proof file',
                        size: TextFieldSize.small,
                      ),
                      SailTextField(
                        controller: viewModel.messageController,
                        label: 'Custom Message (optional)',
                        hintText: 'Enter a custom message or leave blank for random',
                        size: TextFieldSize.small,
                      ),
                      QtButton(
                        label: 'Generate',
                        onPressed: viewModel.generateProof,
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
                ),
                // Verify Proof of Funds
                SailRawCard(
                  title: 'Verify Proof of Funds',
                  subtitle: 'Verify a proof of funds file',
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailTextField(
                        controller: viewModel.fileInController,
                        label: 'Input File Path',
                        hintText: 'Enter path to the proof file',
                        size: TextFieldSize.small,
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailText.primary13('Skip first row:'),
                          Switch(
                            value: viewModel.skipFirstRow,
                            onChanged: (value) => viewModel.toggleSkipFirstRow(),
                          ),
                        ],
                      ),
                      QtButton(
                        label: 'Verify',
                        onPressed: viewModel.verifyProof,
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
                ),
                if (viewModel.result != null)
                  SailRawCard(
                    title: 'Result',
                    child: SelectableText(
                      viewModel.result!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}