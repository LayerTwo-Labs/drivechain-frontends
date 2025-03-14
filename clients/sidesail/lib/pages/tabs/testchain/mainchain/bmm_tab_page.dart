import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/bmm_provider.dart';
import 'package:sidesail/rpc/models/bmm_result.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
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
                  SailButton.icon(
                    onPressed: model.running ? null : () async => model.toggleRunning(true),
                    disabled: model.running,
                    icon: const Icon(
                      Icons.play_arrow,
                      size: SailStyleValues.iconSizePrimary,
                    ),
                    label: 'Start mining',
                  ),
                  const SizedBox(width: 10),
                  SailButton.icon(
                    onPressed: !model.running ? null : () async => model.toggleRunning(false),
                    disabled: !model.running,
                    icon: const Icon(
                      Icons.stop,
                      size: SailStyleValues.iconSizePrimary,
                    ),
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
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: SailColumn(
                          spacing: SailStyleValues.padding16,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 640,
                              ),
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
                      )
                    : Flexible(
                        child: SingleChildScrollView(
                          child: DashboardGroup(
                            title: 'Blind Merged Mining attempts',
                            widgetTrailing: SailText.secondary13(model.bmmAttempts.length.toString()),
                            children: [
                              SailColumn(
                                spacing: 0,
                                withDivider: true,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: model.bmmAttempts.length,
                                    itemBuilder: (context, index) => BMMAttemptView(
                                      key: ValueKey<String>(model.bmmAttempts[index].result.txid),
                                      bmmAttempt: model.bmmAttempts[index],
                                      onPressed: () => {},
                                    ),
                                  ),
                                ],
                              ),
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

class BMMAttemptView extends StatelessWidget {
  final BmmAttempt bmmAttempt;
  final VoidCallback onPressed;

  const BMMAttemptView({
    super.key,
    required this.bmmAttempt,
    required this.onPressed,
  });

  String get ticker => GetIt.I.get<SidechainContainer>().rpc.chain.ticker;

  Map<String, dynamic> get decodedAttempt => jsonDecode(bmmAttempt.result.raw);

  @override
  Widget build(BuildContext context) {
    final (status, icon) = bmmAttempt.status();

    return ExpandableListEntry(
      entry: SingleValueContainer(
        width: 180,
        icon: Tooltip(
          message: status,
          child: SailSVG.icon(icon, width: 13),
        ),
        copyable: false,
        label: status,
        value: extractTXTitle(bmmAttempt),
      ),
      expandedEntry: ExpandedTXView(
        decodedTX: decodedAttempt,
        width: 180,
      ),
    );
  }

  String extractTXTitle(BmmAttempt attempt) {
    String title =
        '${formatBitcoin(satoshiToBTC(attempt.bidSatoshis), symbol: ticker)} bid containing ${attempt.result.ntxn} transaction(s) with ${formatBitcoin(satoshiToBTC(attempt.result.nfees), symbol: ticker)} total fees';
    return title;
  }
}
