import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;

bool _supportsBroadcast(String chain) => chain == 'bitnames' || chain == 'bitassets';

class ExplorerTransactionActions extends StatefulWidget {
  final ExplorerModel model;
  final pb.Transaction transaction;
  final ValueChanged<ExplorerTarget> onOpen;

  const ExplorerTransactionActions({super.key, required this.model, required this.transaction, required this.onOpen});

  @override
  State<ExplorerTransactionActions> createState() => _ExplorerTransactionActionsState();
}

class _ExplorerTransactionActionsState extends State<ExplorerTransactionActions> {
  bool _busy = false;
  String? _error;
  String? _notice;
  pb.RebroadcastTransactionResponse? _response;

  Future<void> _rebroadcast() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
      _response = null;
    });
    try {
      final response = await widget.model.rebroadcastTransaction(widget.transaction.txid);
      if (mounted) {
        setState(() => _response = response);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _copy() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final transaction = await widget.model.signedTransaction(widget.transaction.txid);
      await Clipboard.setData(ClipboardData(text: transaction));
      if (mounted) {
        setState(() => _notice = 'The signed transaction is on the clipboard.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    if (!_supportsBroadcast(widget.model.chain) || transaction.confirmed || transaction.kind == pb.Kind.KIND_DEPOSIT) {
      return const SizedBox.shrink();
    }
    final response = _response;
    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        Wrap(
          spacing: SailStyleValues.padding08,
          runSpacing: SailStyleValues.padding08,
          children: [
            SailButton(
              label: 'Rebroadcast',
              variant: ButtonVariant.secondary,
              disabled: _busy,
              onPressed: _rebroadcast,
            ),
            SailButton(
              label: 'Copy Signed Transaction',
              variant: ButtonVariant.secondary,
              disabled: _busy,
              onPressed: _copy,
            ),
          ],
        ),
        if (_error != null)
          SailText.primary13(_error!, color: SailTheme.of(context).colors.error, overflow: TextOverflow.visible),
        if (_notice != null) SailText.secondary13(_notice!),
        if (response != null)
          _BroadcastResult(txid: response.txid, peerCount: response.peerCount, onOpen: widget.onOpen),
      ],
    );
  }
}

class ExplorerBroadcastButton extends StatefulWidget {
  final ExplorerModel model;
  final ValueChanged<ExplorerTarget> onOpen;

  const ExplorerBroadcastButton({super.key, required this.model, required this.onOpen});

  @override
  State<ExplorerBroadcastButton> createState() => _ExplorerBroadcastButtonState();
}

class _ExplorerBroadcastButtonState extends State<ExplorerBroadcastButton> {
  bool _open = false;

  Future<void> _showForm() async {
    if (_open) {
      return;
    }
    setState(() => _open = true);
    try {
      final txid = await showThemedDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _BroadcastDialog(model: widget.model),
      );
      if (mounted && txid != null) {
        widget.onOpen(ExplorerTarget.transaction(txid));
      }
    } finally {
      if (mounted) {
        setState(() => _open = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsBroadcast(widget.model.chain)) {
      return const SizedBox.shrink();
    }
    return SailButton(
      label: 'Broadcast Transaction',
      variant: ButtonVariant.secondary,
      disabled: _open,
      skipLoading: true,
      onPressed: _showForm,
    );
  }
}

class _BroadcastDialog extends StatefulWidget {
  final ExplorerModel model;

  const _BroadcastDialog({required this.model});

  @override
  State<_BroadcastDialog> createState() => _BroadcastDialogState();
}

class _BroadcastDialogState extends State<_BroadcastDialog> {
  final TextEditingController _transaction = TextEditingController();
  bool _busy = false;
  String? _error;
  pb.BroadcastTransactionResponse? _response;

  @override
  void dispose() {
    _transaction.dispose();
    super.dispose();
  }

  Future<void> _broadcast() async {
    if (_busy || _response != null) {
      return;
    }
    final transaction = _transaction.text;
    if (transaction.trim().isEmpty) {
      setState(() => _error = 'Paste a signed transaction.');
      return;
    }
    try {
      if (jsonDecode(transaction) is! Map<String, dynamic>) {
        setState(() => _error = 'The signed transaction must be a JSON object.');
        return;
      }
    } on FormatException {
      setState(() => _error = 'The signed transaction contains invalid JSON.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await widget.model.broadcastTransaction(transaction);
      if (mounted) {
        setState(() => _response = response);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final response = _response;
    return PopScope(
      canPop: !_busy,
      child: SailDialog(
        title: 'Broadcast Transaction',
        subtitle: 'Paste the full signed transaction JSON for ${widget.model.chain}.',
        error: _error,
        maxWidth: 600,
        actions: [
          SailButton(
            label: 'Close',
            variant: ButtonVariant.secondary,
            disabled: _busy,
            onPressed: () async => Navigator.of(context).pop(),
          ),
          if (response == null) SailButton(label: 'Broadcast', disabled: _busy, onPressed: _broadcast),
        ],
        child: response != null
            ? _BroadcastResult(
                txid: response.txid,
                peerCount: response.peerCount,
                onOpen: (target) => Navigator.of(context).pop(target.id),
              )
            : SailTextarea(
                controller: _transaction,
                label: 'Signed transaction JSON',
                placeholder: 'Paste the signed transaction JSON',
                minLines: 5,
                maxLines: 8,
                autofocus: true,
                enabled: !_busy,
                monospace: true,
              ),
      ),
    );
  }
}

class _BroadcastResult extends StatelessWidget {
  final String txid;
  final int peerCount;
  final ValueChanged<ExplorerTarget> onOpen;

  const _BroadcastResult({required this.txid, required this.peerCount, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        SailText.primary13('The node accepted the transaction.'),
        SailText.secondary13(
          peerCount == 0
              ? 'No peers are connected. The node will retry.'
              : 'The node will relay the transaction to peers.',
        ),
        SailText.secondary13('The transaction remains pending until a block includes it.'),
        SailText.primary13(txid, monospace: true, overflow: TextOverflow.visible),
        SailButton(
          label: 'Open Transaction',
          variant: ButtonVariant.secondary,
          onPressed: () async => onOpen(ExplorerTarget.transaction(txid)),
        ),
      ],
    );
  }
}
