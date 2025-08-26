import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thirds/blake3.dart';

@RoutePage()
class MessagingTabPage extends StatefulWidget {
  const MessagingTabPage({super.key});

  @override
  State<MessagingTabPage> createState() => _MessagingTabPageState();
}

class _MessagingTabPageState extends State<MessagingTabPage> {
  final BitAssetsRPC rpc = GetIt.I.get<BitAssetsRPC>();
  final bitassetsProvider = GetIt.I.get<BitAssetsProvider>();

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

  bool get _hasBitAssetEncryptMatch {
    return _resolveEncryptionKey(encryptPubkeyController.text) != null;
  }

  bool get _hasBitAssetDecryptMatch {
    return _resolveEncryptionKey(decryptPubkeyController.text) != null;
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to update UI when text changes
    encryptPubkeyController.addListener(_onChange);
    decryptPubkeyController.addListener(_onChange);
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
              subtitle: 'Encrypt a message for a BitAsset or pubkey',
              error: encryptError,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailTextField(
                    label: "Receiver's BitAsset or Encryption Pubkey (Bech32m)",
                    hintText: 'Enter a BitAsset or a pubkey',
                    controller: encryptPubkeyController,
                    suffixWidget: _hasBitAssetEncryptMatch ? SailSVG.icon(SailSVGAsset.iconSuccess, width: 20) : null,
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
                  SailButton(label: 'Encrypt', onPressed: handleEncrypt, loading: encryptLoading),
                  if (encryptResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SailText.secondary13(encryptResult!, monospace: true),
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
                    label: "Receiver's BitAsset or Encryption Pubkey (Bech32m)",
                    hintText: 'Enter a BitAsset or a pubkey',
                    controller: decryptPubkeyController,
                    suffixWidget: _hasBitAssetDecryptMatch ? SailSVG.icon(SailSVGAsset.iconSuccess, width: 20) : null,
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
                  SailButton(label: 'Decrypt', onPressed: handleDecrypt, loading: decryptLoading),
                  if (decryptResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SailText.secondary13(decryptResult!, monospace: true),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Resolves the input to an encryption pubkey
  /// Input can be: username, blake3 hash, or direct encryption key
  String? _resolveEncryptionKey(String input) {
    if (input.isEmpty) {
      return null;
    }

    final trimmedInput = input.trim();

    // then check if input is a blake3 hash match
    var existingEntryMatch = bitassetsProvider.entries
        .where((entry) => entry.hash == blake3Hex(utf8.encode(trimmedInput)).toLowerCase())
        .firstOrNull;

    if (existingEntryMatch != null) {
      // we found a plaintext match! save it to disk for easy access later
      bitassetsProvider.saveHashNameMapping(trimmedInput);
      // refetch to set the name in the list
      bitassetsProvider.fetch();
    }

    // First, check if input is already a direct hash match in bitassets
    existingEntryMatch ??= bitassetsProvider.entries
        .where((entry) => entry.hash.toLowerCase() == trimmedInput.toLowerCase())
        .firstOrNull;

    // If no bitasset match found, assume input is a direct encryption key
    return existingEntryMatch?.details.encryptionPubkey;
  }

  void _onChange() {
    setState(() {});
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

      final ciphertext = await rpc.encryptMsg(msg: encryptMessageController.text.trim(), encryptionPubkey: resolvedKey);
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

      final plaintext = await rpc.decryptMsg(
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

  @override
  void dispose() {
    encryptPubkeyController.removeListener(_onChange);
    decryptPubkeyController.removeListener(_onChange);
    super.dispose();
  }
}
