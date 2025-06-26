import 'dart:convert';
import 'dart:math' as math;

import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/providers/parentchain/bmm_provider.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/rpcs/zcash_rpc.dart';
import 'package:sail_ui/settings/secure_store.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';
import 'package:synchronized/synchronized.dart';

/// Represents a single UTXO for mock implementation
class _MockUTXO {
  final String txid;
  final int vout;
  final String address;
  final double amount;
  final int confirmations;
  final String scriptPubKey; // For validation
  final bool isChange;
  final int time; // Add time field

  _MockUTXO({
    required this.txid,
    required this.vout,
    required this.address,
    required this.amount,
    required this.confirmations,
    required this.scriptPubKey,
    required this.time, // Add to constructor
    this.isChange = false,
  });

  Map<String, dynamic> toJson() => {
        'txid': txid,
        'vout': vout,
        'address': address,
        'amount': amount,
        'confirmations': confirmations,
        'scriptPubKey': scriptPubKey,
        'isChange': isChange,
        'time': time, // Add to JSON
      };

  factory _MockUTXO.fromJson(Map<String, dynamic> json) => _MockUTXO(
        txid: json['txid'],
        vout: json['vout'],
        address: json['address'],
        amount: json['amount'],
        confirmations: json['confirmations'],
        scriptPubKey: json['scriptPubKey'],
        time: json['time'], // Add to fromJson
        isChange: json['isChange'] ?? false,
      );
}

/// A mock implementation of ZCashRPC that simulates a live node with persistent state
class MockZCashRPCLive extends ZCashRPC {
  final KeyValueStore storage;
  final _lock = Lock();

  // Add new storage keys
  static const String _utxoSetKey = 'utxo_set';

  // Helper methods for UTXO management
  Future<List<_MockUTXO>> _getUTXOSet() async {
    final utxoSetStr = await storage.getString(_utxoSetKey);
    if (utxoSetStr == null) return [];
    final utxoList = jsonDecode(utxoSetStr) as List;
    return utxoList.map((u) => _MockUTXO.fromJson(u)).toList();
  }

  Future<void> _updateUTXOSet(List<_MockUTXO> utxos) async {
    await _lock.synchronized(() async {
      await storage.setString(
        _utxoSetKey,
        jsonEncode(utxos.map((u) => u.toJson()).toList()),
      );
      notifyListeners(); // Notify after UTXO set changes
    });
  }

  String _generateTxid() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  MockZCashRPCLive({required this.storage})
      : super(
          conf: NodeConnectionSettings('./mocked.conf', 'mocktown', 1337, '', '', true),
          binary: ZCash(),
          restartOnFailure: false,
        ) {
    _initializeUTXOSet(); // Initialize UTXO set when mock is created
  }

  Future<String> _generateBlock() async {
    final blockHash = _generateTxid();

    await _lock.synchronized(() async {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final address = await getSideAddress();
      final blocks = await _getBlocks();
      final transparentTransactions = await _getTransparentTransactions();

      // Add mining reward
      final txid = _generateTxid();
      transparentTransactions.add(
        CoreTransaction(
          address: address,
          category: 'generate',
          amount: 12.5,
          fee: 0,
          confirmations: 1,
          txid: txid,
          time: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          timereceived: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          label: '',
          vout: 0,
          trusted: true,
          blockhash: blockHash,
          blockindex: blocks.length,
          blocktime: timestamp,
          comment: '',
          bip125Replaceable: 'no',
          abandoned: false,
          raw: '{"txid": "$txid", "generated": true}',
        ),
      );

      // Increase confirmations for all transactions
      final updatedTransactions = transparentTransactions.map((tx) {
        return CoreTransaction(
          address: tx.address,
          category: tx.category,
          amount: tx.amount,
          label: tx.label,
          vout: tx.vout,
          fee: tx.fee,
          confirmations: tx.confirmations + 1,
          trusted: tx.trusted,
          blockhash: tx.confirmations == 0 ? blockHash : tx.blockhash,
          blockindex: tx.confirmations == 0 ? blocks.length : tx.blockindex,
          blocktime: tx.confirmations == 0 ? timestamp : tx.blocktime,
          txid: tx.txid,
          time: DateTime.fromMillisecondsSinceEpoch((tx.time.millisecondsSinceEpoch ~/ 1000) * 1000),
          timereceived: DateTime.fromMillisecondsSinceEpoch((tx.timereceived.millisecondsSinceEpoch ~/ 1000) * 1000),
          comment: tx.comment,
          bip125Replaceable: tx.bip125Replaceable,
          abandoned: tx.abandoned,
          raw: tx.raw,
        );
      }).toList();

      await _updateTransparentTransactions(updatedTransactions);

      // Save block data
      blocks.add({
        'hash': blockHash,
        'height': blocks.length + 1,
        'time': timestamp,
        'previousblockhash': blocks.isEmpty ? '' : blocks.last['hash'],
      });
      await storage.setString('blocks', jsonEncode(blocks));
    });

    notifyListeners();
    return blockHash;
  }

  Future<List<CoreTransaction>> _getTransparentTransactions() async {
    final txListStr = await storage.getString('transparent_transactions');
    if (txListStr == null) return [];
    final txList = jsonDecode(txListStr) as List;
    return txList.map((t) => CoreTransaction.fromJson(t)).toList();
  }

  Future<List<CoreTransaction>> _getShieldedTransactions() async {
    final txListStr = await storage.getString('shielded_transactions');
    if (txListStr == null) return [];
    final txList = jsonDecode(txListStr) as List;
    return txList.map((t) => CoreTransaction.fromJson(t)).toList();
  }

  Future<void> _updateTransparentTransactions(List<CoreTransaction> transactions) async {
    await _lock.synchronized(() async {
      await storage.setString(
        'transparent_transactions',
        jsonEncode(transactions.map((t) => t.toJson()).toList()),
      );
      notifyListeners(); // Notify after transaction changes
    });
  }

  Future<void> _updateShieldedTransactions(List<CoreTransaction> transactions) async {
    await _lock.synchronized(() async {
      await storage.setString(
        'shielded_transactions',
        jsonEncode(transactions.map((t) => t.toJson()).toList()),
      );
      notifyListeners(); // Notify after shielded transaction changes
    });
  }

  Future<List<CoreTransaction>> _getTransactions() async {
    final txListStr = await storage.getString('transactions');
    if (txListStr == null) return [];
    final txList = jsonDecode(txListStr) as List;
    return txList.map((t) => CoreTransaction.fromJson(t)).toList();
  }

  Future<List<Map<String, dynamic>>> _getBlocks() async {
    final blocksStr = await storage.getString('blocks');
    if (blocksStr == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(blocksStr));
  }

  @override
  Future<(double, double)> balance() async {
    // Calculate transparent balance from unspent transparent UTXOs
    final transparentUtxos = await listUnshieldedCoins();
    final transparentBalance = transparentUtxos.fold<double>(
      0,
      (sum, utxo) => sum + utxo.amount,
    );

    // Calculate shielded balance from unspent shielded UTXOs
    final shieldedUtxos = await listShieldedCoins();
    final shieldedBalance = shieldedUtxos.fold<double>(
      0,
      (sum, utxo) => sum + utxo.amount,
    );

    return (transparentBalance, shieldedBalance);
  }

  @override
  Future<String> sendTransparent(String address, double amount, bool subtractFeeFromAmount) async {
    final utxos = await _getUTXOSet();
    if (utxos.isEmpty) {
      throw Exception('No UTXOs available');
    }

    final txid = _generateTxid();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final fee = cleanAmount(await sideEstimateFee());
    amount = cleanAmount(amount);

    final transactions = await _getTransparentTransactions();

    // Add the send transaction
    transactions.add(
      CoreTransaction(
        address: address,
        category: 'send',
        amount: -amount,
        fee: -fee,
        confirmations: 0,
        txid: txid,
        time: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        timereceived: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        label: '',
        vout: 0,
        trusted: false,
        blockhash: '',
        blockindex: 0,
        blocktime: timestamp,
        comment: '',
        bip125Replaceable: 'unknown',
        abandoned: false,
        raw: '{"txid": "$txid", "amount": $amount, "fee": $fee}',
      ),
    );

    await _updateTransparentTransactions(transactions);

    // Trigger balance updates
    notifyListeners();

    return txid;
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    return await _lock.synchronized(() async {
      amount = cleanAmount(amount);
      final fee = await sideEstimateFee();

      if (amount + fee > utxo.amount) {
        throw Exception('Insufficient transparent funds in UTXO');
      }

      final txid = _generateTxid();
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final privateAddress = await getPrivateAddress();

      final transparentTransactions = await _getTransparentTransactions();
      final shieldedTransactions = await _getShieldedTransactions();

      // Find and remove the original UTXO transaction
      transparentTransactions.removeWhere((tx) => tx.txid == utxo.txid);

      // Add spending transaction for the transparent UTXO
      transparentTransactions.add(
        CoreTransaction(
          address: utxo.address,
          category: 'send',
          amount: -utxo.amount,
          fee: 0,
          confirmations: 0,
          txid: txid,
          time: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          timereceived: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          label: '',
          vout: 0,
          trusted: false,
          blockhash: '',
          blockindex: 0,
          blocktime: 0,
          comment: '',
          bip125Replaceable: 'unknown',
          abandoned: false,
          raw: '{"txid": "$txid", "spent": true, "spends": "${utxo.txid}"}',
        ),
      );

      // Add shielding transaction to shielded list
      shieldedTransactions.add(
        CoreTransaction(
          address: privateAddress,
          category: 'shield_receive',
          amount: amount,
          fee: 0,
          confirmations: 0,
          txid: txid,
          time: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          timereceived: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          label: '',
          vout: 1,
          trusted: false,
          blockhash: '',
          blockindex: 0,
          blocktime: 0,
          comment: '',
          bip125Replaceable: 'unknown',
          abandoned: false,
          raw: '{"txid": "$txid", "shielded": true}',
        ),
      );

      // If there's change, create a new transparent UTXO for it
      final change = utxo.amount - amount - fee;
      if (change > 0) {
        transparentTransactions.add(
          CoreTransaction(
            address: utxo.address,
            category: 'receive',
            amount: change,
            fee: 0,
            confirmations: 0,
            txid: txid,
            time: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
            timereceived: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
            label: '',
            vout: 2,
            trusted: false,
            blockhash: '',
            blockindex: 0,
            blocktime: 0,
            comment: '',
            bip125Replaceable: 'unknown',
            abandoned: false,
            raw: '{"txid": "$txid", "change": true}',
          ),
        );
      }

      await _updateTransparentTransactions(transparentTransactions);
      await _updateShieldedTransactions(shieldedTransactions);

      final opid = 'opid-${_generateTxid()}';
      return opid;
    });
  }

  @override
  Future<(String, String)> deshield(ShieldedUTXO utxo, double amount) async {
    return await _lock.synchronized(() async {
      amount = cleanAmount(amount);
      final fee = await sideEstimateFee();

      if (amount + fee > utxo.amount) {
        throw Exception('Insufficient shielded funds in UTXO');
      }

      final txid = _generateTxid();
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final transparentAddress = await getSideAddress();

      final transparentTransactions = await _getTransparentTransactions();
      final shieldedTransactions = await _getShieldedTransactions();

      // Find and remove the original shielded UTXO transaction
      shieldedTransactions.removeWhere((tx) => tx.txid == utxo.txid);

      // Add spending transaction for the shielded UTXO
      shieldedTransactions.add(
        CoreTransaction(
          address: utxo.address,
          category: 'deshield_send',
          amount: -utxo.amount,
          fee: -fee,
          confirmations: 0,
          txid: txid,
          time: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          timereceived: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          label: '',
          vout: 0,
          trusted: false,
          blockhash: '',
          blockindex: 0,
          blocktime: 0,
          comment: '',
          bip125Replaceable: 'unknown',
          abandoned: false,
          raw: '{"txid": "$txid", "spent": true, "spends": "${utxo.txid}"}',
        ),
      );

      // Create new transparent UTXO for the deshielded amount
      transparentTransactions.add(
        CoreTransaction(
          address: transparentAddress,
          category: 'receive', // Changed from deshield_receive to receive to match UTXO handling
          amount: amount,
          fee: 0,
          confirmations: 0,
          txid: txid,
          time: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          timereceived: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
          label: '',
          vout: 0,
          trusted: false,
          blockhash: '',
          blockindex: 0,
          blocktime: 0,
          comment: '',
          bip125Replaceable: 'unknown',
          abandoned: false,
          raw: '{"txid": "$txid", "deshielded": true}',
        ),
      );

      // If there's change, create a new shielded UTXO for it
      final change = utxo.amount - amount - fee;
      if (change > 0) {
        shieldedTransactions.add(
          CoreTransaction(
            address: utxo.address,
            category: 'shield_receive',
            amount: change,
            fee: 0,
            confirmations: 0,
            txid: txid,
            time: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
            timereceived: DateTime.fromMillisecondsSinceEpoch((timestamp * 1000) * 1000),
            label: '',
            vout: 1,
            trusted: false,
            blockhash: '',
            blockindex: 0,
            blocktime: 0,
            comment: '',
            bip125Replaceable: 'unknown',
            abandoned: false,
            raw: '{"txid": "$txid", "change": true}',
          ),
        );
      }

      await _updateTransparentTransactions(transparentTransactions);
      await _updateShieldedTransactions(shieldedTransactions);

      final opid = 'opid-${_generateTxid()}';
      return (opid, transparentAddress);
    });
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    return sendTransparent(address, amount, subtractFeeFromAmount);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    return await _lock.synchronized(() async {
      return await sendTransparent(address, amount, false);
    });
  }

  @override
  Future<List<OperationStatus>> listOperations() async {
    final operationsStr = await storage.getString('operations');
    final operations = operationsStr != null ? jsonDecode(operationsStr) as List : [];
    return (operations).map((op) => OperationStatus.fromJson(op)).toList();
  }

  @override
  Future<List<ShieldedUTXO>> listShieldedCoins() async {
    final transactions = await _getShieldedTransactions();
    final utxos = <ShieldedUTXO>[];

    for (final tx in transactions) {
      final cleanedAmount = cleanAmount(tx.amount);
      // Only include shield_receive transactions that have a strictly positive amount
      if (tx.category == 'shield_receive' && cleanedAmount > 0.0) {
        utxos.add(
          ShieldedUTXO(
            txid: tx.txid,
            pool: 'sapling',
            type: 'sapling',
            outindex: 0,
            confirmations: tx.confirmations,
            spendable: true,
            address: tx.address,
            amount: cleanedAmount,
            amountZat: (cleanedAmount * 100000000).round().toDouble(),
            memo: '',
            change: false,
            raw: tx.raw,
          ),
        );
      }
    }

    return utxos;
  }

  @override
  Future<List<UnshieldedUTXO>> listUnshieldedCoins() async {
    final transactions = await _getTransparentTransactions();
    final utxos = <UnshieldedUTXO>[];
    final spentTxids = <String>{};

    // First, collect all spent txids
    for (final tx in transactions) {
      try {
        final raw = jsonDecode(tx.raw);
        if (raw['spent'] == true) {
          spentTxids.add(tx.txid);
        }
      } catch (_) {
        // Skip if raw JSON is invalid
      }
    }

    for (final tx in transactions) {
      final cleanedAmount = cleanAmount(tx.amount);
      // Only include receive/generate transactions that:
      // 1. Have a strictly positive amount
      // 2. Haven't been spent
      if ((tx.category == 'receive' || tx.category == 'generate') &&
          cleanedAmount > 0.0 &&
          !spentTxids.contains(tx.txid)) {
        utxos.add(
          UnshieldedUTXO(
            txid: tx.txid,
            address: tx.address,
            amount: cleanedAmount,
            confirmations: tx.confirmations,
            generated: tx.category == 'generate',
            raw: tx.raw,
          ),
        );
      }
    }

    return utxos;
  }

  @override
  Future<List<ShieldedUTXO>> listPrivateTransactions() async {
    final transactions = await _getTransactions();
    return transactions
        .where((tx) => tx.category.contains('shield'))
        .map(
          (tx) => ShieldedUTXO(
            txid: tx.txid,
            pool: 'sapling',
            type: 'sapling',
            outindex: 0,
            confirmations: tx.confirmations,
            spendable: true,
            address: tx.address,
            amount: tx.amount.abs(),
            amountZat: (tx.amount.abs() * 100000000).round().toDouble(),
            memo: '',
            change: false,
            raw: tx.toString(),
          ),
        )
        .toList();
  }

  @override
  Future<String> getPrivateAddress() async {
    return 'zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg';
  }

  @override
  Future<String> getSideAddress() async {
    return 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu';
  }

  @override
  Future<String> getDepositAddress() async {
    final address = await getSideAddress();
    return formatDepositAddress(address, chain.slot);
  }

  @override
  Future<int> ping() async {
    return 100;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<void> stopRPC() async {
    super.dispose();
  }

  @override
  Future<int> account() async {
    return 0;
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await _getBlocks();
    final latestBlock = blocks.isEmpty ? null : blocks.last;

    return BlockchainInfo(
      chain: 'mocknet',
      blocks: blocks.length,
      headers: blocks.length,
      bestBlockHash: latestBlock?['hash'] as String,
      difficulty: 1.0,
      time: latestBlock?['time'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      medianTime: latestBlock?['time'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      verificationProgress: 100.0,
      initialBlockDownload: false,
      chainWork: '0000000000000000000000000000000000000000000000000000000000000000',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return await _getTransactions();
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.00001;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  Future<dynamic> callRAW(String method, [params]) async {
    switch (method) {
      case 'getbalance':
        final (transparent, _) = await balance();
        return transparent;
      case 'getunconfirmedbalance':
        return 0.0;
      case 'z_getbalance':
        final (_, shielded) = await balance();
        return shielded;
      case 'generate':
        if (params == null || params.isEmpty) {
          throw Exception('Missing required parameter: number of blocks to generate');
        }

        int numBlocks;
        try {
          numBlocks = int.parse(params[0].toString());
        } catch (e) {
          throw Exception('Invalid parameter: number of blocks must be a number');
        }

        if (numBlocks <= 0) {
          throw Exception('Invalid parameter: number of blocks must be positive');
        }

        final blockHashes = <String>[];
        for (var i = 0; i < numBlocks; i++) {
          final hash = await _generateBlock();
          blockHashes.add(hash);
        }

        return blockHashes;
      default:
        throw Exception('Method $method not implemented in mock');
    }
  }

  @override
  List<String> getMethods() {
    return zcashRPCMethods;
  }

  // Add method to initialize UTXO set from existing transactions
  Future<void> _initializeUTXOSet() async {
    final transactions = await _getTransparentTransactions();
    final utxoSet = <_MockUTXO>[];

    for (final tx in transactions) {
      if ((tx.category == 'receive' || tx.category == 'generate') && tx.amount > 0) {
        try {
          final raw = jsonDecode(tx.raw);
          if (raw['spent'] != true) {
            utxoSet.add(
              _MockUTXO(
                txid: tx.txid,
                vout: tx.vout,
                address: tx.address,
                amount: tx.amount,
                confirmations: tx.confirmations,
                scriptPubKey: 'mock-script',
                isChange: raw['change'] == true,
                time: tx.time.millisecondsSinceEpoch ~/ 1000,
              ),
            );
          }
        } catch (_) {
          // Skip invalid transactions
        }
      }
    }

    await _updateUTXOSet(utxoSet);
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    return [];
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    return BmmResult.empty();
  }
}
