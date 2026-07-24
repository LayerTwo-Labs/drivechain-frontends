import 'package:bitwindow/signing/psbt_signer.dart';
import 'package:bitwindow/utils/explorer_url.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Signs an unsigned PSBT with [signer], then combines, finalizes and
/// broadcasts it, returning the txid (or null if the user cancelled).
Future<String?> signAndBroadcast(
  BuildContext context, {
  required String walletId,
  required String unsignedPsbtBase64,
  required PsbtSigner signer,
}) async {
  final wallet = GetIt.I<OrchestratorRPC>().wallet;

  final String signed;
  try {
    signed = await signer.signPsbt(unsignedPsbtBase64, context);
  } on PsbtSigningCancelled {
    return null;
  }

  final combined = await wallet.combinePsbt(psbtsBase64: [unsignedPsbtBase64, signed]);
  final rawTxHex = await wallet.finalizePsbt(psbtBase64: combined);
  // Broadcast over the wallet's own chain source, which also refreshes its scan.
  final txid = await wallet.broadcastTransaction(walletId: walletId, txHex: rawTxHex);

  final network = GetIt.I.get<BitcoinConfProvider>().network;
  GetIt.I.get<NotificationProvider>().add(
    title: 'Transaction broadcast',
    content: txid,
    dialogType: DialogType.info,
    links: [NotificationLink(text: 'View transaction', url: mempoolTxUrl(txid, network))],
  );
  return txid;
}
