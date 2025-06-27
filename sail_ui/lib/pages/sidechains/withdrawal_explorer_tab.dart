import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class WithdrawalExplorerTab extends StatelessWidget {
  const WithdrawalExplorerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => WithdrawalExplorerViewModel(),
      builder: (context, viewModel, child) {
        return SailSkeletonizer(
          description: 'Loading withdrawal bundle...',
          enabled: viewModel.isBusy,
          child: viewModel.bundle == null
              ? const Center(child: Text('No pending bundle'))
              : SailCard(
                  title: 'Pending Withdrawal Bundle',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary15('Withdrawals bundled:'),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: SailTable(
                          getRowId: (index) => viewModel.bundle!.withdrawalOutputs[index].mainAddress,
                          headerBuilder: (context) => [
                            SailTableHeaderCell(name: 'Amount (sats)'),
                            SailTableHeaderCell(name: 'Mainchain Fee (sats)'),
                            SailTableHeaderCell(name: 'Destination Address'),
                          ],
                          rowBuilder: (context, row, selected) {
                            final withdrawal = viewModel.bundle!.withdrawalOutputs[row];
                            return [
                              SailTableCell(
                                value: withdrawal.valueSats.toString(),
                                monospace: true,
                              ),
                              SailTableCell(
                                value: withdrawal.mainFeeSats.toString(),
                                monospace: true,
                              ),
                              SailTableCell(
                                value: withdrawal.mainAddress,
                                copyValue: withdrawal.mainAddress,
                                monospace: true,
                              ),
                            ];
                          },
                          rowCount: viewModel.bundle?.withdrawalOutputs.length ?? 0,
                          drawGrid: true,
                          contextMenuItems: (rowId) {
                            final withdrawal = viewModel.bundle!.withdrawalOutputs.firstWhere(
                              (w) => w.mainAddress == rowId,
                            );
                            return [
                              SailMenuItem(
                                onSelected: () {
                                  // Copy destination address to clipboard
                                  Clipboard.setData(ClipboardData(text: withdrawal.mainAddress));
                                },
                                child: SailText.primary12('Copy Address'),
                              ),
                              SailMenuItem(
                                onSelected: () {
                                  // Show withdrawal details in a dialog
                                  showThemedDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: SailText.primary15('Withdrawal Details'),
                                        content: SailColumn(
                                          spacing: SailStyleValues.padding08,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SailText.primary12('Amount: ${withdrawal.valueSats} sats'),
                                            SailText.primary12('Mainchain Fee: ${withdrawal.mainFeeSats} sats'),
                                            SailText.primary12('Destination: ${withdrawal.mainAddress}'),
                                            SailText.primary12(
                                              'Total Value: ${withdrawal.valueSats + withdrawal.mainFeeSats} sats',
                                            ),
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
                ),
        );
      },
    );
  }
}

class WithdrawalExplorerViewModel extends BaseViewModel {
  final SidechainRPC sidechainRPC = GetIt.I.get<SidechainRPC>();

  PendingWithdrawalBundle? bundle;
  Timer? _refreshTimer;

  WithdrawalExplorerViewModel() {
    fetchBundle();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (_) => fetchBundle());
  }

  Future<void> fetchBundle() async {
    setBusy(true);
    try {
      final response = await sidechainRPC.getPendingWithdrawalBundle();
      bundle = response;
    } catch (e) {
      bundle = null;
    }
    setBusy(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
