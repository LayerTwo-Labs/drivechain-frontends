import 'package:coinshift/providers/analytics_provider.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

/// Widget for identifying and recovering from swap failures.
class SwapFailureRecoveryWidget extends StatelessWidget {
  const SwapFailureRecoveryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SwapFailureRecoveryViewModel>.reactive(
      viewModelBuilder: () => SwapFailureRecoveryViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Swap Recovery',
          subtitle: 'Manage stuck or problematic swaps',
          child: model.problemSwaps.isEmpty
              ? _NoProblemsView()
              : SailColumn(
                  spacing: SailStyleValues.padding12,
                  children: [
                    _RecoverySummary(model: model),
                    ...model.problemSwaps.map(
                      (swap) => _SwapRecoveryCard(
                        swap: swap,
                        model: model,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _NoProblemsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Center(
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: theme.colors.success,
          ),
          SailText.primary15('No Recovery Needed'),
          SailText.secondary13('All swaps are progressing normally'),
        ],
      ),
    );
  }
}

class _RecoverySummary extends StatelessWidget {
  final SwapFailureRecoveryViewModel model;

  const _RecoverySummary({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.orange.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.orange),
      ),
      child: SailRow(
        spacing: SailStyleValues.padding12,
        children: [
          Icon(Icons.warning_amber, color: theme.colors.orange, size: 24),
          Expanded(
            child: SailText.primary13(
              '${model.problemSwaps.length} swap(s) may need attention',
            ),
          ),
          SailButton(
            label: 'Refresh All',
            small: true,
            variant: ButtonVariant.secondary,
            loading: model.isRefreshing,
            onPressed: () async => await model.refreshAll(),
          ),
        ],
      ),
    );
  }
}

class _SwapRecoveryCard extends StatelessWidget {
  final CoinShiftSwap swap;
  final SwapFailureRecoveryViewModel model;

  const _SwapRecoveryCard({
    required this.swap,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();
    final issue = _getSwapIssue(swap);

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
          border: Border.all(color: theme.colors.divider),
        ),
        child: SailColumn(
          spacing: SailStyleValues.padding12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with swap ID and chain
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailText.primary13(
                      'Swap ${swap.idHex.substring(0, 12)}...',
                      monospace: true,
                    ),
                    InkWell(
                      onTap: () => _copySwapId(context, swap.idHex),
                      child: Icon(
                        Icons.copy,
                        size: 14,
                        color: theme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding08,
                    vertical: SailStyleValues.padding04,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colors.backgroundSecondary,
                    borderRadius: SailStyleValues.borderRadius,
                    border: Border.all(color: theme.colors.divider),
                  ),
                  child: SailText.secondary12(swap.parentChain.value),
                ),
              ],
            ),

            // Issue description
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: issue.color.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadius,
              ),
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Icon(issue.icon, size: 16, color: issue.color),
                  Expanded(
                    child: SailText.secondary12(issue.description, color: issue.color),
                  ),
                ],
              ),
            ),

            // Swap details
            SailRow(
              spacing: SailStyleValues.padding16,
              children: [
                _SwapDetail(label: 'L2 Amount', value: formatter.formatSats(swap.l2Amount)),
                if (swap.l1Amount != null)
                  _SwapDetail(label: 'L1 Amount', value: formatter.formatSats(swap.l1Amount!)),
                _SwapDetail(label: 'State', value: swap.state.state),
              ],
            ),

            // Confirmation progress (if applicable)
            if (swap.state.isWaitingConfirmations) _ConfirmationProgress(swap: swap),

            // Recovery actions
            _RecoveryActions(swap: swap, model: model),
          ],
        ),
      ),
    );
  }

  SwapIssue _getSwapIssue(CoinShiftSwap swap) {
    if (swap.state.isPending) {
      return SwapIssue(
        icon: Icons.hourglass_empty,
        color: Colors.orange,
        description: 'Pending - Waiting for L1 payment to be detected',
      );
    }
    if (swap.state.isWaitingConfirmations) {
      final current = swap.state.currentConfirmations ?? 0;
      final required = swap.state.requiredConfirmations ?? 1;
      if (current < required / 2) {
        return SwapIssue(
          icon: Icons.sync,
          color: Colors.blue,
          description: 'Slow confirmations - $current/$required confirmed',
        );
      }
    }
    return SwapIssue(
      icon: Icons.help_outline,
      color: Colors.grey,
      description: 'Unknown issue - ${swap.state.state}',
    );
  }

  void _copySwapId(BuildContext context, String swapId) {
    Clipboard.setData(ClipboardData(text: swapId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Swap ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class SwapIssue {
  final IconData icon;
  final Color color;
  final String description;

  SwapIssue({
    required this.icon,
    required this.color,
    required this.description,
  });
}

class _SwapDetail extends StatelessWidget {
  final String label;
  final String value;

  const _SwapDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        SailText.primary13(value, monospace: true),
      ],
    );
  }
}

class _ConfirmationProgress extends StatelessWidget {
  final CoinShiftSwap swap;

  const _ConfirmationProgress({required this.swap});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final current = swap.state.currentConfirmations ?? 0;
    final required = swap.state.requiredConfirmations ?? 1;
    final progress = required > 0 ? current / required : 0.0;

    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.secondary12('Confirmations'),
            SailText.primary13('$current / $required', monospace: true),
          ],
        ),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: theme.colors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progress >= 1.0
                    ? theme.colors.success
                    : progress >= 0.5
                        ? theme.colors.info
                        : theme.colors.orange,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecoveryActions extends StatelessWidget {
  final CoinShiftSwap swap;
  final SwapFailureRecoveryViewModel model;

  const _RecoveryActions({
    required this.swap,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SailButton(
          label: 'Refresh Status',
          small: true,
          variant: ButtonVariant.ghost,
          loading: model.isRefreshingSwap(swap.idHex),
          onPressed: () async => await model.refreshSwap(swap.idHex),
        ),
        if (swap.state.isReadyToClaim)
          SailButton(
            label: 'Claim Now',
            small: true,
            variant: ButtonVariant.primary,
            loading: model.isClaimingSwap(swap.idHex),
            onPressed: () async => await model.claimSwap(swap),
          ),
        if (swap.state.isPending)
          SailButton(
            label: 'Update L1 TX',
            small: true,
            variant: ButtonVariant.secondary,
            onPressed: () async => model.showUpdateL1TxDialog(context, swap),
          ),
      ],
    );
  }
}

class SwapFailureRecoveryViewModel extends BaseViewModel {
  AnalyticsProvider get _analyticsProvider => GetIt.I.get<AnalyticsProvider>();
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();

  bool isRefreshing = false;
  final Set<String> _refreshingSwaps = {};
  final Set<String> _claimingSwaps = {};

  List<CoinShiftSwap> get problemSwaps => _analyticsProvider.swapsNeedingAttention;

  SwapFailureRecoveryViewModel() {
    _analyticsProvider.addListener(notifyListeners);
    _swapProvider.addListener(notifyListeners);
  }

  bool isRefreshingSwap(String swapId) => _refreshingSwaps.contains(swapId);
  bool isClaimingSwap(String swapId) => _claimingSwaps.contains(swapId);

  Future<void> refreshAll() async {
    isRefreshing = true;
    notifyListeners();

    await _analyticsProvider.refresh();

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> refreshSwap(String swapId) async {
    _refreshingSwaps.add(swapId);
    notifyListeners();

    await _swapProvider.fetchSwaps();

    _refreshingSwaps.remove(swapId);
    notifyListeners();
  }

  Future<void> claimSwap(CoinShiftSwap swap) async {
    _claimingSwaps.add(swap.idHex);
    notifyListeners();

    try {
      await _swapProvider.claimSwap(swap);
    } finally {
      _claimingSwaps.remove(swap.idHex);
      notifyListeners();
    }
  }

  void showUpdateL1TxDialog(BuildContext context, CoinShiftSwap swap) {
    showDialog(
      context: context,
      builder: (context) => _UpdateL1TxDialog(swap: swap),
    );
  }

  @override
  void dispose() {
    _analyticsProvider.removeListener(notifyListeners);
    _swapProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class _UpdateL1TxDialog extends StatefulWidget {
  final CoinShiftSwap swap;

  const _UpdateL1TxDialog({required this.swap});

  @override
  State<_UpdateL1TxDialog> createState() => _UpdateL1TxDialogState();
}

class _UpdateL1TxDialogState extends State<_UpdateL1TxDialog> {
  final TextEditingController _txidController = TextEditingController();
  final TextEditingController _confirmationsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _txidController.dispose();
    _confirmationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update L1 Transaction'),
      content: SailColumn(
        spacing: SailStyleValues.padding12,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailText.secondary13(
            'Enter the L1 transaction ID and current confirmation count for this swap.',
          ),
          SailTextField(
            controller: _txidController,
            hintText: 'L1 Transaction ID (hex)',
          ),
          SailTextField(
            controller: _confirmationsController,
            hintText: 'Current confirmations',
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_txidController.text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final swapProvider = GetIt.I<SwapProvider>();
      await swapProvider.updateSwapL1Txid(
        swapId: widget.swap.idHex,
        l1TxidHex: _txidController.text,
        confirmations: int.tryParse(_confirmationsController.text) ?? 0,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
