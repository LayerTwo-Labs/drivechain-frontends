import 'package:bitwindow/utils/explorer_url.dart';
import 'package:bitwindow/widgets/airgap_sign_step.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Single-sig external-signer (airgap) flow: produce the signed PSBT via
/// [AirgapSignStep], then combine, finalize and broadcast it.
class AirgapPsbtDialog extends StatefulWidget {
  final String unsignedPsbtBase64;

  /// Called with the broadcast txid on success.
  final void Function(String txid)? onBroadcast;

  const AirgapPsbtDialog({
    super.key,
    required this.unsignedPsbtBase64,
    this.onBroadcast,
  });

  @override
  State<AirgapPsbtDialog> createState() => _AirgapPsbtDialogState();
}

class _AirgapPsbtDialogState extends State<AirgapPsbtDialog> {
  bool _broadcasting = false;
  String? _broadcastTxid;
  String? _error;

  OrchestratorWalletRPC get _wallet => GetIt.I<OrchestratorRPC>().wallet;

  Future<void> _finalizeAndBroadcast(String signedPsbtBase64) async {
    setState(() {
      _broadcasting = true;
      _error = null;
    });
    try {
      final combined = await _wallet.combinePsbt(
        psbtsBase64: [widget.unsignedPsbtBase64, signedPsbtBase64],
      );
      final rawTxHex = await _wallet.finalizePsbt(psbtBase64: combined);
      final txid = await bitcoindRpcCall('sendrawtransaction', params: [rawTxHex]) as String;

      _broadcastTxid = txid;
      widget.onBroadcast?.call(txid);

      final network = GetIt.I.get<BitcoinConfProvider>().network;
      GetIt.I.get<NotificationProvider>().add(
        title: 'Transaction broadcast',
        content: txid,
        dialogType: DialogType.info,
        links: [NotificationLink(text: 'View transaction', url: mempoolTxUrl(txid, network))],
      );

      if (mounted) {
        showSailToast(context, 'Transaction broadcast', variant: SailToastVariant.success);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _broadcasting = false;
          _error = 'Failed to broadcast: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
      child: _card(),
    );
  }

  Widget _card() {
    if (_broadcasting) {
      return SailCard(
        title: 'External signer (airgap)',
        subtitle: 'Combining, finalizing and broadcasting',
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          children: [
            const SizedBox(height: 40),
            const Center(child: LoadingIndicator()),
            if (_broadcastTxid != null) SailText.secondary12('txid: $_broadcastTxid'),
          ],
        ),
      );
    }
    if (_error != null) {
      return SailCard(
        title: 'External signer (airgap)',
        error: _error,
        child: SailRow(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: SailStyleValues.padding08,
          children: [
            SailButton(
              label: 'Back',
              variant: ButtonVariant.ghost,
              onPressed: () async => setState(() => _error = null),
            ),
          ],
        ),
      );
    }
    return AirgapSignStep(
      unsignedPsbtBase64: widget.unsignedPsbtBase64,
      onSigned: _finalizeAndBroadcast,
      onCancel: () => Navigator.of(context).pop(false),
    );
  }
}
