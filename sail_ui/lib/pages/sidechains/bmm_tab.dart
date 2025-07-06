import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BMMTab extends StatelessWidget {
  const BMMTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BMMViewModel(),
      builder: (context, viewModel, child) {
        return SailCard(
          title: 'BMM',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailRow(
                spacing: SailStyleValues.padding04,
                children: [
                  SailButton(
                    label: 'Start',
                    disabled: viewModel.isMining,
                    onPressed: () async => viewModel.bmmProvider.startMining(),
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Stop',
                    onPressed: () async => viewModel.bmmProvider.stopMining(),
                    disabled: !viewModel.isMining,
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(width: 16),
                  SailText.primary15('Bid Amount:'),
                  SizedBox(
                    width: 120,
                    child: SailTextField(
                      controller: viewModel.bidAmountController,
                      hintText: '0.0001',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SailText.primary15('Refresh:'),
                  SizedBox(
                    width: 150,
                    child: SailTextField(
                      controller: viewModel.intervalController,
                      hintText: '1 Second(s)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SailTable(
                  getRowId: (index) => viewModel.attempts[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(name: 'MC txid'),
                    SailTableHeaderCell(name: 'MC Block'),
                    SailTableHeaderCell(name: 'SC Block'),
                    SailTableHeaderCell(name: 'Txns'),
                    SailTableHeaderCell(name: 'Fees'),
                    SailTableHeaderCell(name: 'Bid Amount'),
                    SailTableHeaderCell(name: 'Profit'),
                    SailTableHeaderCell(name: 'Status'),
                  ],
                  rowBuilder: (context, row, selected) {
                    final attempt = viewModel.attempts[row];
                    final shortTxid = attempt.txid.length > 10 ? '${attempt.txid.substring(0, 10)}..' : attempt.txid;
                    final shortBlockHash = attempt.hashLastMainBlock.length > 10
                        ? '${attempt.hashLastMainBlock.substring(0, 10)}..'
                        : attempt.hashLastMainBlock;

                    return [
                      SailTableCell(
                        value: shortTxid,
                        copyValue: attempt.txid,
                        monospace: true,
                      ),
                      SailTableCell(
                        value: shortBlockHash,
                        copyValue: attempt.hashLastMainBlock,
                        monospace: true,
                      ),
                      SailTableCell(
                        value: attempt.bmmBlockCreated ?? '-',
                        monospace: true,
                      ),
                      SailTableCell(value: attempt.ntxn.toString()),
                      SailTableCell(value: attempt.nfees.toString()),
                      SailTableCell(value: viewModel.bidAmountController.text),
                      SailTableCell(value: '-'), // Profit placeholder
                      SailTableCell(value: attempt.status),
                    ];
                  },
                  rowCount: viewModel.attempts.length,
                  drawGrid: true,
                  contextMenuItems: (rowId) {
                    final attempt = viewModel.attempts.firstWhere((a) => a.txid == rowId);
                    return [
                      SailMenuItem(
                        onSelected: () {
                          // Copy transaction ID to clipboard
                          Clipboard.setData(ClipboardData(text: attempt.txid));
                        },
                        child: SailText.primary12('Copy TXID'),
                      ),
                      if (attempt.bmmBlockCreated != null)
                        SailMenuItem(
                          onSelected: () {
                            // Copy block hash to clipboard
                            Clipboard.setData(ClipboardData(text: attempt.bmmBlockCreated!));
                          },
                          child: SailText.primary12('Copy Block Hash'),
                        ),
                      SailMenuItem(
                        onSelected: () {
                          // Show attempt details in a dialog
                          showThemedDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: SailText.primary15('BMM Attempt Details'),
                                content: SailColumn(
                                  spacing: SailStyleValues.padding08,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary12('Transaction ID: ${attempt.txid}'),
                                    SailText.primary12('Mainchain Block: ${attempt.hashLastMainBlock}'),
                                    if (attempt.bmmBlockCreated != null)
                                      SailText.primary12('Sidechain Block: ${attempt.bmmBlockCreated}'),
                                    if (attempt.bmmBlockSubmitted != null)
                                      SailText.primary12('Submitted Block: ${attempt.bmmBlockSubmitted}'),
                                    if (attempt.bmmBlockSubmittedBlind != null)
                                      SailText.primary12('Submitted Blind: ${attempt.bmmBlockSubmittedBlind}'),
                                    SailText.primary12('Transactions: ${attempt.ntxn}'),
                                    SailText.primary12('Fees: ${attempt.nfees}'),
                                    if (attempt.error != null)
                                      SailText.primary12('Error: ${attempt.error}', color: Colors.red),
                                  ],
                                ),
                                actions: [
                                  SailButton(
                                    label: 'Close',
                                    onPressed: () async => Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: SailText.primary12('Show Details'),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BMMViewModel extends BaseViewModel {
  final BMMProvider bmmProvider = GetIt.I.get<BMMProvider>();

  final TextEditingController bidAmountController;
  final TextEditingController intervalController;

  Timer? _syncTimer;

  BMMViewModel()
      : bidAmountController = TextEditingController(),
        intervalController = TextEditingController() {
    // Initialize controllers with provider values
    bidAmountController.text = bmmProvider.bidAmount.toString();
    intervalController.text = bmmProvider.interval.inSeconds.toString();

    // Listen for changes in the text fields
    bidAmountController.addListener(_onBidAmountChanged);
    intervalController.addListener(_onIntervalChanged);

    // Listen for changes in provider and update controllers
    bmmProvider.addListener(_syncControllers);

    // Optionally, keep controllers in sync every second
    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) => _syncControllers());
  }

  bool get isMining => bmmProvider.isMining;

  void _onBidAmountChanged() {
    final parsed = double.tryParse(bidAmountController.text);
    if (parsed != null && parsed != bmmProvider.bidAmount) {
      bmmProvider.setBidAmount(parsed);
    }
    notifyListeners();
  }

  void _onIntervalChanged() {
    final parsed = int.tryParse(intervalController.text);
    if (parsed != null && parsed != bmmProvider.interval.inSeconds) {
      bmmProvider.setInterval(Duration(seconds: parsed));
    }
    notifyListeners();
  }

  void _syncControllers() {
    if (bidAmountController.text != bmmProvider.bidAmount.toString()) {
      bidAmountController.text = bmmProvider.bidAmount.toString();
    }
    if (intervalController.text != bmmProvider.interval.inSeconds.toString()) {
      intervalController.text = bmmProvider.interval.inSeconds.toString();
    }
    notifyListeners();
  }

  List<BmmResult> get attempts => bmmProvider.attempts;

  @override
  void dispose() {
    bidAmountController.removeListener(_onBidAmountChanged);
    intervalController.removeListener(_onIntervalChanged);
    bidAmountController.dispose();
    intervalController.dispose();
    bmmProvider.removeListener(_syncControllers);
    _syncTimer?.cancel();
    super.dispose();
  }
}
