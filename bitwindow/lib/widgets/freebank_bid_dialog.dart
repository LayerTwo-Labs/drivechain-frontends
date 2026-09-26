import 'dart:io';

import 'package:bitwindow/utils/freebank_conf.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';

/// Bidding for FreeBank blocks from BitWindow: the name the node writes into the
/// blocks it wins, then the BMM engine's own controls. FreeBank has no app of its
/// own, so BitWindow is where a user starts it.
class FreeBankBidDialog extends StatefulWidget {
  const FreeBankBidDialog({super.key});

  @override
  State<FreeBankBidDialog> createState() => _FreeBankBidDialogState();
}

class _FreeBankBidDialogState extends State<FreeBankBidDialog> {
  final FreeBankRPC _rpc = GetIt.I.get<FreeBankRPC>();
  final TextEditingController _name = TextEditingController();
  String? _saved;
  String? _error;
  bool _saving = false;

  bool get _hasName => _saved != null && _saved!.isNotEmpty;

  File get _conf => File(filePath([_rpc.binary.datadirNetwork(), 'freebank.conf']));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final conf = await _conf.exists() ? await _conf.readAsString() : '';
      final tag = readCoinbaseTag(conf);
      if (!mounted) {
        return;
      }
      setState(() {
        _saved = tag;
        // A name is required before the first bid, so offer one to change.
        _name.text = (tag == null || tag.isEmpty) ? suggestCoinbaseTag() : tag;
      });
    } catch (e) {
      GetIt.I.get<Logger>().w('FreeBank: could not read freebank.conf: $e');
    }
  }

  Future<void> _save() async {
    final problem = coinbaseTagProblem(_name.text);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final conf = await _conf.exists() ? await _conf.readAsString() : '';
      await _conf.parent.create(recursive: true);
      await _conf.writeAsString(setCoinbaseTag(conf, _name.text));
      // freebankd reads the name at startup only.
      await GetIt.I.get<BinaryProvider>().restart(_rpc.binary);
      if (!mounted) {
        return;
      }
      setState(() => _saved = _name.text.trim());
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Could not save the name: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 760,
        height: 720,
        padding: const EdgeInsets.all(SailStyleValues.padding25),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Bid for FreeBank blocks'),
            SailText.secondary13(
              'For each eCash block, your node offers a small fee to have its next FreeBank block included. '
              'A bid is paid from your BitWindow wallet, and only when it wins.',
            ),
            SailText.primary13('Name on your blocks', bold: true),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailTextField(
                    controller: _name,
                    hintText: "Your name, or your pool's name",
                    enabled: !_saving,
                  ),
                ),
                SailButton(
                  label: 'Save',
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
            SailText.secondary12(
              _error ??
                  (!_hasName
                      ? 'Blocks you win show this name on the explorer. Change it if you like, then save. '
                            'Saving restarts your FreeBank node.'
                      : 'Blocks you win show "$_saved" on the explorer. Saving a new name restarts your FreeBank node.'),
              color: _error == null ? null : theme.colors.error,
            ),
            Expanded(
              // Every block a bid wins carries the name, so bidding waits for one.
              child: _hasName
                  ? const BMMTab()
                  : Stack(
                      children: [
                        const IgnorePointer(child: Opacity(opacity: 0.35, child: BMMTab())),
                        Center(child: SailText.primary15('Save a name above to start bidding.')),
                      ],
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SailButton(label: 'Close', onPressed: () async => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}
