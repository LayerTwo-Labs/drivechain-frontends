import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

// From testchain-deprecated/src/policy/withdrawalbundle.h
// MAX_WITHDRAWAL_BUNDLE_WEIGHT = (CORE_MAX_STANDARD_TX_WEIGHT / CORE_WITNESS_SCALE_FACTOR) / 2
// = (400000 / 4) / 2 = 50000
const int maxWithdrawalBundleWeight = 50000;

// Base weight for a withdrawal bundle transaction (overhead + OP_RETURN outputs)
const int baseWithdrawalBundleWeight = 288;

// Weight per P2PKH output (~34 bytes × 4 = 136 weight units)
const int weightPerWithdrawalOutput = 136;

class WithdrawalExplorerTab extends StatelessWidget {
  const WithdrawalExplorerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: InlineTabBar(
        tabs: [
          const SingleTabItem(label: 'Bundle Explorer', child: BundleExplorerTab()),
          const SingleTabItem(label: 'Next Bundle', child: NextBundleTab()),
        ],
        initialIndex: 0,
      ),
    );
  }
}

class BundleExplorerTab extends StatelessWidget {
  const BundleExplorerTab({super.key});

  void _showBundleHistoryDialog(BuildContext context, PendingBundleViewModel viewModel) {
    final theme = SailTheme.of(context);
    showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SailText.primary15('Bundle History'),
          content: SizedBox(
            width: 500,
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Bundle Info
                SailText.primary13('Current Bundle', bold: true),
                Container(
                  padding: const EdgeInsets.all(SailStyleValues.padding12),
                  decoration: BoxDecoration(
                    color: viewModel.bundle != null
                        ? theme.colors.success.withValues(alpha: 0.1)
                        : theme.colors.backgroundSecondary,
                    borderRadius: SailStyleValues.borderRadiusSmall,
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: viewModel.bundle != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BundleInfoRow(label: 'Status', value: 'Pending'),
                            _BundleInfoRow(
                              label: 'Height Created',
                              value: viewModel.bundle!.heightCreated.toString(),
                            ),
                            _BundleInfoRow(
                              label: 'Withdrawals',
                              value: viewModel.bundle!.withdrawalOutputs.length.toString(),
                            ),
                            _BundleInfoRow(
                              label: 'Total Amount',
                              value: '${viewModel.totalAmount} sats',
                            ),
                            _BundleInfoRow(
                              label: 'Total Fees',
                              value: '${viewModel.totalFees} sats',
                            ),
                          ],
                        )
                      : SailText.secondary13('No pending bundle'),
                ),

                Divider(color: theme.colors.divider),

                // Last Failed Bundle
                SailText.primary13('Last Failed Bundle', bold: true),
                Container(
                  padding: const EdgeInsets.all(SailStyleValues.padding12),
                  decoration: BoxDecoration(
                    color: viewModel.lastFailedHeight != null
                        ? theme.colors.error.withValues(alpha: 0.1)
                        : theme.colors.backgroundSecondary,
                    borderRadius: SailStyleValues.borderRadiusSmall,
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: viewModel.lastFailedHeight != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BundleInfoRow(
                              label: 'Failed at Height',
                              value: viewModel.lastFailedHeight.toString(),
                              valueColor: theme.colors.error,
                            ),
                            const SizedBox(height: 4),
                            SailText.secondary12(
                              'This bundle failed to be included in the mainchain and was rejected.',
                              italic: true,
                            ),
                          ],
                        )
                      : SailText.secondary13('No failed bundles recorded'),
                ),

                Divider(color: theme.colors.divider),

                // Note about limitations
                Container(
                  padding: const EdgeInsets.all(SailStyleValues.padding08),
                  decoration: BoxDecoration(
                    color: theme.colors.info.withValues(alpha: 0.1),
                    borderRadius: SailStyleValues.borderRadiusSmall,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: theme.colors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SailText.primary12(
                          'Full bundle history requires backend support. Currently showing current bundle and last failed height only.',
                          color: theme.colors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SailButton(
              label: 'Close',
              variant: ButtonVariant.secondary,
              onPressed: () async => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PendingBundleViewModel(),
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bundle Status Header
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                margin: const EdgeInsets.only(bottom: SailStyleValues.padding16),
                decoration: BoxDecoration(
                  color: viewModel.bundle != null
                      ? theme.colors.success.withValues(alpha: 0.1)
                      : theme.colors.orange.withValues(alpha: 0.1),
                  borderRadius: SailStyleValues.borderRadiusSmall,
                  border: Border.all(
                    color: viewModel.bundle != null
                        ? theme.colors.success.withValues(alpha: 0.3)
                        : theme.colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                viewModel.bundle != null ? Icons.pending_actions : Icons.hourglass_empty,
                                size: 20,
                                color: viewModel.bundle != null ? theme.colors.success : theme.colors.orange,
                              ),
                              const SizedBox(width: 8),
                              SailText.primary13(
                                viewModel.bundle != null
                                    ? 'Pending Bundle: ${viewModel.bundle!.withdrawalOutputs.length} withdrawals'
                                    : 'No pending withdrawal bundle',
                                bold: true,
                              ),
                            ],
                          ),
                          if (viewModel.lastFailedHeight != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.error_outline, size: 16, color: theme.colors.error),
                                const SizedBox(width: 4),
                                SailText.primary12(
                                  'Last failed bundle at height: ${viewModel.lastFailedHeight}',
                                  color: theme.colors.error,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SailButton(
                      label: 'Bundle History',
                      variant: ButtonVariant.secondary,
                      onPressed: () async => _showBundleHistoryDialog(context, viewModel),
                    ),
                  ],
                ),
              ),
              SailText.primary12('Select a withdrawal bundle to show details'),
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
                      SailTableCell(value: withdrawal.valueSats.toString(), monospace: true),
                      SailTableCell(value: withdrawal.mainFeeSats.toString(), monospace: true),
                      SailTableCell(value: withdrawal.mainAddress, copyValue: withdrawal.mainAddress, monospace: true),
                    ];
                  },
                  rowCount: viewModel.bundle?.withdrawalOutputs.length ?? 0,
                  drawGrid: true,
                  contextMenuItems: (rowId) {
                    final withdrawal = viewModel.bundle!.withdrawalOutputs.firstWhere((w) => w.mainAddress == rowId);
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
                title: 'Bundle Details',
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
                            SailTableCell(value: withdrawal.valueSats.toString(), monospace: true),
                            SailTableCell(value: withdrawal.mainFeeSats.toString(), monospace: true),
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
                                        SailButton(label: 'Close', onPressed: () async => Navigator.of(context).pop()),
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

  /// Calculate cumulative weight for a withdrawal at the given index
  /// Each withdrawal output adds ~136 weight units to the bundle
  int getCumulativeWeight(int index) {
    // Base weight for the bundle transaction (version, locktime, OP_RETURN outputs, etc.)
    // Plus weight for each output up to and including this index
    return baseWithdrawalBundleWeight + ((index + 1) * weightPerWithdrawalOutput);
  }

  /// Check if a withdrawal at the given index will exceed the bundle weight limit
  bool exceedsWeightLimit(int index) {
    return getCumulativeWeight(index) > maxWithdrawalBundleWeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => NextBundleViewModel(),
      builder: (context, viewModel, child) {
        final outputs = viewModel.filteredOutputs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SailText.primary12(
                    'Candidate withdrawals sorted by mainchain fee. (Each consumes ~$weightPerWithdrawalOutput weight units.)',
                    italic: true,
                  ),
                ),
                // Mine Only toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailToggle(
                      label: 'Mine Only',
                      value: viewModel.mineOnly,
                      onChanged: viewModel.toggleMineOnly,
                    ),
                    if (viewModel.mineOnly && viewModel.myAddresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Tooltip(
                          message: 'No addresses found in enforcer wallet',
                          child: Icon(Icons.warning_amber, size: 16, color: theme.colors.orange),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SailTable(
                getRowId: (index) => outputs[index].mainAddress,
                headerBuilder: (context) => [
                  SailTableHeaderCell(name: 'Amount (sats)'),
                  SailTableHeaderCell(name: 'Mainchain Fee (sats)'),
                  SailTableHeaderCell(name: 'Destination Address'),
                  SailTableHeaderCell(name: 'Cumulative Bundle Weight'),
                ],
                rowBuilder: (context, row, selected) {
                  final withdrawal = outputs[row];
                  final cumulativeWeight = getCumulativeWeight(row);
                  final weightDisplay = '$cumulativeWeight / $maxWithdrawalBundleWeight';

                  return [
                    SailTableCell(value: withdrawal.valueSats.toString(), monospace: true),
                    SailTableCell(value: withdrawal.mainFeeSats.toString(), monospace: true),
                    SailTableCell(value: withdrawal.mainAddress, copyValue: withdrawal.mainAddress, monospace: true),
                    SailTableCell(
                      value: weightDisplay,
                      monospace: true,
                      alignment: Alignment.centerRight,
                    ),
                  ];
                },
                rowCount: outputs.length,
                drawGrid: true,
                // RED highlighting for withdrawals that won't fit in the bundle
                rowBackgroundColor: (index) {
                  if (exceedsWeightLimit(index)) {
                    return theme.colors.error.withValues(alpha: 0.7);
                  }
                  return null;
                },
                contextMenuItems: (rowId) {
                  final withdrawal = outputs.firstWhere((w) => w.mainAddress == rowId);
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
                              actions: [SailButton(label: 'Close', onPressed: () async => Navigator.of(context).pop())],
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
  int? lastFailedHeight;
  Timer? _refreshTimer;

  int get totalAmount => bundle?.withdrawalOutputs.fold<int>(0, (sum, w) => sum + w.valueSats) ?? 0;
  int get totalFees => bundle?.withdrawalOutputs.fold<int>(0, (sum, w) => sum + w.mainFeeSats) ?? 0;
  int get totalSize => (bundle?.withdrawalOutputs.length ?? 0) * 34;

  PendingBundleViewModel() {
    fetchBundle();
    fetchLastFailedHeight();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (_) {
      fetchBundle();
      fetchLastFailedHeight();
    });
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

  Future<void> fetchLastFailedHeight() async {
    try {
      final response = await sidechainRPC.getLatestFailedWithdrawalBundleHeight();
      if (lastFailedHeight != response) {
        lastFailedHeight = response;
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors
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
  EnforcerRPC? get enforcerRPC => GetIt.I.isRegistered<EnforcerRPC>() ? GetIt.I.get<EnforcerRPC>() : null;

  PendingWithdrawalBundle? bundle;
  Timer? _refreshTimer;
  bool mineOnly = false;
  Set<String> myAddresses = {};

  /// Get filtered withdrawal outputs based on mineOnly toggle
  List<WithdrawalOutput> get filteredOutputs {
    if (bundle == null) return [];
    if (!mineOnly || myAddresses.isEmpty) return bundle!.withdrawalOutputs;
    return bundle!.withdrawalOutputs.where((w) => myAddresses.contains(w.mainAddress)).toList();
  }

  int get totalAmount => filteredOutputs.fold<int>(0, (sum, w) => sum + w.valueSats);
  int get totalFees => filteredOutputs.fold<int>(0, (sum, w) => sum + w.mainFeeSats);
  int get totalSize => filteredOutputs.length * 34;

  NextBundleViewModel() {
    fetchBundle();
    fetchMyAddresses();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (_) => fetchBundle());
  }

  void toggleMineOnly(bool value) {
    mineOnly = value;
    notifyListeners();
  }

  Future<void> fetchMyAddresses() async {
    try {
      if (enforcerRPC == null) return;
      final addresses = await enforcerRPC!.getAddresses();
      myAddresses = addresses.toSet();
      notifyListeners();
    } catch (e) {
      // Ignore errors - addresses will be empty
    }
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

class _BundleInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BundleInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.primary12(label),
          SailText.primary12(value, bold: true, color: valueColor),
        ],
      ),
    );
  }
}
