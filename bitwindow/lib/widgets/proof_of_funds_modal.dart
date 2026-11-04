import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class ProofOfFundsModal extends StatelessWidget {
  const ProofOfFundsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
      child: SailCard(
        title: 'Proof of Funds',
        subtitle: 'Generate or verify cryptographically signed reports proving ownership of UTXOs',
        child: SingleChildScrollView(
          child: SizedBox(
            height: 600,
            child: InlineTabBar(
              tabs: const [
                TabItem(
                  label: 'Generate Report',
                  icon: SailSVGAsset.iconPen,
                  child: GenerateReportTab(),
                ),
                TabItem(
                  label: 'Verify Report',
                  icon: SailSVGAsset.iconCheck,
                  child: VerifyReportTab(),
                ),
              ],
              initialIndex: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class GenerateReportTab extends StatefulWidget {
  const GenerateReportTab({super.key});

  @override
  State<GenerateReportTab> createState() => _GenerateReportTabState();
}

class _GenerateReportTabState extends State<GenerateReportTab> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _filePathController = TextEditingController();
  bool _useRandomMessage = true;
  bool _isGenerating = false;
  String? _error;
  String? _success;
  double _progress = 0.0;
  String _progressText = '';

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        // Update character count
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _filePathController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    final directory = await FilePicker.getDirectoryPath(
      dialogTitle: 'Save Proof of Funds Report',
    );

    if (directory != null) {
      final fileName = 'proof_of_funds_${DateTime.now().millisecondsSinceEpoch}.csv';
      setState(() {
        _filePathController.text = '$directory${Platform.pathSeparator}$fileName';
      });
    }
  }

  Future<void> _generateReport() async {
    if (_filePathController.text.isEmpty) {
      setState(() {
        _error = 'Please select a file location';
      });
      return;
    }

    // Validate message length
    final message = _useRandomMessage ? _generateRandomHex() : _messageController.text;
    if (message.length > 1000) {
      setState(() {
        _error = 'Message must be less than 1000 characters';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _success = null;
      _progress = 0.0;
      _progressText = 'Starting proof generation...';
    });

    try {
      final viewModel = ProofOfFundsViewModel();
      await viewModel.generateProofOfFunds(
        _filePathController.text,
        message,
        _useRandomMessage,
        onProgress: (progress, text) {
          setState(() {
            _progress = progress;
            _progressText = text;
          });
        },
      );

      setState(() {
        _success = 'Proof of funds report generated successfully at ${_filePathController.text}';
        _progress = 1.0;
        _progressText = 'Complete!';
      });
    } catch (e) {
      setState(() {
        _error = 'Error generating report: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  String _generateRandomHex() {
    final random = Random.secure();
    const chars = '0123456789ABCDEF';
    return List.generate(16, (index) => chars[random.nextInt(16)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        child: SailColumn(
          spacing: SailStyleValues.padding20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailColumn(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary15('Message Configuration', bold: true),
                SailCard(
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    children: [
                      Row(
                        children: [
                          SailSwitch(
                            value: _useRandomMessage,
                            onChanged: (value) {
                              setState(() {
                                _useRandomMessage = value;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailText.primary13('Use random message'),
                                const SizedBox(height: 4),
                                SailText.secondary12(
                                  'Generates a secure 16-character hex string for signing',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!_useRandomMessage) ...[
                        SailTextField(
                          controller: _messageController,
                          label: 'Custom Message',
                          hintText: 'Enter your message to sign with each UTXO (max 1000 chars)',
                          maxLines: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SailText.secondary12(
                              '${_messageController.text.length}/1000',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SailColumn(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary15('Output Configuration', bold: true),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: SailTextField(
                        controller: _filePathController,
                        label: 'Output File Location',
                        hintText: 'Choose where to save the proof of funds report',
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: SailButton(
                        onPressed: _selectFile,
                        label: 'Browse',
                        icon: SailSVGAsset.iconSearch,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isGenerating) ...[
              SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary15('Progress', bold: true),
                  SailCard(
                    child: SailColumn(
                      spacing: SailStyleValues.padding12,
                      children: [
                        ProgressBar(
                          current: _progress,
                          goal: 1.0,
                          justPercent: true,
                        ),
                        SailText.secondary12(_progressText),
                        SailText.secondary12('${(_progress * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            Center(
              child: SailButton(
                onPressed: _isGenerating ? null : _generateReport,
                label: 'Generate Proof of Funds Report',
                loadingLabel: 'Generating report',
                icon: SailSVGAsset.iconPen,
                loading: _isGenerating,
              ),
            ),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 20, color: theme.colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SailText.primary13(
                        _error!,
                        color: theme.colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_success != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.circleCheck, width: 20, color: theme.colors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SailText.primary13(
                        _success!,
                        color: theme.colors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VerifyReportTab extends StatefulWidget {
  const VerifyReportTab({super.key});

  @override
  State<VerifyReportTab> createState() => _VerifyReportTabState();
}

class _VerifyReportTabState extends State<VerifyReportTab> {
  final TextEditingController _filePathController = TextEditingController();
  bool _isVerifying = false;
  String? _error;
  VerificationResult? _result;
  double _progress = 0.0;
  String _progressText = '';

  @override
  void dispose() {
    _filePathController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.pickFile(
      dialogTitle: 'Select Proof of Funds Report',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    final path = result?.path;
    if (path != null) {
      setState(() {
        _filePathController.text = path;
      });
    }
  }

  Future<void> _verifyReport() async {
    if (_filePathController.text.isEmpty) {
      setState(() {
        _error = 'Please select a file to verify';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
      _result = null;
      _progress = 0.0;
      _progressText = 'Starting verification...';
    });

    try {
      final viewModel = ProofOfFundsViewModel();
      final result = await viewModel.verifyProofOfFunds(
        _filePathController.text,
        onProgress: (progress, text) {
          setState(() {
            _progress = progress;
            _progressText = text;
          });
        },
      );

      setState(() {
        _result = result;
        _progress = 1.0;
        _progressText = 'Verification complete!';
      });
    } catch (e) {
      setState(() {
        _error = 'Error verifying report: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding16),
          child: SailColumn(
            spacing: SailStyleValues.padding20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary15('Input Configuration', bold: true),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SailTextField(
                          controller: _filePathController,
                          label: 'Input File',
                          hintText: 'Select CSV file to verify signatures',
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: SailButton(
                          onPressed: _selectFile,
                          label: 'Browse',
                          icon: SailSVGAsset.iconSearch,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_isVerifying) ...[
                SailColumn(
                  spacing: SailStyleValues.padding12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary15('Progress', bold: true),
                    SailCard(
                      child: SailColumn(
                        spacing: SailStyleValues.padding12,
                        children: [
                          ProgressBar(
                            current: _progress,
                            goal: 1.0,
                            justPercent: true,
                          ),
                          SailText.secondary12(_progressText),
                          SailText.secondary12('${(_progress * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              Center(
                child: SailButton(
                  onPressed: _isVerifying ? null : _verifyReport,
                  label: 'Verify Proof of Funds Report',
                  loadingLabel: 'Verifying Signatures',
                  icon: SailSVGAsset.iconCheck,
                  loading: _isVerifying,
                ),
              ),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 20, color: theme.colors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SailText.primary13(
                          _error!,
                          color: theme.colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_result != null) ...[
                Builder(
                  builder: (context) {
                    final result = _result!;
                    final isValid = result.validCount == result.totalCount;
                    final color = isValid ? theme.colors.success : theme.colors.error;

                    return SailColumn(
                      spacing: SailStyleValues.padding16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary15('Verification Results', bold: true),
                        SailCard(
                          child: SailColumn(
                            spacing: SailStyleValues.padding20,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SailSVG.fromAsset(
                                    isValid ? SailSVGAsset.badgeCheck : SailSVGAsset.triangleAlert,
                                    width: 28,
                                    color: color,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SailText.primary15(
                                        isValid ? 'All Signatures Valid' : 'Some Signatures Failed',
                                        bold: true,
                                        color: color,
                                      ),
                                      SailText.secondary13(
                                        '${result.validCount} of ${result.totalCount} signatures verified successfully',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      label: 'Valid Signatures',
                                      value: '${result.validCount}',
                                      color: theme.colors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatCard(
                                      label: 'Total BTC',
                                      value: formatter
                                          .formatBTC(result.totalBTC)
                                          .replaceAll(' ${formatter.currentUnit.symbol}', ''),
                                      color: theme.colors.primary,
                                    ),
                                  ),
                                  if (result.failedCount > 0) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Failed',
                                        value: '${result.failedCount}',
                                        color: theme.colors.error,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (result.details.isNotEmpty) ...[
                          SailText.primary15('Transaction Details', bold: true),
                          SailCard(
                            child: SizedBox(
                              height: 240,
                              child: SailColumn(
                                spacing: SailStyleValues.padding08,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SailText.secondary12('Address', bold: true),
                                      const Spacer(),
                                      SailText.secondary12('Amount (BTC)', bold: true),
                                      const SizedBox(width: 60),
                                      SailText.secondary12('Status', bold: true),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: result.details.length,
                                      itemBuilder: (context, index) {
                                        final detail = result.details[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: SailText.primary12(
                                                  '${detail.address.substring(0, 12)}...${detail.address.substring(detail.address.length - 6)}',
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: SailText.primary12(
                                                  formatter
                                                      .formatBTC(detail.amount)
                                                      .replaceAll(' ${formatter.currentUnit.symbol}', ''),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 60,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    SailSVG.fromAsset(
                                                      detail.isValid ? SailSVGAsset.circleCheck : SailSVGAsset.circleX,
                                                      width: 16,
                                                      color: detail.isValid ? theme.colors.success : theme.colors.error,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    SailText.secondary12(
                                                      detail.isValid ? 'Valid' : 'Invalid',
                                                      color: detail.isValid ? theme.colors.success : theme.colors.error,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SailText.primary20(value, bold: true, color: color),
          const SizedBox(height: 4),
          SailText.secondary12(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Orchestrator migration status: COMPLETE
/// - listUnspent: via orchestratorWallet (orchestrator)
/// - signMessage: via bitwindowd (bitwindowd)
class ProofOfFundsViewModel extends BaseViewModel {
  final Logger log = GetIt.I.get<Logger>();
  final EnforcerRPC enforcer = GetIt.I.get<EnforcerRPC>();
  final BitwindowRPC bitwindowd = GetIt.I.get<BitwindowRPC>();
  OrchestratorWalletRPC get orchestratorWallet => GetIt.I.get<OrchestratorRPC>().wallet;
  final BitcoindConnection mainchain = GetIt.I.get<BitcoindConnection>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  Future<void> generateProofOfFunds(
    String filename,
    String message,
    bool useRandom, {
    Function(double, String)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1, 'Retrieving wallet UTXOs...');
      final utxos = await _getUnspentOutputs();

      onProgress?.call(0.2, 'Preparing message for signing...');
      final messageToSign = useRandom ? _generateRandomHex() : message;

      onProgress?.call(0.3, 'Creating signed CSV report...');
      await _createSignedCSV(filename, utxos, messageToSign, onProgress);

      log.i('Proof of funds generated successfully');
    } catch (e) {
      log.e('Error generating proof of funds: $e');
      rethrow;
    }
  }

  Future<List<UTXO>> _getUnspentOutputs() async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      throw Exception('No active wallet');
    }

    final response = await orchestratorWallet.listUnspent(walletId);
    final unspents = response.utxos;
    log.i('Retrieved ${unspents.length} UTXOs from orchestrator wallet');

    final filteredUtxos = unspents.where((utxo) => utxo.address.isNotEmpty).map((utxo) {
      return UTXO(
        txid: utxo.txid,
        vout: utxo.vout,
        address: utxo.address,
        amount: satoshiToBTC(utxo.amountSats.toInt()),
      );
    }).toList();

    return filteredUtxos;
  }

  Future<void> _createSignedCSV(
    String filename,
    List<UTXO> utxos,
    String message,
    Function(double, String)? onProgress,
  ) async {
    final file = File(filename);
    final buffer = StringBuffer();

    // Write header
    buffer.writeln('blockchain,txid,address,message,signature,amount,publicKey');
    log.i('Attempting to sign ${utxos.length} UTXOs with message: "$message"');

    int successCount = 0;
    int failCount = 0;

    // Sign and write each UTXO with progress updates and rate limiting
    for (int i = 0; i < utxos.length; i++) {
      final utxo = utxos[i];
      final progress = 0.3 + (0.6 * (i / utxos.length));
      onProgress?.call(progress, 'Signing UTXO ${i + 1} of ${utxos.length}: ${utxo.address.substring(0, 12)}...');

      try {
        log.d('Signing UTXO ${utxo.txid}:${utxo.vout} with address ${utxo.address}');

        final signatureResult = await _signMessageForAddress(utxo.address, message);

        if (signatureResult != null) {
          final csvLine =
              'BTC,${utxo.txid},${utxo.address},$message,${signatureResult.signature},${utxo.amount},${signatureResult.publicKey}';
          buffer.writeln(csvLine);
          log.i('Successfully signed UTXO ${utxo.txid}:${utxo.vout}');
          successCount++;
        } else {
          log.w('Failed to sign UTXO ${utxo.txid}:${utxo.vout} - no signature generated');
          failCount++;
          // Write line without signature
          final csvLine = 'BTC,${utxo.txid},${utxo.address},$message,,${utxo.amount},';
          buffer.writeln(csvLine);
        }

        // Rate limiting: small delay between UTXOs to prevent wallet lockup
        if (i < utxos.length - 1) {
          await Future.delayed(Duration(milliseconds: 100));
        }
      } catch (e) {
        log.e('Error signing for address ${utxo.address}: $e');
        failCount++;

        // Write line without signature for debugging
        final csvLine = 'BTC,${utxo.txid},${utxo.address},$message,,${utxo.amount},';
        buffer.writeln(csvLine);
      }
    }

    onProgress?.call(0.9, 'Writing CSV file...');
    await file.writeAsString(buffer.toString());

    onProgress?.call(1.0, 'Complete!');
    log.i('Wrote CSV file with ${buffer.toString().split('\n').length - 2} UTXO entries to $filename');
    log.i('Successfully signed: $successCount, Failed: $failCount');
  }

  Future<SignatureResult?> _signMessageForAddress(String address, String message) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) {
      throw Exception('No active wallet');
    }
    try {
      final signed = await bitwindowd.wallet.signMessage(walletId, message, address);
      return SignatureResult(signature: signed.signature, publicKey: signed.publicKey);
    } catch (e) {
      log.e('Error signing message for address $address: $e');
      return null;
    }
  }

  Future<VerificationResult> verifyProofOfFunds(
    String filename, {
    Function(double, String)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1, 'Reading file...');
      final file = File(filename);

      if (!await file.exists()) {
        throw Exception('File does not exist: $filename');
      }

      final lines = await file.readAsLines();
      if (lines.isEmpty) {
        throw Exception('File is empty');
      }

      onProgress?.call(0.2, 'Parsing CSV data...');
      final startIndex = 1; // Skip header row only
      int validCount = 0;
      int totalCount = 0;
      double totalBTC = 0;
      final details = <VerificationDetail>[];

      final totalLines = lines.length - startIndex;

      for (int i = startIndex; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) {
          continue;
        }

        final progress = 0.2 + (0.7 * ((i - startIndex) / totalLines));
        onProgress?.call(progress, 'Verifying signature ${i - startIndex + 1} of $totalLines...');

        final fields = _parseCSVLine(lines[i]);
        if (fields.length < 7) {
          continue;
        }

        final address = fields[2];
        final message = fields[3];
        final signature = fields[4];
        final amount = double.tryParse(fields[5]) ?? 0;
        final publicKey = fields[6];

        totalCount++;
        bool isValid = false;

        if (signature.isEmpty || publicKey.isEmpty) {
          isValid = false;
        } else {
          try {
            isValid = await _verifyBitcoinSignature(message, signature, publicKey, address);

            if (isValid) {
              validCount++;
              totalBTC += amount;
              log.d('Valid signature for address $address');
            } else {
              log.w('Invalid signature for address $address');
            }
          } catch (e) {
            log.e('Error verifying signature for address $address: $e');
            isValid = false;
          }
        }

        details.add(
          VerificationDetail(
            address: address,
            amount: amount,
            isValid: isValid,
          ),
        );
      }

      onProgress?.call(1.0, 'Verification complete!');
      log.i('Verification complete: $validCount/$totalCount valid signatures');

      return VerificationResult(
        totalCount: totalCount,
        validCount: validCount,
        failedCount: totalCount - validCount,
        totalBTC: totalBTC,
        details: details,
      );
    } catch (e) {
      log.e('Error verifying proof of funds: $e');
      rethrow;
    }
  }

  /// Checks that the public key owns the address, then that it signed the
  /// message in the Bitcoin signed message format.
  Future<bool> _verifyBitcoinSignature(
    String message,
    String signatureBase64,
    String publicKeyHex,
    String address,
  ) async {
    try {
      return await GetIt.I.get<BitwindowRPC>().wallet.verifyMessage(
        _walletReader.activeWalletId ?? '',
        message,
        signatureBase64,
        address,
        signerPublicKey: publicKeyHex,
      );
    } catch (e) {
      log.e('Error in signature verification: $e');
      return false;
    }
  }

  List<String> _parseCSVLine(String line) {
    return line.split(',').map((field) => field.trim()).toList();
  }

  String _generateRandomHex() {
    final random = Random.secure();
    const chars = '0123456789ABCDEF';
    return List.generate(16, (index) => chars[random.nextInt(16)]).join();
  }
}

class UTXO {
  final String txid;
  final int vout;
  final String address;
  final double amount;
  String? publicKey;
  String? signature;

  UTXO({
    required this.txid,
    required this.vout,
    required this.address,
    required this.amount,
    this.publicKey,
    this.signature,
  });
}

class SignatureResult {
  final String signature;
  final String publicKey;

  SignatureResult({
    required this.signature,
    required this.publicKey,
  });
}

class VerificationResult {
  final int totalCount;
  final int validCount;
  final int failedCount;
  final double totalBTC;
  final List<VerificationDetail> details;

  VerificationResult({
    required this.totalCount,
    required this.validCount,
    required this.failedCount,
    required this.totalBTC,
    required this.details,
  });
}

class VerificationDetail {
  final String address;
  final double amount;
  final bool isValid;

  VerificationDetail({
    required this.address,
    required this.amount,
    required this.isValid,
  });
}
