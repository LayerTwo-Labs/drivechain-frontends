import 'dart:convert';

class BlockchainInfo {
  // indicates whether the chain is currently downloading the chain
  // for the first time
  final bool initialBlockDownload;
  final int blockHeight;

  BlockchainInfo({
    required this.initialBlockDownload,
    required this.blockHeight,
  });

  factory BlockchainInfo.fromMap(Map<String, dynamic> map) {
    return BlockchainInfo(
      initialBlockDownload: map['initialblockdownload'] ?? '',
      blockHeight: map['blocks'] ?? 0,
    );
  }

  static BlockchainInfo fromJson(String json) => BlockchainInfo.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'initialblockdownload': initialBlockDownload,
      };
}
