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

  const DataDirSetupPage({
    super.key,
    required this.network,
  });

  @override
  State<DataDirSetupPage> createState() => _DataDirSetupPageState();
}

class _DataDirSetupPageState extends State<DataDirSetupPage> {
  String? _selectedPath;
  bool _isSelecting = false;
  String? _errorMessage;

  BitcoinConfProvider get _confProvider => GetIt.I.get<BitcoinConfProvider>();

  BitcoinNetwork get _targetNetwork => widget.network;

  Future<void> _selectDirectory() async {
    setState(() {
      _isSelecting = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        // Validate directory is writable
        final testFile = File(path.join(result, '.bitwindow_test'));
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
          setState(() {
            _selectedPath = result;
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Selected directory is not writable';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting directory: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSelecting = false;
        });
      }
    }
  }

  Future<void> _handleContinue() async {
    if (_selectedPath == null) {
      setState(() {
        _errorMessage = 'Please select a directory';
      });
      return;
    }

    try {
      // Save the datadir for the target network
      await _confProvider.updateDataDir(_selectedPath, forNetwork: _targetNetwork);

      // sleep for 500 millis because windows file stuff sucks, and we cant await
      await Future.delayed(const Duration(milliseconds: 500));

      // Commit the network change now that datadir is configured
      await _confProvider.commitNetworkChange(widget.network);

      if (mounted) {
        context.router.pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving configuration: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final networkName = _targetNetwork.toDisplayName();

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                                  _selectedPath ?? 'No directory selected',
                                ),
                              ),
                              const SizedBox(width: 16),
                              SailButton(
                                label: 'Browse',
                                loading: _isSelecting,
                                onPressed: () async => await _selectDirectory(),
                              ),
                            ],
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          SailText.secondary12(
                            _errorMessage!,
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
                        disabled: _selectedPath == null,
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
