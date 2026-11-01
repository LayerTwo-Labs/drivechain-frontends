import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class DataDirSetupPage extends StatefulWidget {
  /// The network we're configuring the datadir for.
  final BitcoinNetwork network;

  const DataDirSetupPage({super.key, required this.network});

  @override
  State<DataDirSetupPage> createState() => _DataDirSetupPageState();
}

/// Picks and saves a Bitcoin data directory for one network.
class DataDirSelection extends ChangeNotifier {
  String? selectedPath;
  bool selecting = false;
  String? error;

  BitcoinConfProvider get _conf => GetIt.I.get<BitcoinConfProvider>();

  /// Asks for a directory and keeps it when it is writable.
  Future<void> browse() async {
    selecting = true;
    error = null;
    notifyListeners();
    try {
      final result = await FilePicker.getDirectoryPath();
      if (result != null) {
        final testFile = File(path.join(result, '.bitwindow_test'));
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
          selectedPath = result;
        } catch (e) {
          error = 'Selected directory is not writable';
        }
      }
    } catch (e) {
      error = 'Error selecting directory: $e';
    } finally {
      selecting = false;
      notifyListeners();
    }
  }

  /// Saves the chosen directory for [network]. Returns false and sets [error]
  /// when it did not persist.
  Future<bool> save(BitcoinNetwork network) async {
    final chosen = selectedPath;
    if (chosen == null) {
      error = 'Please select a directory';
      notifyListeners();
      return false;
    }
    try {
      await _conf.updateDataDir(chosen, forNetwork: network);

      // A pick that didn't persist would send the user through this page again
      // on the next boot, with no sign anything went wrong.
      if (!_conf.hasDataDirFor(network)) {
        error = 'Could not save the data directory — check the BitWindow log';
        notifyListeners();
        return false;
      }

      // sleep for 500 millis because windows file stuff sucks, and we cant await
      await Future.delayed(const Duration(milliseconds: 500));

      await _conf.commitNetworkChange(network);
      return true;
    } catch (e) {
      error = 'Error saving configuration: $e';
      notifyListeners();
      return false;
    }
  }
}

class _DataDirSetupPageState extends State<DataDirSetupPage> {
  final DataDirSelection _selection = DataDirSelection();

  BitcoinNetwork get _targetNetwork => widget.network;

  @override
  void initState() {
    super.initState();
    _selection.addListener(_onChange);
  }

  @override
  void dispose() {
    _selection.removeListener(_onChange);
    _selection.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleContinue() async {
    if (await _selection.save(_targetNetwork) && mounted) {
      context.router.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final networkName = _targetNetwork.toDisplayName();

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              width: 800,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      SailText.primary40(
                        'Configure Data Directory',
                        bold: true,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SailText.primary15(
                        '$networkName requires a data directory to store blockchain data.\nThis will require significant disk space (700GB+ for mainnet).',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                  const Spacer(),
                  // Directory selector
                  SizedBox(
                    width: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colors.border),
                            borderRadius: SailStyleValues.borderRadiusSmall,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SailText.secondary13(
                                  _selection.selectedPath ?? 'No directory selected',
                                ),
                              ),
                              const SizedBox(width: 16),
                              SailButton(
                                label: 'Browse',
                                loading: _selection.selecting,
                                onPressed: _selection.browse,
                              ),
                            ],
                          ),
                        ),
                        if (_selection.error != null) ...[
                          const SizedBox(height: 8),
                          SailText.secondary12(
                            _selection.error!,
                            color: theme.colors.error,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Spacer(),
                  const Spacer(),
                  // Continue button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SailButton(
                        label: 'Continue',
                        variant: ButtonVariant.primary,
                        disabled: _selection.selectedPath == null,
                        onPressed: _handleContinue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
