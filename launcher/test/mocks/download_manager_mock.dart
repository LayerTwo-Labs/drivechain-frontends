import 'dart:async';
import 'dart:io';

import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/binary_provider.dart';

class MockDownloadProvider extends BinaryProvider {
  final _statusController = StreamController<void>.broadcast();

  MockDownloadProvider() : super(appDir: Directory(''), initialBinaries: []);

  @override
  Future<bool> downloadBinary(Binary binary) async {
    // Simulate a successful download
    _statusController.add(null);
    return true;
  }
}
