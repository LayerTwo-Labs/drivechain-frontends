import 'package:bitwindow/providers/cheque_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:stacked/stacked.dart';

class ChequesTabViewModel extends BaseViewModel {
  final ChequeProvider _chequeProvider = GetIt.I.get<ChequeProvider>();
  bool _wasUnlocked = true;

  List<Cheque> get cheques => _chequeProvider.cheques;
  bool get isLoading => _chequeProvider.isLoading;
  @override
  String? get modelError => _chequeProvider.modelError;
  bool get isWalletUnlocked => _chequeProvider.isWalletUnlocked;

  ChequesTabViewModel() {
    _chequeProvider.addListener(_onChequeProviderChanged);
    _wasUnlocked = _chequeProvider.isWalletUnlocked;
  }

  void _onChequeProviderChanged() {
    notifyListeners();
  }

  Future<void> refresh() async {
    await _chequeProvider.fetch();
  }

  Future<bool> unlockWallet(String password) async {
    return await _chequeProvider.unlockWallet(password);
  }

  void createNewCheque(BuildContext context) {
    GetIt.I.get<AppRouter>().push(const CreateChequeRoute());
  }

  void cashCheque(BuildContext context) {
    GetIt.I.get<AppRouter>().push(const CashChequeRoute());
  }

  bool checkWalletLocked() {
    if (_wasUnlocked && !_chequeProvider.isWalletUnlocked) {
      _wasUnlocked = false;
      return true;
    }
    _wasUnlocked = _chequeProvider.isWalletUnlocked;
    return false;
  }

  @override
  void dispose() {
    _chequeProvider.removeListener(_onChequeProviderChanged);
    super.dispose();
  }
}

class ChequesTab extends StatelessWidget {
  const ChequesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChequesTabViewModel>.reactive(
      viewModelBuilder: () => ChequesTabViewModel(),
      onViewModelReady: (model) => model.refresh(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Your Checks',
          error: model.modelError,
          bottomPadding: false,
          widgetHeaderEnd: model.cheques.isNotEmpty
              ? SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Cash Cheque',
                      variant: ButtonVariant.secondary,
                      onPressed: () async => model.cashCheque(context),
                    ),
                    SailButton(
                      label: 'Create New Cheque',
                      onPressed: () async => model.createNewCheque(context),
                    ),
                  ],
                )
              : null,
          child: model.cheques.isEmpty
              ? Center(
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SailText.primary15('No cheques yet'),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SailButton(
                            label: 'Cash a Cheque',
                            variant: ButtonVariant.secondary,
                            onPressed: () async => model.cashCheque(context),
                          ),
                          SailButton(
                            label: 'Create Your First Cheque',
                            onPressed: () async => model.createNewCheque(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : ChequesTable(cheques: model.cheques),
        );
      },
    );
  }
}

class ChequesTable extends StatelessWidget {
  final List<Cheque> cheques;

  const ChequesTable({
    super.key,
    required this.cheques,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SailTable(
        drawGrid: true,
        getRowId: (index) => cheques[index].id.toString(),
        headerBuilder: (context) => [
          SailTableHeaderCell(name: 'Created'),
          SailTableHeaderCell(name: 'Address'),
          SailTableHeaderCell(name: 'Expected Amount'),
          SailTableHeaderCell(name: 'Status'),
          SailTableHeaderCell(name: 'Funded Amount'),
          SailTableHeaderCell(name: 'Actions'),
        ],
        rowBuilder: (context, row, selected) {
          final cheque = cheques[row];
          return [
            SailTableCell(value: _formatDate(cheque.createdAt)),
            SailTableCell(
              value: _truncateAddress(cheque.address),
              copyValue: cheque.address,
            ),
            SailTableCell(value: _formatSats(cheque.expectedAmountSats.toInt())),
            SailTableCell(
              value: cheque.hasSweptTxid() && cheque.sweptTxid.isNotEmpty
                  ? 'Swept'
                  : cheque.hasFundedTxid()
                  ? 'Funded'
                  : 'Unfunded',
              textColor: cheque.hasSweptTxid() && cheque.sweptTxid.isNotEmpty
                  ? context.sailTheme.colors.text.withValues(alpha: 0.5)
                  : cheque.hasFundedTxid()
                  ? context.sailTheme.colors.success
                  : context.sailTheme.colors.orange,
            ),
            SailTableCell(
              value: cheque.hasFundedTxid() && cheque.hasActualAmountSats()
                  ? _formatSats(cheque.actualAmountSats.toInt())
                  : '-',
            ),
            SailTableCell(
              value: 'View Details      ',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cheque.hasSweptTxid() && cheque.sweptTxid.isNotEmpty)
                    SailButton(
                      label: 'Swept',
                      onPressed: () async => _viewCheque(context, cheque),
                      variant: ButtonVariant.secondary,
                      insideTable: true,
                      disabled: true,
                    )
                  else
                    SailButton(
                      label: cheque.hasFundedTxid() ? 'View Details' : 'Fund Cheque',
                      onPressed: () async => _viewCheque(context, cheque),
                      variant: cheque.hasFundedTxid() ? ButtonVariant.secondary : ButtonVariant.primary,
                      insideTable: true,
                    ),
                  const SizedBox(width: SailStyleValues.padding08),
                  SailButton(
                    icon: SailSVGAsset.iconDelete,
                    onPressed: () async => _deleteCheque(context, cheque),
                    variant: ButtonVariant.destructive,
                    insideTable: true,
                  ),
                ],
              ),
            ),
          ];
        },
        rowCount: cheques.length,
        onDoubleTap: (rowId) {
          final cheque = cheques.firstWhere((c) => c.id.toString() == rowId);
          _viewCheque(context, cheque);
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

  void _viewCheque(BuildContext context, Cheque cheque) {
    GetIt.I.get<AppRouter>().push(ChequeDetailRoute(chequeId: cheque.id.toInt()));
  }

  Future<void> _deleteCheque(BuildContext context, Cheque cheque) async {
    if (cheque.hasFundedTxid() && !cheque.hasSweptTxid()) {
      showSnackBar(context, 'Cannot delete funded cheque. Sweep the funds first.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SailTheme.of(context).colors.background,
        title: SailText.primary15('Delete Cheque'),
        content: SailColumn(
          spacing: SailStyleValues.padding12,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Are you sure you want to delete this check?'),
            if (!cheque.hasFundedTxid() || cheque.hasSweptTxid())
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
      final chequeProvider = GetIt.I.get<ChequeProvider>();
      final success = await chequeProvider.deleteCheque(cheque.id.toInt());

      if (!context.mounted) return;

      if (success) {
        showSnackBar(context, 'Check deleted successfully');
      } else {
        showSnackBar(context, chequeProvider.modelError ?? 'Failed to delete cheque');
      }
    }
  }
}
