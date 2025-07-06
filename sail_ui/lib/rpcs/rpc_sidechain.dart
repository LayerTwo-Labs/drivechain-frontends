import 'dart:convert';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// RPC connection for all sidechain nodes
abstract class SidechainRPC extends RPCConnection {
  SidechainRPC({
    required super.conf,
    required super.binary,
    required super.restartOnFailure,
  });

  Sidechain get chain => Sidechain.fromBinary(binary);

  Future<dynamic> callRAW(String method, [List<dynamic>? params]);

  Future<List<CoreTransaction>> listTransactions();
  List<String> getMethods();

  Future<String> getDepositAddress();
  Future<int> getBlockCount();

  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  );
  Future<String> getSideAddress();
  Future<double> sideEstimateFee();
  Future<List<SidechainUTXO>> listUTXOs();

  /// Mine a block with a fee
  Future<BmmResult> mine(int feeSats);

  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle();

  /// Initiate a withdrawal to the specified mainchain address
  Future<String> withdraw(
    String address,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  );
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}

// Bitcoin types
class BitcoinOutPoint {
  final String txid;
  final int vout;

  BitcoinOutPoint({
    required this.txid,
    required this.vout,
  });

  factory BitcoinOutPoint.fromMap(Map<String, dynamic> map) {
    return BitcoinOutPoint(
      txid: map['txid'] as String,
      vout: map['vout'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'txid': txid,
        'vout': vout,
      };
}

class BitcoinTransaction {
  final String txid;
  final String hash;
  final int version;
  final int locktime;
  final List<BitcoinInput> inputs;
  final List<BitcoinOutput> outputs;

  BitcoinTransaction({
    required this.txid,
    required this.hash,
    required this.version,
    required this.locktime,
    required this.inputs,
    required this.outputs,
  });

  factory BitcoinTransaction.fromMap(Map<String, dynamic> map) {
    return BitcoinTransaction(
      txid: map['txid'] as String,
      hash: map['hash'] as String,
      version: map['version'] as int,
      locktime: map['locktime'] as int,
      inputs: (map['inputs'] as List<dynamic>).map((e) => BitcoinInput.fromMap(e as Map<String, dynamic>)).toList(),
      outputs: (map['outputs'] as List<dynamic>).map((e) => BitcoinOutput.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'txid': txid,
        'hash': hash,
        'version': version,
        'locktime': locktime,
        'inputs': inputs.map((e) => e.toMap()).toList(),
        'outputs': outputs.map((e) => e.toMap()).toList(),
      };
}

class BitcoinInput {
  final String txid;
  final int vout;
  final String? coinbase;
  final BitcoinScriptSig? scriptSig;
  final int sequence;
  final List<String>? witness;

  BitcoinInput({
    required this.txid,
    required this.vout,
    this.coinbase,
    this.scriptSig,
    required this.sequence,
    this.witness,
  });

  factory BitcoinInput.fromMap(Map<String, dynamic> map) {
    return BitcoinInput(
      txid: map['txid'] as String,
      vout: map['vout'] as int,
      coinbase: map['coinbase'] as String?,
      scriptSig: map['scriptSig'] != null ? BitcoinScriptSig.fromMap(map['scriptSig'] as Map<String, dynamic>) : null,
      sequence: map['sequence'] as int,
      witness: map['witness']?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() => {
        'txid': txid,
        'vout': vout,
        if (coinbase != null) 'coinbase': coinbase,
        if (scriptSig != null) 'scriptSig': scriptSig!.toMap(),
        'sequence': sequence,
        if (witness != null) 'witness': witness,
      };
}

class BitcoinOutput {
  final double amount;
  final int vout;
  final BitcoinScriptPubKey scriptPubKey;

  BitcoinOutput({
    required this.amount,
    required this.vout,
    required this.scriptPubKey,
  });

  factory BitcoinOutput.fromMap(Map<String, dynamic> map) {
    return BitcoinOutput(
      amount: (map['amount'] as num).toDouble(),
      vout: map['vout'] as int,
      scriptPubKey: BitcoinScriptPubKey.fromMap(map['scriptPubKey'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'vout': vout,
        'scriptPubKey': scriptPubKey.toMap(),
      };
}

class BitcoinScriptSig {
  final String asm;
  final String hex;

  BitcoinScriptSig({required this.asm, required this.hex});

  factory BitcoinScriptSig.fromMap(Map<String, dynamic> map) {
    return BitcoinScriptSig(
      asm: map['asm'] as String,
      hex: map['hex'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'asm': asm,
        'hex': hex,
      };
}

class BitcoinScriptPubKey {
  final String type;
  final String address;
  final String? asm;
  final String? hex;
  final List<String>? addresses;
  final int? reqSigs;

  BitcoinScriptPubKey({
    required this.type,
    required this.address,
    this.asm,
    this.hex,
    this.addresses,
    this.reqSigs,
  });

  factory BitcoinScriptPubKey.fromMap(Map<String, dynamic> map) {
    return BitcoinScriptPubKey(
      type: map['type'] as String,
      address: map['address'] as String,
      asm: map['asm'] as String?,
      hex: map['hex'] as String?,
      addresses: map['addresses']?.cast<String>(),
      reqSigs: map['reqSigs'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'address': address,
        if (asm != null) 'asm': asm,
        if (hex != null) 'hex': hex,
        if (addresses != null) 'addresses': addresses,
        if (reqSigs != null) 'reqSigs': reqSigs,
      };
}

enum OutPointType {
  regular,
  coinbase,
  deposit,
}

class PWBOutPoint {
  final OutPointType type;
  final RegularOutPoint? regular;
  final CoinbaseOutPoint? coinbase;
  final BitcoinOutPoint? deposit;

  PWBOutPoint({
    required this.type,
    this.regular,
    this.coinbase,
    this.deposit,
  }) : assert(
          (type == OutPointType.regular && regular != null) ||
              (type == OutPointType.coinbase && coinbase != null) ||
              (type == OutPointType.deposit && deposit != null),
        );

  factory PWBOutPoint.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('Regular')) {
      return PWBOutPoint(
        type: OutPointType.regular,
        regular: RegularOutPoint.fromMap(map['Regular'] as Map<String, dynamic>),
      );
    } else if (map.containsKey('Coinbase')) {
      return PWBOutPoint(
        type: OutPointType.coinbase,
        coinbase: CoinbaseOutPoint.fromMap(map['Coinbase'] as Map<String, dynamic>),
      );
    } else if (map.containsKey('Deposit')) {
      return PWBOutPoint(
        type: OutPointType.deposit,
        deposit: BitcoinOutPoint.fromMap(map['Deposit'] as Map<String, dynamic>),
      );
    }
    throw ArgumentError('Invalid outpoint type');
  }

  Map<String, dynamic> toMap() {
    switch (type) {
      case OutPointType.regular:
        return {'Regular': regular!.toMap()};
      case OutPointType.coinbase:
        return {'Coinbase': coinbase!.toMap()};
      case OutPointType.deposit:
        return {'Deposit': deposit!.toMap()};
    }
  }
}

class RegularOutPoint {
  final String txid;
  final int vout;

  RegularOutPoint({required this.txid, required this.vout});

  factory RegularOutPoint.fromMap(Map<String, dynamic> map) {
    return RegularOutPoint(
      txid: map['txid'] as String,
      vout: map['vout'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'txid': txid,
        'vout': vout,
      };
}

class CoinbaseOutPoint {
  final String merkleRoot;
  final int vout;

  CoinbaseOutPoint({required this.merkleRoot, required this.vout});

  factory CoinbaseOutPoint.fromMap(Map<String, dynamic> map) {
    return CoinbaseOutPoint(
      merkleRoot: map['merkle_root'] as String,
      vout: map['vout'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'merkle_root': merkleRoot,
        'vout': vout,
      };
}

class PWBOutput {
  final String address;
  final OutputContent content;

  PWBOutput({required this.address, required this.content});

  factory PWBOutput.fromMap(Map<String, dynamic> map) {
    return PWBOutput(
      address: map['address'] as String,
      content: OutputContent.fromMap(map['content'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() => {
        'address': address,
        'content': content.toMap(),
      };
}

class OutputContent {
  final OutputContentType type;
  final int? value;
  final WithdrawalOutput? withdrawal;

  OutputContent({
    required this.type,
    this.value,
    this.withdrawal,
  }) : assert(
          (type == OutputContentType.value && value != null) ||
              (type == OutputContentType.withdrawal && withdrawal != null),
        );

  factory OutputContent.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('Value')) {
      return OutputContent(
        type: OutputContentType.value,
        value: map['Value'] as int,
      );
    } else if (map.containsKey('Withdrawal')) {
      return OutputContent(
        type: OutputContentType.withdrawal,
        withdrawal: WithdrawalOutput.fromMap(map['Withdrawal'] as Map<String, dynamic>),
      );
    }
    throw ArgumentError('Invalid output content type');
  }

  Map<String, dynamic> toMap() {
    switch (type) {
      case OutputContentType.value:
        return {'Value': value};
      case OutputContentType.withdrawal:
        return {'Withdrawal': withdrawal!.toMap()};
    }
  }
}

enum OutputContentType {
  value,
  withdrawal,
}

class WithdrawalOutput {
  final int valueSats;
  final int mainFeeSats;
  final String mainAddress;

  WithdrawalOutput({
    required this.valueSats,
    required this.mainFeeSats,
    required this.mainAddress,
  });

  factory WithdrawalOutput.fromMap(Map<String, dynamic> map) {
    return WithdrawalOutput(
      valueSats: map['value_sats'] as int,
      mainFeeSats: map['main_fee_sats'] as int,
      mainAddress: map['main_address'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'value_sats': valueSats,
        'main_fee_sats': mainFeeSats,
        'main_address': mainAddress,
      };
}

class PendingWithdrawalBundle {
  final List<SpendUtxo> spendUtxos;
  final BitcoinTransaction tx;
  final int heightCreated;

  PendingWithdrawalBundle({
    required this.spendUtxos,
    required this.tx,
    required this.heightCreated,
  });

  factory PendingWithdrawalBundle.fromMap(Map<String, dynamic> map) {
    return PendingWithdrawalBundle(
      spendUtxos:
          (map['spend_utxos'] as List<dynamic>?)?.map((item) => SpendUtxo.fromMap(item as List<dynamic>)).toList() ??
              [],
      tx: BitcoinTransaction.fromMap(map['tx'] as Map<String, dynamic>),
      heightCreated: map['height_created'] as int,
    );
  }

  static PendingWithdrawalBundle? fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return null;
    return PendingWithdrawalBundle.fromMap(json);
  }

  Map<String, dynamic> toMap() => {
        'spend_utxos': spendUtxos.map((e) => e.toList()).toList(),
        'tx': tx.toMap(),
        'height_created': heightCreated,
      };

  String toJson() => jsonEncode(toMap());

  // Helper method to get the transaction ID
  String get txid => tx.txid;

  // Helper method to get the number of UTXOs being spent
  int get utxoCount => spendUtxos.length;

  // Helper method to calculate total value being withdrawn
  int get totalValue {
    int total = 0;
    for (final spendUtxo in spendUtxos) {
      if (spendUtxo.output.content.type == OutputContentType.value) {
        total += spendUtxo.output.content.value!;
      }
    }
    return total;
  }

  // Helper method to get all withdrawal outputs
  List<WithdrawalOutput> get withdrawalOutputs {
    List<WithdrawalOutput> withdrawals = [];
    for (final spendUtxo in spendUtxos) {
      if (spendUtxo.output.content.type == OutputContentType.withdrawal) {
        withdrawals.add(spendUtxo.output.content.withdrawal!);
      }
    }
    return withdrawals;
  }

  static PendingWithdrawalBundle empty() => PendingWithdrawalBundle(
        spendUtxos: [],
        tx: BitcoinTransaction(
          txid: '',
          hash: '',
          version: 0,
          locktime: 0,
          inputs: [],
          outputs: [],
        ),
        heightCreated: 0,
      );
}

// New class to properly represent the [OutPoint, Output] pair structure
class SpendUtxo {
  final PWBOutPoint outPoint;
  final PWBOutput output;

  SpendUtxo({
    required this.outPoint,
    required this.output,
  });

  factory SpendUtxo.fromMap(List<dynamic> list) {
    if (list.length != 2) {
      throw ArgumentError('SpendUtxo must have exactly 2 elements: [OutPoint, Output]');
    }

    return SpendUtxo(
      outPoint: PWBOutPoint.fromMap(list[0] as Map<String, dynamic>),
      output: PWBOutput.fromMap(list[1] as Map<String, dynamic>),
    );
  }

  List<dynamic> toList() => [outPoint.toMap(), output.toMap()];
}

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
  final String raw; // raw JSON string, empty means "Trying..."

  String get status {
    if (raw.isEmpty) return 'Trying...';
    if (error != null) return 'Error: $error';
    return 'Success';
  }

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

  BmmResult copyWith({
    String? hashLastMainBlock,
    String? bmmBlockCreated,
    String? bmmBlockSubmitted,
    String? bmmBlockSubmittedBlind,
    int? ntxn,
    int? nfees,
    String? txid,
    String? error,
    String? raw,
  }) {
    return BmmResult(
      hashLastMainBlock: hashLastMainBlock ?? this.hashLastMainBlock,
      bmmBlockCreated: bmmBlockCreated ?? this.bmmBlockCreated,
      bmmBlockSubmitted: bmmBlockSubmitted ?? this.bmmBlockSubmitted,
      bmmBlockSubmittedBlind: bmmBlockSubmittedBlind ?? this.bmmBlockSubmittedBlind,
      ntxn: ntxn ?? this.ntxn,
      nfees: nfees ?? this.nfees,
      txid: txid ?? this.txid,
      error: error ?? this.error,
      raw: raw ?? this.raw,
    );
  }

  factory BmmResult.fromMap(Map<String, dynamic>? map) {
    if (map == null) throw Exception('Null mining result');

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

  static BmmResult empty() => BmmResult(
        hashLastMainBlock: '0000000000000000000000000000000000000000000000000000000000000000',
        bmmBlockCreated: null,
        bmmBlockSubmitted: null,
        bmmBlockSubmittedBlind: null,
        ntxn: 0,
        nfees: 0,
        txid: '',
        error: null,
        raw: '{}',
      );
}

// Helper function for handling empty strings
String? ifNonEmpty(String? input) {
  if (input == null || input.isEmpty) return null;
  return input;
}
