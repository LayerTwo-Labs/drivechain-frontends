import 'dart:math';

import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';

/// Strategy for selecting UTXOs when building transactions
enum CoinSelectionStrategy {
  largestFirst,
  smallestFirst,
  random,
}

/// Result of coin selection
class CoinSelectionResult {
  final List<UnspentOutput> inputs;
  final int fee;
  final int change;

  CoinSelectionResult({
    required this.inputs,
    required this.fee,
    required this.change,
  });

  int get totalInputs => inputs.fold(0, (sum, u) => sum + u.valueSats.toInt());
  List<String> get outpoints => inputs.map((u) => u.output).toList();
}

/// Exception thrown when there aren't enough funds to complete a transaction
class InsufficientFundsException implements Exception {
  final int needed;
  final int available;
  final int frozenAmount;
  final String message;

  InsufficientFundsException({
    required this.needed,
    required this.available,
    required this.frozenAmount,
    required this.message,
  });

  @override
  String toString() => message;
}

/// Coin selection algorithm for building Bitcoin transactions
class CoinSelector {
  // P2WPKH input ~68 vbytes, output ~31 vbytes, overhead ~10 vbytes
  static const int inputVbytes = 68;
  static const int outputVbytes = 31;
  static const int overheadVbytes = 10;

  /// Main entry point for coin selection
  ///
  /// [allUtxos] - All available UTXOs from the wallet
  /// [frozenOutpoints] - Set of outpoints that should not be spent automatically
  /// [targetSats] - Amount to send (not including fees)
  /// [feeSatsPerVbyte] - Fee rate in satoshis per virtual byte
  /// [requiredUtxos] - UTXOs that must be included (user-selected)
  /// [numOutputs] - Number of outputs (usually 2: destination + change)
  /// [strategy] - Coin selection strategy to use
  /// [formatSats] - Function to format satoshi amounts for error messages
  ///
  /// Returns [CoinSelectionResult] with selected inputs, fee, and change amount
  /// Throws [InsufficientFundsException] if there aren't enough funds
  static CoinSelectionResult select({
    required List<UnspentOutput> allUtxos,
    required Set<String> frozenOutpoints,
    required int targetSats,
    required int feeSatsPerVbyte,
    required String Function(int) formatSats,
    List<UnspentOutput> requiredUtxos = const [],
    int numOutputs = 2,
    CoinSelectionStrategy strategy = CoinSelectionStrategy.largestFirst,
  }) {
    // 1. Filter out frozen UTXOs from available pool
    final requiredOutpoints = requiredUtxos.map((u) => u.output).toSet();
    final available = allUtxos
        .where((u) => !frozenOutpoints.contains(u.output))
        .where((u) => !requiredOutpoints.contains(u.output))
        .toList();

    // 2. Start with required UTXOs
    final selected = List<UnspentOutput>.from(requiredUtxos);
    int selectedAmount = selected.fold(0, (sum, u) => sum + u.valueSats.toInt());

    // 3. Calculate fee estimation function
    int estimateFee(int inputCount) {
      final vsize = overheadVbytes + (inputCount * inputVbytes) + (numOutputs * outputVbytes);
      return vsize * feeSatsPerVbyte;
    }

    // 4. Check if required UTXOs already cover target + fee
    int fee = estimateFee(selected.length);
    int needed = targetSats + fee;

    if (selectedAmount >= needed) {
      return CoinSelectionResult(
        inputs: selected,
        fee: fee,
        change: selectedAmount - targetSats - fee,
      );
    }

    // 5. Sort available UTXOs by strategy
    _sortByStrategy(available, strategy);

    // 6. Add UTXOs until we have enough
    for (final utxo in available) {
      selected.add(utxo);
      selectedAmount += utxo.valueSats.toInt();

      // Recalculate fee with new input count
      fee = estimateFee(selected.length);
      needed = targetSats + fee;

      if (selectedAmount >= needed) {
        return CoinSelectionResult(
          inputs: selected,
          fee: fee,
          change: selectedAmount - targetSats - fee,
        );
      }
    }

    // 7. Not enough funds
    final totalAvailable = selectedAmount;
    final totalFrozen = allUtxos
        .where((u) => frozenOutpoints.contains(u.output))
        .fold(0, (sum, u) => sum + u.valueSats.toInt());

    String message;
    if (totalFrozen > 0 && totalAvailable + totalFrozen >= needed) {
      message =
          'Insufficient funds. ${formatSats(totalFrozen)} are frozen. '
          'Unfreeze some UTXOs to complete this transaction.';
    } else {
      message =
          'Insufficient funds. Need ${formatSats(needed)}, '
          'have ${formatSats(totalAvailable)} available.';
    }

    throw InsufficientFundsException(
      needed: needed,
      available: totalAvailable,
      frozenAmount: totalFrozen,
      message: message,
    );
  }

  /// Estimate transaction fee for given parameters
  static int estimateFee({
    required int inputCount,
    required int feeSatsPerVbyte,
    int numOutputs = 2,
  }) {
    final vsize = overheadVbytes + (inputCount * inputVbytes) + (numOutputs * outputVbytes);
    return vsize * feeSatsPerVbyte;
  }

  /// Sort UTXOs by the given strategy
  static void _sortByStrategy(List<UnspentOutput> utxos, CoinSelectionStrategy strategy) {
    switch (strategy) {
      case CoinSelectionStrategy.largestFirst:
        utxos.sort((a, b) => b.valueSats.compareTo(a.valueSats));
        break;
      case CoinSelectionStrategy.smallestFirst:
        utxos.sort((a, b) => a.valueSats.compareTo(b.valueSats));
        break;
      case CoinSelectionStrategy.random:
        final random = Random();
        utxos.shuffle(random);
        break;
    }
  }
}

extension CoinSelectionStrategyExtension on CoinSelectionStrategy {
  String get displayName {
    switch (this) {
      case CoinSelectionStrategy.largestFirst:
        return 'Largest First';
      case CoinSelectionStrategy.smallestFirst:
        return 'Smallest First';
      case CoinSelectionStrategy.random:
        return 'Random';
    }
  }

  String get description {
    switch (this) {
      case CoinSelectionStrategy.largestFirst:
        return 'Minimizes number of inputs for lower fees now';
      case CoinSelectionStrategy.smallestFirst:
        return 'Cleans up small UTXOs over time';
      case CoinSelectionStrategy.random:
        return 'Better privacy, harder to fingerprint';
    }
  }
}
