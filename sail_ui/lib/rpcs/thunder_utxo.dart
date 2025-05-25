import 'dart:convert';

/// Represents a Thunder UTXO
class ThunderUTXO {
  final String outpoint;
  final String address;
  final int valueSats;

  ThunderUTXO({
    required this.outpoint,
    required this.address,
    required this.valueSats,
  });

  factory ThunderUTXO.fromJson(Map<String, dynamic> json) {
    final outpoint = json['outpoint']['Deposit'] as String;
    final address = json['output']['address'] as String;
    final valueSats = json['output']['content']['Value'] as int;

    return ThunderUTXO(
      outpoint: outpoint,
      address: address,
      valueSats: valueSats,
    );
  }

  Map<String, dynamic> toJson() => {
        'outpoint': {'Deposit': outpoint},
        'output': {
          'address': address,
          'content': {'Value': valueSats},
        },
      };

  static List<ThunderUTXO> fromJsonList(List<dynamic> json) {
    return json.map((item) => ThunderUTXO.fromJson(item as Map<String, dynamic>)).toList();
  }

  static String toJsonList(List<ThunderUTXO> utxos) {
    return jsonEncode(utxos.map((utxo) => utxo.toJson()).toList());
  }
}
