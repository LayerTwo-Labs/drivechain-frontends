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
          download: DownloadConfig(
            baseUrl: '',
            files: {
              OS.linux: 'mock',
              OS.macos: 'mock',
              OS.windows: 'mock',
            },
          ),
          binary: 'mock',
          network: NetworkConfig(port: 8272),
          chainLayer: 0,
        );

  @override
  Color get color => SailColorScheme.orange;
}
