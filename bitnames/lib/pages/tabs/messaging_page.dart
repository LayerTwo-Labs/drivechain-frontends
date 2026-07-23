import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:flutter/widgets.dart';
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
  final BitnamesRPC rpc = GetIt.I.get<BitnamesRPC>();
  final bitnamesProvider = GetIt.I.get<BitnamesProvider>();

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

  bool get _hasBitnamesEncryptMatch {
    return _resolveEncryptionKey(encryptPubkeyController.text) != null;
  }

  bool get _hasBitnamesDecryptMatch {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final encrypt = _encryptCard(), decrypt = _decryptCard();
          if (constraints.maxWidth < 800) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [encrypt, const SizedBox(height: 24), decrypt],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: encrypt),
              const SizedBox(width: 24),
              Expanded(child: decrypt),
            ],
          );
        },
      ),
    );
  }

  Widget _encryptCard() => SailCard(
    title: 'Encrypt',
    subtitle: 'Encrypt a message for a BitName or pubkey',
    error: encryptError,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailTextField(
          label: "Recipient's BitName or encryption pubkey (Bech32m)",
          hintText: 'Enter a BitName or pubkey',
          controller: encryptPubkeyController,
          suffixWidget: _hasBitnamesEncryptMatch ? SailSVG.icon(SailSVGAsset.iconSuccess, height: 20) : null,
        ),
        const SizedBox(height: 16),
        SailTextField(
          label: 'Plaintext message',
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
            child: ResultRow(
              label: 'Ciphertext',
              value: encryptResult!,
              monospace: true,
              copyable: true,
            ),
          ),
      ],
    ),
  );

  Widget _decryptCard() => SailCard(
    title: 'Decrypt',
    subtitle: 'Decrypt a message sent to one of your BitNames',
    error: decryptError,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailTextField(
          label: 'Your BitName or encryption pubkey (Bech32m)',
          hintText: 'Enter your receiving BitName or pubkey',
          controller: decryptPubkeyController,
          suffixWidget: _hasBitnamesDecryptMatch ? SailSVG.icon(SailSVGAsset.iconSuccess, height: 20) : null,
        ),
        const SizedBox(height: 16),
        SailTextField(
          label: 'Ciphertext message (hex)',
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
            child: ResultRow(
              label: 'Plaintext',
              value: decryptResult!,
              copyable: true,
            ),
          ),
      ],
    ),
  );

  BitnameEntry? _resolveBitName(String input) {
    final trimmedInput = input.trim();
    if (trimmedInput.isEmpty) return null;

    var existingEntryMatch = bitnamesProvider.entries
        .where(
          (entry) => entry.hash == blake3Hex(utf8.encode(trimmedInput)).toLowerCase(),
        )
        .firstOrNull;
    existingEntryMatch ??= bitnamesProvider.entries
        .where(
          (entry) => entry.hash.toLowerCase() == trimmedInput.toLowerCase(),
        )
        .firstOrNull;
    return existingEntryMatch;
  }

  String? _resolveEncryptionKey(String input) => _resolveBitName(input)?.details.encryptionPubkey;

  String _requireEncryptionKey(String input) {
    final trimmed = input.trim(), entry = _resolveBitName(input);
    if (entry != null) {
      final key = entry.details.encryptionPubkey;
      if (key == null) {
        throw const FormatException(
          'This BitName has no encryption key. Its owner must add one before messaging.',
        );
      }
      if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(trimmed)) unawaited(bitnamesProvider.saveHashNameMapping(trimmed));
      return key;
    }
    if (trimmed.isEmpty) throw const FormatException('Enter a BitName or encryption pubkey.');
    return trimmed;
  }

  Future<void> handleEncrypt() async {
    setState(() {
      encryptLoading = true;
      encryptError = null;
      encryptResult = null;
    });

    try {
      final resolvedKey = _requireEncryptionKey(encryptPubkeyController.text);
      final ciphertext = await rpc.encryptMsg(
        msg: encryptMessageController.text,
        encryptionPubkey: resolvedKey,
      );
      if (!mounted) return;
      setState(() => encryptResult = ciphertext);
    } catch (e) {
      if (mounted) setState(() => encryptError = _friendlyError(e));
    } finally {
      if (mounted) setState(() => encryptLoading = false);
    }
  }

  Future<void> handleDecrypt() async {
    setState(() {
      decryptLoading = true;
      decryptError = null;
      decryptResult = null;
    });

    try {
      final resolvedKey = _requireEncryptionKey(decryptPubkeyController.text);
      final plaintext = await rpc.decryptMsg(
        ciphertext: decryptMessageController.text.trim(),
        encryptionPubkey: resolvedKey,
      );
      if (!mounted) return;
      setState(() => decryptResult = plaintext);
    } catch (e) {
      if (mounted) setState(() => decryptError = _friendlyError(e));
    } finally {
      if (mounted) setState(() => decryptLoading = false);
    }
  }

  String _friendlyError(Object error) => error is FormatException
      ? error.message.toString()
      : 'Request failed. Check the BitNames connection and try again.';

  void _onChange() {
    if (mounted) setState(() {});
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
