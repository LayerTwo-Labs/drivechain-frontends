import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class VerifyTimestampViewModel extends BaseViewModel {
  final TimestampProvider _timestampProvider = GetIt.I.get<TimestampProvider>();

  String? selectedFilename;
  bool isVerifying = false;
  VerifyTimestampResponse? verificationResult;
  @override
  String? modelError;

  Future<void> pickAndVerifyFile() async {
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

        selectedFilename = result.files.single.name;
        isVerifying = true;
        verificationResult = null;
        modelError = null;
        notifyListeners();

        final bytes = await file.readAsBytes();
        final verifyResult = await _timestampProvider.verifyFile(bytes, selectedFilename!);

        if (verifyResult != null) {
          verificationResult = verifyResult;
        } else {
          modelError = _timestampProvider.modelError ?? 'File not found in timestamps';
        }

        isVerifying = false;
        notifyListeners();
      }
    } catch (e) {
      modelError = 'Error: $e';
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
    return ViewModelBuilder<VerifyTimestampViewModel>.reactive(
      viewModelBuilder: () => VerifyTimestampViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: SailTheme.of(context).colors.background,
          appBar: AppBar(
            backgroundColor: SailTheme.of(context).colors.background,
            foregroundColor: SailTheme.of(context).colors.text,
            title: SailText.primary20('Verify a Timestamp'),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: SailStyleValues.padding20,
                    children: [
                      SailText.secondary13(
                        'Select a file to check if it has been timestamped on the Bitcoin blockchain.',
                      ),
                      SailButton(
                        label: 'Choose File',
                        loading: model.isVerifying,
                        onPressed: () async => model.pickAndVerifyFile(),
                        icon: SailSVGAsset.iconSearch,
                      ),
                      if (model.verificationResult != null)
                        Container(
                          padding: const EdgeInsets.all(SailStyleValues.padding16),
                          decoration: BoxDecoration(
                            color: context.sailTheme.colors.success.withValues(alpha: 0.1),
                            borderRadius: SailStyleValues.borderRadius,
                            border: Border.all(
                              color: context.sailTheme.colors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
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
                                  Expanded(
                                    child: SailText.primary15(
                                      '${model.verificationResult!.timestamp.filename} was timestamped at ${_formatDate(model.verificationResult!.timestamp.confirmedAt)}',
                                    ),
                                  ),
                                ],
                              ),
                              if (model.verificationResult!.timestamp.hasBlockHeight())
                                TimestampInfoRow(
                                  label: 'Block',
                                  value: model.verificationResult!.timestamp.blockHeight.toString(),
                                ),
                              if (model.verificationResult!.timestamp.hasTxid())
                                TimestampInfoRow(label: 'Transaction', value: model.verificationResult!.timestamp.txid),
                            ],
                          ),
                        ),
                      if (model.modelError != null)
                        Container(
                          padding: const EdgeInsets.all(SailStyleValues.padding12),
                          decoration: BoxDecoration(
                            color: context.sailTheme.colors.error.withValues(alpha: 0.1),
                            borderRadius: SailStyleValues.borderRadiusSmall,
                            border: Border.all(color: context.sailTheme.colors.error),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: SailStyleValues.padding08,
                            children: [
                              if (model.selectedFilename != null) SailText.primary13(model.selectedFilename!),
                              SailText.secondary13(
                                model.modelError!,
                                color: context.sailTheme.colors.error,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
