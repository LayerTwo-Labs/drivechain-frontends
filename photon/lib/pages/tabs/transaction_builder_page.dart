import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class TransactionBuilderPage extends StatelessWidget {
  const TransactionBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<TransactionBuilderViewModel>.reactive(
        viewModelBuilder: () => TransactionBuilderViewModel(),
        builder: (context, model, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel - UTXO selector
              Expanded(
                flex: 2,
                child: _UtxoSelectorPanel(model: model),
              ),
              const SizedBox(width: SailStyleValues.padding16),
              // Right panel - Transaction creator
              Expanded(
                flex: 3,
                child: _TransactionCreatorPanel(model: model),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UtxoSelectorPanel extends StatelessWidget {
  final TransactionBuilderViewModel model;

  const _UtxoSelectorPanel({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return SailCard(
      title: 'Wallet UTXOs',
      subtitle: 'Available funds to spend',
      bottomPadding: false,
      widgetHeaderEnd: SailButton(
        label: 'Refresh',
        variant: ButtonVariant.secondary,
        small: true,
        onPressed: model.refreshUtxos,
        loading: model.isLoadingUtxos,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadiusSmall,
            ),
            child: ListenableBuilder(
              listenable: formatter,
              builder: (context, child) => SailRow(
                spacing: SailStyleValues.padding16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.secondary13('Total Available'),
                      SailText.primary15(formatter.formatSats(model.totalAvailable), bold: true),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.secondary13('Selected'),
                      SailText.primary15(formatter.formatSats(model.selectedValue), bold: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SailStyleValues.padding08),
          // UTXO list
          Expanded(
            child: model.utxoError != null
                ? Center(child: SailText.primary13(model.utxoError!, color: theme.colors.error))
                : ListenableBuilder(
                    listenable: formatter,
                    builder: (context, child) => SailTable(
                      getRowId: (index) => model.walletUtxos[index].outpoint,
                      headerBuilder: (context) => [
                        SailTableHeaderCell(name: ''),
                        SailTableHeaderCell(name: 'Outpoint'),
                        SailTableHeaderCell(name: 'Value'),
                      ],
                      rowBuilder: (context, row, selected) {
                        final utxo = model.walletUtxos[row];
                        final isSelected = model.selectedUtxos.contains(utxo.outpoint);
                        return [
                          SailTableCell(
                            value: '',
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (_) => model.toggleUtxo(utxo.outpoint),
                            ),
                          ),
                          SailTableCell(
                            value: _truncateOutpoint(utxo.outpoint),
                            copyValue: utxo.outpoint,
                            monospace: true,
                          ),
                          SailTableCell(
                            value: formatter.formatSats(utxo.valueSats.toInt()),
                            monospace: true,
                          ),
                        ];
                      },
                      rowCount: model.walletUtxos.length,
                      drawGrid: true,
                      emptyPlaceholder: model.isLoadingUtxos ? 'Loading UTXOs...' : 'No UTXOs in wallet',
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _truncateOutpoint(String outpoint) {
    if (outpoint.length <= 16) return outpoint;
    final parts = outpoint.split(':');
    if (parts.length == 2) {
      final hash = parts[0];
      final index = parts[1];
      if (hash.length > 8) {
        return '${hash.substring(0, 8)}...:$index';
      }
    }
    return outpoint;
  }
}

class _TransactionCreatorPanel extends StatelessWidget {
  final TransactionBuilderViewModel model;

  const _TransactionCreatorPanel({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return SailCard(
      title: 'Create Transaction',
      subtitle: 'Build and broadcast a transaction',
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
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
                    'UTXO selection is informational. The wallet will automatically select UTXOs for the transaction.',
                    color: theme.colors.info,
                  ),
                ),
              ],
            ),
          ),

          // Output creator
          SailText.primary15('Create Output', bold: true),
          SailTextField(
            label: 'Destination Address',
            controller: model.addressController,
            hintText: 'Enter recipient address',
          ),
          NumericField(
            label: 'Amount (BTC)',
            controller: model.amountController,
            hintText: '0.00000000',
          ),
          SailTextField(
            label: 'Fee (BTC)',
            controller: model.feeController,
            hintText: '0.00001',
            readOnly: true,
          ),

          // Fee breakdown
          if (model.amountBtc != null) ...[
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding12),
              decoration: BoxDecoration(
                color: theme.colors.backgroundSecondary,
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: ListenableBuilder(
                listenable: formatter,
                builder: (context, child) => Column(
                  children: [
                    _FeeRow(label: 'Amount', value: model.amountBtc ?? 0),
                    const SizedBox(height: 4),
                    _FeeRow(label: 'Fee', value: model.feeBtc),
                    Divider(color: theme.colors.divider, height: SailStyleValues.padding16),
                    _FeeRow(label: 'Total', value: (model.amountBtc ?? 0) + model.feeBtc, bold: true),
                  ],
                ),
              ),
            ),
          ],

          // Actions
          const SizedBox(height: SailStyleValues.padding08),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailButton(
                label: 'Sign & Broadcast',
                onPressed: model.canSend ? () async => model.sendTransaction(context) : null,
                disabled: !model.canSend,
                loading: model.isSending,
              ),
              SailButton(
                label: 'Clear',
                variant: ButtonVariant.secondary,
                onPressed: model.clear,
              ),
            ],
          ),

          // Error/Success messages
          if (model.sendError != null)
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: theme.colors.error.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: SailText.primary12(model.sendError!, color: theme.colors.error),
            ),
          if (model.txid != null)
            Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: theme.colors.success.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary12('Transaction sent!', color: theme.colors.success, bold: true),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: SailText.primary12(
                          'TXID: ${model.txid}',
                          color: theme.colors.success,
                          monospace: true,
                        ),
                      ),
                      CopyButton(text: model.txid!),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const _FeeRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SailText.primary12(label, bold: bold),
        SailText.primary12(formatBitcoin(value), monospace: true, bold: bold),
      ],
    );
  }
}

class TransactionBuilderViewModel extends BaseViewModel {
  PhotonRPC get _rpc => GetIt.I.get<PhotonRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController feeController = TextEditingController(text: '0.00001');

  List<SidechainUTXO> walletUtxos = [];
  Set<String> selectedUtxos = {};
  String? utxoError;
  String? sendError;
  String? txid;
  bool isLoadingUtxos = true;
  bool isSending = false;

  int get totalAvailable => walletUtxos.fold(0, (sum, utxo) => sum + utxo.valueSats.toInt());

  int get selectedValue {
    int total = 0;
    for (final utxo in walletUtxos) {
      if (selectedUtxos.contains(utxo.outpoint)) {
        total += utxo.valueSats.toInt();
      }
    }
    return total;
  }

  double? get amountBtc => double.tryParse(amountController.text);
  double get feeBtc => double.tryParse(feeController.text) ?? 0.00001;

  bool get canSend {
    return addressController.text.isNotEmpty && amountBtc != null && amountBtc! > 0 && !isSending;
  }

  TransactionBuilderViewModel() {
    _init();
    addressController.addListener(notifyListeners);
    amountController.addListener(notifyListeners);
    feeController.addListener(notifyListeners);
  }

  Future<void> _init() async {
    await refreshUtxos();
  }

  Future<void> refreshUtxos() async {
    isLoadingUtxos = true;
    utxoError = null;
    notifyListeners();

    try {
      walletUtxos = await _rpc.listUTXOs();
    } catch (e) {
      utxoError = e.toString();
    } finally {
      isLoadingUtxos = false;
      notifyListeners();
    }
  }

  void toggleUtxo(String outpoint) {
    if (selectedUtxos.contains(outpoint)) {
      selectedUtxos.remove(outpoint);
    } else {
      selectedUtxos.add(outpoint);
    }
    notifyListeners();
  }

  Future<void> sendTransaction(BuildContext context) async {
    if (!canSend) return;

    isSending = true;
    sendError = null;
    txid = null;
    notifyListeners();

    try {
      final resultTxid = await _rpc.sideSend(
        addressController.text,
        amountBtc!,
        false,
      );
      txid = resultTxid;

      // Refresh balance and UTXOs
      await Future.wait([
        _balanceProvider.fetch(),
        refreshUtxos(),
      ]);

      if (context.mounted) {
        await successDialog(
          context: context,
          action: 'Send Transaction',
          title: 'Transaction sent successfully',
          subtitle: 'TXID: $resultTxid',
        );
      }
    } catch (e) {
      sendError = e.toString();
      if (context.mounted) {
        await errorDialog(
          context: context,
          action: 'Send Transaction',
          title: 'Failed to send transaction',
          subtitle: e.toString(),
        );
      }
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    addressController.clear();
    amountController.clear();
    feeController.text = '0.00001';
    selectedUtxos.clear();
    sendError = null;
    txid = null;
    notifyListeners();
  }

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    feeController.dispose();
    super.dispose();
  }
}
