import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';

class DenialDialog extends StatefulWidget {
  final String output;

  const DenialDialog({
    super.key,
    required this.output,
  });

  @override
  State<DenialDialog> createState() => _DenialDialogState();
}

class _DenialDialogState extends State<DenialDialog> {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();

  final hopsController = TextEditingController(text: '3');
  final minutesController = TextEditingController(text: '2');
  final hoursController = TextEditingController(text: '0');
  final daysController = TextEditingController(text: '0');

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

  @override
  void dispose() {
    hopsController.dispose();
    minutesController.dispose();
    hoursController.dispose();
    daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailDialog(
      title: 'Start Automatic Denial',
      maxWidth: 700,
      maxHeight: 600,
      actions: [
        SailButton(
          label: 'Cancel',
          onPressed: () async => Navigator.pop(context),
          variant: ButtonVariant.secondary,
        ),
        SailButton(
          label: 'Start',
          onPressed: () async {
            final hops = int.tryParse(hopsController.text) ?? 3;
            await api.bitwindowd.createDenial(
              txid: widget.output.split(':').first,
              vout: int.parse(widget.output.split(':').last),
              numHops: hops,
              delaySeconds: getTotalSeconds(),
            );
            await transactionProvider.fetch();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                ),
              ),
              SailText.primary15('min'),
              Expanded(
                child: SailTextField(
                  controller: hoursController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
                ),
              ),
              SailText.primary15('hr'),
              Expanded(
                child: SailTextField(
                  controller: daysController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
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
                ),
              ),
              SailText.primary15('hops.'),
            ],
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
              ),
              SailButton(
                label: 'Paranoid',
                onPressed: setParanoidDefaults,
                variant: ButtonVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DenyAllDialog extends StatefulWidget {
  final List<UnspentOutput> utxos;

  const DenyAllDialog({
    super.key,
    required this.utxos,
  });

  @override
  State<DenyAllDialog> createState() => _DenyAllDialogState();
}

class _DenyAllDialogState extends State<DenyAllDialog> {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();

  final hopsController = TextEditingController(text: '3');
  final minutesController = TextEditingController(text: '2');
  final hoursController = TextEditingController(text: '0');
  final daysController = TextEditingController(text: '0');

  bool isProcessing = false;
  int processedCount = 0;
  String? errorMessage;

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

  Future<void> denyAll() async {
    setState(() {
      isProcessing = true;
      processedCount = 0;
      errorMessage = null;
    });

    final hops = int.tryParse(hopsController.text) ?? 3;
    final delaySeconds = getTotalSeconds();

    for (final utxo in widget.utxos) {
      try {
        await api.bitwindowd.createDenial(
          txid: utxo.output.split(':').first,
          vout: int.parse(utxo.output.split(':').last),
          numHops: hops,
          delaySeconds: delaySeconds,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailDialog(
      title: 'Deny All UTXOs',
      maxWidth: 700,
      maxHeight: 600,
      actions: [
        SailButton(
          label: 'Cancel',
          onPressed: () async => Navigator.pop(context),
          variant: ButtonVariant.secondary,
          disabled: isProcessing,
        ),
        SailButton(
          label: isProcessing ? 'Processing ($processedCount/${widget.utxos.length})...' : 'Deny All',
          onPressed: denyAll,
          disabled: isProcessing,
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Starting deniability on ${widget.utxos.length} UTXOs'),
          const SailSpacing(SailStyleValues.padding08),

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
