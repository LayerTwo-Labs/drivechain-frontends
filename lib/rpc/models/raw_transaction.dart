class RawTransaction {
  final String txid;
  final String hash;
  final int size;
  final int vsize;
  final int version;
  final int locktime;
  final List<Vin> vin;
  final List<Vout> vout;

  RawTransaction({
    required this.txid,
    required this.hash,
    required this.size,
    required this.vsize,
    required this.version,
    required this.locktime,
    required this.vin,
    required this.vout,
  });

  factory RawTransaction.fromJson(Map<String, dynamic> json) {
    return RawTransaction(
      txid: json['txid'],
      hash: json['hash'],
      size: json['size'],
      vsize: json['vsize'],
      version: json['version'],
      locktime: json['locktime'],
      vin: (json['vin'] as List).map((e) => Vin.fromJson(e)).toList(),
      vout: (json['vout'] as List).map((e) => Vout.fromJson(e)).toList(),
    );
  }
}

class Vin {
  final String txid;
  final int vout;
  final ScriptSig scriptSig;
  final List<String>? txinwitness;
  final int sequence;

  Vin({
    required this.txid,
    required this.vout,
    required this.scriptSig,
    this.txinwitness,
    required this.sequence,
  });

  factory Vin.fromJson(Map<String, dynamic> json) {
    return Vin(
      txid: getMapKey(json, 'txid', ''),
      vout: getMapKey(json, 'vout', 0),
      scriptSig: ScriptSig.fromJson(json['scriptSig']),
      txinwitness: json['txinwitness']?.cast<String>(),
      sequence: json['sequence'],
    );
  }
}

class ScriptSig {
  final String asm;
  final String hex;

  ScriptSig({required this.asm, required this.hex});

  factory ScriptSig.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ScriptSig(asm: '', hex: '');
    }

    return ScriptSig(
      asm: json['asm'],
      hex: json['hex'],
    );
  }
}

class Vout {
  final double value;
  final int n;
  final ScriptPubKey scriptPubKey;

  Vout({required this.value, required this.n, required this.scriptPubKey});

  factory Vout.fromJson(Map<String, dynamic> json) {
    return Vout(
      value: json['value'],
      n: json['n'],
      scriptPubKey: ScriptPubKey.fromJson(json['scriptPubKey']),
    );
  }
}

class ScriptPubKey {
  final String asm;
  final String hex;
  final int reqSigs;
  final String type;
  final List<String> addresses;

  ScriptPubKey({
    required this.asm,
    required this.hex,
    required this.reqSigs,
    required this.type,
    required this.addresses,
  });

  factory ScriptPubKey.fromJson(Map<String, dynamic> json) {
    return ScriptPubKey(
      asm: json['asm'],
      hex: json['hex'],
      reqSigs: getMapKey(json, 'reqSigs', 0),
      type: json['type'],
      addresses: List<String>.from(json['addresses'] ?? []),
    );
  }
}

dynamic getMapKey(Map<String, dynamic> json, String key, fallback) {
  if (json.containsKey(key)) {
    return json[key];
  }

  return fallback;
}
