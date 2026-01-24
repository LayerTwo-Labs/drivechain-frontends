import 'dart:math';

import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart' hide DetailRow;

class DenialDialog extends StatefulWidget {
  /// For single UTXO mode, pass the output string (txid:vout)
  final String? output;

  /// For single UTXO mode, the value in satoshis
  final int? valueSats;

  /// For batch mode, pass a list of UTXOs
  final List<UnspentOutput>? utxos;

  /// Fee per hop in satoshis (matches server/engines/deniability_engine.go)
  static const int feePerHopSats = 10000;

  const DenialDialog({
    super.key,
    this.output,
    this.valueSats,
    this.utxos,
  }) : assert(output != null || utxos != null, 'Either output or utxos must be provided');

  bool get isBatchMode => utxos != null && utxos!.isNotEmpty;

  @override
  State<DenialDialog> createState() => _DenialDialogState();
}

class _DenialDialogState extends State<DenialDialog> {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();
  final SettingsProvider settingsProvider = GetIt.I.get<SettingsProvider>();

  BitcoinUnit get currentUnit => settingsProvider.bitcoinUnit;

  final hopsController = TextEditingController(text: '3');
  final minutesController = TextEditingController(text: '2');
  final hoursController = TextEditingController(text: '0');
  final daysController = TextEditingController(text: '0');
  final List<TextEditingController> targetSizeControllers = [];

  bool isProcessing = false;
  int processedCount = 0;
  String? errorMessage;

  int get maxTargetSizes => 1 << (int.tryParse(hopsController.text) ?? 3); // 2^hops

  Future<void> setNormalDefaults() async {
    setState(() {
      hopsController.text = '3';
      minutesController.text = '2';
      hoursController.text = '0';
      daysController.text = '0';
    });
  }

  Future<void> setParanoidDefaults() async {
    setState(() {
      hopsController.text = '6';
      minutesController.text = '0';
      hoursController.text = '0';
      daysController.text = '2';
    });
  }

  int getTotalSeconds() {
    final minutes = int.tryParse(minutesController.text) ?? 0;
    final hours = int.tryParse(hoursController.text) ?? 0;
    final days = int.tryParse(daysController.text) ?? 0;

    return minutes * 60 + hours * 3600 + days * 86400;
  }

  /// Get target UTXO sizes distributed randomly across hops.
  /// Returns a sparse array where the value at each index is the target amount
  /// (0 means random split for that hop).
  /// This ensures target amounts are created at random points during the denial process.
  List<int>? getTargetUtxoSizes() {
    final hops = int.tryParse(hopsController.text) ?? 3;

    // Parse the user-entered target sizes
    final userSizes = targetSizeControllers
        .map((c) {
          final text = c.text.trim();
          if (text.isEmpty) return null;
          // Parse as the current unit and convert to sats
          return parseAmountToSatoshis(text, currentUnit);
        })
        .whereType<int>()
        .where((s) => s > 0)
        .toList();

    if (userSizes.isEmpty) return null;

    // Create a sparse array of size 'hops', initialized to 0 (meaning random split)
    final distributed = List<int>.filled(hops, 0);

    // Randomly assign each target size to a unique hop
    final availableHops = List<int>.generate(hops, (i) => i);
    availableHops.shuffle(Random());

    for (var i = 0; i < userSizes.length && i < availableHops.length; i++) {
      distributed[availableHops[i]] = userSizes[i];
    }

    return distributed;
  }

  void addTargetSize() {
    if (targetSizeControllers.length < maxTargetSizes) {
      setState(() {
        targetSizeControllers.add(TextEditingController());
      });
    }
  }

  void removeTargetSize(int index) {
    setState(() {
      targetSizeControllers[index].dispose();
      targetSizeControllers.removeAt(index);
    });
  }

  Future<void> startDenial() async {
    final hops = int.tryParse(hopsController.text) ?? 3;
    final delaySeconds = getTotalSeconds();
    final targetSizes = getTargetUtxoSizes();

    // Validate target sizes don't exceed available balance
    if (targetSizes != null && targetSizes.isNotEmpty) {
      final totalFees = hops * DenialDialog.feePerHopSats;
      final totalTargetSizes = targetSizes.fold(0, (sum, s) => sum + s);

      int? available;
      if (widget.isBatchMode) {
        // For batch: validate against smallest UTXO
        final minUtxo = widget.utxos!.map((u) => u.valueSats.toInt()).reduce(min);
        available = minUtxo - totalFees;
      } else if (widget.valueSats != null) {
        available = widget.valueSats! - totalFees;
      }

      if (available != null && totalTargetSizes > available) {
        setState(() {
          errorMessage = 'Target sizes sum exceeds available balance after fees';
        });
        return;
      }
    }

    setState(() {
      isProcessing = true;
      processedCount = 0;
      errorMessage = null;
    });

    if (widget.isBatchMode) {
      // Batch mode: process multiple UTXOs
      for (final utxo in widget.utxos!) {
        try {
          await api.bitwindowd.createDenial(
            txid: utxo.output.split(':').first,
            vout: int.parse(utxo.output.split(':').last),
            numHops: hops,
            delaySeconds: delaySeconds,
            targetUtxoSizes: targetSizes,
          );
          setState(() {
            processedCount++;
          });
        } catch (e) {
          setState(() {
            errorMessage = 'Failed on UTXO ${utxo.output}: $e';
          });
          break;
        }
      }
    } else {
      // Single mode
      try {
        await api.bitwindowd.createDenial(
          txid: widget.output!.split(':').first,
          vout: int.parse(widget.output!.split(':').last),
          numHops: hops,
          delaySeconds: delaySeconds,
          targetUtxoSizes: targetSizes,
        );
      } catch (e) {
        setState(() {
          errorMessage = 'Failed: $e';
        });
      }
    }

    await transactionProvider.fetch();

    if (mounted && errorMessage == null) {
      Navigator.pop(context);
    }

    setState(() {
      isProcessing = false;
    });
  }

  @override
  void dispose() {
    hopsController.dispose();
    minutesController.dispose();
    hoursController.dispose();
    daysController.dispose();
    for (final c in targetSizeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBatch = widget.isBatchMode;
    final utxoCount = isBatch ? widget.utxos!.length : 1;

    String buttonLabel;
    if (isProcessing) {
      buttonLabel = isBatch ? 'Processing ($processedCount/$utxoCount)...' : 'Starting...';
    } else {
      buttonLabel = isBatch ? 'Deny All' : 'Start';
    }

    return SailDialog(
      title: isBatch ? 'Deny All UTXOs' : 'Start Automatic Denial',
      maxWidth: 700,
      maxHeight: 850,
      actions: [
        SailButton(
          label: 'Cancel',
          onPressed: () async => Navigator.pop(context),
          variant: ButtonVariant.secondary,
          disabled: isProcessing,
        ),
        SailButton(
          label: buttonLabel,
          onPressed: startDenial,
          disabled: isProcessing,
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBatch) ...[
            SailText.primary15('Starting deniability on $utxoCount UTXOs'),
            const SailSpacing(SailStyleValues.padding08),
          ],

          // Delay input row
          SailText.primary15('Send coins to yourself...'),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary15('...with random delays of up to'),
              Expanded(
                child: SailTextField(
                  controller: minutesController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
                  enabled: !isProcessing,
                ),
              ),
              SailText.primary15('min'),
              Expanded(
                child: SailTextField(
                  controller: hoursController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
                  enabled: !isProcessing,
                ),
              ),
              SailText.primary15('hr'),
              Expanded(
                child: SailTextField(
                  controller: daysController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
                  enabled: !isProcessing,
                ),
              ),
              SailText.primary15('day(s)...'),
            ],
          ),

          // Hops input row
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary15('...and stop after'),
              SizedBox(
                width: 90,
                child: SailTextField(
                  controller: hopsController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '3 hops',
                  enabled: !isProcessing,
                ),
              ),
              SailText.primary15('hops.'),
            ],
          ),

          // Target UTXO sizes (optional)
          SailText.secondary13('With at least one UTXO of size:'),
          for (int i = 0; i < targetSizeControllers.length; i++)
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SizedBox(
                  width: 150,
                  child: SailTextField(
                    controller: targetSizeControllers[i],
                    size: TextFieldSize.small,
                    textFieldType: currentUnit == BitcoinUnit.btc ? TextFieldType.bitcoin : TextFieldType.number,
                    hintText: currentUnit.symbol,
                    enabled: !isProcessing,
                  ),
                ),
                if (i == targetSizeControllers.length - 1 && targetSizeControllers.length < maxTargetSizes)
                  SailButton(
                    label: '+',
                    onPressed: () async => addTargetSize(),
                    variant: ButtonVariant.ghost,
                    disabled: isProcessing,
                  ),
              ],
            ),
          if (targetSizeControllers.isEmpty)
            SailButton(
              label: '+ Add target size',
              onPressed: () async => addTargetSize(),
              variant: ButtonVariant.ghost,
              disabled: isProcessing,
            ),

          // Default buttons
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary15('Defaults:'),
              SailButton(
                label: 'Normal',
                onPressed: setNormalDefaults,
                variant: ButtonVariant.secondary,
                disabled: isProcessing,
              ),
              SailButton(
                label: 'Paranoid',
                onPressed: setParanoidDefaults,
                variant: ButtonVariant.secondary,
                disabled: isProcessing,
              ),
            ],
          ),

          if (errorMessage != null) ...[
            const SailSpacing(SailStyleValues.padding08),
            SailText.primary13(
              errorMessage!,
              color: SailTheme.of(context).colors.error,
            ),
          ],
        ],
      ),
    );
  }
}

class ConsolidateDialog extends StatefulWidget {
  final List<UnspentOutput> utxos;

  const ConsolidateDialog({
    super.key,
    required this.utxos,
  });

  @override
  State<ConsolidateDialog> createState() => _ConsolidateDialogState();
}

class _ConsolidateDialogState extends State<ConsolidateDialog> {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();
  final WalletReaderProvider walletReader = GetIt.I.get<WalletReaderProvider>();

  bool isProcessing = false;
  String? errorMessage;
  String? txid;

  // Fixed fee of 10k sats (same as deniability engine)
  static const int fixedFeeSats = 10000;

  int get totalSats => widget.utxos.fold(0, (sum, u) => sum + u.valueSats.toInt());
  int get sendAmount => totalSats - fixedFeeSats;

  Future<void> consolidate() async {
    if (sendAmount <= 0) {
      setState(() {
        errorMessage = 'Total amount is less than the fee';
      });
      return;
    }

    setState(() {
      isProcessing = true;
      errorMessage = null;
    });

    try {
      final walletId = walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      // Get a new address to consolidate to
      final address = await api.wallet.getNewAddress(walletId);

      // Send all to the new address, using fixed fee and requiring our UTXOs
      final resultTxid = await api.wallet.sendTransaction(
        walletId,
        {address: sendAmount},
        fixedFeeSats: fixedFeeSats,
        requiredInputs: widget.utxos,
      );

      setState(() {
        txid = resultTxid;
      });

      await transactionProvider.fetch();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SailDialog(
      title: 'Consolidate UTXOs',
      maxWidth: 500,
      maxHeight: 400,
      actions: [
        SailButton(
          label: 'Cancel',
          onPressed: () async => Navigator.pop(context),
          variant: ButtonVariant.secondary,
          disabled: isProcessing,
        ),
        SailButton(
          label: isProcessing ? 'Consolidating...' : 'Consolidate',
          onPressed: consolidate,
          disabled: isProcessing,
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Merge ${widget.utxos.length} UTXOs into a single UTXO'),
          const SailSpacing(SailStyleValues.padding08),

          DetailRow(
            label: 'UTXOs to merge',
            value: '${widget.utxos.length}',
          ),
          DetailRow(
            label: 'Total Amount',
            value: formatter.formatSats(totalSats),
          ),
          DetailRow(
            label: 'Fee',
            value: formatter.formatSats(fixedFeeSats),
          ),
          DetailRow(
            label: 'You will receive',
            value: formatter.formatSats(sendAmount > 0 ? sendAmount : 0),
          ),

          const SailSpacing(SailStyleValues.padding08),
          SailText.secondary13(
            'This will create a transaction sending all your coins to a new address in your wallet.',
          ),

          if (errorMessage != null) ...[
            const SailSpacing(SailStyleValues.padding08),
            SailText.primary13(
              errorMessage!,
              color: SailTheme.of(context).colors.error,
            ),
          ],
        ],
      ),
    );
  }
}
