import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Encrypts and decrypts messages for a name on the chain or a raw pubkey.
class MessagingView extends StatefulWidget {
  /// The kind of name, e.g. `BitName`.
  final String noun;
  final String? Function(String input) resolveEncryptionKey;
  final Future<String> Function({required String msg, required String encryptionPubkey}) encrypt;
  final Future<String> Function({required String ciphertext, required String encryptionPubkey}) decrypt;

  const MessagingView({
    super.key,
    required this.noun,
    required this.resolveEncryptionKey,
    required this.encrypt,
    required this.decrypt,
  });

  @override
  State<MessagingView> createState() => _MessagingViewState();
}

class _MessagingViewState extends State<MessagingView> {
  final TextEditingController encryptPubkeyController = TextEditingController();
  final TextEditingController encryptMessageController = TextEditingController();
  String? encryptResult;
  bool encryptLoading = false;
  String? encryptError;

  final TextEditingController decryptPubkeyController = TextEditingController();
  final TextEditingController decryptMessageController = TextEditingController();
  String? decryptResult;
  bool decryptLoading = false;
  String? decryptError;

  bool get _hasEncryptMatch => _resolveEncryptionKey(encryptPubkeyController.text) != null;

  bool get _hasDecryptMatch => _resolveEncryptionKey(decryptPubkeyController.text) != null;

  String? _resolveEncryptionKey(String input) => widget.resolveEncryptionKey(input);

  @override
  void initState() {
    super.initState();
    encryptPubkeyController.addListener(_onChange);
    decryptPubkeyController.addListener(_onChange);
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SailCard(
              title: 'Encrypt',
              subtitle: 'Encrypt a message for a ${widget.noun} or pubkey',
              error: encryptError,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailTextField(
                    label: "Receiver's ${widget.noun} or Encryption Pubkey (Bech32m)",
                    hintText: 'Enter a ${widget.noun} or a pubkey',
                    controller: encryptPubkeyController,
                    suffixWidget: _hasEncryptMatch ? SailSVG.icon(SailSVGAsset.iconSuccess, height: 20) : null,
                  ),
                  const SizedBox(height: 16),
                  SailTextField(
                    label: 'Plaintext message:',
                    hintText: 'Enter a message to encrypt',
                    controller: encryptMessageController,
                    minLines: 3,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 16),
                  SailButton(
                    label: 'Encrypt',
                    onPressed: handleEncrypt,
                    loading: encryptLoading,
                  ),
                  if (encryptResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SailText.secondary13(
                        encryptResult!,
                        monospace: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: SailCard(
              title: 'Decrypt',
              subtitle: 'Decrypt a message using your pubkey',
              error: decryptError,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailTextField(
                    label: "Receiver's ${widget.noun} or Encryption Pubkey (Bech32m)",
                    hintText: 'Enter a ${widget.noun} or a pubkey',
                    controller: decryptPubkeyController,
                    suffixWidget: _hasDecryptMatch ? SailSVG.icon(SailSVGAsset.iconSuccess, height: 20) : null,
                  ),
                  const SizedBox(height: 16),
                  SailTextField(
                    label: 'Ciphertext message (hex):',
                    hintText: 'Enter a ciphertext message',
                    controller: decryptMessageController,
                    minLines: 3,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 16),
                  SailButton(
                    label: 'Decrypt',
                    onPressed: handleDecrypt,
                    loading: decryptLoading,
                  ),
                  if (decryptResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SailText.secondary13(
                        decryptResult!,
                        monospace: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleEncrypt() async {
    setState(() {
      encryptLoading = true;
      encryptError = null;
      encryptResult = null;
    });

    try {
      final resolvedKey = _resolveEncryptionKey(encryptPubkeyController.text) ?? encryptPubkeyController.text.trim();
      if (resolvedKey.isEmpty) {
        setState(() => encryptError = 'Must enter a valid pubkey');
        return;
      }

      final ciphertext = await widget.encrypt(
        msg: encryptMessageController.text.trim(),
        encryptionPubkey: resolvedKey,
      );
      setState(() => encryptResult = ciphertext);
    } catch (e) {
      setState(() => encryptError = e.toString());
    } finally {
      setState(() => encryptLoading = false);
    }
  }

  Future<void> handleDecrypt() async {
    setState(() {
      decryptLoading = true;
      decryptError = null;
      decryptResult = null;
    });

    try {
      final resolvedKey = _resolveEncryptionKey(decryptPubkeyController.text) ?? decryptPubkeyController.text.trim();
      if (resolvedKey.isEmpty) {
        setState(() => decryptError = 'Must enter a valid pubkey');
        return;
      }

      final plaintext = await widget.decrypt(
        ciphertext: decryptMessageController.text.trim(),
        encryptionPubkey: resolvedKey,
      );
      setState(() => decryptResult = plaintext);
    } catch (e) {
      setState(() => decryptError = e.toString());
    } finally {
      setState(() => decryptLoading = false);
    }
  }

  void _onChange() {
    setState(() {});
  }

  @override
  void dispose() {
    encryptPubkeyController.removeListener(_onChange);
    decryptPubkeyController.removeListener(_onChange);
    encryptPubkeyController.dispose();
    decryptPubkeyController.dispose();
    encryptMessageController.dispose();
    decryptMessageController.dispose();
    super.dispose();
  }
}
