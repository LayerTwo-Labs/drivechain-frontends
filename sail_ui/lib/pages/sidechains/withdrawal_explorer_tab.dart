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
    return SailCard(
      child: InlineTabBar(
        tabs: [
          const SingleTabItem(
            label: 'Bundle Explorer',
            child: BundleExplorerTab(),
          ),
          const SingleTabItem(
            label: 'Next Bundle',
            child: NextBundleTab(),
          ),
        ],
        initialIndex: 0,
      ),
    );
  }
}

class BundleExplorerTab extends StatelessWidget {
  const BundleExplorerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PendingBundleViewModel(),
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SailText.primary12(
                'Select a withdrawal bundle to show details',
              ),
              SizedBox(
                height: 150,
                child: SailTable(
                  getRowId: (index) => viewModel.bundle!.withdrawalOutputs[index].mainAddress,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(name: 'Sidechain block #'),
                    SailTableHeaderCell(name: 'Hash'),
                    SailTableHeaderCell(name: 'Amount'),
                    SailTableHeaderCell(name: 'Status'),
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
                    ];
                  },
                ),
              ),
              SailCard(
                title: 'Data for bundle <enter hash of bundle here>',
                child: Column(
                  children: [
                    // Bundle summary stats
                    SailCard(
                      child: SailRow(
                        spacing: SailStyleValues.padding16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.primary13('Mainchain status: Pending'),
                              SailText.primary13('Withdrawals: ${viewModel.bundle?.withdrawalOutputs.length ?? 0}'),
                              SailText.primary13('Height Created: ${viewModel.bundle?.heightCreated ?? 0}'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.primary13('Total withdrawal amount: ${viewModel.totalAmount}'),
                              SailText.primary13('Total mainchain fees: ${viewModel.totalFees}'),
                              SailText.primary13('Total size: ${viewModel.totalSize}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 300,
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
            ],
          ),
        );
      },
    );
  }
}

class NextBundleTab extends StatelessWidget {
  const NextBundleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => NextBundleViewModel(),
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary12(
              'Candidate withdrawals sorted by mainchain fee. (Each consumes 136 mainchain vBytes.)',
              italic: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SailTable(
                getRowId: (index) => viewModel.bundle!.withdrawalOutputs[index].mainAddress,
                headerBuilder: (context) => [
                  SailTableHeaderCell(name: 'Amount (sats)'),
                  SailTableHeaderCell(name: 'Mainchain Fee (sats)'),
                  SailTableHeaderCell(name: 'Destination Address'),
                  SailTableHeaderCell(name: 'Cumulative WithdrawalBundle weight'),
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
        );
      },
    );
  }
}

class PendingBundleViewModel extends BaseViewModel {
  final SidechainRPC sidechainRPC = GetIt.I.get<SidechainRPC>();

  PendingWithdrawalBundle? bundle;
  Timer? _refreshTimer;

  int get totalAmount => bundle?.withdrawalOutputs.fold<int>(0, (sum, w) => sum + w.valueSats) ?? 0;
  int get totalFees => bundle?.withdrawalOutputs.fold<int>(0, (sum, w) => sum + w.mainFeeSats) ?? 0;
  int get totalSize => (bundle?.withdrawalOutputs.length ?? 0) * 34;

  PendingBundleViewModel() {
    fetchBundle();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (_) => fetchBundle());
  }

  Future<void> fetchBundle() async {
    try {
      final response = await sidechainRPC.getPendingWithdrawalBundle();
      // Only notify if the bundle actually changed
      if (bundle?.toJson() != response?.toJson()) {
        bundle = response;
        notifyListeners();
      }
    } catch (e) {
      // Only notify if the bundle actually changed (from non-null to null)
      if (bundle != null) {
        bundle = null;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

class NextBundleViewModel extends BaseViewModel {
  final SidechainRPC sidechainRPC = GetIt.I.get<SidechainRPC>();

  PendingWithdrawalBundle? bundle;
  Timer? _refreshTimer;

  int get totalAmount => bundle?.withdrawalOutputs.fold<int>(0, (sum, w) => sum + w.valueSats) ?? 0;
  int get totalFees => bundle?.withdrawalOutputs.fold<int>(0, (sum, w) => sum + w.mainFeeSats) ?? 0;
  int get totalSize => (bundle?.withdrawalOutputs.length ?? 0) * 34;

  NextBundleViewModel() {
    fetchBundle();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (_) => fetchBundle());
  }

  Future<void> fetchBundle() async {
    try {
      final response = await sidechainRPC.getPendingWithdrawalBundle();
      // Only notify if the bundle actually changed
      if (bundle?.toJson() != response?.toJson()) {
        bundle = response;
        notifyListeners();
      }
    } catch (e) {
      // Only notify if the bundle actually changed (from non-null to null)
      if (bundle != null) {
        bundle = null;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
