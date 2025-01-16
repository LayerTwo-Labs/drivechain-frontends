import 'dart:io';

import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/download_provider.dart' as sail;

// Re-export types needed by overview page
export 'package:sail_ui/providers/download_provider.dart' show DownloadProgress, DownloadStatus;

class DownloadProvider extends sail.DownloadProvider {
  DownloadProvider({
    required Directory datadir,
    required List<Binary> configs,
  }) : super(
          datadir: datadir,
          binaries: configs,
        );

  @override
  Stream<Map<String, sail.DownloadProgress>> get statusStream => super.statusStream;

  @override
  Future<bool> downloadBinary(Binary binary) => super.downloadBinary(binary);

  // Initialize is a no-op since the parent class handles initialization in constructor
  Future<void> initialize() async {}
}