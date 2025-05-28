import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class MessagingTabPage extends StatefulWidget {
  const MessagingTabPage({super.key});

  @override
  State<MessagingTabPage> createState() => _MessagingTabPageState();
}

class _MessagingTabPageState extends State<MessagingTabPage> {
  final BitnamesRPC rpc = GetIt.I.get<BitnamesRPC>();

  // Encrypt controllers/state
  final TextEditingController encryptPubkeyController = TextEditingController();
  final TextEditingController encryptMessageController = TextEditingController();
  String? encryptResult;
  bool encryptLoading = false;
  String? encryptError;

  // Decrypt controllers/state
  final TextEditingController decryptPubkeyController = TextEditingController();
  final TextEditingController decryptMessageController = TextEditingController();
  String? decryptResult;
  bool decryptLoading = false;
  String? decryptError;

  Future<void> handleEncrypt() async {
    setState(() {
      encryptLoading = true;
      encryptError = null;
      encryptResult = null;
    });
    try {
      final ciphertext = await rpc.encryptMsg(
        msg: encryptMessageController.text.trim(),
        encryptionPubkey: encryptPubkeyController.text.trim(),
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
      final plaintext = await rpc.decryptMsg(
        ciphertext: decryptMessageController.text.trim(),
        encryptionPubkey: decryptPubkeyController.text.trim(),
      );
      setState(() => decryptResult = plaintext);
    } catch (e) {
      setState(() => decryptError = e.toString());
    } finally {
      setState(() => decryptLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encrypt Card
          Expanded(
            child: SailCard(
              title: 'Encrypt',
              subtitle: 'Encrypt a message for a BitName or pubkey',
              error: encryptError,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailTextField(
                    label: "Receiver's BitName or Encryption Pubkey (Bech32m)",
                    hintText: 'Enter a BitName or a pubkey',
                    controller: encryptPubkeyController,
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
          // Decrypt Card
          Expanded(
            child: SailCard(
              title: 'Decrypt',
              subtitle: 'Decrypt a message using your pubkey',
              error: decryptError,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailTextField(
                    label: "Receiver's BitName or Encryption Pubkey (Bech32m)",
                    hintText: 'Enter a BitName or a pubkey',
                    controller: decryptPubkeyController,
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
}
