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
    return ViewModelBuilder<CreateTimestampViewModel>.reactive(
      viewModelBuilder: () => CreateTimestampViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: SailTheme.of(context).colors.background,
          appBar: AppBar(
            backgroundColor: SailTheme.of(context).colors.background,
            foregroundColor: SailTheme.of(context).colors.text,
            title: SailText.primary20('Timestamp a File'),
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
                        'Upload a file (max 1MB) to timestamp on the Bitcoin blockchain. '
                        'This will create a permanent, verifiable proof that the file existed at this time.',
                      ),
                      if (model.selectedFile == null)
                        Column(
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
                        )
                      else
                        Column(
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
                      SailButton(
                        label: model.selectedFile == null ? 'Choose File' : 'Change File',
                        variant: ButtonVariant.secondary,
                        onPressed: () async => model.pickFile(),
                        icon: SailSVGAsset.iconSearch,
                      ),
                      if (model.modelError != null)
                        Container(
                          padding: const EdgeInsets.all(SailStyleValues.padding12),
                          decoration: BoxDecoration(
                            color: context.sailTheme.colors.error.withValues(alpha: 0.1),
                            borderRadius: SailStyleValues.borderRadiusSmall,
                            border: Border.all(color: context.sailTheme.colors.error),
                          ),
                          child: SailText.secondary13(
                            model.modelError!,
                            color: context.sailTheme.colors.error,
                          ),
                        ),
                      Row(
                        spacing: SailStyleValues.padding08,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SailButton(
                            label: 'Cancel',
                            variant: ButtonVariant.ghost,
                            onPressed: () async => GetIt.I.get<AppRouter>().pop(),
                          ),
                          SailButton(
                            label: 'Timestamp File',
                            loading: model.isCreating,
                            disabled: model.selectedFile == null,
                            onPressed: () async => model.timestampFile(context),
                          ),
                        ],
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
}
