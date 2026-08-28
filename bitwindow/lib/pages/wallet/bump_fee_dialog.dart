import 'dart:async';

import 'package:bitwindow/pages/wallet/bump_fee_choices.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// Replaces an unconfirmed transaction with one that pays a higher fee. The
/// preview comes from the backend, so the fee, the size and the output that
/// pays are the wallet's own numbers.
class BumpFeeDialog extends StatefulWidget {
  final String txid;

  const BumpFeeDialog({super.key, required this.txid});

  @override
  State<BumpFeeDialog> createState() => _BumpFeeDialogState();
}

class _BumpFeeDialogState extends State<BumpFeeDialog> {
  OrchestratorWalletRPC get _wallet => GetIt.I.get<OrchestratorRPC>().wallet;
  TransactionProvider get _transactions => GetIt.I.get<TransactionProvider>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  final TextEditingController _rateController = TextEditingController();
  Timer? _debounce;

  wmpb.PreviewBumpFeeResponse? _preview;
  int? _feeFromVout;
  // Counts the previews asked for. A slower answer to an older question must
  // not overwrite the newer one the user reads.
  int _requestId = 0;
  bool _loading = true;
  bool _replacing = false;
  // Set when a preview fails: the plan on screen answers an older question.
  bool _stale = false;
  bool _pickOutput = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPreview());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _rateController.dispose();
    super.dispose();
  }

  int? get _rate {
    final rate = int.tryParse(_rateController.text.trim());
    if (rate == null || rate <= 0) {
      return null;
    }
    return rate;
  }

  Future<void> _loadPreview() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) {
        throw Exception('No active wallet');
      }
      final preview = await _wallet.previewBumpFee(
        walletId: walletId,
        txid: widget.txid,
        newFeeRate: _rate,
        feeFromVout: _feeFromVout,
      );
      if (!mounted || requestId != _requestId) {
        return;
      }
      final first = _preview == null;
      setState(() {
        _preview = preview;
        _stale = false;
        _loading = false;
        if (first && _rateController.text.isEmpty) {
          _rateController.text = preview.suggestedFeeRate.toString();
        }
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _error = e.toString();
        // The plan on screen belongs to a question this one failed to answer.
        // It stays visible, but it cannot broadcast anything.
        _stale = true;
        _loading = false;
      });
    }
  }

  void _onRateChanged(String _) {
    _debounce?.cancel();
    // The plan on screen belongs to the rate before this keystroke, and so does
    // any answer still in flight. Both go stale here, or a fast press
    // broadcasts a fee the user never read.
    setState(() {
      _requestId++;
      _loading = true;
      _stale = false;
      _error = null;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_loadPreview());
    });
  }

  Future<void> _selectOutput(int vout) async {
    setState(() => _feeFromVout = vout);
    await _loadPreview();
  }

  Future<void> _replace() async {
    setState(() {
      _replacing = true;
      _error = null;
    });
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) {
        throw Exception('No active wallet');
      }
      final result = await _wallet.bumpFee(
        walletId: walletId,
        txid: widget.txid,
        newFeeRate: _rate,
        feeFromVout: _feeFromVout,
      );
      if (!mounted) {
        GetIt.I<Logger>().i('replaced ${widget.txid} with ${result.newTxid}');
        return;
      }
      showSailToast(context, 'Replaced. New txid: ${result.newTxid}', variant: SailToastVariant.success);
      Navigator.of(context).pop();
      // The network holds the replacement already. A refresh that fails changes
      // nothing about that, so it never reports the send as failed.
      unawaited(_transactions.fetch());
    } catch (e) {
      if (!mounted) {
        GetIt.I<Logger>().e('failed to replace ${widget.txid}: $e');
        return;
      }
      setState(() {
        _error = e.toString();
        _replacing = false;
      });
    }
  }

  Future<void> _accelerate() async {
    Navigator.of(context).pop(BumpFeeOutcome.accelerate);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final plan = preview != null && preview.hasPlan() ? preview.plan : null;
    final choices = preview == null ? null : BumpFeeChoices.of(preview, pickOutput: _pickOutput);
    // Core adds a coin when the change cannot pay, so it replaces the
    // transaction even with no plan to show.
    final hasWay = plan != null || (choices?.replaceWithoutPlan ?? false);
    final canReplace = hasWay && !_loading && !_replacing && !_stale;

    return PopScope(
      canPop: !_replacing,
      child: SailDialog(
        title: 'Bump the fee',
        maxWidth: 620,
        maxHeight: 620,
        error: _error,
        actions: [
          SailButton(
            label: 'Cancel',
            onPressed: () async => Navigator.of(context).pop(),
            variant: ButtonVariant.secondary,
            disabled: _replacing,
          ),
          if (choices != null && choices.showOverride)
            SailButton(
              label: 'I want to RBF it',
              onPressed: () async => setState(() => _pickOutput = true),
              variant: ButtonVariant.secondary,
              disabled: _replacing,
            ),
          if (choices != null && choices.showAccelerate)
            SailButton(
              label: 'Accelerate (CPFP)',
              onPressed: _accelerate,
              variant: choices.showReplace ? ButtonVariant.secondary : ButtonVariant.primary,
              disabled: _replacing,
            ),
          if (choices != null && choices.showReplace)
            SailButton(
              label: _replacing ? 'Replacing...' : 'Replace transaction',
              onPressed: _replace,
              disabled: !canReplace,
            ),
        ],
        child: _loading && preview == null
            ? const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: LoadingIndicator()),
              )
            : SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (preview != null) ..._transactionDetails(preview),
                  if (preview != null) ..._newFee(preview),
                ],
              ),
      ),
    );
  }

  List<Widget> _transactionDetails(wmpb.PreviewBumpFeeResponse preview) {
    final formatter = GetIt.I<FormatterProvider>();
    return [
      SailText.primary15('This transaction'),
      DetailRow(label: 'Transaction ID', value: widget.txid),
      DetailRow(label: 'Inputs', value: '${preview.inputCount} coins · ${preview.vsizeVbytes} vB'),
      DetailRow(
        label: 'Fee now',
        value:
            '${formatter.formatSats(preview.oldFeeSats.toInt())} · '
            '${preview.oldFeeRateSatVb.toStringAsFixed(1)} ${activeTicker.feeRate}',
      ),
    ];
  }

  List<Widget> _newFee(wmpb.PreviewBumpFeeResponse preview) {
    final formatter = GetIt.I<FormatterProvider>();
    final plan = preview.hasPlan() ? preview.plan : null;
    final theme = SailTheme.of(context);

    return [
      const SailSpacing(SailStyleValues.padding08),
      SailText.primary15('New fee'),
      SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          SizedBox(
            width: 120,
            child: SailTextField(
              controller: _rateController,
              size: TextFieldSize.small,
              textFieldType: TextFieldType.number,
              hintText: preview.suggestedFeeRate.toString(),
              enabled: !_replacing,
              onChanged: _onRateChanged,
            ),
          ),
          SailText.secondary13(activeTicker.feeRate),
          const Spacer(),
          SailDropdownButton<int>(
            value: null,
            hint: 'Estimate',
            items: [
              SailDropdownItem(value: 1, label: 'Fast · 1 block'),
              SailDropdownItem(value: 3, label: 'Medium · 3 blocks'),
              SailDropdownItem(value: 6, label: 'Slow · 6 blocks'),
            ],
            onChanged: (confTarget) => unawaited(_applyEstimate(confTarget)),
          ),
        ],
      ),
      if (plan != null) ...[
        DetailRow(
          label: 'New fee',
          value:
              '${formatter.formatSats(plan.newFeeSats.toInt())} · '
              '${plan.newFeeRateSatVb.toStringAsFixed(1)} ${activeTicker.feeRate}',
        ),
        DetailRow(label: 'You pay more', value: formatter.formatSats(plan.extraFeeSats.toInt())),
        DetailRow(
          label: 'Output ${plan.feeFromVout} · ${plan.reducesPayment ? 'payment' : 'change'}',
          value: plan.outputRemoved
              ? '${formatter.formatSats(plan.amountBeforeSats.toInt())} → goes away'
              : '${formatter.formatSats(plan.amountBeforeSats.toInt())} → '
                    '${formatter.formatSats(plan.amountAfterSats.toInt())}',
        ),
        if (plan.reducesPayment)
          SailText.primary13(
            'The recipient of output ${plan.feeFromVout} gets '
            '${formatter.formatSats(plan.extraFeeSats.toInt())} less.',
            color: theme.colors.orange,
          ),
      ],
      if (preview.reason.isNotEmpty)
        SailText.primary13(
          BumpFeeChoices.of(preview, pickOutput: _pickOutput).reason,
          color: theme.colors.orange,
        ),
      if (_pickOutput) ..._outputPicker(preview),
    ];
  }

  List<Widget> _outputPicker(wmpb.PreviewBumpFeeResponse preview) {
    final formatter = GetIt.I<FormatterProvider>();
    return [
      const SailSpacing(SailStyleValues.padding08),
      SailText.primary15('Take the fee from'),
      ...preview.outputs
          .where((o) => o.address.isNotEmpty)
          .map(
            (output) => SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailRadioButton<int>(
                  value: output.vout,
                  groupValue: _feeFromVout ?? (preview.hasPlan() ? preview.plan.feeFromVout : -1),
                  onChanged: _replacing ? null : (vout) => unawaited(_selectOutput(vout)),
                ),
                Expanded(
                  child: SailText.primary13(
                    'Output ${output.vout} · ${output.isChange ? 'change' : 'payment'} · ${output.address}',
                  ),
                ),
                SailText.secondary13(formatter.formatSats(output.amountSats.toInt())),
              ],
            ),
          ),
    ];
  }

  Future<void> _applyEstimate(int? confTarget) async {
    if (confTarget == null || _replacing) {
      return;
    }
    _debounce?.cancel();
    setState(() {
      _requestId++;
      _loading = true;
      _stale = false;
      _error = null;
    });
    double? rate;
    try {
      rate = await feeRateForTarget(confTarget);
    } catch (e) {
      rate = null;
    }
    if (!mounted) {
      return;
    }
    if (rate == null) {
      setState(() {
        _error = 'No fee estimate for $confTarget blocks. Type a rate instead.';
        _loading = false;
        _stale = true;
      });
      return;
    }
    _rateController.text = rate.ceil().toString();
    await _loadPreview();
  }
}

/// What the user chose when the dialog cannot build a replacement.
enum BumpFeeOutcome { accelerate }
