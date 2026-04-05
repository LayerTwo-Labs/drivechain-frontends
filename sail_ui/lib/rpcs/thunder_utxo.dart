import 'dart:convert';

/// Type of outpoint in a UTXO
enum OutpointType {
  deposit,
  regular,

  // bitname specific types
  bitnameReservation,
  bitname,
}

/// Represents a generic sidechain UTXO
class SidechainUTXO {
  final String outpoint;
  final String address;
  final int valueSats;
  final OutpointType type;

  SidechainUTXO({
    required this.outpoint,
    required this.address,
    required this.valueSats,
    required this.type,
  });

  factory SidechainUTXO.fromJson(Map<String, dynamic> json) {
    final outpoint = json['outpoint'] as Map<String, dynamic>;
    final address = json['output']['address'] as String;
    final valueSats = json['output']['content']['Value'] as int;

    // Handle both Regular and Deposit outpoint types
    String outpointStr;
    OutpointType type;
    if (outpoint.containsKey('Regular')) {
      final regular = outpoint['Regular'] as Map<String, dynamic>;
      outpointStr = '${regular['txid']}:${regular['vout']}';
      type = OutpointType.regular;
    } else {
      outpointStr = outpoint['Deposit'] as String;
      type = OutpointType.deposit;
    }

    return SidechainUTXO(
      outpoint: outpointStr,
      address: address,
      valueSats: valueSats,
      type: type,
    );
  }

  static List<SidechainUTXO> fromJsonList(List<dynamic> json) {
    return json.map((item) => SidechainUTXO.fromJson(item as Map<String, dynamic>)).toList();
  }
}

/// Represents a Bitnames UTXO that extends the base SidechainUTXO
class BitnamesUTXO extends SidechainUTXO {
  final String content; // The full content as a JSON string

  BitnamesUTXO({
    required super.outpoint,
    required super.address,
    required super.valueSats,
    required super.type,
    required this.content,
  });

  factory BitnamesUTXO.fromJson(Map<String, dynamic> json) {
    final outpoint = json['outpoint'] as Map<String, dynamic>;
    final output = json['output'] as Map<String, dynamic>;

    // Handle both Regular and Deposit outpoint types
    String outpointStr;
    OutpointType type;
    if (outpoint.containsKey('Regular')) {
      final regular = outpoint['Regular'] as Map<String, dynamic>;
      outpointStr = '${regular['txid']}:${regular['vout']}';
      type = OutpointType.regular;
    } else {
      outpointStr = outpoint['Deposit'] as String;
      type = OutpointType.deposit;
    }

    // Get value from content
    int valueSats = 0;
    final content = output['content'] as Map<String, dynamic>;
    if (content.containsKey('BitcoinSats')) {
      valueSats = content['BitcoinSats'] as int;
    } else if (content.containsKey('BitNameReservation')) {
      // For BitNameReservation, value is 0
      type = OutpointType.bitnameReservation;
      valueSats = 0;
    } else if (content.containsKey('BitName')) {
      // For BitName, value is 0
      type = OutpointType.bitname;
      valueSats = 0;
    }

    return BitnamesUTXO(
      outpoint: outpointStr,
      address: output['address'] as String,
      valueSats: valueSats,
      type: type,
      content: jsonEncode(content),
    );
  }
}
