import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:coinshift/widgets/swap/swap_status_badge.dart';

/// Status filter for swaps
enum SwapStatusFilter {
  all('All'),
  pending('Pending'),
  waitingConfirmations('Waiting Confirmations'),
  readyToClaim('Ready To Claim'),
  completed('Completed'),
  cancelled('Cancelled')
  ;

  final String label;
  const SwapStatusFilter(this.label);
}

/// Table widget showing all swaps with claim buttons, filters, and search
class SwapList extends StatelessWidget {
  final bool showOnlyActive;

  const SwapList({super.key, this.showOnlyActive = false});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SwapListViewModel>.reactive(
      viewModelBuilder: () => SwapListViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: showOnlyActive ? 'Active Swaps' : 'My Swaps',
          bottomPadding: false,
          child: Column(
            children: [
              // Header with refresh button and checking status
              Padding(
                padding: const EdgeInsets.all(SailStyleValues.padding08),
                child: SailRow(
                  spacing: SailStyleValues.padding08,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailButton(
                          label: 'Refresh',
                          small: true,
                          variant: ButtonVariant.secondary,
                          loading: model.isLoading,
                          onPressed: () async => await model.refresh(),
                        ),
                        if (model.isCheckingConfirmations)
                          SailText.secondary12(
                            '🔄 Checking confirmations...',
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Success message
              if (model.successMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding08,
                  ),
                  child: _SuccessMessage(
                    message: model.successMessage!,
                    onDismiss: model.clearSuccessMessage,
                  ),
                ),

              // Search and filter row
              Padding(
                padding: const EdgeInsets.all(SailStyleValues.padding08),
                child: SailRow(
                  spacing: SailStyleValues.padding16,
                  children: [
                    // Search by swap ID
                    Expanded(
                      child: SailTextField(
                        controller: model.searchController,
                        hintText: 'Search by Swap ID...',
                        label: '',
                        onSubmitted: (_) => model.searchSwap(),
                        suffixWidget: SailRow(
                          spacing: SailStyleValues.padding04,
                          children: [
                            SailButton(
                              label: 'Search',
                              small: true,
                              variant: ButtonVariant.secondary,
                              onPressed: () async => model.searchSwap(),
                            ),
                            if (model.searchController.text.isNotEmpty)
                              SailButton(
                                label: 'Clear',
                                small: true,
                                variant: ButtonVariant.ghost,
                                onPressed: () async => model.clearSearch(),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Status filter dropdown
                    SailDropdownButton<SwapStatusFilter>(
                      value: model.statusFilter,
                      items: SwapStatusFilter.values
                          .map(
                            (filter) => SailDropdownItem<SwapStatusFilter>(
                              value: filter,
                              label: filter.label,
                            ),
                          )
                          .toList(),
                      onChanged: (filter) {
                        if (filter != null) {
                          model.setStatusFilter(filter);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Search error
              if (model.searchError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding08,
                  ),
                  child: _ErrorMessage(message: model.searchError!),
                ),

              // Searched swap result
              if (model.searchedSwap != null)
                Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding08),
                  child: _SearchedSwapCard(
                    swap: model.searchedSwap!,
                    onClaim: (swap) => model.claimSwap(context, swap),
                  ),
                ),

              const Divider(height: 1),

              // Table
              Expanded(
                child: SailSkeletonizer(
                  description: 'Loading swaps...',
                  enabled: model.isLoading && model.filteredSwaps.isEmpty,
                  child: _SwapTable(
                    swaps: model.filteredSwaps,
                    onClaim: (swap) => model.claimSwap(context, swap),
                    onExpand: model.toggleSwapExpanded,
                    expandedSwapId: model.expandedSwapId,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _SuccessMessage({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding08),
      margin: const EdgeInsets.only(bottom: SailStyleValues.padding08),
      decoration: BoxDecoration(
        color: theme.colors.success.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.success),
      ),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          Icon(Icons.check_circle, color: theme.colors.success, size: 16),
          Expanded(child: SailText.primary13(message, color: theme.colors.success)),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: theme.colors.success),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding08),
      margin: const EdgeInsets.only(bottom: SailStyleValues.padding08),
      decoration: BoxDecoration(
        color: theme.colors.error.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.error),
      ),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          Icon(Icons.error, color: theme.colors.error, size: 16),
          Expanded(child: SailText.primary13(message, color: theme.colors.error)),
        ],
      ),
    );
  }
}

class _SearchedSwapCard extends StatelessWidget {
  final CoinShiftSwap swap;
  final Function(CoinShiftSwap) onClaim;

  const _SearchedSwapCard({required this.swap, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.info.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.info),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13('Searched Swap:', bold: true, color: theme.colors.info),
          SailRow(
            spacing: SailStyleValues.padding16,
            children: [
              SailText.secondary12('ID: ${swap.idHex.substring(0, 16)}...'),
              SailText.secondary12('Chain: ${swap.parentChain.value}'),
              SailText.secondary12('Amount: ${formatter.formatSats(swap.l2Amount)}'),
              SwapStatusBadge(state: swap.state),
            ],
          ),
          if (swap.state.isReadyToClaim)
            SailButton(
              label: 'Claim',
              small: true,
              onPressed: () async => onClaim(swap),
            ),
        ],
      ),
    );
  }
}

class _SwapTable extends StatefulWidget {
  final List<CoinShiftSwap> swaps;
  final Function(CoinShiftSwap) onClaim;
  final Function(String) onExpand;
  final String? expandedSwapId;

  const _SwapTable({
    required this.swaps,
    required this.onClaim,
    required this.onExpand,
    this.expandedSwapId,
  });

  @override
  State<_SwapTable> createState() => _SwapTableState();
}

class _SwapTableState extends State<_SwapTable> {
  String sortColumn = 'created';
  bool sortAscending = false;

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
    });
  }

  List<CoinShiftSwap> get sortedSwaps {
    final sorted = List<CoinShiftSwap>.from(widget.swaps);
    sorted.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'id':
          aValue = a.idHex;
          bValue = b.idHex;
        case 'direction':
          aValue = a.direction.name;
          bValue = b.direction.name;
        case 'chain':
          aValue = a.parentChain.value;
          bValue = b.parentChain.value;
        case 'amount':
          aValue = a.l2Amount;
          bValue = b.l2Amount;
        case 'status':
          aValue = a.state.state;
          bValue = b.state.state;
        case 'created':
        default:
          aValue = a.createdAtHeight;
          bValue = b.createdAtHeight;
      }
      return sortAscending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    if (widget.swaps.isEmpty) {
      return Center(
        child: SailColumn(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SailText.primary15('No swaps found'),
            SailText.secondary12('Swaps will appear here once created'),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => ListView.builder(
        itemCount: sortedSwaps.length,
        itemBuilder: (context, index) {
          final swap = sortedSwaps[index];
          final isExpanded = widget.expandedSwapId == swap.idHex;

          return _SwapRow(
            swap: swap,
            formatter: formatter,
            isExpanded: isExpanded,
            onTap: () => widget.onExpand(swap.idHex),
            onClaim: () => widget.onClaim(swap),
          );
        },
      ),
    );
  }
}

class _SwapRow extends StatelessWidget {
  final CoinShiftSwap swap;
  final FormatterProvider formatter;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onClaim;

  const _SwapRow({
    required this.swap,
    required this.formatter,
    required this.isExpanded,
    required this.onTap,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Column(
      children: [
        // Main row
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding12,
              vertical: SailStyleValues.padding08,
            ),
            decoration: BoxDecoration(
              color: isExpanded ? theme.colors.backgroundSecondary : null,
            ),
            child: SailRow(
              spacing: SailStyleValues.padding16,
              children: [
                // Expand icon
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colors.textSecondary,
                ),

                // ID
                SizedBox(
                  width: 100,
                  child: SailText.primary12(
                    '${swap.idHex.substring(0, 8)}...',
                    monospace: true,
                  ),
                ),

                // Direction
                SizedBox(
                  width: 70,
                  child: SailText.secondary12(
                    swap.direction == SwapDirection.l2ToL1 ? 'L2 → L1' : 'L1 → L2',
                  ),
                ),

                // Chain
                SizedBox(
                  width: 70,
                  child: SailText.secondary12(swap.parentChain.value),
                ),

                // Amount
                SizedBox(
                  width: 120,
                  child: SailText.primary12(
                    formatter.formatSats(swap.l2Amount),
                    monospace: true,
                  ),
                ),

                // Status
                SwapStatusBadge(state: swap.state),

                // Progress bar for waiting confirmations
                if (swap.state.isWaitingConfirmations) ...[
                  SizedBox(
                    width: 100,
                    child: _ConfirmationProgress(
                      current: swap.state.currentConfirmations ?? 0,
                      required: swap.state.requiredConfirmations ?? 1,
                    ),
                  ),
                ],

                const Spacer(),

                // Claim button
                if (swap.state.isReadyToClaim)
                  SailButton(
                    label: 'Claim',
                    small: true,
                    onPressed: () async => onClaim(),
                  ),
              ],
            ),
          ),
        ),

        // Expanded details
        if (isExpanded) _SwapDetails(swap: swap, formatter: formatter),

        const Divider(height: 1),
      ],
    );
  }
}

class _ConfirmationProgress extends StatelessWidget {
  final int current;
  final int required;

  const _ConfirmationProgress({required this.current, required this.required});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final progress = required > 0 ? (current / required).clamp(0.0, 1.0) : 0.0;

    return SailColumn(
      spacing: SailStyleValues.padding04,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colors.backgroundSecondary,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.info),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        SailText.secondary12('$current / $required'),
      ],
    );
  }
}

class _SwapDetails extends StatelessWidget {
  final CoinShiftSwap swap;
  final FormatterProvider formatter;

  const _SwapDetails({required this.swap, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      color: theme.colors.backgroundSecondary,
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending warning
          if (swap.createdAtHeight == 0) ...[
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: theme.colors.error.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadius,
              ),
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Icon(Icons.warning, color: theme.colors.error, size: 16),
                  Expanded(
                    child: SailText.secondary12(
                      'PENDING (in mempool, not yet in block). '
                      'Mine a block or wait for one to be mined to confirm your swap.',
                      color: theme.colors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Details grid
          Wrap(
            spacing: SailStyleValues.padding20,
            runSpacing: SailStyleValues.padding08,
            children: [
              _DetailItem(label: 'Swap ID', value: swap.idHex),
              _DetailItem(label: 'Chain', value: swap.parentChain.value),
              _DetailItem(label: 'State', value: swap.state.toString()),
              _DetailItem(label: 'L2 Amount', value: formatter.formatSats(swap.l2Amount)),
              if (swap.l1Amount != null) _DetailItem(label: 'L1 Amount', value: formatter.formatSats(swap.l1Amount!)),
              _DetailItem(
                label: 'L2 Recipient',
                value: swap.l2Recipient ?? 'Open Swap',
              ),
              if (swap.l1RecipientAddress != null) _DetailItem(label: 'L1 Recipient', value: swap.l1RecipientAddress!),
              if (swap.l1Txid != null) _DetailItem(label: 'L1 TxID', value: swap.l1Txid!),
              _DetailItem(
                label: 'Created',
                value: swap.createdAtHeight == 0 ? 'Pending' : 'Block ${swap.createdAtHeight}',
              ),
              _DetailItem(
                label: 'Required Confirmations',
                value: swap.requiredConfirmations.toString(),
              ),
            ],
          ),

          // Waiting confirmations info
          if (swap.state.isWaitingConfirmations) ...[
            const Divider(),
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: theme.colors.info.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadius,
              ),
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13('⏳ Waiting for Confirmations', bold: true),
                  _ConfirmationProgress(
                    current: swap.state.currentConfirmations ?? 0,
                    required: swap.state.requiredConfirmations ?? 1,
                  ),
                  SailText.secondary12(
                    'Confirmations are checked automatically every 10 seconds.',
                  ),
                ],
              ),
            ),
          ],

          // Pending swap info
          if (swap.state.isPending) ...[
            const Divider(),
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: theme.colors.info.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadius,
              ),
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13('⚠️ For users filling this swap', bold: true),
                  SailText.secondary12(
                    'Only send the L1 transaction to fill this swap after the swap has '
                    '${swap.requiredConfirmations} confirmations from the L2 sidechain.',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 12,
            color: theme.colors.text,
            fontFamily: 'SourceCodePro',
          ),
        ),
      ],
    );
  }
}

class SwapListViewModel extends BaseViewModel {
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();

  final TextEditingController searchController = TextEditingController();

  SwapStatusFilter statusFilter = SwapStatusFilter.all;
  String? expandedSwapId;
  CoinShiftSwap? searchedSwap;
  String? searchError;
  String? successMessage;
  bool isCheckingConfirmations = false;

  List<CoinShiftSwap> get swaps => _swapProvider.swaps;
  List<CoinShiftSwap> get activeSwaps => _swapProvider.activeSwaps;
  bool get isLoading => _swapProvider.isLoading;

  /// Filter swaps by status
  List<CoinShiftSwap> get filteredSwaps {
    return swaps.where((swap) {
      switch (statusFilter) {
        case SwapStatusFilter.all:
          return true;
        case SwapStatusFilter.pending:
          return swap.state.isPending;
        case SwapStatusFilter.waitingConfirmations:
          return swap.state.isWaitingConfirmations;
        case SwapStatusFilter.readyToClaim:
          return swap.state.isReadyToClaim;
        case SwapStatusFilter.completed:
          return swap.state.isCompleted;
        case SwapStatusFilter.cancelled:
          return swap.state.isCancelled;
      }
    }).toList();
  }

  SwapListViewModel() {
    _swapProvider.addListener(notifyListeners);
  }

  void setStatusFilter(SwapStatusFilter filter) {
    statusFilter = filter;
    notifyListeners();
  }

  void toggleSwapExpanded(String swapId) {
    if (expandedSwapId == swapId) {
      expandedSwapId = null;
    } else {
      expandedSwapId = swapId;
    }
    notifyListeners();
  }

  void searchSwap() {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      searchedSwap = null;
      searchError = null;
      notifyListeners();
      return;
    }

    // Search in loaded swaps first
    final matches = swaps.where((swap) => swap.idHex.toLowerCase().startsWith(query.toLowerCase())).toList();

    if (matches.isEmpty) {
      searchError = 'No swap found starting with "$query"';
      searchedSwap = null;
    } else if (matches.length > 1) {
      searchError = 'Multiple swaps found. Please enter more characters.';
      searchedSwap = null;
    } else {
      searchedSwap = matches.first;
      searchError = null;
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    searchedSwap = null;
    searchError = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    successMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _swapProvider.refresh();
  }

  Future<void> claimSwap(BuildContext context, CoinShiftSwap swap) async {
    final txid = await _swapProvider.claimSwap(swap);
    if (txid != null) {
      successMessage = 'Swap claimed successfully! Transaction ID: $txid';
      notifyListeners();
    } else if (_swapProvider.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to claim: ${_swapProvider.error}')),
      );
    }
  }

  @override
  void dispose() {
    _swapProvider.removeListener(notifyListeners);
    searchController.dispose();
    super.dispose();
  }
}
