import 'dart:convert';

class BlockchainInfo {
  // indicates whether the chain is currently downloading the chain
  // for the first time
  final bool initialBlockDownload;

  BlockchainInfo({
    required this.initialBlockDownload,
  });

  factory BlockchainInfo.fromMap(Map<String, dynamic> map) {
    return BlockchainInfo(
      initialBlockDownload: map['initialblockdownload'] ?? '',
    );
  }

  static BlockchainInfo fromJson(String json) => BlockchainInfo.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'initialblockdownload': initialBlockDownload,
      };
}
