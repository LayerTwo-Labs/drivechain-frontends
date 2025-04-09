import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/bmm_provider.dart';
import 'package:sidesail/rpc/models/bmm_result.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BlindMergedMiningTabPage extends StatelessWidget {
  const BlindMergedMiningTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BlindMergedMiningTabPageViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          scrollable: true,
          widgetTitle: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  SailButton(
                    variant: ButtonVariant.secondary,
                    onPressed: model.running ? null : () async => model.toggleRunning(true),
                    disabled: model.running,
                    icon: SailSVGAsset.iconArrowForward,
                    label: 'Start mining',
                  ),
                  const SizedBox(width: 10),
                  SailButton(
                    variant: ButtonVariant.secondary,
                    onPressed: !model.running ? null : () async => model.toggleRunning(false),
                    disabled: !model.running,
                    icon: SailSVGAsset.iconArrow,
                    label: 'Stop mining',
                  ),
                ],
              ),
              const SizedBox(width: SailStyleValues.padding08),
              SizedBox(
                width: 250,
                child: SailTextField.tiny(
                  controller: model.bidController,
                  hintText: 'Bid amount',
                  suffix: 'sats',
                  prefix: 'Bid amount: ',
                  textFieldType: TextFieldType.number,
                ),
              ),
              SizedBox(
                width: 250,
                child: SailTextField.tiny(
                  controller: model.refreshController,
                  hintText: 'Refresh interval',
                  prefix: 'Refresh interval: ',
                  suffix: 'seconds',
                  textFieldType: TextFieldType.number,
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                model.bmmAttempts.isEmpty
                    ? _buildEmptyState()
                    : Expanded(
                        child: SailCard(
                          title: 'Blind Merged Mining attempts',
                          subtitle: '${model.bmmAttempts.length} attempts',
                          child: Column(
                            children: [
                              SailSpacing(SailStyleValues.padding16),
                              Expanded(
                                child: SailTable(
                                  getRowId: (index) => model.bmmAttempts[index].result.txid,
                                  headerBuilder: (context) => [
                                    const SailTableHeaderCell(name: 'Status'),
                                    const SailTableHeaderCell(name: 'Transaction'),
                                    const SailTableHeaderCell(name: 'Block Height'),
                                    const SailTableHeaderCell(name: 'Bid Amount'),
                                  ],
                                  rowBuilder: (context, row, selected) {
                                    final attempt = model.bmmAttempts[row];
                                    final (status, icon) = attempt.status();

                                    return [
                                      SailTableCell(
                                        value: status,
                                        child: Row(
                                          children: [
                                            Tooltip(
                                              message: status,
                                              child: SailSVG.icon(icon, width: 13),
                                            ),
                                            const SizedBox(width: 8),
                                            SailText.primary12(status),
                                          ],
                                        ),
                                      ),
                                      SailTableCell(
                                        value: attempt.result.txid,
                                        monospace: true,
                                      ),
                                      SailTableCell(
                                        value: attempt.mainchainBlockHeight.toString(),
                                        monospace: true,
                                      ),
                                      SailTableCell(
                                        value: '${attempt.bidSatoshis} sats',
                                        monospace: true,
                                      ),
                                    ];
                                  },
                                  rowCount: model.bmmAttempts.length,
                                  columnWidths: const [-1, -1, -1, -1],
                                  drawGrid: true,
                                  onDoubleTap: (rowId) {
                                    final attempt = model.bmmAttempts.firstWhere(
                                      (a) => a.result.txid == rowId,
                                    );
                                    _showBMMDetails(context, attempt);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SailText.primary13(
              'Blind Merged Mining (BMM) is the mechanism used for mining on a sidechain.\n\n'
              'Pressing the "start" button here starts the BMM process. The BMM process consists '
              'of a sequence of attempts which can succeed or fail. When an attempt is first made '
              'it has a pending status. The next attempt decides the outcome of the previous one, '
              'which is reflected in the table below.\n\n'
              'A BMM attempt can also fail to be created in its entirety. In that case, it is not '
              "added to the table. Notably, a BMM attempt only succeeds if there's been mined at"
              'least 1 block on the mainchain since the last BMM attempt.\n\n'
              "A BMM attempt includes a satoshi denominated 'bid' amount. This amount is paid to "
              'the the mainchain miners for the right to construct a new sidechain block. The '
              'profit from mining the sidechain block is the total fees collected on the sidechain, '
              'minus the bid to the mainchain miners. If the fees collected on the sidechain is '
              'less than the bid amount, the profit goes negative (money lost!)'
              '',
            ),
          ),
          SailText.primary20(
            'No BMM attempts yet. Click the start button!\n(and automine at the same time)',
            bold: true,
          ),
        ],
      ),
    );
  }

  void _showBMMDetails(BuildContext context, BmmAttempt attempt) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'BMM Attempt Details',
            subtitle: attempt.result.txid,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'Status', value: attempt.status().$1),
                  DetailRow(label: 'Transaction ID', value: attempt.result.txid),
                  DetailRow(label: 'Block Height', value: attempt.mainchainBlockHeight.toString()),
                  DetailRow(label: 'Bid Amount', value: '${attempt.bidSatoshis} sats'),
                  DetailRow(label: 'Number of Transactions', value: attempt.result.ntxn.toString()),
                  DetailRow(label: 'Total Fees', value: '${attempt.result.nfees} sats'),
                  const SailSpacing(SailStyleValues.padding16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlindMergedMiningTabPageViewModel extends BaseViewModel {
  BMMProvider get _bmmProvider => GetIt.I.get<BMMProvider>();
  Logger get log => GetIt.I.get<Logger>();

  final bidController = TextEditingController();
  final refreshController = TextEditingController();

  int get bidAmountSats => int.tryParse(bidController.text) ?? 1000;
  int get refreshSeconds => int.tryParse(refreshController.text) ?? 3;

  BlindMergedMiningTabPageViewModel() {
    bidController.text = '1000';
    refreshController.text = '3';

    _bmmProvider.addListener(notifyListeners);
  }

  bool running = false;
  List<BmmAttempt> get bmmAttempts => _bmmProvider.bmmAttempts;

  Timer? refreshTimer;

  void toggleRunning(bool to) {
    running = to;
    notifyListeners();

    if (running) {
      log.i('starting refresh timer with interval $refreshSeconds');

      refreshTimer = Timer.periodic(Duration(seconds: refreshSeconds), (_) {
        _bmmProvider.handleBmmTick(bidAmountSats);
      });
    } else {
      log.i('stopping refresh timer');

      refreshTimer?.cancel();
      refreshTimer = null;
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _bmmProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class BmmAttempt {
  BmmAttempt({
    required this.result,
    required this.bidSatoshis,
    required this.sidechainBlockHeight,
    required this.mainchainBlockHeight,
  });

  BmmResult result;
  int bidSatoshis;
  int sidechainBlockHeight;
  int mainchainBlockHeight;

  // Attempts are not in a known outcome state when they're first connected. This
  // is determined on later attempts.

  bool failed = false;
  bool connected = false;

  (String, SailSVGAsset) status() {
    if (failed) {
      return ('Failed', SailSVGAsset.iconFailed);
    }
    if (connected) {
      return ('Success', SailSVGAsset.iconSuccess);
    }

    return ('Trying...', SailSVGAsset.iconPending);
  }
}

List<T> removeNulls<T>(List<T?> xs) {
  return xs.where((element) => element != null).cast<T>().toList();
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

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
              bold: true,
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
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
        SailText.primary13(title, bold: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: SailTheme.of(context).colors.divider,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
    );
  }
}
