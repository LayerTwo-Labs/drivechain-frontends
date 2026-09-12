import 'dart:convert';
import 'dart:typed_data';

import 'package:blockchain_utils/bech32/bech32.dart';
import 'package:blockchain_utils/bip/ecc/keys/ed25519_keys.dart';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:bs58/bs58.dart';
import 'package:connectrpc/connect.dart';
import 'package:sidechain_core/rpcs/bitnames_rpc.dart';
import 'package:thirds/blake3.dart';
import 'package:uuid/uuid.dart';

class BitnamesMessage {
  static const prefix = 'bitnames-message:';
  static const version = 1;

  final String id;
  final String sender;
  final String recipient;
  final String text;
  final String key;
  final String signature;

  const BitnamesMessage({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.text,
    required this.key,
    required this.signature,
  });

  String get storeId => '$prefix$sender:$recipient:$id';

  String get signedText => '$prefix${jsonEncode(_payload)}';

  Map<String, dynamic> get _payload => {
    'version': version,
    'id': id,
    'sender': sender,
    'recipient': recipient,
    'text': text,
  };

  String encode() => '$prefix${jsonEncode({..._payload, 'key': key, 'signature': signature})}';

  static BitnamesMessage? decode(String text) {
    if (!text.startsWith(prefix)) {
      return null;
    }
    final data = jsonDecode(text.substring(prefix.length));
    if (data is! Map<String, dynamic> ||
        data['version'] != version ||
        data['id'] is! String ||
        !Uuid.isValidUUID(fromString: data['id'] as String) ||
        !_isHash(data['sender']) ||
        !_isHash(data['recipient']) ||
        data['text'] is! String ||
        data['key'] is! String ||
        data['signature'] is! String) {
      throw const FormatException('Invalid BitNames message');
    }
    return BitnamesMessage(
      id: data['id'] as String,
      sender: data['sender'] as String,
      recipient: data['recipient'] as String,
      text: data['text'] as String,
      key: data['key'] as String,
      signature: data['signature'] as String,
    );
  }

  static bool _isHash(dynamic value) => value is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

  static String nameHash(String name) =>
      _isHash(name.toLowerCase()) ? name.toLowerCase() : blake3Hex(utf8.encode(name.toLowerCase()));

  static String addressForKey(String key) {
    final List<int> bytes;
    try {
      bytes = Bech32Decoder.decode('bn-svk', key, encoding: Bech32Encodings.bech32m);
    } on BlockchainUtilsException {
      throw const FormatException('Invalid BitNames owner key');
    }
    if (bytes.length != 32 ||
        !Ed25519PublicKey.isValidBytes(bytes) ||
        key != Bech32Encoder.encode('bn-svk', bytes, encoding: Bech32Encodings.bech32m)) {
      throw const FormatException('Invalid BitNames owner key');
    }
    return base58.encode(Uint8List.fromList(blake3(bytes).sublist(0, 20)));
  }

  static Future<BitnamesMessage> sign({
    required BitnamesRPC rpc,
    required String sender,
    required String recipient,
    required String text,
  }) async {
    final message = BitnamesMessage(
      id: const Uuid().v4(),
      sender: sender,
      recipient: recipient,
      text: text,
      key: '',
      signature: '',
    );
    final owner = await rpc.getBitNameOwner(sender);
    final result = await rpc.signArbitraryMsgAsAddr(msg: message.signedText, address: owner);
    final key = result['verifying_key'];
    final signature = result['signature'];
    if (key == null || signature == null || addressForKey(key) != owner) {
      throw const FormatException('The signature key does not match the BitName owner');
    }
    return BitnamesMessage(
      id: message.id,
      sender: sender,
      recipient: recipient,
      text: text,
      key: key,
      signature: signature,
    );
  }

  Future<String> checkSender(BitnamesRPC rpc, String recipientHash) async {
    if (recipient != recipientHash) {
      throw const FormatException('The message recipient does not match the selected identity');
    }
    if (!RegExp(r'^[0-9a-fA-F]{128}$').hasMatch(signature)) {
      throw const FormatException('Invalid BitNames message signature');
    }
    final address = addressForKey(key);
    final valid = await rpc.callRAW('verify_signature', [signature, key, 'arbitrary', signedText]);
    if (valid != true) {
      throw const FormatException('Invalid BitNames message signature');
    }
    final String owner;
    try {
      owner = await rpc.getBitNameOwner(sender);
    } on ConnectException catch (e) {
      if (e.code != Code.notFound) {
        rethrow;
      }
      throw const FormatException('The sender BitName has no owner');
    }
    if (address != owner) {
      throw const FormatException('The signature key does not match the BitName owner');
    }
    return owner;
  }
}
