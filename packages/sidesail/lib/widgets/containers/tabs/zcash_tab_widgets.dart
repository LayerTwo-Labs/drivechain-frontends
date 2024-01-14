import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/pages/tabs/dashboard_tab_page.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

class ShieldUTXOAction extends StatelessWidget {
  final UnshieldedUTXO utxo;

  const ShieldUTXOAction({super.key, required this.utxo});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ShieldUTXOActionViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Shield coins',
          endActionButton: SailButton.primary(
            'Execute shield',
            disabled: viewModel.bitcoinAmountController.text.isEmpty,
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.executeShield(context, utxo);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'How much do you want to shield?',
              suffixText: 'BTC',
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
              value: '${viewModel.shieldFee}',
            ),
            StaticActionField(
              label: 'Total amount',
              value: viewModel.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class ShieldUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      ((double.tryParse(bitcoinAmountController.text) ?? 0) + (shieldFee)).toStringAsFixed(8);

  double get shieldFee => _zcashProvider.sideFee;
  double? get amount => double.tryParse(bitcoinAmountController.text);

  ShieldUTXOActionViewModel() {
    bitcoinAmountController.addListener(notifyListeners);
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
      'shielding utxo: $amount BTC to ${utxo.address} with $shieldFee shield fee',
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
        title: 'You shielded $amount BTC to your Z-address',
        subtitle: 'OPID: $shieldID',
      );
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

    // also pop the info modal
    await _router.pop();
  }
}

class DeshieldUTXOAction extends StatelessWidget {
  final ShieldedUTXO utxo;

  const DeshieldUTXOAction({super.key, required this.utxo});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DeshieldUTXOActionViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Deshield coins',
          endActionButton: SailButton.primary(
            'Execute deshield',
            disabled: viewModel.bitcoinAmountController.text.isEmpty,
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.executeDeshield(context, utxo);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'How much do you want to deshield?',
              suffixText: 'BTC',
              bitcoinInput: true,
              autofocus: true,
            ),
            const StaticActionField(
              label: 'Deshield from',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Deshield to',
              value: viewModel.deshieldAddress,
            ),
            StaticActionField(
              label: 'Deshield fee',
              value: '${viewModel.deshieldFee}',
            ),
            StaticActionField(
              label: 'Total amount',
              value: viewModel.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class DeshieldUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      ((double.tryParse(bitcoinAmountController.text) ?? 0) + (deshieldFee)).toStringAsFixed(8);

  String deshieldAddress = '';
  double get deshieldFee => _zcashProvider.sideFee;
  double? get amount => double.tryParse(bitcoinAmountController.text);

  DeshieldUTXOActionViewModel() {
    bitcoinAmountController.addListener(notifyListeners);

    init();
  }

  void init() async {
    deshieldAddress = await _rpc.getNewAddress();
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
      'deshielding utxo: $amount BTC to ${utxo.address} with $deshieldFee deshield fee',
    );

    try {
      final deshieldID = await _rpc.deshield(
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
        title: 'You deshielded $amount BTC to tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        subtitle: 'OPID: $deshieldID',
      );
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

    // also pop the info modal
    await _router.pop();
  }
}

class CastSingleUTXOAction extends StatelessWidget {
  final ShieldedUTXO utxo;

  const CastSingleUTXOAction({super.key, required this.utxo});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => CastSingleUTXOActionViewModel(utxo: utxo),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Cast single UTXO',
          endActionButton: SailButton.primary(
            'Execute cast',
            loading: viewModel.isBusy,
            disabled: viewModel.includedInBills == null,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.executeCast(context, utxo);
            },
          ),
          children: [
            const StaticActionField(
              label: 'Deshield from',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Deshield to',
              value: viewModel.castAddresses.join('\n'),
            ),
            StaticActionField(
              label: 'Cast fee',
              value: '${viewModel.castFee}',
            ),
            StaticActionField(
              label: 'Castable amount',
              value: viewModel.castableAmount.toStringAsFixed(8),
            ),
            StaticActionField(
              label: 'Total amount',
              value: viewModel.totalBitcoinAmount.toStringAsFixed(8),
            ),
            StaticActionField(
              label: 'Executed by',
              value: viewModel.maxExecuteTime.toString(),
            ),
          ],
        );
      }),
    );
  }
}

class CastSingleUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  List<PendingCastBill>? get includedInBills => _castProvider.findBillsForAmount(utxo.amount - castFee);
  DateTime get maxExecuteTime => includedInBills!
      .reduce(
        (currentMax, bill) => bill.executeTime.isAfter(currentMax.executeTime) ? bill : currentMax,
      )
      .executeTime;
  double get castableAmount => includedInBills!.fold(0, (sum, bill) => sum + bill.castAmount);
  double get totalBitcoinAmount => castableAmount + castFee;
  double get castFee => _zcashProvider.sideFee * _rpc.numUTXOsPerCast;

  List<String> castAddresses = [];

  ShieldedUTXO utxo;

  CastSingleUTXOActionViewModel({required this.utxo}) {
    init();
  }

  void init() async {
    castAddresses.add(await _rpc.getNewAddress());
    castAddresses.add(await _rpc.getNewAddress());
    castAddresses.add(await _rpc.getNewAddress());
    castAddresses.add(await _rpc.getNewAddress());

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
      'casting utxo: $castableAmount BTC to $castAddresses with $castFee deshield fee',
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

      List<int> uniqueMinutes = includedInBills!.map((bundle) => bundle.executeIn.inSeconds).toSet().toList();

      await successDialog(
        context: context,
        action: 'Cast single UTXO',
        title: 'You will cast $totalBitcoinAmount BTC to $castAddresses',
        subtitle:
            'Will cast to ${includedInBills!.length} new unique UTXOs in ${uniqueMinutes.join(', ')} seconds.\n\nDont close the application until you have no shielded coins left in your wallet.',
      );
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

    // also pop the info modal
    await _router.pop();
  }
}

class MeltAction extends StatelessWidget {
  const MeltAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => MeltActionViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Melt all UTXOs',
          endActionButton: SailButton.primary(
            'Execute melt',
            disabled: viewModel.meltInMinutesController.text.isEmpty,
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.melt(context);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.meltInMinutesController,
              hintText: 'How many minutes should the melt take?',
              suffixText: 'minutes',
              numberInput: true,
              autofocus: true,
            ),
            const StaticActionField(
              label: 'Shield to',
              value: 'Your Z-address',
            ),
            StaticActionField(
              label: 'Shield from',
              value:
                  // extract address, then join on a newline
                  viewModel.meltableUTXOs.map((utxo) => utxo.address).join('\n'),
            ),
            StaticActionField(
              label: 'Melt fee',
              value: '${viewModel.meltFee.toStringAsFixed(8)} ${viewModel._rpc.chain.ticker}',
            ),
            StaticActionField(
              label: 'Melt amount',
              value: '${viewModel.meltAmount.toStringAsFixed(8)} ${viewModel._rpc.chain.ticker}',
            ),
            StaticActionField(
              label: 'Total amount',
              value: '${viewModel.totalBitcoinAmount.toStringAsFixed(8)} ${viewModel._rpc.chain.ticker}',
            ),
          ],
        );
      }),
    );
  }
}

class MeltActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();

  double get shieldFee => _zcashProvider.sideFee;

  final bitcoinAmountController = TextEditingController();
  double get totalBitcoinAmount => (meltAmount + meltFee);

  List<UnshieldedUTXO> get meltableUTXOs =>
      _zcashProvider.unshieldedUTXOs.where((utxo) => utxo.amount > 0.0001).toList();
  double get meltAmount =>
      _zcashProvider.unshieldedUTXOs.map((entry) => entry.amount).reduce((value, element) => value + element) - meltFee;
  double get meltFee => (_zcashProvider.sideFee * meltableUTXOs.length);
  TextEditingController meltInMinutesController = TextEditingController();

  MeltActionViewModel() {
    bitcoinAmountController.addListener(notifyListeners);
    meltInMinutesController.addListener(notifyListeners);
  }

  void melt(BuildContext context) async {
    setBusy(true);
    _initiateMelt(context);
    setBusy(false);
  }

  void _initiateMelt(BuildContext context) async {
    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    log.i(
      'melting ${meltableUTXOs.length} utxos: $meltAmount BTC to with $shieldFee shield fee',
    );

    try {
      final willMeltAt = await _zcashProvider.melt(
        meltableUTXOs,
        double.tryParse(meltInMinutesController.text) ?? 1,
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
            'You will shield ${meltableUTXOs.length} coins for a total of ${totalBitcoinAmount.toStringAsFixed(8)} BTC to your Z-address',
        subtitle:
            'Will melt in ${willMeltAt.map((e) => e.toStringAsFixed(e.roundToDouble() == e ? 0 : 2)).join(', ')} minutes.\nDont close the application until ${meltInMinutesController.text} minute(s) have passed',
      );
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

    // also pop the info modal
    await _router.pop();
  }

  @override
  void dispose() {
    super.dispose();
    bitcoinAmountController.removeListener(notifyListeners);
    meltInMinutesController.removeListener(notifyListeners);
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
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Melt single UTXO',
          endActionButton: SailButton.primary(
            'Execute melt',
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.melt(context, utxo);
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
              value: viewModel.castAmount.toStringAsFixed(8),
            ),
            StaticActionField(
              label: 'Cast fee',
              value: '${viewModel.shieldFee}',
            ),
            StaticActionField(
              label: 'Total amount',
              value: viewModel.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class MeltSingleUTXOActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  final UnshieldedUTXO utxo;

  String get totalBitcoinAmount => ((castAmount + (shieldFee)).toStringAsFixed(8));

  double get shieldFee => _zcashProvider.sideFee;
  double get castAmount => utxo.amount - shieldFee;

  MeltSingleUTXOActionViewModel({required this.utxo});

  void melt(BuildContext context, UnshieldedUTXO utxo) async {
    setBusy(true);
    _executeMelt(context, utxo);
    setBusy(false);
  }

  void _executeMelt(BuildContext context, UnshieldedUTXO utxo) async {
    if (!context.mounted) {
      return;
    }

    log.i(
      'melting utxo: $castAmount BTC to ${utxo.address} with $shieldFee shield fee',
    );

    try {
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
        title: 'You melted $castAmount BTC to your Z-address',
        subtitle: 'OPID: $shieldID',
      );
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

    // also pop the info modal
    await _router.pop();
  }
}

class CastAction extends StatelessWidget {
  const CastAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => CastActionViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Cast all UTXOs',
          endActionButton: SailButton.primary(
            'Execute cast',
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              viewModel.cast(context);
            },
          ),
          children: [
            const StaticActionField(
              label: 'Deshield to',
              value: 'Various transparent addresses',
            ),
            StaticActionField(
              label: 'Deshield from',
              value:
                  // extract address, then join on a newline
                  viewModel.castableUTXOs.map((utxo) => utxo.address).join('\n'),
            ),
            StaticActionField(
              label: 'Cast fee',
              value: '${viewModel.castFee.toStringAsFixed(8)} ${viewModel._rpc.chain.ticker}',
            ),
            StaticActionField(
              label: 'Cast amount',
              value: '${viewModel.castAmount.toStringAsFixed(8)} ${viewModel._rpc.chain.ticker}',
            ),
            StaticActionField(
              label: 'Total amount',
              value: '${viewModel.totalBitcoinAmount.toStringAsFixed(8)} ${viewModel._rpc.chain.ticker}',
            ),
          ],
        );
      }),
    );
  }
}

class CastActionViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  AppRouter get _router => GetIt.I.get<AppRouter>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();

  double get shieldFee => _zcashProvider.sideFee;
  List<PendingCastBill> get includedInBundle {
    final List<PendingCastBill> bundles = [];

    for (final utxo in _zcashProvider.shieldedUTXOs) {
      final utxoBundle = _castProvider.findBillsForAmount(utxo.amount);
      if (utxoBundle != null) {
        bundles.addAll(utxoBundle);
      }
    }

    return bundles;
  }

  List<ShieldedUTXO> get castableUTXOs => _zcashProvider.shieldedUTXOs;

  num get castFee => _rpc.numUTXOsPerCast * shieldFee;
  num get castAmount => includedInBundle.map((e) => e.castAmount).reduce((sum, fee) => sum + fee);
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
      'casting ${_zcashProvider.shieldedUTXOs.length} utxos: $castAmount BTC to with $shieldFee shield fee',
    );

    try {
      for (final _ in includedInBundle) {
        // TODO
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
        action: 'Cast all UTXOs',
        title:
            'You will cast ${_zcashProvider.shieldedUTXOs.length} coins for a total of ${totalBitcoinAmount.toStringAsFixed(8)} BTC to your Z-address',
        subtitle:
            'Will cast in various minutes.\nDont close the application until you have no shielded coins left in your wallet',
      );
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

    // also pop the info modal
    await _router.pop();
  }
}

class OperationView extends StatefulWidget {
  final OperationStatus tx;

  const OperationView({super.key, required this.tx});

  @override
  State<OperationView> createState() => _OperationViewState();
}

class _OperationViewState extends State<OperationView> {
  bool expanded = false;
  late Map<String, dynamic> decodedTx;
  @override
  void initState() {
    super.initState();
    decodedTx = jsonDecode(widget.tx.raw);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailScaleButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueContainer(
              width: 105,
              icon: widget.tx.status == 'success'
                  ? Tooltip(
                      message: 'Success',
                      child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
                    )
                  : Tooltip(
                      message: 'Failed',
                      child: SailSVG.icon(SailSVGAsset.iconFailed, width: 13),
                    ),
              copyable: false,
              label: widget.tx.method,
              value: widget.tx.params,
              trailingText: DateFormat('dd MMM HH:mm').format(widget.tx.creationTime),
            ),
          ),
          if (expanded)
            ExpandedTXView(
              decodedTX: decodedTx,
              width: 105,
            ),
        ],
      ),
    );
  }
}

class UnshieldedUTXOView extends StatefulWidget {
  final UnshieldedUTXO utxo;
  final VoidCallback shieldAction;
  final bool meltMode;

  const UnshieldedUTXOView({
    super.key,
    required this.utxo,
    required this.shieldAction,
    required this.meltMode,
  });

  @override
  State<UnshieldedUTXOView> createState() => _UnshieldedUTXOViewState();
}

class _UnshieldedUTXOViewState extends State<UnshieldedUTXOView> {
  bool expanded = false;
  late Map<String, dynamic> decodedUTXO;
  @override
  void initState() {
    super.initState();
    decodedUTXO = jsonDecode(widget.utxo.raw);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailScaleButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueContainer(
              width: 130,
              prefixAction: SailButton.secondary(
                widget.meltMode ? 'Melt' : 'Shield',
                onPressed: widget.shieldAction,
                size: ButtonSize.small,
                disabled: widget.utxo.amount <= 0.0001000,
              ),
              icon: widget.utxo.confirmations >= 1
                  ? Tooltip(
                      message: '${widget.utxo.confirmations} confirmations',
                      child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
                    )
                  : Tooltip(
                      message: 'Unconfirmed',
                      child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
                    ),
              copyable: false,
              label: '${widget.utxo.amount.toStringAsFixed(8)} BTC',
              value: widget.utxo.address,
              trailingText: '',
            ),
          ),
          if (expanded)
            ExpandedTXView(
              decodedTX: decodedUTXO,
              width: 105,
            ),
        ],
      ),
    );
  }
}

class ShieldedUTXOView extends StatefulWidget {
  final ShieldedUTXO utxo;
  final VoidCallback deshieldAction;
  final bool castMode;

  const ShieldedUTXOView({
    super.key,
    required this.utxo,
    required this.deshieldAction,
    required this.castMode,
  });

  @override
  State<ShieldedUTXOView> createState() => _ShieldedUTXOViewState();
}

class _ShieldedUTXOViewState extends State<ShieldedUTXOView> {
  bool expanded = false;
  late Map<String, dynamic> decodedUTXO;
  @override
  void initState() {
    super.initState();
    decodedUTXO = jsonDecode(widget.utxo.raw);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailScaleButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueContainer(
              width: 130,
              prefixAction: SailButton.secondary(
                widget.castMode ? 'Cast' : 'Deshield',
                onPressed: widget.deshieldAction,
                size: ButtonSize.small,
                disabled: widget.utxo.amount <= 0.0001000,
              ),
              icon: widget.utxo.confirmations >= 1
                  ? Tooltip(
                      message: '${widget.utxo.confirmations} confirmations',
                      child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
                    )
                  : Tooltip(
                      message: 'Unconfirmed',
                      child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
                    ),
              copyable: false,
              label: '${widget.utxo.amount.toStringAsFixed(8)} BTC',
              value: widget.utxo.txid,
              trailingText: '',
            ),
          ),
          if (expanded)
            ExpandedTXView(
              decodedTX: decodedUTXO,
              width: 105,
            ),
        ],
      ),
    );
  }
}
