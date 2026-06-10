import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/paper_wallet_generator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';

/// Paper Check Dialog - Create funded Bitcoin checks with redemption keys
///
/// Qt equivalent: None (disabled in mainchain-deprecated: showPaperCheckDialogAction->setEnabled(false))
/// Design follows Paper Wallet dialog structure for consistency
class PaperCheckDialog extends StatefulWidget {
  const PaperCheckDialog({super.key});

  @override
  State<PaperCheckDialog> createState() => _PaperCheckDialogState();
}

class _PaperCheckDialogState extends State<PaperCheckDialog> {
  final TextEditingController _amountController = TextEditingController();
  PaperWalletKeypair? _keypair;
  bool _isGenerating = false;
  bool _isSending = false;
  bool _showPrivateKey = false;
  String? _error;
  String? _txid;

  OrchestratorWalletRPC get _orchestratorWallet => GetIt.I.get<OrchestratorRPC>().wallet;
  TransactionProvider get _transactionsProvider => GetIt.I.get<TransactionProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  @override
  void initState() {
    super.initState();
    _generateKeypair();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generateKeypair() async {
    setState(() {
      _isGenerating = true;
      _showPrivateKey = false;
      _txid = null;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final keypair = PaperWalletGenerator.generate();

    setState(() {
      _keypair = keypair;
      _isGenerating = false;
    });
  }

  Future<void> _createCheck() async {
    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      setState(() {
        _error = 'Please enter an amount';
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Please enter a valid amount greater than 0';
      });
      return;
    }

    if (_keypair == null) {
      setState(() {
        _error = 'No address generated';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _error = null;
      _txid = null;
    });

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      // Convert BTC to satoshis
      final satoshis = (amount * 100000000).toInt();

      // Send funds to the generated address
      final destinations = <String, int>{
        _keypair!.publicAddress: satoshis,
      };

      final txid = (await _orchestratorWallet.sendTransaction(
        walletId: walletId,
        destinations: destinations,
      )).txid;

      setState(() {
        _txid = txid;
        _isSending = false;
      });

      // Refresh transactions
      await _transactionsProvider.fetch();
    } catch (e) {
      setState(() {
        _error = 'Failed to create check: ${e.toString()}';
        _isSending = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showSailToast(context, '$label copied to clipboard');
  }

  Future<void> _printPaperCheck() async {
    if (_keypair == null || _txid == null) return;

    final pdf = pw.Document();
    final amount = _amountController.text.trim();

    final recipientQr = await QrPainter(
      data: _keypair!.publicAddress,
      version: QrVersions.auto,
      gapless: false,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
    ).toImageData(300);

    final redemptionQr = await QrPainter(
      data: _keypair!.privateKeyWIF,
      version: QrVersions.auto,
      gapless: false,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
    ).toImageData(300);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              children: [
                pw.Text(
                  'BITCOIN PAPER CHECK',
                  style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Amount: $amount BTC',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.blue, width: 3),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'RECIPIENT',
                              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text('Bitcoin Address', style: const pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(height: 15),
                            if (recipientQr != null)
                              pw.Image(
                                pw.MemoryImage(recipientQr.buffer.asUint8List()),
                                width: 200,
                                height: 200,
                              ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              _keypair!.publicAddress,
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Give this check to the recipient',
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 30),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(20),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.red, width: 3),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'REDEEM',
                              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text('Private Key (WIF)', style: const pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(height: 15),
                            if (redemptionQr != null)
                              pw.Image(
                                pw.MemoryImage(redemptionQr.buffer.asUint8List()),
                                width: 200,
                                height: 200,
                              ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              _keypair!.privateKeyWIF,
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Recipient needs this key to redeem',
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.red),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.orange, width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SECURITY WARNINGS',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '• Anyone with the private key can spend these funds',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '• Store this check in a secure location',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '• Do not share the private key except with the intended recipient',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Transaction ID: $_txid',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailModal(
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 750),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadiusSmall,
          border: Border.all(color: theme.colors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - matches Qt dialog title bar pattern
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
                  SailText.primary20('Write a Check'),
                  SailTappable(
                    onTap: () async => Navigator.of(context).pop(),
                    borderRadius: SailStyleValues.borderRadiusSmall,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: SailSVG.fromAsset(SailSVGAsset.x, color: theme.colors.text),
                    ),
                  ),
                ],
              ),
            ),

            // Content - Qt QVBoxLayout equivalent
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colors.actionHeader,
                        borderRadius: SailStyleValues.borderRadiusSmall,
                        border: Border.all(color: theme.colors.primary),
                      ),
                      child: Row(
                        children: [
                          SailSVG.fromAsset(SailSVGAsset.info, width: 20, color: theme.colors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SailText.secondary12(
                              'A paper check sends Bitcoin to a new address, then displays both '
                              'the address and private key. The recipient can import the private '
                              'key to redeem the funds.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount input (if not yet funded)
                    if (_txid == null) ...[
                      SailText.primary13('Check Amount (BTC):'),
                      const SizedBox(height: 8),
                      SailTextField(
                        controller: _amountController,
                        hintText: '0.001',
                        textFieldType: TextFieldType.bitcoin,
                        monospace: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SailSVG.fromAsset(SailSVGAsset.landmark, color: theme.colors.primary),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Error display
                    if (_error != null) ...[
                      SailAlert(
                        variant: SailAlertVariant.destructive,
                        icon: SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 20, color: theme.colors.error),
                        description: _error!,
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (_isGenerating || _keypair == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            children: [
                              SailCircularProgressIndicator(color: theme.colors.primary),
                              const SizedBox(height: 16),
                              SailText.secondary13('Generating check address...'),
                            ],
                          ),
                        ),
                      )
                    else
                      // Check Content
                      Column(
                        children: [
                          // Success banner (if funded)
                          if (_txid != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colors.success.withValues(alpha: 0.1),
                                borderRadius: SailStyleValues.borderRadiusSmall,
                                border: Border.all(color: theme.colors.success),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SailSVG.fromAsset(
                                        SailSVGAsset.circleCheck,
                                        width: 24,
                                        color: theme.colors.success,
                                      ),
                                      const SizedBox(width: 12),
                                      SailText.primary15('Check Created Successfully!', bold: true),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SailText.secondary12('Transaction ID:'),
                                  const SizedBox(height: 4),
                                  SailSelectableText(
                                    _txid!,
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexMono',
                                      fontSize: 11,
                                      color: theme.colors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SailButton(
                                    label: 'Copy TX ID',
                                    variant: ButtonVariant.secondary,
                                    onPressed: () async => _copyToClipboard(_txid!, 'Transaction ID'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Amount display
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colors.background,
                                borderRadius: SailStyleValues.borderRadiusSmall,
                                border: Border.all(color: theme.colors.border),
                              ),
                              child: Row(
                                children: [
                                  SailSVG.fromAsset(SailSVGAsset.wallet, width: 32, color: theme.colors.primary),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SailText.secondary12('Check Amount'),
                                      const SizedBox(height: 4),
                                      SailText.primary20('${_amountController.text} BTC', bold: true),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Two-panel layout (matches Paper Wallet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Recipient Address
                              Expanded(
                                child: _RecipientPanel(
                                  keypair: _keypair!,
                                  txid: _txid,
                                  onCopy: () => _copyToClipboard(_keypair!.publicAddress, 'Address'),
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Right: Redemption Key
                              Expanded(
                                child: _RedemptionPanel(
                                  keypair: _keypair!,
                                  showPrivateKey: _showPrivateKey,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _showPrivateKey = !_showPrivateKey;
                                    });
                                  },
                                  onCopy: () => _copyToClipboard(_keypair!.privateKeyWIF, 'Private key'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colors.border),
                ),
              ),
              child: _txid == null
                  // Before funding: Show Generate New and Create Check
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailButton(
                          label: 'Generate New Address',
                          variant: ButtonVariant.secondary,
                          onPressed: () async => _generateKeypair(),
                          loading: _isGenerating,
                          disabled: _isSending,
                        ),
                        Row(
                          children: [
                            SailButton(
                              label: 'Create Check',
                              onPressed: () async => _createCheck(),
                              loading: _isSending,
                              disabled: _isGenerating || _keypair == null,
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
                    )
                  // After funding: Show Create Another and Print
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailButton(
                          label: 'Create Another',
                          variant: ButtonVariant.secondary,
                          onPressed: () async {
                            _amountController.clear();
                            await _generateKeypair();
                          },
                        ),
                        Row(
                          children: [
                            SailButton(
                              label: 'Print',
                              onPressed: () async => _printPaperCheck(),
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
}

/// Widget for displaying the recipient address panel
class _RecipientPanel extends StatelessWidget {
  final PaperWalletKeypair keypair;
  final String? txid;
  final VoidCallback onCopy;

  const _RecipientPanel({
    required this.keypair,
    required this.txid,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: theme.colors.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailSVG.fromAsset(SailSVGAsset.qrCode, width: 24, color: theme.colors.primary),
              const SizedBox(width: 8),
              SailText.primary15('RECIPIENT', bold: true),
            ],
          ),
          const SizedBox(height: 8),
          SailText.secondary12(
            'Bitcoin Address',
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
              data: keypair.publicAddress,
              version: QrVersions.auto,
              size: 180,
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
          SailSelectableText(
            keypair.publicAddress,
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
            onPressed: () async => onCopy(),
          ),
          const SizedBox(height: 16),

          // Instructions
          SailText.secondary12(
            txid != null ? 'Give this check to the recipient' : 'Address where check will be sent',
            textAlign: TextAlign.center,
            color: theme.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying the redemption key panel
class _RedemptionPanel extends StatelessWidget {
  final PaperWalletKeypair keypair;
  final bool showPrivateKey;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;

  const _RedemptionPanel({
    required this.keypair,
    required this.showPrivateKey,
    required this.onToggleVisibility,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

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
              SailSVG.fromAsset(SailSVGAsset.key, width: 24, color: theme.colors.error),
              const SizedBox(width: 8),
              SailText.primary15('REDEEM', bold: true),
              const Spacer(),
              SailTooltip(
                message: showPrivateKey ? 'Hide private key' : 'Show private key',
                child: SailTappable(
                  onTap: () async => onToggleVisibility(),
                  borderRadius: SailStyleValues.borderRadiusSmall,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SailSVG.fromAsset(
                      showPrivateKey ? SailSVGAsset.eyeOff : SailSVGAsset.eye,
                      width: 20,
                      color: theme.colors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SailText.secondary12(
            'Private Key (WIF)',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          if (showPrivateKey) ...[
            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.backgroundSecondary,
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: QrImageView(
                data: keypair.privateKeyWIF,
                version: QrVersions.auto,
                size: 180,
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
            SailSelectableText(
              keypair.privateKeyWIF,
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
              onPressed: () async => onCopy(),
            ),
          ] else
            Column(
              children: [
                const SizedBox(height: 40),
                SailSVG.fromAsset(SailSVGAsset.eyeOff, width: 80, color: theme.colors.textTertiary),
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
          SailAlert(
            variant: SailAlertVariant.destructive,
            description: 'Recipient needs this private key to redeem the check',
          ),
        ],
      ),
    );
  }
}
