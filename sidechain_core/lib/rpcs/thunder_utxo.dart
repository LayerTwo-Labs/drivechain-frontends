import 'dart:convert';

/// Type of outpoint in a UTXO
enum OutpointType {
  deposit,
  regular,
  coinbase,

  // bitname specific types
  bitnameReservation,
  bitname,
}

/// One outpoint of a UTXO: the text form to show, and the kind it names.
class Outpoint {
  final String id;
  final OutpointType type;

  const Outpoint(this.id, this.type);

  /// Reads the externally tagged form every sidechain node writes.
  factory Outpoint.fromJson(Map<String, dynamic> json) {
    final regular = json['Regular'];
    if (regular is Map<String, dynamic>) {
      return Outpoint('${regular['txid']}:${regular['vout']}', OutpointType.regular);
    }
    final coinbase = json['Coinbase'];
    if (coinbase is Map<String, dynamic>) {
      return Outpoint('${coinbase['merkle_root']}:${coinbase['vout']}', OutpointType.coinbase);
    }
    return Outpoint(json['Deposit'] as String, OutpointType.deposit);
  }
}

/// Represents a generic sidechain UTXO
class SidechainUTXO {
  final String outpoint;
  final String address;
  final int valueSats;
  final OutpointType type;

  /// confirmed is false while a block still has to carry this coin. A node
  /// lists only mined coins, so the orchestrator adds the rest.
  final bool confirmed;

  SidechainUTXO({
    required this.outpoint,
    required this.address,
    required this.valueSats,
    required this.type,
    this.confirmed = true,
  });

  factory SidechainUTXO.fromJson(Map<String, dynamic> json) {
    final outpoint = Outpoint.fromJson(json['outpoint'] as Map<String, dynamic>);
    return SidechainUTXO(
      outpoint: outpoint.id,
      address: json['output']['address'] as String,
      valueSats: json['output']['content']['Value'] as int,
      type: outpoint.type,
      confirmed: json['confirmed'] as bool? ?? true,
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
    required super.confirmed,
    required this.content,
  });

  factory BitnamesUTXO.fromJson(Map<String, dynamic> json) {
    final outpoint = Outpoint.fromJson(json['outpoint'] as Map<String, dynamic>);
    final output = json['output'] as Map<String, dynamic>;
    String outpointStr = outpoint.id;
    OutpointType type = outpoint.type;

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
      confirmed: json['confirmed'] as bool? ?? true,
      content: jsonEncode(content),
    );
  }
}
