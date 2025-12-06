import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BitDriveTab extends StatelessWidget {
  const BitDriveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BitDriveViewModel>.reactive(
      viewModelBuilder: () => BitDriveViewModel(),
      builder: (context, model, child) {
        return InlineTabBar(
          tabs: [
            SingleTabItem(
              label: 'Store',
              child: _StoreTab(model: model),
            ),
            SingleTabItem(
              label: 'My Files',
              child: _MyFilesTab(model: model),
            ),
          ],
          endWidget: model.bitdriveDir != null
              ? SailButton(
                  label: 'Open Folder',
                  variant: ButtonVariant.ghost,
                  icon: SailSVGAsset.folderOpen,
                  onPressed: () async => model.openBitdriveDir(),
                )
              : null,
        );
      },
    );
  }
}

class _StoreTab extends StatelessWidget {
  final BitDriveViewModel model;

  const _StoreTab({required this.model});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailText.primary15(
            'What do you want to store on Bitcoin?',
            bold: true,
          ),
          SailText.secondary12(
            'Your content will be permanently stored on the Bitcoin blockchain. Maximum size: 1 MB.',
          ),
          const SailSpacing(SailStyleValues.padding08),
          SailTextField(
            controller: model.textController,
            maxLines: 6,
            hintText: 'Write anything here...',
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: context.sailTheme.colors.divider,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding16),
                child: SailText.secondary12('OR'),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: context.sailTheme.colors.divider,
                ),
              ),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailButton(
                label: 'Choose File',
                variant: ButtonVariant.secondary,
                icon: SailSVGAsset.upload,
                onPressed: () async => model.pickFile(context),
              ),
              if (model.selectedFileName != null) ...[
                Expanded(
                  child: SailText.primary13(model.selectedFileName!),
                ),
                SailButton(
                  variant: ButtonVariant.ghost,
                  icon: SailSVGAsset.iconClose,
                  onPressed: () async => model.clearSelectedFile(),
                ),
              ] else
                Expanded(
                  child: SailText.secondary12('No file selected'),
                ),
            ],
          ),
          const SailSpacing(SailStyleValues.padding16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => model.toggleAdvancedSettings(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SailRow(
                    spacing: SailStyleValues.padding04,
                    children: [
                      Icon(
                        model.showAdvancedSettings ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                        size: 16,
                        color: context.sailTheme.colors.textSecondary,
                      ),
                      SailText.secondary12('Advanced settings'),
                    ],
                  ),
                ),
              ),
              SailButton(
                label: 'Store on Bitcoin',
                variant: model.canStore ? ButtonVariant.primary : ButtonVariant.secondary,
                disabled: !model.canStore,
                loading: model.isBusy,
                loadingLabel: 'Storing...',
                onPressed: () async => model.store(context),
              ),
            ],
          ),
          if (model.showAdvancedSettings)
            SailCard(
              padding: true,
              secondary: true,
              child: SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailCheckbox(
                    value: model.shouldEncrypt,
                    onChanged: model.onEncryptChanged,
                    label: 'Encrypt content (uses your wallet key)',
                  ),
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SizedBox(
                        width: 150,
                        child: NumericField(
                          label: 'Fee (BTC)',
                          controller: model.feeController,
                          hintText: '0.0001',
                        ),
                      ),
                      SailButton(
                        variant: ButtonVariant.icon,
                        icon: SailSVGAsset.arrowUp,
                        onPressed: () async => model.adjustFee(0.0001),
                      ),
                      SailButton(
                        variant: ButtonVariant.icon,
                        icon: SailSVGAsset.arrowDown,
                        onPressed: () async => model.adjustFee(-0.0001),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MyFilesTab extends StatelessWidget {
  final BitDriveViewModel model;

  const _MyFilesTab({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          spacing: SailStyleValues.padding16,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailColumn(
              spacing: SailStyleValues.padding04,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary15('Your files stored on Bitcoin', bold: true),
                SailText.secondary12(
                  '${model.downloadedFiles.length} files downloaded${model.pendingDownloadsCount > 0 ? ', ${model.pendingDownloadsCount} pending' : ''}',
                ),
              ],
            ),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Scan for new',
                  variant: model.pendingDownloadsCount > 0 ? ButtonVariant.secondary : ButtonVariant.primary,
                  loading: model.isScanning,
                  loadingLabel: 'Scanning...',
                  onPressed: () async => model.scanFiles(),
                ),
                SailButton(
                  label: 'Download all',
                  variant: model.pendingDownloadsCount > 0 ? ButtonVariant.primary : ButtonVariant.secondary,
                  disabled: model.pendingDownloadsCount == 0,
                  loading: model.isDownloading,
                  loadingLabel: 'Downloading...',
                  onPressed: () async => model.downloadFiles(),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: model.downloadedFiles.isEmpty
              ? Center(
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SailSVG.fromAsset(
                        SailSVGAsset.folder,
                        color: context.sailTheme.colors.textTertiary,
                        width: 48,
                      ),
                      SailText.secondary13('No files downloaded yet'),
                      SailText.secondary12(
                        'Click "Scan for new" to find files stored on Bitcoin',
                        color: context.sailTheme.colors.textTertiary,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 300,
                  child: SailTable(
                    getRowId: (index) => model.downloadedFiles[index].path,
                    headerBuilder: (context) => [
                      const SailTableHeaderCell(name: 'Date', alignment: Alignment.centerLeft),
                      const SailTableHeaderCell(name: 'Name', alignment: Alignment.centerLeft),
                      const SailTableHeaderCell(name: 'Size', alignment: Alignment.centerLeft),
                    ],
                    rowBuilder: (context, row, selected) {
                      final file = model.downloadedFiles[row];
                      return [
                        SailTableCell(
                          value: DateFormat('MMM d, yyyy').format(file.date),
                          alignment: Alignment.centerLeft,
                        ),
                        SailTableCell(
                          value: file.name,
                          alignment: Alignment.centerLeft,
                        ),
                        SailTableCell(
                          value: _formatFileSize(file.size),
                          alignment: Alignment.centerLeft,
                        ),
                      ];
                    },
                    rowCount: model.downloadedFiles.length,
                    emptyPlaceholder: 'No files downloaded yet',
                    drawGrid: true,
                  ),
                ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class BitDriveFile {
  final String name;
  final String path;
  final DateTime date;
  final int size;

  BitDriveFile({
    required this.name,
    required this.path,
    required this.date,
    required this.size,
  });
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
  String? get bitdriveDir => _bitdriveDir;

  bool showAdvancedSettings = false;
  List<BitDriveFile> downloadedFiles = [];

  bool get isScanning => provider.isScanning;
  bool get isDownloading => provider.isDownloading;
  int get pendingDownloadsCount => provider.pendingDownloadsCount;

  BitDriveViewModel() {
    provider.addListener(_onProviderChanged);
    textController.addListener(() => onTextChanged(textController.text));
    _initBitdrive();
  }

  Future<void> _initBitdrive() async {
    // Initialize the BitDrive provider when the user opens the BitDrive tab
    // This triggers filesystem access only when needed (see issue #842)
    await provider.init();
    await _initBitdriveDir();
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

  void toggleAdvancedSettings() {
    showAdvancedSettings = !showAdvancedSettings;
    notifyListeners();
  }

  Future<void> scanFiles() async {
    notifyListeners();
    await provider.scanForFiles();
    notifyListeners();
  }

  Future<void> downloadFiles() async {
    notifyListeners();
    await provider.downloadPendingFiles();
    await _loadDownloadedFiles();
    notifyListeners();
  }

  Future<void> _initBitdriveDir() async {
    final appDir = await Environment.datadir();
    _bitdriveDir = path.join(appDir.path, 'bitdrive');
    await _loadDownloadedFiles();
    notifyListeners();
  }

  Future<void> _loadDownloadedFiles() async {
    if (_bitdriveDir == null) return;

    try {
      final dir = Directory(_bitdriveDir!);
      if (!await dir.exists()) {
        downloadedFiles = [];
        return;
      }

      final files = <BitDriveFile>[];
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          files.add(
            BitDriveFile(
              name: path.basename(entity.path),
              path: entity.path,
              date: stat.modified,
              size: stat.size,
            ),
          );
        }
      }

      files.sort((a, b) => b.date.compareTo(a.date));
      downloadedFiles = files;
      notifyListeners();
    } catch (e) {
      log.e('Error loading downloaded files: $e');
    }
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
        showSnackBar(context, 'Content stored on Bitcoin!');
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
