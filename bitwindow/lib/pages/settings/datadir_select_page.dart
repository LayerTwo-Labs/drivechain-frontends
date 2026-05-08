import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Full-page picker for the Bitcoin Core data directory. Pushed when a
/// network switch needs a datadir but none is configured.
class DataDirSelectPage extends StatefulWidget {
  final BitcoinNetwork? network;

  const DataDirSelectPage({super.key, this.network});

  @override
  State<DataDirSelectPage> createState() => _DataDirSelectPageState();
}

class _DataDirSelectPageState extends State<DataDirSelectPage> {
  String? _selectedPath;
  bool _isPicking = false;

  Future<void> _pickDirectory() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.getDirectoryPath();
      if (result != null && mounted) {
        setState(() => _selectedPath = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting directory: $e'),
            backgroundColor: SailTheme.of(context).colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  String _subtitle() {
    switch (widget.network) {
      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
        return 'Mainnet needs a Bitcoin Core data directory with the blockchain data (2.5TB+). Pick a directory that contains the blocks folder.';
      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        return 'Forknet needs a data directory to store the chain. Pick an empty directory or one already used for forknet.';
      default:
        return 'Pick a directory for Bitcoin Core to store its data.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final networkName = widget.network?.toDisplayName() ?? 'Bitcoin Core';

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
        leading: SailAppBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: 800,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        SailText.primary24(
                          'Select $networkName Data Directory',
                          bold: true,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SailText.secondary13(
                          _subtitle(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(SailStyleValues.padding12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colors.border),
                            borderRadius: SailStyleValues.borderRadiusSmall,
                            color: theme.colors.backgroundSecondary,
                          ),
                          child: SailText.secondary13(
                            _selectedPath ?? 'No directory selected',
                            monospace: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SailButton(
                          label: 'Browse',
                          loading: _isPicking,
                          onPressed: () async => await _pickDirectory(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BottomActionBar(
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.secondary,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
                const SizedBox(width: SailStyleValues.padding12),
                SailButton(
                  label: 'Confirm',
                  variant: ButtonVariant.primary,
                  disabled: _selectedPath == null,
                  onPressed: () async => Navigator.of(context).pop(_selectedPath),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
