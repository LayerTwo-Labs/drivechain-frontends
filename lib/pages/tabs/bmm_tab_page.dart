import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BlindMergedMiningTabPage extends StatelessWidget {
  const BlindMergedMiningTabPage({super.key});

  // For debugging purposes: set this to true to display raw BMM attempt data
  final _displayRawRes = false;

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Blind merged mining',
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => BlindMergedMiningTabPageViewModel(),
        builder: ((context, viewModel, child) {
          return Center(
            child: Column(
              children: [
                SizedBox(
                  width: 750,
                  child: SailText.primary14(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SailText.mediumPrimary20('BMM loop'),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: viewModel.running ? null : viewModel.toggleRunning,
                          icon: const Icon(Icons.play_arrow),
                          label: SailText.primary12('Start'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: !viewModel.running ? null : viewModel.toggleRunning,
                          icon: const Icon(Icons.stop),
                          label: SailText.primary12('Stop'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        initialValue: viewModel.bidAmountSats.toString(),
                        readOnly: viewModel.running,
                        inputFormatters: [
                          // just digits
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Bid amount',
                          suffixText: 'sats',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        initialValue: viewModel.refreshSeconds.toString(),
                        readOnly: viewModel.running,
                        inputFormatters: [
                          // just digits
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Refresh',
                          suffixText: 'second(s)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                viewModel.bmmAttempts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: SailText.mediumPrimary20('No BMM attempts yet. Click the start button!'),
                      )
                    : Flexible(
                        child: SingleChildScrollView(
                          child: DataTable(
                            dataRowMaxHeight: _displayRawRes ? 350 : null,
                            columns: removeNulls([
                              DataColumn(label: SailText.primary14('MC txid')),
                              DataColumn(label: SailText.primary14('MC block')),
                              DataColumn(label: SailText.primary14('SC block')),
                              DataColumn(label: SailText.primary14('Transactions')),
                              DataColumn(label: SailText.primary14('Fees')),
                              DataColumn(label: SailText.primary14('Bid amount')),
                              DataColumn(label: SailText.primary14('Profit')),
                              DataColumn(label: SailText.primary14('Status')),
                              _displayRawRes ? DataColumn(label: SailText.primary14('Raw')) : null,
                            ]),
                            rows: viewModel.bmmAttempts.map(
                              (res) {
                                final profit = res.result.nfees - res.bidSatoshis;
                                return DataRow(
                                  cells: removeNulls(
                                    [
                                      DataCell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: res.result.txid));
                                          showSnackBar(context, 'Copied TXID');
                                        },
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            res.result.txid,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(SelectableText(res.mainchainBlockHeight.toString())),
                                      DataCell(SelectableText(res.sidechainBlockHeight.toString())),
                                      DataCell(SelectableText(res.result.ntxn.toString())),
                                      DataCell(SelectableText('${res.result.nfees.toString()} sats')),
                                      DataCell(SelectableText('${res.bidSatoshis.toString()} sats')),
                                      DataCell(SelectableText('${profit.toString()} sats')),
                                      DataCell(Text(res.status())),
                                      _displayRawRes
                                          ? DataCell(
                                              SizedBox(
                                                width: 500,
                                                child: Text(
                                                  const JsonEncoder.withIndent(' ').convert(res.result.toJson()),
                                                  softWrap: true,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class BlindMergedMiningTabPageViewModel extends BaseViewModel {
  RPC get _rpc => GetIt.I.get<RPC>();

  int bidAmountSats = 1000;
  int refreshSeconds = 3;
  bool running = false;

  List<BmmAttempt> bmmAttempts = [];

  Timer? refreshTimer;

  void toggleRunning() {
    running = !running;
    notifyListeners();

    if (running) {
      log.i('starting refresh timer');

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
    final currentBlockCount = await _rpc.blockCount();

    if (res.error != null) {
      log.d('was not able to advance BMM: ${res.error}');
    }

    var attempt = BmmAttempt(
      result: res,
      bidSatoshis: bidAmountSats,

      // BMM attempts are always for the /next/ block height
      sidechainBlockHeight: currentBlockCount + 1,

      // TODO: fetch mainchain block by TXID to get a correct number
      mainchainBlockHeight: await _rpc.mainchainBlockCount(),
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

  String status() {
    if (failed) {
      return 'Failed';
    }
    if (connected) {
      return 'Success';
    }

    return 'Trying...';
  }
}

List<T> removeNulls<T>(List<T?> xs) {
  return xs.where((element) => element != null).cast<T>().toList();
}
