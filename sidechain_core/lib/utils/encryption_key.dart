import 'dart:convert';

import 'package:thirds/blake3.dart';

/// A name on the chain: its BLAKE3 hash and its encryption pubkey.
typedef NamedPubkey = ({String hash, String? encryptionPubkey});

/// The encryption pubkey of the name that [input] identifies, by plaintext or
/// by hash. Calls [onPlaintextMatch] when [input] is the plaintext of a name.
String? resolveEncryptionPubkey(
  String input,
  List<NamedPubkey> entries, {
  required void Function(String plaintext) onPlaintextMatch,
}) {
  if (input.isEmpty) {
    return null;
  }

  final trimmed = input.trim();
  final plaintextHash = blake3Hex(utf8.encode(trimmed)).toLowerCase();
  var match = entries.where((entry) => entry.hash == plaintextHash).firstOrNull;
  if (match != null) {
    onPlaintextMatch(trimmed);
  }

  match ??= entries.where((entry) => entry.hash.toLowerCase() == trimmed.toLowerCase()).firstOrNull;
  return match?.encryptionPubkey;
}
