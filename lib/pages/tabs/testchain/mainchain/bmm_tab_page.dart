import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/pages/tabs/dashboard_tab_page.dart';
import 'package:sidesail/rpc/models/bmm_result.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BlindMergedMiningTabPage extends StatelessWidget {
  const BlindMergedMiningTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BlindMergedMiningTabPageViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          widgetTitle: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  SailButton.icon(
                    onPressed: viewModel.running ? null : () => viewModel.toggleRunning(true),
                    disabled: viewModel.running,
                    icon: const Icon(
                      Icons.play_arrow,
                      size: SailStyleValues.iconSizePrimary,
                    ),
                    label: 'Start mining',
                  ),
                  const SizedBox(width: 10),
                  SailButton.icon(
                    onPressed: !viewModel.running ? null : () => viewModel.toggleRunning(false),
                    disabled: !viewModel.running,
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
                  controller: viewModel.bidController,
                  hintText: 'Bid amount',
                  suffix: 'sats',
                  prefix: 'Bid amount: ',
                  textFieldType: TextFieldType.number,
                ),
              ),
              SizedBox(
                width: 250,
                child: SailTextField.tiny(
                  controller: viewModel.refreshController,
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
                viewModel.bmmAttempts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: SailColumn(
                          spacing: SailStyleValues.padding15,
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
                            widgetTrailing: SailText.secondary13(viewModel.bmmAttempts.length.toString()),
                            children: [
                              SailColumn(
                                spacing: 0,
                                withDivider: true,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: viewModel.bmmAttempts.length,
                                    itemBuilder: (context, index) => BMMAttemptView(
                                      key: ValueKey<String>(viewModel.bmmAttempts[index].result.txid),
                                      bmmAttempt: viewModel.bmmAttempts[index],
                                      onPressed: () => viewModel.toggleRunning(false),
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
  TestchainRPC get _rpc => GetIt.I.get<TestchainRPC>();

  final bidController = TextEditingController();
  final refreshController = TextEditingController();

  int get bidAmountSats => int.tryParse(bidController.text) ?? 1000;
  int get refreshSeconds => int.tryParse(refreshController.text) ?? 3;

  BlindMergedMiningTabPageViewModel() {
    bidController.text = '1000';
    refreshController.text = '3';
  }

  bool running = false;

  List<BmmAttempt> bmmAttempts = [];

  Timer? refreshTimer;

  void toggleRunning(bool to) {
    running = to;
    notifyListeners();

    if (running) {
      log.i('starting refresh timer with interval $refreshSeconds');

      refreshTimer = Timer.periodic(Duration(seconds: refreshSeconds), _handleBmmTick);
    } else {
      log.i('stopping refresh timer');

      refreshTimer?.cancel();
      refreshTimer = null;
    }
  }

  // Based off of RefreshBMM in testchain
  // https://github.com/LayerTwo-Labs/testchain/blob/c44e3a737d1780a1a07135657ac0fd7686251933/src/qt/sidechainpage.cpp#L767
  void _handleBmmTick(Timer _) async {
    final res = await _rpc.refreshBMM(bidAmountSats);
    final currentBlockCount = await _rpc.sideBlockCount();

    if (res.error != null) {
      log.d('was not able to advance BMM: ${res.error}');
    }

    var attempt = BmmAttempt(
      result: res,
      bidSatoshis: bidAmountSats,

      // BMM attempts are always for the /next/ block height
      sidechainBlockHeight: currentBlockCount + 1,

      // TODO: fetch mainchain block by TXID to get a correct number
      mainchainBlockHeight: await _rpc.mainBlockCount(),
    );

    // Add the attempt!
    if (res.bmmBlockCreated != null) {
      log.d('adding attempt: ${res.bmmBlockCreated}');
      _addAttempt(attempt);
    }

    // We were able to advance the chain, and must update its descendants.
    // (Or something like that... Not completely sure, tbh)
    if (res.bmmBlockSubmitted != null) {
      log.d('updating connected: ${res.bmmBlockSubmitted}');
      _updateConnected(res);
    }

    notifyListeners();
  }

  // Ported from SidechainBMMTableModel::AddAttempt in the testchain codebase
  void _addAttempt(BmmAttempt attempt) {
    bmmAttempts.insert(
      0,
      attempt,
    );

    // Skip if there are less than 2 BMM requests
    if (bmmAttempts.length < 2) {
      log.d('less than twp BMM requests, skipping');
      return;
    }

    // Skip the first (newest) entry
    const start = 1;
    // When we add a new attempt, set the last 6 BMM requests to failed if
    // they weren't connected - they have expired.
    const attemptsToUpdate = 6;
    bmmAttempts.slice(start, min(start + attemptsToUpdate, bmmAttempts.length)).forEach((attempt) {
      if (attempt.connected) {
        return;
      }

      log.d('marking attempt as failed: ${attempt.result.txid}');

      // If the attempt wasn't connected, it per def failed.
      attempt.failed = true;
    });
  }

  // Ported from SidechainBMMTableModel::UpdateForConnected in the testchain codebase
  void _updateConnected(BmmResult current) {
    //  auto it = std::find_if(model.begin(), model.end(),
    //     [ hashMerkleRoot ](BMMTableObject a) { return a.hashMerkleRoot == hashMerkleRoot; });
    final toUpdate =
        bmmAttempts.firstWhereOrNull((prev) => prev.result.bmmBlockCreated == current.bmmBlockSubmittedBlind);

    if (toUpdate == null) {
      log.w('was not able to find bmmBlockSubmittedBlind: ${current.bmmBlockSubmittedBlind}');
      return;
    }

    log.d('updating connected block: ${toUpdate.result.txid}');

    //  it->fFailed = false;
    // it->fConnected = true;
    toUpdate.failed = false;
    toUpdate.connected = true;
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
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

class BMMAttemptView extends StatefulWidget {
  final BmmAttempt bmmAttempt;
  final VoidCallback onPressed;

  const BMMAttemptView({
    super.key,
    required this.bmmAttempt,
    required this.onPressed,
  });

  @override
  State<BMMAttemptView> createState() => _BMMAttemptViewState();
}

class _BMMAttemptViewState extends State<BMMAttemptView> {
  bool expanded = false;
  late Map<String, dynamic> decodedAttempt;
  @override
  void initState() {
    super.initState();
    decodedAttempt = jsonDecode(widget.bmmAttempt.result.raw);
  }

  @override
  Widget build(BuildContext context) {
    final (status, icon) = widget.bmmAttempt.status();
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailScaleButton(
            onPressed: () {
              widget.onPressed();
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueContainer(
              width: expanded ? 180 : 70,
              icon: Tooltip(
                message: status,
                child: SailSVG.icon(icon, width: 13),
              ),
              copyable: false,
              label: status,
              value: extractTXTitle(widget.bmmAttempt),
            ),
          ),
          if (expanded)
            ExpandedTXView(
              decodedTX: decodedAttempt,
              width: 180,
            ),
        ],
      ),
    );
  }

  String extractTXTitle(BmmAttempt attempt) {
    String title =
        '${(satoshiToBTC(attempt.bidSatoshis)).toStringAsFixed(8)} BTC bid containing ${attempt.result.ntxn} transaction(s) with ${attempt.result.nfees.toStringAsFixed(8)} SBTC total fees';
    return title;
  }
}
