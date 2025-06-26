import 'dart:ui';

import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/style/color_scheme.dart';
import 'package:sail_ui/utils/file_utils.dart';

class MockBinary extends Binary {
  MockBinary()
      : super(
          name: 'Mocktown',
          version: '0.0.0',
          description: 'Mock Binary',
          repoUrl: 'https://mock.test',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.mock',
              OS.macos: 'Mock',
              OS.windows: 'Mock',
            },
          ),
          metadata: MetadataConfig(
            baseUrl: '',
            files: {
              OS.linux: 'mock',
              OS.macos: 'mock',
              OS.windows: 'mock',
            },
            remoteTimestamp: null,
            downloadedTimestamp: null,
            binaryPath: null,
            updateable: false,
          ),
          binary: 'mock',
          port: 8272,
          chainLayer: 0,
        );

  @override
  Color get color => SailColorScheme.orange;

  @override
  Binary copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    DownloadInfo? downloadInfo,
  }) {
    return MockBinary();
  }
}
