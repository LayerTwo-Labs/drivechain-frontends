import 'dart:io';

import 'package:bitwindow/utils/freebank_conf.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';

// The BMM tab scrolls on its own, so the dialog gives it a fixed slot.
const _bmmTabHeight = 420.0;

// The tab's control row holds two buttons and three fields, with a 44 px gap
// between them, and it does not wrap. Below this width Flutter clips the
// max-bid field and the manual-bid button.
const _bmmTabWidth = 1160.0;

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

  /// Why the engine's controls stay shut, or null when a bid can go out. Every
  /// block a bid wins carries the name, and a node that restarts answers no RPC
  /// until it is up again.
  String? get _blockedReason {
    if (!_hasName) {
      return 'Save a name above to start bidding.';
    }
    if (!_rpc.connected) {
      return 'Waiting for FreeBank to start.';
    }
    return null;
  }

  File get _conf => File(filePath([_rpc.binary.datadirNetwork(), 'freebank.conf']));

  @override
  void initState() {
    super.initState();
    _rpc.addListener(_onConnectionChanged);
    _load();
  }

  void _onConnectionChanged() {
    if (mounted) {
      setState(() {});
    }
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
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Could not read the name: $e');
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
    _rpc.removeListener(_onConnectionChanged);
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailDialog(
      title: 'Bid for FreeBank blocks',
      subtitle:
          'For each eCash block, your node offers a small fee to have its next FreeBank block included. '
          'A bid is paid from your BitWindow wallet, and only when it wins.',
      error: _error,
      maxWidth: _bmmTabWidth + 80,
      maxHeight: 720,
      withCloseButton: true,
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            _hasName
                ? 'Blocks you win show "$_saved" on the explorer. Saving a new name restarts your FreeBank node.'
                : 'Blocks you win show this name on the explorer. Change it if you like, then save. '
                      'Saving restarts your FreeBank node.',
          ),
          SizedBox(
            height: _bmmTabHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _bmmTabWidth,
                child: _blockedReason == null
                    ? const BMMTab()
                    : Stack(
                        children: [
                          const IgnorePointer(child: Opacity(opacity: 0.35, child: BMMTab())),
                          Center(child: SailText.primary15(_blockedReason!)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
