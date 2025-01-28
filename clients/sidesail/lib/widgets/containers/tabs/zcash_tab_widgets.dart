import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

class ShieldUTXOAction extends StatelessWidget {
  final UnshieldedUTXO utxo;

  const ShieldUTXOAction({super.key, required this.utxo});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ShieldUTXOActionViewModel(utxo),
      builder: ((context, model, child) {
        return DashboardActionModal(
          'Shield coins',
          endActionButton: SailButton.primary(
            'Execute shield',
            disabled: model.bitcoinAmountController.text.isEmpty,
            loading: model.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              model.executeShield(context, utxo);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: model.bitcoinAmountController,
              hintText: 'How much do you want to shield?',
              suffixText: model.ticker,
              disabled: utxo.generated,
              bitcoinInput: true,
              autofocus: true,
            ),
            StaticActionField(
              label: 'Shield from',
              value: utxo.address,
            ),
            const StaticActionField(
              label: 'Shield to',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Shield fee',
              value: formatBitcoin(model.shieldFee, symbol: model.ticker),
            ),
            StaticActionField(
              label: 'Total amount',
              value: model.totalBitcoinAmount,
            ),
            if (utxo.generated)
              const StaticActionInfo(
                text: 'This is a coinbase output, and you must shield 100% of the amount',
              ),
          ],
        );
      }),
    );
  }
}

class ShieldUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount => formatBitcoin(
        ((double.tryParse(bitcoinAmountController.text) ?? 0) + (shieldFee)),
        symbol: ticker,
      );

  double get shieldFee => _zcashProvider.sideFee;
  String get ticker => _sidechainContainer.rpc.chain.ticker;
  double? get amount => double.tryParse(bitcoinAmountController.text);
  late double maxAmount;

  ShieldUTXOActionViewModel(UnshieldedUTXO utxo) {
    maxAmount = max(0, utxo.amount - shieldFee);
    bitcoinAmountController.addListener(_withMaxAmount);

    if (utxo.generated) {
      bitcoinAmountController.text = utxo.amount.toString();
    }
  }

  void _withMaxAmount() {
    String currentInput = bitcoinAmountController.text;

    if (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount) {
      bitcoinAmountController.text = maxAmount.toString();
      bitcoinAmountController.selection =
          TextSelection.fromPosition(TextPosition(offset: bitcoinAmountController.text.length));
    } else {
      notifyListeners();
    }
  }

  void shield(BuildContext context, UnshieldedUTXO utxo) async {
    setBusy(true);
    executeShield(context, utxo);
    setBusy(false);
  }

  void executeShield(BuildContext context, UnshieldedUTXO utxo) async {
    if (amount == null) {
      log.e('shield amount was empty');
      return;
    }

    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    log.i(
      'shielding utxo: $amount $ticker to ${utxo.address} with $shieldFee shield fee',
    );

    try {
      final shieldID = await _rpc.shield(
        utxo,
        amount!,
      );
      log.i('deshield operation ID: $shieldID');

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_zcashProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Initiated shield',
        title: 'Initiated shield of $amount $ticker to your Z-address',
        subtitle: 'OPID: $shieldID',
      );
      // also pop the info modal
      await _router.maybePop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Shield coins',
        title: 'Could not shield coins',
        subtitle: error.toString(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    bitcoinAmountController.removeListener(_withMaxAmount);
  }
}

class DeshieldUTXOAction extends StatelessWidget {
  final ShieldedUTXO utxo;

  const DeshieldUTXOAction({super.key, required this.utxo});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DeshieldUTXOActionViewModel(utxo),
      builder: ((context, model, child) {
        return DashboardActionModal(
          'Deshield coins',
          endActionButton: SailButton.primary(
            'Execute deshield',
            disabled: model.bitcoinAmountController.text.isEmpty,
            loading: model.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              model.executeDeshield(context, utxo);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: model.bitcoinAmountController,
              hintText: 'How much do you want to deshield?',
              suffixText: model.ticker,
              bitcoinInput: true,
              autofocus: true,
            ),
            const StaticActionField(
              label: 'Deshield from',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Deshield to',
              value: model.deshieldAddress,
            ),
            StaticActionField(
              label: 'Deshield fee',
              value: formatBitcoin(model.deshieldFee, symbol: model.ticker),
            ),
            StaticActionField(
              label: 'Total amount',
              value: model.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class DeshieldUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      formatBitcoin(((double.tryParse(bitcoinAmountController.text) ?? 0) + (deshieldFee)), symbol: ticker);

  double get deshieldFee => _zcashProvider.sideFee;
  String get ticker => _sidechainContainer.rpc.chain.ticker;
  double? get amount => double.tryParse(bitcoinAmountController.text);

  String deshieldAddress = '';
  late double maxAmount;

  DeshieldUTXOActionViewModel(ShieldedUTXO utxo) {
    maxAmount = max(0, utxo.amount - deshieldFee);
    bitcoinAmountController.addListener(_withMaxAmount);

    init();
  }

  void _withMaxAmount() {
    String currentInput = bitcoinAmountController.text;

    if (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount) {
      bitcoinAmountController.text = maxAmount.toString();
      bitcoinAmountController.selection =
          TextSelection.fromPosition(TextPosition(offset: bitcoinAmountController.text.length));
    } else {
      notifyListeners();
    }
  }

  void init() async {
    deshieldAddress = await _rpc.getSideAddress();
    notifyListeners();
  }

  void deshield(BuildContext context, ShieldedUTXO utxo) async {
    setBusy(true);
    executeDeshield(context, utxo);
    setBusy(false);
  }

  void executeDeshield(BuildContext context, ShieldedUTXO utxo) async {
    if (amount == null) {
      log.e('deshield amount was empty');
      return;
    }

    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    log.i(
      'deshielding utxo: $amount $ticker to ${utxo.address} with $deshieldFee deshield fee',
    );

    try {
      final (deshieldID, address) = await _rpc.deshield(
        utxo,
        amount!,
      );
      log.i('deshield operation ID: $deshieldID');

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_zcashProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Initiated deshield',
        title: 'Initiated deshield of $amount $ticker to $address',
        subtitle: 'OPID: $deshieldID',
      );
      // also pop the info modal
      await _router.maybePop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Deshield coins',
        title: 'Could not deshield coins',
        subtitle: error.toString(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    bitcoinAmountController.removeListener(_withMaxAmount);
  }
}

class CastSingleUTXOAction extends StatelessWidget {
  final ShieldedUTXO utxo;

  const CastSingleUTXOAction({super.key, required this.utxo});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => CastSingleUTXOActionViewModel(utxo: utxo),
      builder: ((context, model, child) {
        return DashboardActionModal(
          'Cast single UTXO',
          endActionButton: SailButton.primary(
            'Execute cast',
            loading: model.isBusy,
            disabled: model.includedInBills == null,
            size: ButtonSize.regular,
            onPressed: () async {
              model.executeCast(context, utxo);
            },
          ),
          children: [
            const StaticActionField(
              label: 'Deshield from',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Deshield to',
              value: model.castAddresses.join('\n'),
            ),
            StaticActionField(
              label: 'Cast fee',
              value: '${model.castFee}',
            ),
            StaticActionField(
              label: 'Castable amount',
              value: formatBitcoin(model.castableAmount, symbol: model.ticker),
            ),
            StaticActionField(
              label: 'Total amount',
              value: formatBitcoin(model.totalBitcoinAmount, symbol: model.ticker),
            ),
          ],
        );
      }),
    );
  }
}

class CastSingleUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  List<PendingDeshield>? get includedInBills => _castProvider.findBillsForAmount(utxo);
  double get castableAmount => includedInBills!.fold(0, (sum, bill) => sum + bill.amount);
  double get totalBitcoinAmount => castableAmount + castFee;
  double get castFee => _zcashProvider.sideFee * _rpc.numUTXOsPerCast;
  String get ticker => _sidechainContainer.rpc.chain.ticker;

  List<String> castAddresses = [];

  ShieldedUTXO utxo;

  CastSingleUTXOActionViewModel({required this.utxo}) {
    init();
  }

  void init() async {
    castAddresses.add(await _rpc.getSideAddress());
    castAddresses.add(await _rpc.getSideAddress());
    castAddresses.add(await _rpc.getSideAddress());
    castAddresses.add(await _rpc.getSideAddress());

    notifyListeners();
  }

  void cast(BuildContext context, ShieldedUTXO utxo) async {
    setBusy(true);
    executeCast(context, utxo);
    setBusy(false);
  }

  void executeCast(BuildContext context, ShieldedUTXO utxo) async {
    if (includedInBills == null) {
      log.e('was not eligible for a bundle');
      await errorDialog(
        context: context,
        action: 'Cast single UTXO',
        title: 'This UTXO is not eligible for being included in a bundle, amount is probably too low.',
        subtitle: error.toString(),
      );
      return;
    }

    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    log.i(
      'casting utxo: $castableAmount $ticker to $castAddresses with $castFee deshield fee',
    );

    try {
      _castProvider.addPendingUTXO(
        includedInBills!,
        utxo: utxo,
      );

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_zcashProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Cast single UTXO',
        title: 'Initiated cast of $totalBitcoinAmount $ticker to $castAddresses',
        subtitle:
            'Will cast to ${includedInBills!.length} new unique UTXOs.\n\nDont close the application until you have no private coins left in your wallet.',
      );
      // also pop the info modal
      await _router.maybePop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Cast single UTXO',
        title: 'Could not cast coins for UTXO',
        subtitle: error.toString(),
      );
    }
  }
}

class MeltAction extends StatelessWidget {
  final bool doEverythingMode;

  const MeltAction({
    super.key,
    required this.doEverythingMode,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => MeltActionViewModel(),
      builder: ((context, model, child) {
        return DashboardActionModal(
          doEverythingMode ? 'Do everything for me' : 'Melt UTXOs',
          endActionButton: SailButton.primary(
            doEverythingMode ? 'Execute melt, then cast' : 'Execute melt',
            loading: model.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              model.melt(
                context,
                castAfterCompletion: doEverythingMode,
              );
            },
          ),
          children: [
            if (doEverythingMode)
              const SailPadding(
                child: QuestionText(
                  '"Do everything for me" will first melt all your coins, then cast them. The entire process can take up to 7 days.',
                ),
              ),
            const StaticActionField(
              label: 'Melt to',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Melt from',
              value:
                  // extract address, then join on a newline
                  model.meltableUTXOs.map((utxo) => utxo.address).join('\n'),
            ),
            StaticActionField(
              label: 'Melt fee',
              value: formatBitcoin(model.meltFee, symbol: model._rpc.chain.ticker),
            ),
            StaticActionField(
              label: 'Melt amount',
              value: formatBitcoin(model.meltAmount, symbol: model._rpc.chain.ticker),
            ),
            StaticActionField(
              label: 'Total amount',
              value: formatBitcoin(model.totalBitcoinAmount, symbol: model._rpc.chain.ticker),
            ),
          ],
        );
      }),
    );
  }
}

class MeltActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();

  final bitcoinAmountController = TextEditingController();

  double get shieldFee => _zcashProvider.sideFee;
  String get ticker => _sidechainContainer.rpc.chain.ticker;
  double get totalBitcoinAmount => (meltAmount + meltFee);
  List<UnshieldedUTXO> get meltableUTXOs =>
      _zcashProvider.unshieldedUTXOs.where((utxo) => utxo.amount > zcashFee).toList();
  double get meltAmount =>
      _zcashProvider.unshieldedUTXOs.map((entry) => entry.amount).fold(0.0, (value, element) => value + element) -
      meltFee;
  double get meltFee => (_zcashProvider.sideFee * meltableUTXOs.length);

  MeltActionViewModel() {
    bitcoinAmountController.addListener(notifyListeners);
  }

  void melt(BuildContext context, {bool castAfterCompletion = false}) async {
    setBusy(true);
    _initiateMelt(context, castAfterCompletion: castAfterCompletion);
    setBusy(false);
  }

  void _initiateMelt(BuildContext context, {bool castAfterCompletion = false}) async {
    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    log.i(
      'melting ${meltableUTXOs.length} utxos: $meltAmount $ticker to with $shieldFee shield fee',
    );

    try {
      final willMeltAt = await _zcashProvider.melt(
        meltableUTXOs,
        0.10,
      );

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_zcashProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Initiated melt',
        title:
            'You will shield ${meltableUTXOs.length} coins for a total of ${formatBitcoin(totalBitcoinAmount, symbol: ticker)} to your Z-address',
        subtitle: 'Will complete melt in ${willMeltAt.map((e) => e).join(', ')} seconds.',
      );
      // also pop the info modal
      await _router.maybePop();
      if (castAfterCompletion) {
        _castProvider.castWhenMeltCompleted(meltAmount);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Melt coins',
        title: 'Could not melt coins',
        subtitle: error.toString(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    bitcoinAmountController.removeListener(notifyListeners);
  }
}

class MeltSingleUTXOAction extends StatelessWidget {
  final UnshieldedUTXO utxo;

  const MeltSingleUTXOAction({
    super.key,
    required this.utxo,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => MeltSingleUTXOActionViewModel(utxo: utxo),
      builder: ((context, model, child) {
        return DashboardActionModal(
          'Melt single UTXO',
          endActionButton: SailButton.primary(
            'Execute melt',
            loading: model.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              model.melt(context, utxo);
            },
          ),
          children: [
            StaticActionField(
              label: 'Shield from',
              value: utxo.address,
            ),
            const StaticActionField(
              label: 'Shield to',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Cast amount',
              value: formatBitcoin(model.castAmount, symbol: model.ticker),
            ),
            StaticActionField(
              label: 'Cast fee',
              value: '${model.shieldFee}',
            ),
            StaticActionField(
              label: 'Total amount',
              value: model.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class MeltSingleUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  final UnshieldedUTXO utxo;

  String get totalBitcoinAmount => formatBitcoin(((castAmount + (shieldFee))), symbol: ticker);
  String get ticker => _sidechainContainer.rpc.chain.ticker;
  double get shieldFee => _zcashProvider.sideFee;
  double get castAmount => utxo.amount - shieldFee;

  MeltSingleUTXOActionViewModel({required this.utxo});

  void melt(BuildContext context, UnshieldedUTXO utxo) async {
    if (!context.mounted) {
      return;
    }

    log.i(
      'melting utxo: $castAmount $ticker to ${utxo.address} with $shieldFee shield fee',
    );

    try {
      setBusy(true);

      final shieldID = await _rpc.shield(
        utxo,
        castAmount,
      );
      log.i('melt operation ID: $shieldID');

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_zcashProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Initiated melt',
        title: 'Initiated melt of $castAmount $ticker to your Z-address',
        subtitle: 'OPID: $shieldID',
      );
      // also pop the info modal
      await _router.maybePop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Cast coins',
        title: 'Could not cast coins',
        subtitle: error.toString(),
      );
    } finally {
      setBusy(false);
    }
  }
}

class CastAction extends StatelessWidget {
  const CastAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => CastActionViewModel(),
      builder: ((context, model, child) {
        return DashboardActionModal(
          'Cast UTXOs',
          endActionButton: SailButton.primary(
            'Execute cast',
            loading: model.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              model.cast(context);
            },
          ),
          children: [
            const StaticActionField(
              label: 'Deshield to',
              value: 'Various transparent addresses',
            ),
            StaticActionField(
              label: 'Deshield from (txid)',
              value:
                  // extract address, then join on a newline
                  model.castableUTXOs.map((utxo) => utxo.txid).join('\n'),
            ),
            StaticActionField(
              label: 'Cast fee',
              value: formatBitcoin(model.castAllFee, symbol: model._rpc.chain.ticker),
            ),
            StaticActionField(
              label: 'Cast amount',
              value: formatBitcoin(model.castAmount, symbol: model._rpc.chain.ticker),
            ),
            StaticActionField(
              label: 'Total amount',
              value: formatBitcoin(model.totalBitcoinAmount, symbol: model._rpc.chain.ticker),
            ),
          ],
        );
      }),
    );
  }
}

class CastActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();

  String get ticker => _sidechainContainer.rpc.chain.ticker;
  double get shieldFee => _zcashProvider.sideFee;
  List<PendingDeshield> get includedInBundle {
    final List<PendingDeshield> bundles = [];

    for (final utxo in _zcashProvider.shieldedUTXOs) {
      final utxoBundle = _castProvider.findBillsForAmount(utxo);
      if (utxoBundle != null) {
        bundles.addAll(utxoBundle);
      }
    }

    return bundles;
  }

  // cant cast utxo with less than cast fee
  List<ShieldedUTXO> get castableUTXOs =>
      _zcashProvider.shieldedUTXOs.where((element) => element.amount > castFee).toList();
  num get castFee => _rpc.numUTXOsPerCast * shieldFee;
  num get castAllFee => castFee * castableUTXOs.length;
  num get castAmount => includedInBundle.map((e) => e.amount).fold(0.0, (sum, fee) => sum + fee);
  double get totalBitcoinAmount => (castAmount + castFee).toDouble();

  CastActionViewModel();

  void cast(BuildContext context) async {
    setBusy(true);
    _initiateCast(context);
    setBusy(false);
  }

  void _initiateCast(BuildContext context) async {
    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    log.i(
      'casting ${_zcashProvider.shieldedUTXOs.length} utxos: $castAmount $ticker to with $castFee cast fee',
    );

    try {
      List<PendingDeshield>? bundles = [];

      for (final utxo in _zcashProvider.shieldedUTXOs) {
        final utxoBundle = _castProvider.findBillsForAmount(utxo);
        if (utxoBundle == null) {
          continue;
        }
        bundles.addAll(utxoBundle.toList());

        log.i(
          'casting utxo to bills of power ${utxoBundle.map((e) => e.amount).join(' $ticker, ')}',
        );

        _castProvider.addPendingUTXO(
          utxoBundle,
          utxo: utxo,
        );
      }

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_zcashProvider.fetch());

      if (!context.mounted) {
        return;
      }

      await successDialog(
        context: context,
        action: 'Cast UTXOs',
        title:
            'You will cast ${_zcashProvider.shieldedUTXOs.length} coins for a total of ${formatBitcoin(totalBitcoinAmount, symbol: ticker)} to your Z-address',
        subtitle:
            'Will cast to ${bundles.length} new unique UTXOs.\n\nDont close the application until you have no shielded coins left in your wallet.',
      );
      // also pop the info modal
      await _router.maybePop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Cast coins',
        title: 'Could not cast coins',
        subtitle: error.toString(),
      );
    }
  }
}

class OperationView extends StatelessWidget {
  final OperationStatus tx;

  const OperationView({
    super.key,
    required this.tx,
  });

  Map<String, dynamic> get decodedTX => jsonDecode(tx.raw);

  @override
  Widget build(BuildContext context) {
    return ExpandableListEntry(
      entry: SingleValueContainer(
        width: 115,
        icon: tx.status == 'success'
            ? Tooltip(
                message: 'Success',
                child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
              )
            : Tooltip(
                message: 'Failed',
                child: SailSVG.icon(SailSVGAsset.iconFailed, width: 13),
              ),
        copyable: false,
        label: tx.method,
        value: tx.id,
        trailingText: DateFormat('dd MMM HH:mm:ss').format(tx.creationTime),
      ),
      expandedEntry: ExpandedTXView(
        decodedTX: decodedTX,
        width: 115,
      ),
    );
  }
}

class UnshieldedUTXOView extends StatelessWidget {
  final UnshieldedUTXO utxo;
  final VoidCallback? shieldAction;
  final bool meltMode;

  const UnshieldedUTXOView({
    super.key,
    required this.utxo,
    required this.shieldAction,
    required this.meltMode,
  });

  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();

  Map<String, dynamic> get decodedUTXO => jsonDecode(utxo.raw);
  Color? get utxoColor => getCastColor(utxo.amount);

  @override
  Widget build(BuildContext context) {
    return ExpandableListEntry(
      entry: SingleValueContainer(
        prefixAction: shieldAction == null
            ? null
            : SailButton.secondary(
                meltMode ? 'Melt' : 'Shield',
                onPressed: shieldAction!,
                size: ButtonSize.small,
                disabled: utxo.amount <= zcashFee,
              ),
        icon: utxo.confirmations >= 1
            ? Tooltip(
                message: '${utxo.confirmations} confirmations',
                child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
              )
            : Tooltip(
                message: 'Unconfirmed',
                child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
              ),
        color: utxoColor,
        copyable: false,
        label: formatBitcoin(utxo.amount, symbol: _sidechainContainer.rpc.chain.ticker),
        labelTooltip: isCastAmount(utxo.amount) ? 'Casted, safe UTXO' : 'Not casted, unsafe UTXO',
        value: utxo.address,
      ),
      expandedEntry: ExpandedTXView(
        decodedTX: decodedUTXO,
        width: 115,
      ),
    );
  }
}

class ShieldedUTXOView extends StatelessWidget {
  final ShieldedUTXO utxo;
  final VoidCallback? deshieldAction;
  final bool castMode;

  const ShieldedUTXOView({
    super.key,
    required this.utxo,
    required this.deshieldAction,
    required this.castMode,
  });

  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();

  Map<String, dynamic> get decodedUTXO => jsonDecode(utxo.raw);
  Color? get utxoColor => getCastColor(utxo.amount);

  @override
  Widget build(BuildContext context) {
    return ExpandableListEntry(
      entry: SingleValueContainer(
        prefixAction: deshieldAction == null
            ? null
            : SailButton.secondary(
                castMode ? 'Cast' : 'Deshield',
                onPressed: deshieldAction!,
                size: ButtonSize.small,
                disabled: utxo.amount <= zcashFee,
              ),
        icon: utxo.confirmations >= 1
            ? Tooltip(
                message: '${utxo.confirmations} confirmations',
                child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
              )
            : Tooltip(
                message: 'Unconfirmed',
                child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
              ),
        color: utxoColor,
        copyable: false,
        label: formatBitcoin(utxo.amount, symbol: _sidechainContainer.rpc.chain.ticker),
        labelTooltip: isCastAmount(utxo.amount) ? 'Melted, safe UTXO' : 'Not melted, unsafe amount',
        value: utxo.txid,
        trailingText: '',
      ),
      expandedEntry: ExpandedTXView(
        decodedTX: decodedUTXO,
        width: 115,
      ),
    );
  }
}

class PendingCastView extends StatefulWidget {
  final PendingCastBill pending;
  final Binary chain;

  const PendingCastView({
    super.key,
    required this.pending,
    required this.chain,
  });

  @override
  State<PendingCastView> createState() => _PendingCastViewState();
}

class _PendingCastViewState extends State<PendingCastView> {
  int executeInSeconds = 0;
  late Map<String, dynamic> expandInfo;

  // for counting down until execution
  Timer? _timer;
  Duration _timeLeft = const Duration();

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _timeLeft = widget.pending.executeTime.difference(DateTime.now());
        if (_timeLeft.isNegative) {
          _timeLeft = const Duration(seconds: 0);
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    expandInfo = convertPendingShieldsToMap(widget.pending.pendingShields);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    String countdownText = _timeLeft.isNegative ? 'Executing...' : 'Executing in ${_timeLeft.inSeconds} seconds';

    return ExpandableListEntry(
      entry: SingleValueContainer(
        icon: Tooltip(
          message: 'Waiting for timer to expire',
          child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
        ),
        copyable: false,
        label: formatBitcoin(widget.pending.castAmount, symbol: widget.chain.ticker),
        value:
            widget.pending.pendingShields.isNotEmpty ? 'Will deshield ${widget.pending.pendingShields.length} txs' : '',
        trailingText: countdownText,
      ),
      expandedEntry: ExpandedTXView(
        decodedTX: expandInfo,
        width: 105,
      ),
    );
  }

  Map<String, dynamic> convertPendingShieldsToMap(List<PendingDeshield> pendingShields) {
    Map<String, dynamic> resultMap = {};

    for (int i = 0; i < pendingShields.length; i++) {
      resultMap[i.toString()] = pendingShields[i].fromUTXO.txid;
    }

    return resultMap;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class PendingMeltView extends StatefulWidget {
  final PendingShield tx;

  const PendingMeltView({
    super.key,
    required this.tx,
  });

  @override
  State<PendingMeltView> createState() => _PendingMeltViewState();
}

class _PendingMeltViewState extends State<PendingMeltView> {
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();

  int executeInSeconds = 0;
  late Map<String, dynamic> decodedTX;

  // for counting down until execution
  Timer? _timer;
  Duration _timeLeft = const Duration();

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _timeLeft = widget.tx.executeTime.difference(DateTime.now());
        if (_timeLeft.isNegative) {
          _timeLeft = const Duration(seconds: 0);
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    decodedTX = jsonDecode(widget.tx.utxo.raw);
  }

  @override
  Widget build(BuildContext context) {
    String countdownText = _timeLeft.inSeconds <= 0 ? 'Executing...' : 'Executing in ${_timeLeft.inSeconds} seconds';

    return ExpandableListEntry(
      entry: SingleValueContainer(
        width: 105,
        icon: Tooltip(
          message: 'Waiting for timer to expire',
          child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
        ),
        copyable: false,
        label: formatBitcoin(widget.tx.utxo.amount, symbol: _sidechainContainer.rpc.chain.ticker),
        value:
            'Will melt ${widget.tx.utxo.amount} ${_sidechainContainer.rpc.chain.ticker} from ${widget.tx.utxo.address}',
        trailingText: countdownText,
      ),
      expandedEntry: ExpandedTXView(
        decodedTX: decodedTX,
        width: 105,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class CastHelp extends StatelessWidget {
  const CastHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuestionContainer(
      category: 'Cast help',
      children: [
        QuestionTitle('What is casting?'),
        QuestionText('Casting gives you ultra-secure ultra-user-friendly “click button”-level coin anonymization.'),
        QuestionText(
          'Casting lets you deshield your coins in predefined amounts, at predefined times. The amounts are the same as everyone else that uses zSide, making it impossible to match your inputs&outputs when moving coins from shielded to non-shielded.',
        ),
        QuestionText(
          'The amounts are powers of two, starting at 1, e.g: 0.00000001 BTC, 0.00000002 BTC, 0.00000004 BTC, 0.00000008 BTC etc.',
        ),
        QuestionText(
          'For example, 0.75 BTC will be withdrawn in 4 UTXOs. 1x0.67108864 BTC, 1x0.04194304 BTC, 1x0.02097152 BTC and 1x0.01048576 BTC. That sums to 0.74448896 BTC, which is 99.26% of 0.75 BTC.',
        ),
        QuestionText(
          'The residual 0.00551104 BTC will stay un-withdrawn, in your z-address on the sidechain, to be withdrawn later.',
        ),
        QuestionText('Read more here: https://www.truthcoin.info/blog/zside-meltcast/'),
      ],
    );
  }
}

class MeltHelp extends StatelessWidget {
  const MeltHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuestionContainer(
      category: 'Melt help',
      children: [
        QuestionTitle('What is melting?'),
        QuestionText(
          'Melting shields your transparent UTXOs, but does it in a way to preserve your privacy.',
        ),
        QuestionText(
          'It does this by making sure there is no change when you shield coins to your z-address.',
        ),
        QuestionText(
          'Just like cast, melting gives you ultra-secure ultra-user-friendly “click button”-level coin anonymization.',
        ),
        QuestionText(
          'You can melt per-UTXO, or all UTXOs at once. Both strategies makes sure to spend the full amount of the UTXO, leaving you with no change, or dust.',
        ),
        QuestionText(
          "Together with cast, it's a great way to anonymize your coins.",
        ),
        QuestionText(
          'When melting all your coins, you set the max time that you want the melt to take. The application automatically selects a timeout per UTXO, and makes sure to shield at that specific time. This furthers your privacy by not pegging you to a specific timezone.',
        ),
        QuestionText(
          'Because this version uses test money, the melting frequency is much faster than in a real-world scenario. Here, it takes minutes, while with real money it would take days.',
        ),
        QuestionText('Read more here: https://www.truthcoin.info/blog/zside-meltcast/'),
      ],
    );
  }
}

class OperationHelp extends StatelessWidget {
  const OperationHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuestionContainer(
      category: 'Operation help',
      children: [
        QuestionTitle('What are operations?'),
        QuestionText(
          "Operations are zcash's way of keeping track of what happens to zero-knowledge operations, for example when you shield/deshield/melt/cast.",
        ),
        QuestionText(
          'In the table below, you can keep track of whether the z_operation fails or succeeds, and view all parameters to each zero-knowledge operation.',
        ),
      ],
    );
  }
}

class MeltAndCastHelp extends StatelessWidget {
  const MeltAndCastHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return QuestionContainer(
      category: "What's going on?",
      children: [
        const QuestionText(
          'On this page, you can "melt" and "cast" your UTXOs. The diagram below explains the process.',
        ),
        const SailSpacing(SailStyleValues.padding20),
        SailSVG.png(
          SailPNGAsset.meltCastDiagram,
          width: MediaQuery.of(context).size.width,
        ),
        const SailSpacing(SailStyleValues.padding20),
        const QuestionTitle('What is melting?'),
        const QuestionText(
          'Melting shields your transparent UTXOs, but does it in a way to preserve your privacy.',
        ),
        const QuestionText(
          'It does this by making sure there is no change when you shield coins to your z-address.',
        ),
        const QuestionText(
          'Just like cast, melting gives you ultra-secure ultra-user-friendly “click button”-level coin anonymization.',
        ),
        const QuestionText(
          'You can melt per-UTXO, or all UTXOs at once. Both strategies makes sure to spend the full amount of the UTXO, leaving you with no change, or dust.',
        ),
        const QuestionText(
          "Together with cast, it's a great way to anonymize your coins.",
        ),
        const QuestionText(
          'When melting all your coins, you set the max time that you want the melt to take. The application automatically selects a timeout per UTXO, and makes sure to shield at that specific time. This furthers your privacy by not pegging you to a specific timezone.',
        ),
        const QuestionText(
          'Because this version uses test money, the melting frequency is much faster than in a real-world scenario. Here, it takes minutes, while with real money it would take days.',
        ),
        const QuestionText('Read more here: https://www.truthcoin.info/blog/zside-meltcast/'),
        const SailSpacing(SailStyleValues.padding20),
        const QuestionTitle('What is casting?'),
        const QuestionText(
          'Casting gives you ultra-secure ultra-user-friendly “click button”-level coin anonymization.',
        ),
        const QuestionText(
          'Casting lets you deshield your coins in predefined amounts, at predefined times. The amounts are the same as everyone else that uses zSide, making it impossible to match your inputs&outputs when moving coins from shielded to non-shielded.',
        ),
        const QuestionText(
          'The amounts are powers of two, starting at 1, e.g: 0.00000001 BTC, 0.00000002 BTC, 0.00000004 BTC, 0.00000008 BTC etc.',
        ),
        const QuestionText(
          'For example, 0.75 BTC will be withdrawn in 4 UTXOs. 1x0.67108864 BTC, 1x0.04194304 BTC, 1x0.02097152 BTC and 1x0.01048576 BTC. That sums to 0.74448896 BTC, which is 99.26% of 0.75 BTC.',
        ),
        const QuestionText(
          'The residual 0.00551104 BTC will stay un-withdrawn, in your z-address on the sidechain, to be withdrawn later.',
        ),
        const QuestionText('Read more here: https://www.truthcoin.info/blog/zside-meltcast/'),
      ],
    );
  }
}

bool isCastAmount(double amount) {
  if (amount > 21990.2325) {
    return false;
  }

  final satAmount = (amount * 100000000).toInt();
  if (satAmount <= 0) return false;

  // This checks if satAmount is a power of 2.
  // It does this by using a bitwise operation:
  // If satAmount is a power of 2, it will have only one '1' bit.
  // Subtracting 1 from it will flip all lower bits to '1'.
  // The bitwise AND of these two numbers will be 0 only for powers of 2.
  return (satAmount & (satAmount - 1)) == 0;
}

Color? getCastColor(double amount) {
  final isCasted = isCastAmount(amount);

  return isCasted ? SailColorScheme.green : null;
}
