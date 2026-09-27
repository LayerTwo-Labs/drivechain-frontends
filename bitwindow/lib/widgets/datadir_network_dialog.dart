import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Which repair the user picked for a datadir on another network.
enum DatadirNetworkRepair {
  /// Run the network the blocks belong to.
  switchNetwork,

  /// Rewrite the blocks for the network the app runs.
  convertBlocks,
}

/// True when the app can run the network the blocks belong to: this build lists
/// it, and it reads this same directory. A directory that holds two networks
/// offers no switch, because either network reads one half of it only.
bool canSwitchToDetected(BitcoinConfProvider conf, GetDatadirNetworkResponse answer) {
  if (conf.hasPrivateBitcoinConf || answer.mixed || !answer.switchReadsBlocks) {
    return false;
  }
  return conf.networkOptions.any((option) => option.id == answer.detectedId);
}

/// True when a conversion can move the blocks onto the network the app runs. The
/// daemon names that network in convertFromId, or leaves it empty: it holds the
/// fork heights the conversion rewinds to.
bool canConvertBlocks(BitcoinConfProvider conf, GetDatadirNetworkResponse answer) =>
    !conf.hasPrivateBitcoinConf && answer.convertFromId.isNotEmpty;

bool _isECash(BitcoinConfProvider conf, String id) {
  final option = conf.networkOptions.where((option) => option.id == id).firstOrNull;
  return option != null && conf.networkFromOption(option) == BitcoinNetwork.BITCOIN_NETWORK_ECASH;
}

/// States which network the blocks belong to, which one the app runs, and offers
/// the two repairs.
class DatadirNetworkDialog extends StatelessWidget {
  const DatadirNetworkDialog({super.key, required this.answer});

  final GetDatadirNetworkResponse answer;

  String get _detected => answer.detectedName.isNotEmpty ? answer.detectedName : answer.detectedId;
  String get _selected => answer.selectedName.isNotEmpty ? answer.selectedName : answer.selectedId;
  String get _first => answer.firstName.isNotEmpty ? answer.firstName : answer.firstId;
  String get _source => answer.convertFromName.isNotEmpty ? answer.convertFromName : answer.convertFromId;

  @override
  Widget build(BuildContext context) {
    final conf = GetIt.I.get<BitcoinConfProvider>();
    final canSwitch = canSwitchToDetected(conf, answer);
    final canConvert = canConvertBlocks(conf, answer);

    return SailDialog(
      title: answer.mixed ? 'The block files hold two networks' : 'The blocks on disk are from $_detected',
      subtitle: 'But you are on $_selected.',
      actions: [
        SailButton(
          label: 'Close',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(),
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13(
            answer.mixed
                ? '$_first records and $_detected records sit in one directory. A conversion stopped part '
                      'way, and no node reads every block until they all carry one magic.'
                : 'A start on $_selected rolls this chain back below the fork the two networks share, which '
                      'empties the balance until the branch comes back.',
          ),
          if (canSwitch)
            _repair(
              button: SailButton(
                label: 'Switch to $_detected',
                variant: ButtonVariant.secondary,
                onPressed: () async => Navigator.of(context).pop(DatadirNetworkRepair.switchNetwork),
              ),
              detail: 'The app runs the network these blocks belong to.',
            ),
          if (canConvert)
            _repair(
              button: SailButton(
                label: answer.mixed ? 'Finish the conversion to $_selected' : 'Convert the blocks to $_selected',
                onPressed: () async => Navigator.of(context).pop(DatadirNetworkRepair.convertBlocks),
              ),
              detail: answer.mixed
                  ? 'Every $_source record takes the $_selected magic. The records that already moved stay '
                        'as they are, and chain data is never deleted.'
                  : 'The chain rewinds to the block both networks share, and every record takes the '
                        '$_selected magic. Chain data is never deleted.',
            ),
          if (conf.hasPrivateBitcoinConf)
            SailText.secondary13('Your own bitcoin.conf names the network. Change it there, then restart.'),
          if (!conf.hasPrivateBitcoinConf && !answer.mixed && !answer.switchReadsBlocks)
            SailText.secondary13('$_detected reads another data directory. Point it at this one, then switch.'),
          if (!conf.hasPrivateBitcoinConf && !answer.mixed && answer.switchReadsBlocks && !canSwitch)
            SailText.secondary13('This build lists no network named ${answer.detectedId}.'),
          if (!conf.hasPrivateBitcoinConf && !canConvert) SailText.secondary13(_noConversionReason(conf)),
        ],
      ),
    );
  }

  /// Why the daemon named no conversion. It reports the fact, not the reason, so
  /// the three states it covers read apart here.
  String _noConversionReason(BitcoinConfProvider conf) {
    if (answer.mixed && answer.firstId != answer.selectedId && answer.detectedId != answer.selectedId) {
      return 'Neither half of this directory belongs to $_selected, so no conversion reaches it.';
    }
    if (!_isECash(conf, answer.detectedId) || !_isECash(conf, answer.selectedId)) {
      return 'A conversion runs between two eCash networks only.';
    }
    return 'A conversion moves a chain forward only, and $_selected forks the mainchain before these blocks.';
  }

  Widget _repair({required Widget button, required String detail}) => SailColumn(
    spacing: SailStyleValues.padding08,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [button, SailText.secondary13(detail)],
  );
}
