import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BitDriveTab extends StatelessWidget {
  const BitDriveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<BitDriveViewModel>.reactive(
          viewModelBuilder: () => BitDriveViewModel(),
          builder: (context, model, child) {
            final error = model.error('bitdrive');

            return SailCard(
              title: 'BitDrive',
              subtitle: 'Store and retrieve content in the Bitcoin blockchain',
              error: error,
              child: Column(
                children: [
                  Expanded(
                    child: SailColumn(
                      spacing: SailStyleValues.padding16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input area
                        SailRow(
                          spacing: SailStyleValues.padding16,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: SailColumn(
                                spacing: SailStyleValues.padding08,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SailText.primary13('Content to Store'),
                                  SailText.secondary12(
                                    'Enter text or choose a file (max 1MB)',
                                    color: context.sailTheme.colors.textTertiary,
                                  ),
                                  const SailSpacing(SailStyleValues.padding08),
                                  SailTextField(
                                    controller: model.textController,
                                    maxLines: 3,
                                    hintText: 'Enter text to store...',
                                  ),
                                  SailRow(
                                    spacing: SailStyleValues.padding08,
                                    children: [
                                      SailButton(
                                        label: 'Choose File',
                                        onPressed: () => model.pickFile(context),
                                      ),
                                      if (model.selectedFileName != null)
                                        Expanded(
                                          child: SailText.secondary13(
                                            model.selectedFileName!,
                                          ),
                                        ),
                                      if (model.selectedFileName != null)
                                        SailButton(
                                          variant: ButtonVariant.icon,
                                          icon: SailSVGAsset.iconClose,
                                          onPressed: model.clearSelectedFile,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Right side controls
                            Expanded(
                              flex: 1,
                              child: SailColumn(
                                spacing: SailStyleValues.padding16,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SailText.primary13('Settings'),
                                  SailRow(
                                    spacing: SailStyleValues.padding08,
                                    children: [
                                      Expanded(
                                        child: NumericField(
                                          label: 'Fee (BTC)',
                                          controller: model.feeController,
                                          hintText: '0.0001',
                                        ),
                                      ),
                                      SailButton(
                                        variant: ButtonVariant.icon,
                                        icon: SailSVGAsset.iconArrow,
                                        onPressed: () async {
                                          model.adjustFee(0.0001);
                                        },
                                      ),
                                      SailButton(
                                        variant: ButtonVariant.icon,
                                        icon: SailSVGAsset.iconArrow,
                                        onPressed: () async {
                                          model.adjustFee(-0.0001);
                                        },
                                      ),
                                    ],
                                  ),
                                  SailCheckbox(
                                    value: model.shouldEncrypt,
                                    onChanged: model.onEncryptChanged,
                                    label: 'Encrypt',
                                  ),
                                  const SailSpacing(SailStyleValues.padding16),
                                  SailButton(
                                    label: 'Store',
                                    onPressed: model.canStore ? () => model.store(context) : null,
                                    variant: model.canStore ? ButtonVariant.primary : ButtonVariant.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bottom section with restore button
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.sailTheme.colors.border,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SailButton(
                              label: 'Open BitDrive',
                              onPressed: model._bitdriveDir != null ? () => model.openBitdriveDir() : null,
                              variant: ButtonVariant.secondary,
                            ),
                            Row(
                              children: [
                                SailButton(
                                  label: 'Scan',
                                  onPressed: model.isScanning ? null : () => model.scanFiles(),
                                  variant: model.pendingDownloadsCount > 0 || model.isDownloading
                                      ? ButtonVariant.secondary
                                      : ButtonVariant.primary,
                                  loading: model.isScanning,
                                ),
                                const SizedBox(width: 8),
                                SailButton(
                                  label: 'Download',
                                  onPressed: (model.pendingDownloadsCount > 0 && !model.isDownloading)
                                      ? () => model.downloadFiles()
                                      : null,
                                  variant: model.pendingDownloadsCount > 0 && !model.isDownloading
                                      ? ButtonVariant.primary
                                      : ButtonVariant.secondary,
                                  loading: model.isDownloading,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Fixed height container for status messages
                        Container(
                          height: 32, // Fixed height to prevent layout shifts
                          padding: const EdgeInsets.only(top: 8.0),
                          alignment: Alignment.centerLeft,
                          child: model.isScanning
                              ? SailText.primary13(
                                  'Scanning for BitDrive files...',
                                  color: context.sailTheme.colors.text,
                                )
                              : model.pendingDownloadsCount > 0
                                  ? SailText.primary13(
                                      '${model.pendingDownloadsCount} new files available for download',
                                      color: context.sailTheme.colors.text,
                                    )
                                  : model.isDownloading
                                      ? SailText.primary13(
                                          'Downloading files...',
                                          color: context.sailTheme.colors.text,
                                        )
                                      : null, // No message, but space is still reserved
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class BitDriveViewModel extends BaseViewModel {
  final BitDriveProvider provider = GetIt.I.get<BitDriveProvider>();
  final TextEditingController textController = TextEditingController();
  final TextEditingController feeController = TextEditingController(text: '0.0001');
  Logger get log => GetIt.I.get<Logger>();
  String? selectedFileName;
  Uint8List? selectedFileContent;
  bool get shouldEncrypt => provider.shouldEncrypt;
  bool get canStore => textController.text.isNotEmpty || selectedFileContent != null;
  String? _bitdriveDir;

  // Add getters for the scan and download functionality
  bool get isScanning => provider.isScanning;
  bool get isDownloading => provider.isDownloading;
  int get pendingDownloadsCount => provider.pendingDownloadsCount;

  BitDriveViewModel() {
    provider.addListener(_onProviderChanged);
    textController.addListener(() => onTextChanged(textController.text));
    _initBitdriveDir();
  }

  void _onProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    provider.removeListener(_onProviderChanged);
    textController.dispose();
    feeController.dispose();
    super.dispose();
  }

  // Implement scan and download methods
  Future<void> scanFiles() async {
    notifyListeners();
    await provider.scanForFiles();
    notifyListeners();
  }

  Future<void> downloadFiles() async {
    notifyListeners();
    await provider.downloadPendingFiles();
    notifyListeners();
  }

  Future<void> _initBitdriveDir() async {
    final appDir = await Environment.datadir();
    _bitdriveDir = path.join(appDir.path, 'bitdrive');
    notifyListeners();
  }

  Future<void> openBitdriveDir() async {
    if (_bitdriveDir == null) return;
    try {
      final dir = Directory(_bitdriveDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (Platform.isMacOS) {
        await Process.run('open', [_bitdriveDir!]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [_bitdriveDir!]);
      } else if (Platform.isWindows) {
        // On Windows, we need to convert path to use backslashes and properly escape them
        final windowsPath = _bitdriveDir!.replaceAll('/', '\\');
        await Process.run('explorer', [windowsPath]);
      }
    } catch (e) {
      log.e('Error opening BitDrive directory: $e');
    }
  }

  void adjustFee(double amount) {
    try {
      final currentFee = double.parse(feeController.text);
      final newFee = (currentFee + amount).clamp(0.0001, 1.0);
      final formattedFee = newFee.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      feeController.text = formattedFee;
      provider.setFee(newFee);
      notifyListeners();
    } catch (e) {
      feeController.text = '0.0001';
      provider.setFee(0.0001);
    }
  }

  void onTextChanged(String value) {
    provider.setTextContent(value);
    // Clear any selected file when text is entered
    if (value.isNotEmpty) {
      selectedFileName = null;
      selectedFileContent = null;
    }
    notifyListeners();
  }

  void onEncryptChanged(bool? value) {
    if (value != null) {
      provider.setEncryption(value);
      notifyListeners();
    }
  }

  Future<void> clearSelectedFile() async {
    selectedFileName = null;
    selectedFileContent = null;
    notifyListeners();
  }

  Future<void> pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 1024 * 1024) {
          if (context.mounted) {
            showSnackBar(context, 'File size must be less than 1MB');
          }
          return;
        }

        Uint8List? fileContents;
        if (file.bytes != null) {
          fileContents = file.bytes!;
        } else if (file.path != null) {
          try {
            fileContents = await File(file.path!).readAsBytes();
          } catch (e) {
            Logger().e('Error reading file: $e');
            if (context.mounted) {
              showSnackBar(context, 'Error reading file: $e');
            }
            return;
          }
        }

        if (fileContents != null) {
          selectedFileContent = fileContents;
          selectedFileName = file.name;
          textController.clear();
          await provider.setFileContent(
            fileContents,
            name: file.name,
            type: file.extension != null ? 'application/${file.extension}' : 'application/octet-stream',
          );
          notifyListeners();
        } else {
          if (context.mounted) {
            showSnackBar(context, 'Could not read file contents');
          }
        }
      }
    } catch (e) {
      Logger().e('Error picking file: $e');
      if (context.mounted) {
        showSnackBar(context, 'Error picking file: $e');
      }
    }
  }

  Future<void> store(BuildContext context) async {
    setBusy(true);
    try {
      await provider.store();
      if (context.mounted) {
        showSnackBar(context, 'Content stored successfully');
        textController.clear();
        selectedFileName = null;
        selectedFileContent = null;
      }
    } catch (e) {
      setError(e.toString());
      if (context.mounted) {
        showSnackBar(context, 'Failed to store content: $e');
      }
    } finally {
      setBusy(false);
    }
  }
}
