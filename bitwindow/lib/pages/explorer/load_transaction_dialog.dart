import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

Future<void> showLoadTransactionDialog(BuildContext context) async {
  await showThemedDialog<void>(
    context: context,
    builder: (_) => const LoadTransactionDialog(),
  );
}

class LoadTransactionDialog extends StatefulWidget {
  const LoadTransactionDialog({super.key});

  @override
  State<LoadTransactionDialog> createState() => _LoadTransactionDialogState();
}

class _LoadTransactionDialogState extends State<LoadTransactionDialog> {
  OrchestratorWalletRPC get _wallet => GetIt.I.get<OrchestratorRPC>().wallet;
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();
  Logger get _log => GetIt.I.get<Logger>();

  final _controller = TextEditingController();
  DecodedTransaction? _decoded;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _decode() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final decoded = await _wallet.decodeTransaction(
        input: input,
        walletId: _walletReader.activeWalletId ?? '',
      );
      if (!mounted) return;
      setState(() {
        _decoded = decoded;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      _log.e('failed to decode transaction: $e');
      if (!mounted) return;
      setState(() {
        _decoded = null;
        _error = _humanize(e);
        _isLoading = false;
      });
    }
  }

  String _humanize(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('not a valid')) {
      return 'Not a valid txid, transaction hex, or PSBT.';
    }
    if (raw.contains('not found')) {
      return 'That txid was not found in the active wallet or on chain.';
    }
    if (raw.contains('connection') || raw.contains('unavailable') || raw.contains('refused')) {
      return 'Could not reach the orchestrator. Make sure your daemon is running and try again.';
    }
    return 'Could not decode this transaction. Check the input and try again.';
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
      child: SailCard(
        title: 'Load Transaction',
        subtitle: 'Paste a txid, raw transaction hex, or base64 PSBT',
        error: _error,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SailTextField(
              controller: _controller,
              hintText: 'txid / transaction hex / base64 PSBT',
              minLines: 3,
              maxLines: 6,
            ),
            const SailSpacing(SailStyleValues.padding08),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  onPressed: _isLoading ? null : _decode,
                  label: 'Decode',
                  variant: ButtonVariant.primary,
                  loading: _isLoading,
                ),
              ],
            ),
            const SailSpacing(SailStyleValues.padding16),
            if (_decoded != null) Expanded(child: _DecodedView(decoded: _decoded!)),
          ],
        ),
      ),
    );
  }
}

class _DecodedView extends StatelessWidget {
  final DecodedTransaction decoded;

  const _DecodedView({required this.decoded});

  String get _formLabel {
    switch (decoded.form) {
      case wmpb.DecodedForm.DECODED_FORM_PSBT:
        return 'PSBT';
      case wmpb.DecodedForm.DECODED_FORM_RAW_TX:
        return 'Raw transaction';
      case wmpb.DecodedForm.DECODED_FORM_TXID:
        return 'Transaction (by id)';
      default:
        return 'Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = decoded.details;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SailText.primary13(_formLabel),
            const SailSpacing(SailStyleValues.padding08),
            if (decoded.isPsbt)
              SailText.secondary13(
                '${decoded.signedInputs}/${details.inputs.length} inputs signed',
              ),
          ],
        ),
        const SailSpacing(SailStyleValues.padding08),
        Expanded(
          child: InlineTabBar(
            tabs: [
              TabItem(
                label: 'Overview',
                child: _Overview(decoded: decoded),
              ),
              TabItem(
                label: 'Inputs (${details.inputs.length})',
                child: _InputsTable(decoded: decoded),
              ),
              TabItem(
                label: 'Outputs (${details.outputs.length})',
                child: _OutputsTable(decoded: decoded),
              ),
              TabItem(
                label: 'Diagram',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(SailStyleValues.padding16),
                  child: TransactionDiagram(details: details, hasFee: decoded.hasFee),
                ),
              ),
              TabItem(
                label: 'Bytes',
                child: TransactionByteView(rawHex: details.hex),
              ),
            ],
            initialIndex: 0,
          ),
        ),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  final DecodedTransaction decoded;

  const _Overview({required this.decoded});

  @override
  Widget build(BuildContext context) {
    final details = decoded.details;
    final formatter = GetIt.I<FormatterProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13('Transaction Info'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(label: 'TXID', value: details.txid),
          DetailRow(label: 'Version', value: '${details.version}'),
          DetailRow(label: 'Lock Time', value: '${details.locktime}'),
          const SailSpacing(SailStyleValues.padding16),
          SailText.primary13('Size'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(label: 'Size', value: '${details.sizeBytes} bytes'),
          DetailRow(label: 'Virtual Size', value: '${details.vsizeVbytes} vbytes'),
          DetailRow(label: 'Weight', value: '${details.weightWu} WU'),
          const SailSpacing(SailStyleValues.padding16),
          SailText.primary13('Fee'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(
            label: 'Fee',
            value: decoded.hasFee ? formatter.formatSats(details.feeSats.toInt()) : 'Unknown',
          ),
          DetailRow(
            label: 'Fee Rate',
            value: decoded.hasFee ? '${details.feeRateSatVb.toStringAsFixed(2)} sat/vB' : 'Unknown',
          ),
          const SailSpacing(SailStyleValues.padding16),
          SailText.primary13('Totals'),
          const SailSpacing(SailStyleValues.padding08),
          DetailRow(
            label: 'Total Input',
            value: decoded.hasTotalInput ? formatter.formatSats(details.totalInputSats.toInt()) : 'Unknown',
          ),
          DetailRow(label: 'Total Output', value: formatter.formatSats(details.totalOutputSats.toInt())),
        ],
      ),
    );
  }
}

class _InputsTable extends StatelessWidget {
  final DecodedTransaction decoded;

  const _InputsTable({required this.decoded});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();
    final inputs = decoded.details.inputs;

    return SailTable(
      getRowId: (i) => '${inputs[i].prevTxid}:${inputs[i].prevVout}:$i',
      headerBuilder: (_) => [
        SailTableHeaderCell(name: '#'),
        SailTableHeaderCell(name: 'Amount'),
        SailTableHeaderCell(name: 'Address'),
        SailTableHeaderCell(name: 'Previous Output'),
        SailTableHeaderCell(name: 'Sequence'),
      ],
      rowBuilder: (_, i, _) {
        final input = inputs[i];
        final prevOutput = input.isCoinbase
            ? 'Coinbase'
            : '${input.prevTxid.length >= 8 ? input.prevTxid.substring(0, 8) : input.prevTxid}...:${input.prevVout}';
        final hasValue = !input.isCoinbase && (input.valueSats.toInt() != 0 || input.address.isNotEmpty);

        return [
          SailTableCell(value: '${input.index}'),
          SailTableCell(
            value: input.isCoinbase ? 'N/A' : (hasValue ? formatter.formatSats(input.valueSats.toInt()) : 'Unknown'),
            monospace: true,
          ),
          SailTableCell(
            value: input.isCoinbase ? 'Coinbase' : (input.address.isEmpty ? 'Unknown' : input.address),
            monospace: true,
            copyValue: input.address.isNotEmpty ? input.address : null,
          ),
          SailTableCell(
            value: prevOutput,
            monospace: true,
            copyValue: input.isCoinbase ? null : '${input.prevTxid}:${input.prevVout}',
          ),
          SailTableCell(value: '${input.sequence}', monospace: true),
        ];
      },
      rowCount: inputs.length,
      emptyPlaceholder: 'No inputs',
    );
  }
}

class _OutputsTable extends StatelessWidget {
  final DecodedTransaction decoded;

  const _OutputsTable({required this.decoded});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();
    final outputs = decoded.details.outputs;

    return SailTable(
      getRowId: (i) => '${outputs[i].index}',
      headerBuilder: (_) => [
        SailTableHeaderCell(name: '#'),
        SailTableHeaderCell(name: 'Amount'),
        SailTableHeaderCell(name: 'Address'),
        SailTableHeaderCell(name: 'Type'),
      ],
      rowBuilder: (_, i, _) {
        final output = outputs[i];
        return [
          SailTableCell(value: '${output.index}'),
          SailTableCell(value: formatter.formatSats(output.valueSats.toInt()), monospace: true),
          SailTableCell(
            value: output.address.isEmpty ? 'Unknown' : output.address,
            monospace: true,
            copyValue: output.address.isNotEmpty ? output.address : null,
          ),
          SailTableCell(value: output.scriptType),
        ];
      },
      rowCount: outputs.length,
      emptyPlaceholder: 'No outputs',
    );
  }
}
