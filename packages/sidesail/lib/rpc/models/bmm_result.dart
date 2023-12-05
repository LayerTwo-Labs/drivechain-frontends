import 'dart:convert';

class BmmResult {
  final String hashLastMainBlock;

  // hashCreatedMerkleRoot/hashCreated in the testchain codebase
  final String? bmmBlockCreated;

  // hashConnected in the testchain codebase
  final String? bmmBlockSubmitted;

  // hashMerkleRoot/hashConnectedBlind in the testchain codebase
  final String? bmmBlockSubmittedBlind;

  final int ntxn; // number of transactions
  final int nfees; // total fees
  final String txid; // transaction ID
  final String? error; // error message, if any
  final String raw; // raw JSON string

  BmmResult({
    required this.hashLastMainBlock,
    required this.bmmBlockCreated,
    required this.bmmBlockSubmitted,
    required this.bmmBlockSubmittedBlind,
    required this.ntxn,
    required this.nfees,
    required this.txid,
    this.error,
    required this.raw,
  });

  factory BmmResult.fromMap(Map<String, dynamic> map) {
    return BmmResult(
      hashLastMainBlock: map['hash_last_main_block'] ?? '',
      bmmBlockCreated: ifNonEmpty(map['bmm_block_created']),
      bmmBlockSubmitted: ifNonEmpty(map['bmm_block_submitted']),
      bmmBlockSubmittedBlind: ifNonEmpty(map['bmm_block_submitted_blind']),
      ntxn: map['ntxn'] ?? 0,
      nfees: map['nfees'] ?? 0,
      txid: map['txid'] ?? '',
      error: ifNonEmpty(map['error']),
      raw: jsonEncode(map),
    );
  }

  static BmmResult fromJson(Map<String, dynamic> json) => BmmResult.fromMap(json);
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'hash_last_main_block': hashLastMainBlock,
        'bmm_block_created': bmmBlockCreated,
        'bmm_block_submitted': bmmBlockSubmitted,
        'bmm_block_submitted_blind': bmmBlockSubmittedBlind,
        'ntxn': ntxn,
        'nfees': nfees,
        'txid': txid,
        'error': error,
      };
}

String? ifNonEmpty(String input) {
  if (input.isEmpty || input.split('').every((element) => element == '0')) {
    return null;
  }

  return input;
}
