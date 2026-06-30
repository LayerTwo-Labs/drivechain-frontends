import 'dart:convert';

import 'package:bitwindow/widgets/airgap_psbt_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Standalone PSBT signing tool: paste an unsigned PSBT and run it through the
/// airgap (external signer) flow — export it, collect the signed PSBT back, and
/// broadcast — without going through the send screen first.
class PsbtSignerTab extends StatefulWidget {
  const PsbtSignerTab({super.key});

  @override
  State<PsbtSignerTab> createState() => _PsbtSignerTabState();
}

class _PsbtSignerTabState extends State<PsbtSignerTab> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start(BuildContext context) async {
    final psbt = _controller.text.trim();
    if (psbt.isEmpty) {
      setState(() => _error = 'Paste an unsigned PSBT first');
      return;
    }
    try {
      base64.decode(psbt);
    } catch (_) {
      setState(() => _error = 'Not a valid base64 PSBT');
      return;
    }
    setState(() => _error = null);
    await showThemedDialog<bool>(
      context: context,
      builder: (context) => AirgapPsbtDialog(unsignedPsbtBase64: psbt),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'PSBT Signer',
      subtitle: 'Paste an unsigned PSBT to sign it with an external (airgap) signer',
      error: _error,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SailTextField(
            controller: _controller,
            hintText: 'base64 PSBT',
            minLines: 3,
            maxLines: 6,
          ),
          const SailSpacing(SailStyleValues.padding08),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SailButton(
                onPressed: () => _start(context),
                label: 'Sign with external signer',
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
