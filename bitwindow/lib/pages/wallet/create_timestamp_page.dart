import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class CreateTimestampViewModel extends BaseViewModel {
  final TimestampProvider _timestampProvider = GetIt.I.get<TimestampProvider>();

  File? selectedFile;
  String? selectedFilename;
  int? selectedFileSize;
  bool isCreating = false;
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
        modelError = null;
        notifyListeners();
      }
    } catch (e) {
      modelError = 'Failed to pick file: $e';
      notifyListeners();
    }
  }

  Future<void> timestampFile(BuildContext context) async {
    if (selectedFile == null) {
      modelError = 'Please select a file first';
      notifyListeners();
      return;
    }

    isCreating = true;
    modelError = null;
    notifyListeners();

    try {
      final bytes = await selectedFile!.readAsBytes();
      final timestamp = await _timestampProvider.timestampFile(
        selectedFilename!,
        bytes,
      );

      if (timestamp != null && context.mounted) {
        await GetIt.I.get<AppRouter>().replace(
          TimestampDetailRoute(timestampId: timestamp.id.toInt()),
        );
      } else {
        modelError = _timestampProvider.modelError ?? 'Failed to timestamp file';
      }
    } catch (e) {
      modelError = 'Error: $e';
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }
}

@RoutePage()
class CreateTimestampPage extends StatelessWidget {
  const CreateTimestampPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Timestamp a File',
      body: ViewModelBuilder<CreateTimestampViewModel>.reactive(
        viewModelBuilder: () => CreateTimestampViewModel(),
        builder: (context, model, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SailCard(
                title: 'Select File to Timestamp',
                error: model.modelError,
                child: Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                  child: SailColumn(
                    spacing: SailStyleValues.padding20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.secondary13(
                        'Upload a file (max 1MB) to timestamp on the Bitcoin blockchain. '
                        'This will create a permanent, verifiable proof that the file existed at this time.',
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
                                      SailSVGAsset.iconDownload,
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
                      const SizedBox(height: SailStyleValues.padding20),
                      Row(
                        children: [
                          Expanded(
                            child: SailButton(
                              label: 'Cancel',
                              variant: ButtonVariant.ghost,
                              onPressed: () async => GetIt.I.get<AppRouter>().pop(),
                            ),
                          ),
                          const SizedBox(width: SailStyleValues.padding12),
                          Expanded(
                            flex: 2,
                            child: SailButton(
                              label: 'Timestamp File',
                              loading: model.isCreating,
                              disabled: model.selectedFile == null,
                              onPressed: () async => model.timestampFile(context),
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
}
