import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class VerifyTimestampViewModel extends BaseViewModel {
  final TimestampProvider _timestampProvider = GetIt.I.get<TimestampProvider>();

  File? selectedFile;
  String? selectedFilename;
  int? selectedFileSize;
  bool isVerifying = false;
  VerifyTimestampResponse? verificationResult;
  @override
  String? modelError;

  String get fileSizeFormatted {
    if (selectedFileSize == null) return '';
    final kb = selectedFileSize! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final size = await file.length();

        if (size > maxFileSizeBytes) {
          modelError = 'File too large. Maximum size: 1MB';
          notifyListeners();
          return;
        }

        selectedFile = file;
        selectedFilename = result.files.single.name;
        selectedFileSize = size;
        verificationResult = null;
        modelError = null;
        notifyListeners();
      }
    } catch (e) {
      modelError = 'Failed to pick file: $e';
      notifyListeners();
    }
  }

  Future<void> verifyFile() async {
    if (selectedFile == null) {
      modelError = 'Please select a file first';
      notifyListeners();
      return;
    }

    isVerifying = true;
    modelError = null;
    verificationResult = null;
    notifyListeners();

    try {
      final bytes = await selectedFile!.readAsBytes();
      final result = await _timestampProvider.verifyFile(bytes);

      if (result != null) {
        verificationResult = result;
      } else {
        modelError = _timestampProvider.modelError ?? 'File not found in timestamps';
      }
    } catch (e) {
      modelError = 'Error: $e';
    } finally {
      isVerifying = false;
      notifyListeners();
    }
  }
}

@RoutePage()
class VerifyTimestampPage extends StatelessWidget {
  const VerifyTimestampPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Verify File Timestamp',
      scrollable: true,
      body: ViewModelBuilder<VerifyTimestampViewModel>.reactive(
        viewModelBuilder: () => VerifyTimestampViewModel(),
        builder: (context, model, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SailCard(
                title: 'Verify File',
                error: model.modelError,
                child: Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                  child: SailColumn(
                    spacing: SailStyleValues.padding20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.secondary13(
                        'Select a file to check if it has been timestamped on the Bitcoin blockchain.',
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                      Container(
                        padding: const EdgeInsets.all(SailStyleValues.padding16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.sailTheme.colors.text.withValues(alpha: 0.2),
                          ),
                          borderRadius: SailStyleValues.borderRadius,
                        ),
                        child: SailColumn(
                          spacing: SailStyleValues.padding12,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (model.selectedFile == null)
                              Center(
                                child: SailColumn(
                                  spacing: SailStyleValues.padding12,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SailSVG.icon(
                                      SailSVGAsset.iconSearch,
                                      width: 48,
                                      color: context.sailTheme.colors.text.withValues(alpha: 0.5),
                                    ),
                                    SailText.secondary13('No file selected'),
                                  ],
                                ),
                              )
                            else
                              SailColumn(
                                spacing: SailStyleValues.padding08,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SailSVG.icon(
                                        SailSVGAsset.iconSuccess,
                                        width: 24,
                                      ),
                                      const SizedBox(width: SailStyleValues.padding08),
                                      Expanded(
                                        child: SailText.primary13(
                                          model.selectedFilename ?? 'Unknown',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SailText.secondary12('Size: ${model.fileSizeFormatted}'),
                                ],
                              ),
                            const SizedBox(height: SailStyleValues.padding08),
                            SailButton(
                              label: model.selectedFile == null ? 'Choose File' : 'Change File',
                              variant: ButtonVariant.secondary,
                              onPressed: () async => model.pickFile(),
                              icon: SailSVGAsset.iconSearch,
                            ),
                          ],
                        ),
                      ),
                      if (model.verificationResult != null) ...[
                        const SizedBox(height: SailStyleValues.padding20),
                        Container(
                          padding: const EdgeInsets.all(SailStyleValues.padding16),
                          decoration: BoxDecoration(
                            color: context.sailTheme.colors.success.withValues(alpha: 0.1),
                            borderRadius: SailStyleValues.borderRadius,
                            border: Border.all(
                              color: context.sailTheme.colors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: SailColumn(
                            spacing: SailStyleValues.padding12,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SailSVG.icon(
                                    SailSVGAsset.iconSuccess,
                                    color: context.sailTheme.colors.success,
                                  ),
                                  const SizedBox(width: SailStyleValues.padding08),
                                  SailText.primary15('File Verified!'),
                                ],
                              ),
                              const SizedBox(height: SailStyleValues.padding08),
                              SailText.secondary13(model.verificationResult!.message),
                              const SizedBox(height: SailStyleValues.padding08),
                              TimestampInfoRow(label: 'Filename', value: model.verificationResult!.timestamp.filename),
                              if (model.verificationResult!.timestamp.hasConfirmedAt())
                                TimestampInfoRow(
                                  label: 'Timestamped',
                                  value: _formatDate(model.verificationResult!.timestamp.confirmedAt),
                                ),
                              if (model.verificationResult!.timestamp.hasBlockHeight())
                                TimestampInfoRow(
                                  label: 'Block Height',
                                  value: model.verificationResult!.timestamp.blockHeight.toString(),
                                ),
                              if (model.verificationResult!.timestamp.confirmations > 0)
                                TimestampInfoRow(
                                  label: 'Confirmations',
                                  value: model.verificationResult!.timestamp.confirmations.toString(),
                                ),
                              if (model.verificationResult!.timestamp.hasTxid())
                                TimestampInfoRow(label: 'Transaction', value: model.verificationResult!.timestamp.txid),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: SailStyleValues.padding20),
                      Row(
                        children: [
                          Expanded(
                            child: SailButton(
                              label: 'Close',
                              variant: ButtonVariant.ghost,
                              onPressed: () async => GetIt.I.get<AppRouter>().pop(),
                            ),
                          ),
                          const SizedBox(width: SailStyleValues.padding12),
                          Expanded(
                            flex: 2,
                            child: SailButton(
                              label: 'Verify File',
                              loading: model.isVerifying,
                              disabled: model.selectedFile == null,
                              onPressed: () async => model.verifyFile(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        timestamp.seconds * 1000 + timestamp.nanos ~/ 1000000,
      );
      return DateFormat('MMM d, yyyy HH:mm:ss').format(dt);
    } catch (e) {
      return '-';
    }
  }
}

class TimestampInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const TimestampInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: SailText.secondary12('$label:'),
          ),
          Expanded(
            child: SailText.primary12(value),
          ),
        ],
      ),
    );
  }
}
