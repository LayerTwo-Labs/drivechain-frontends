import 'package:bitwindow/widgets/airgap_sign_step.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

/// Produces a partial-signature PSBT for one keystore/leg.
abstract class PsbtSigner {
  Future<String> signPsbt(String unsignedPsbtBase64, BuildContext context);
}

/// Thrown when the user abandons an interactive signing step.
class PsbtSigningCancelled implements Exception {
  const PsbtSigningCancelled();
  @override
  String toString() => 'Signing cancelled';
}

/// Signs in-process with the hot wallet. Pass [cosignerXpub] for one multisig leg.
class SoftwarePsbtSigner implements PsbtSigner {
  final String walletId;
  final String? cosignerXpub;

  SoftwarePsbtSigner({required this.walletId, this.cosignerXpub});

  OrchestratorWalletRPC get _wallet => GetIt.I<OrchestratorRPC>().wallet;

  @override
  Future<String> signPsbt(String unsignedPsbtBase64, BuildContext context) {
    final xpub = cosignerXpub;
    if (xpub != null) {
      return _wallet.signPsbtWithCosigner(
        walletId: walletId,
        psbtBase64: unsignedPsbtBase64,
        cosignerXpub: xpub,
      );
    }
    return _wallet.signPsbt(walletId: walletId, psbtBase64: unsignedPsbtBase64);
  }
}

/// Signs by handing the PSBT to an external signer over the airgap round-trip.
class AirgapPsbtSigner implements PsbtSigner {
  @override
  Future<String> signPsbt(String unsignedPsbtBase64, BuildContext context) async {
    final signed = await showThemedDialog<String>(
      context: context,
      builder: (context) => SailModal(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
        child: AirgapSignStep(
          unsignedPsbtBase64: unsignedPsbtBase64,
          onSigned: (s) => Navigator.of(context).pop(s),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (signed == null || signed.isEmpty) {
      throw const PsbtSigningCancelled();
    }
    return signed;
  }
}

/// Signs on a USB hardware device.
class HwiPsbtSigner implements PsbtSigner {
  final wmpb.HardwareDeviceSelector device;

  HwiPsbtSigner(this.device);

  OrchestratorWalletRPC get _wallet => GetIt.I<OrchestratorRPC>().wallet;

  @override
  Future<String> signPsbt(String unsignedPsbtBase64, BuildContext context) {
    return _wallet.signPsbtWithDevice(device: device, psbtBase64: unsignedPsbtBase64);
  }
}
