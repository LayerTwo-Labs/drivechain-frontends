import 'package:bitwindow/utils/paper_wallet_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';

/// Paper Wallet Dialog - Generate offline Bitcoin addresses with QR codes
///
/// Qt equivalent: paperwalletdialog.ui (very minimal in mainchain-deprecated)
/// Size from Qt: 1847x931 (but we'll make it more reasonable)
class PaperWalletDialog extends StatefulWidget {
  const PaperWalletDialog({super.key});

  @override
  State<PaperWalletDialog> createState() => _PaperWalletDialogState();
}

class _PaperWalletDialogState extends State<PaperWalletDialog> {
  PaperWalletKeypair? _keypair;
  bool _isGenerating = false;
  bool _showPrivateKey = false;

  @override
  void initState() {
    super.initState();
    _generateKeypair();
  }

  Future<void> _generateKeypair() async {
    setState(() {
      _isGenerating = true;
      _showPrivateKey = false;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final keypair = PaperWalletGenerator.generate();

    setState(() {
      _keypair = keypair;
      _isGenerating = false;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Qt dialog size: 1847x931, but we'll use something more reasonable
    return Dialog(
      backgroundColor: theme.colors.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: SailStyleValues.borderRadiusSmall,
        side: BorderSide(color: theme.colors.border, width: 1),
      ),
      child: Container(
        width: 900, // Reasonable width for modern displays
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - matches Qt dialog title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.primary20('Paper Wallet'), // Qt windowTitle
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colors.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content - Qt QVBoxLayout
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security warning (not in Qt, but important)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colors.actionHeader,
                        borderRadius: SailStyleValues.borderRadiusSmall,
                        border: Border.all(color: theme.colors.orangeLight),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: theme.colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SailText.secondary12(
                              'SECURITY: Generate paper wallets on an offline computer. '
                              'Never share your private key. Store printed wallet securely.',
                              color: theme.colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_isGenerating || _keypair == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: theme.colors.primary),
                              const SizedBox(height: 16),
                              SailText.secondary13('Generating secure keypair...'),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildWalletContent(theme),
                  ],
                ),
              ),
            ),

            // Footer buttons - Qt pushButtonPrint equivalent
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailButton(
                    label: 'Generate New',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => _generateKeypair(),
                    loading: _isGenerating,
                  ),
                  Row(
                    children: [
                      SailButton(
                        label: 'Print', // Qt pushButtonPrint
                        onPressed: () async {
                          // TODO: Implement printing (Qt version also has TODO)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Printing will be implemented in a future update'),
                            ),
                          );
                        },
                        disabled: _keypair == null || _isGenerating,
                      ),
                      const SizedBox(width: 12),
                      SailButton(
                        label: 'Close',
                        variant: ButtonVariant.secondary,
                        onPressed: () async => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletContent(SailThemeData theme) {
    if (_keypair == null) return const SizedBox.shrink();

    // Layout similar to Bitcoin Core paper wallets
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Public Address (for receiving)
        Expanded(
          child: _buildAddressPanel(theme),
        ),
        const SizedBox(width: 24),
        // Right side - Private Key (for spending)
        Expanded(
          child: _buildPrivateKeyPanel(theme),
        ),
      ],
    );
  }

  Widget _buildAddressPanel(SailThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: theme.colors.success, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, color: theme.colors.success, size: 24),
              const SizedBox(width: 8),
              SailText.primary15('LOAD & VERIFY', bold: true),
            ],
          ),
          const SizedBox(height: 8),
          SailText.secondary12(
            'Public Bitcoin Address',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadiusSmall,
            ),
            child: QrImageView(
              data: _keypair!.publicAddress,
              version: QrVersions.auto,
              size: 200,
              padding: EdgeInsets.zero,
              eyeStyle: QrEyeStyle(
                color: theme.colors.text,
                eyeShape: QrEyeShape.square,
              ),
              dataModuleStyle: QrDataModuleStyle(color: theme.colors.text),
              backgroundColor: theme.colors.backgroundSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Address text
          SelectableText(
            _keypair!.publicAddress,
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 11,
              color: theme.colors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Copy button
          SailButton(
            label: 'Copy Address',
            variant: ButtonVariant.secondary,
            onPressed: () async => _copyToClipboard(_keypair!.publicAddress, 'Address'),
          ),
          const SizedBox(height: 16),

          // Instructions
          SailText.secondary12(
            'Share this address to receive Bitcoin',
            textAlign: TextAlign.center,
            color: theme.colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateKeyPanel(SailThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: theme.colors.error, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.key, color: theme.colors.error, size: 24),
              const SizedBox(width: 8),
              SailText.primary15('SPEND', bold: true),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _showPrivateKey ? Icons.visibility_off : Icons.visibility,
                  color: theme.colors.text,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _showPrivateKey = !_showPrivateKey;
                  });
                },
                tooltip: _showPrivateKey ? 'Hide private key' : 'Show private key',
              ),
            ],
          ),
          const SizedBox(height: 8),
          SailText.secondary12(
            'Private Key (WIF)',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          if (_showPrivateKey) ...[
            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.backgroundSecondary,
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: QrImageView(
                data: _keypair!.privateKeyWIF,
                version: QrVersions.auto,
                size: 200,
                padding: EdgeInsets.zero,
                eyeStyle: QrEyeStyle(
                  color: theme.colors.text,
                  eyeShape: QrEyeShape.square,
                ),
                dataModuleStyle: QrDataModuleStyle(color: theme.colors.text),
                backgroundColor: theme.colors.backgroundSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Private key text
            SelectableText(
              _keypair!.privateKeyWIF,
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                color: theme.colors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Copy button
            SailButton(
              label: 'Copy Private Key',
              variant: ButtonVariant.secondary,
              onPressed: () async => _copyToClipboard(_keypair!.privateKeyWIF, 'Private key'),
            ),
          ] else
            Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.visibility_off, size: 80, color: theme.colors.textTertiary),
                const SizedBox(height: 16),
                SailText.secondary12(
                  'Click the eye icon to reveal',
                  color: theme.colors.textTertiary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),

          const SizedBox(height: 16),

          // Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.error.withValues(alpha: 0.1),
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(color: theme.colors.error),
            ),
            child: SailText.secondary12(
              'KEEP SECRET: Anyone with this private key can spend your Bitcoin',
              color: theme.colors.error,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
