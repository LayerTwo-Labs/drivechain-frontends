import 'package:bitwindow/providers/check_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:stacked/stacked.dart';

class ChecksTabViewModel extends BaseViewModel {
  final CheckProvider _checkProvider = GetIt.I.get<CheckProvider>();

  List<Cheque> get checks => _checkProvider.checks;
  bool get isLoading => _checkProvider.isLoading;
  @override
  String? get modelError => _checkProvider.modelError;

  ChecksTabViewModel() {
    _checkProvider.addListener(_onCheckProviderChanged);
  }

  void _onCheckProviderChanged() {
    notifyListeners();
  }

  Future<void> refresh() async {
    await _checkProvider.fetch();
  }

  void createNewCheck(BuildContext context) {
    GetIt.I.get<AppRouter>().push(const CreateCheckRoute());
  }

  void cashCheck(BuildContext context) {
    GetIt.I.get<AppRouter>().push(const CashCheckRoute());
  }

  @override
  void dispose() {
    _checkProvider.removeListener(_onCheckProviderChanged);
    super.dispose();
  }
}

class ChecksTab extends StatelessWidget {
  const ChecksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChecksTabViewModel>.reactive(
      viewModelBuilder: () => ChecksTabViewModel(),
      onViewModelReady: (model) => model.refresh(),
      builder: (context, model, child) {
        return SailCard(
          title: model.checks.isEmpty ? 'Send Bitcoin Without an Internet Connection' : 'Your Checks',
          subtitle: model.checks.isEmpty
              ? "Checks let you transfer Bitcoin to anyone. Create a check with a specific amount, and the recipient can cash it later when they're ready to claim the bitcoin."
              : null,
          error: model.modelError,
          bottomPadding: false,
          widgetHeaderEnd: model.checks.isNotEmpty
              ? SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Cash Check',
                      variant: ButtonVariant.secondary,
                      onPressed: () async => model.cashCheck(context),
                    ),
                    SailButton(
                      label: 'Create New Check',
                      onPressed: () async => model.createNewCheck(context),
                    ),
                  ],
                )
              : null,
          child: model.checks.isEmpty
              ? ChecksEmptyState(
                  onCreateCheck: () => model.createNewCheck(context),
                  onCashCheck: () => model.cashCheck(context),
                )
              : ChecksTable(checks: model.checks),
        );
      },
    );
  }
}

class ChecksEmptyState extends StatelessWidget {
  final VoidCallback onCreateCheck;
  final VoidCallback onCashCheck;

  const ChecksEmptyState({
    super.key,
    required this.onCreateCheck,
    required this.onCashCheck,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(SailStyleValues.padding20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('How It Works'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(
              '1. Create a check for a specific amount\n'
              '2. Share the check data with anyone (QR code, text, print on paper)\n'
              '3. The recipient cashes the check when convenient\n'
              '4. Funds move directly to their wallet',
            ),
            const SailSpacing(SailStyleValues.padding20),
            SailText.primary15('Why Use Checks?'),
            const SailSpacing(SailStyleValues.padding08),
            SailText.secondary13(
              "• Gift Bitcoin without needing the recipient's address upfront\n"
              "• Pay someone who's currently offline\n"
              '• Pre-fund payments that can be claimed later\n'
              '• Share value via any communication channel',
            ),
            const SailSpacing(SailStyleValues.padding20),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Cash a Check',
                  variant: ButtonVariant.secondary,
                  onPressed: () async => onCashCheck(),
                ),
                SailButton(
                  label: 'Create Your First Check',
                  onPressed: () async => onCreateCheck(),
                ),
                Expanded(child: Container()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChecksTable extends StatelessWidget {
  final List<Cheque> checks;

  const ChecksTable({
    super.key,
    required this.checks,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SailTable(
        drawGrid: true,
        getRowId: (index) => checks[index].id.toString(),
        headerBuilder: (context) => [
          SailTableHeaderCell(name: 'Created'),
          SailTableHeaderCell(name: 'Address'),
          SailTableHeaderCell(name: 'Expected Amount'),
          SailTableHeaderCell(name: 'Status'),
          SailTableHeaderCell(name: 'Funded Amount'),
          SailTableHeaderCell(name: 'Actions'),
        ],
        rowBuilder: (context, row, selected) {
          final check = checks[row];
          return [
            SailTableCell(value: _formatDate(check.createdAt)),
            SailTableCell(
              value: _truncateAddress(check.address),
              copyValue: check.address,
            ),
            SailTableCell(value: _formatSats(check.expectedAmountSats.toInt())),
            SailTableCell(
              value: check.hasSweptTxid() && check.sweptTxid.isNotEmpty
                  ? 'Swept'
                  : check.hasFundedTxid()
                  ? 'Funded'
                  : 'Unfunded',
              textColor: check.hasSweptTxid() && check.sweptTxid.isNotEmpty
                  ? context.sailTheme.colors.text.withValues(alpha: 0.5)
                  : check.hasFundedTxid()
                  ? context.sailTheme.colors.success
                  : context.sailTheme.colors.orange,
            ),
            SailTableCell(
              value: check.hasFundedTxid() && check.hasActualAmountSats()
                  ? _formatSats(check.actualAmountSats.toInt())
                  : '-',
            ),
            SailTableCell(
              value: 'View Details      ',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (check.hasSweptTxid() && check.sweptTxid.isNotEmpty)
                    SailButton(
                      label: 'Swept',
                      onPressed: () async => _viewCheck(context, check),
                      variant: ButtonVariant.secondary,
                      insideTable: true,
                      disabled: true,
                    )
                  else
                    SailButton(
                      label: check.hasFundedTxid() ? 'View Details' : 'Fund Check',
                      onPressed: () async => _viewCheck(context, check),
                      variant: check.hasFundedTxid() ? ButtonVariant.secondary : ButtonVariant.primary,
                      insideTable: true,
                    ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    icon: SailSVGAsset.iconDelete,
                    onPressed: () async => _deleteCheck(context, check),
                    variant: ButtonVariant.destructive,
                    insideTable: true,
                  ),
                ],
              ),
            ),
          ];
        },
        rowCount: checks.length,
        onDoubleTap: (rowId) {
          final check = checks.firstWhere((c) => c.id.toString() == rowId);
          _viewCheck(context, check);
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        timestamp.seconds * 1000 + timestamp.nanos ~/ 1000000,
      );
      return DateFormat('MMM d, yyyy HH:mm').format(dt);
    } catch (e) {
      return '-';
    }
  }

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 10)}';
  }

  String _formatSats(int sats) {
    final btc = sats / 100000000;
    return '${btc.toStringAsFixed(8)} BTC';
  }

  void _viewCheck(BuildContext context, Cheque check) {
    GetIt.I.get<AppRouter>().push(CheckDetailRoute(checkId: check.id.toInt()));
  }

  Future<void> _deleteCheck(BuildContext context, Cheque check) async {
    if (check.hasFundedTxid() && !check.hasSweptTxid()) {
      showSnackBar(context, 'Cannot delete funded check. Sweep the funds first.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SailTheme.of(context).colors.background,
        title: SailText.primary15('Delete Check'),
        content: SailColumn(
          spacing: SailStyleValues.padding12,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Are you sure you want to delete this check?'),
            if (!check.hasFundedTxid() || check.hasSweptTxid())
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  color: context.sailTheme.colors.orange.withValues(alpha: 0.1),
                  borderRadius: SailStyleValues.borderRadiusSmall,
                  border: Border.all(
                    color: context.sailTheme.colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    SailSVG.icon(SailSVGAsset.iconWarning, width: 16),
                    const SizedBox(width: SailStyleValues.padding08),
                    Flexible(
                      child: SailText.secondary12(
                        'Make sure you have backed up the private key if funds were sent to this address.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          SailButton(
            label: 'Cancel',
            variant: ButtonVariant.ghost,
            onPressed: () async => Navigator.of(context).pop(false),
          ),
          SailButton(
            label: 'Delete',
            variant: ButtonVariant.destructive,
            onPressed: () async => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final checkProvider = GetIt.I.get<CheckProvider>();
      final success = await checkProvider.deleteCheck(check.id.toInt());

      if (!context.mounted) return;

      if (success) {
        showSnackBar(context, 'Check deleted successfully');
      } else {
        showSnackBar(context, checkProvider.modelError ?? 'Failed to delete check');
      }
    }
  }
}
