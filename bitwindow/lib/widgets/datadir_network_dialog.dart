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

/// A network's display name, or its id while the catalog names none.
String networkLabel(String name, String id) => name.isNotEmpty ? name : id;

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
/// daemon names both ends of it, or neither: the rules live with the catalog.
bool canConvertBlocks(BitcoinConfProvider conf, GetDatadirNetworkResponse answer) =>
    !conf.hasPrivateBitcoinConf && answer.convertFromId.isNotEmpty;

/// States which network the blocks belong to, which one the app runs, and offers
/// every repair that runs.
class DatadirNetworkDialog extends StatelessWidget {
  const DatadirNetworkDialog({super.key, required this.answer});

  final GetDatadirNetworkResponse answer;

  String get _detected => networkLabel(answer.detectedName, answer.detectedId);
  String get _selected => networkLabel(answer.selectedName, answer.selectedId);
  String get _first => networkLabel(answer.firstName, answer.firstId);
  String get _source => networkLabel(answer.convertFromName, answer.convertFromId);
  String get _target => networkLabel(answer.convertToName, answer.convertToId);

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
          SailText.primary13(_cost),
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
                label: answer.mixed ? 'Finish the conversion to $_target' : 'Convert the blocks to $_target',
                onPressed: () async => Navigator.of(context).pop(DatadirNetworkRepair.convertBlocks),
              ),
              detail: answer.mixed
                  ? 'Every $_source record takes the $_target magic. The records that already moved stay as '
                        'they are. The app deletes no chain data.'
                  : 'The chain rewinds to the block both networks share, and every record takes the $_target '
                        'magic. The app deletes no chain data.',
            ),
          for (final note in _notes(conf)) SailText.secondary13(note),
        ],
      ),
    );
  }

  /// What a start costs while the blocks stay as they are.
  String get _cost => answer.mixed
      ? '$_first records and $_detected records sit in one directory. A conversion stopped part way, and '
            'no node reads every block until they all carry one magic.'
      : 'A start on $_selected rolls this chain back to the block the two networks share. Your balance '
            'then reads empty until the chain syncs again.';

  /// True when the directory holds two networks and the app runs neither of them.
  bool get _bothHalvesForeign =>
      answer.mixed && answer.firstId != answer.selectedId && answer.detectedId != answer.selectedId;

  /// Why a repair is absent. One note per repair, and none while it is on offer.
  List<String> _notes(BitcoinConfProvider conf) {
    if (conf.hasPrivateBitcoinConf) {
      return ['Your own bitcoin.conf names the network. Change it there. Then restart BitWindow.'];
    }
    final canSwitch = canSwitchToDetected(conf, answer);
    return [
      if (!canSwitch && !answer.mixed && !answer.switchReadsBlocks)
        '$_detected reads another data directory. Point it at this one. Then switch.',
      if (!canSwitch && !answer.mixed && answer.switchReadsBlocks)
        'This build lists no network named ${answer.detectedId}.',
      if (!canConvertBlocks(conf, answer))
        _bothHalvesForeign
            ? 'Neither half of this directory belongs to $_selected.'
            : 'A conversion moves an eCash chain forward only. It cannot move these blocks to $_selected.',
    ];
  }

  Widget _repair({required Widget button, required String detail}) => SailColumn(
    spacing: SailStyleValues.padding08,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [button, SailText.secondary13(detail)],
  );
}
