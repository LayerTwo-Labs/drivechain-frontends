import 'dart:io';

import 'package:bitwindow/pages/wallet/verify_timestamp_page.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';

final class _PickedFile extends PlatformFile {
  _PickedFile(this.file);

  final File file;

  @override
  String get name => file.uri.pathSegments.last;

  @override
  Uri get uri => file.uri;

  @override
  Never get xFile => throw UnimplementedError();

  @override
  int? lengthSync() => file.lengthSync();

  @override
  Future<int?> length() => file.length();

  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  @override
  Stream<Uint8List> readAsByteStream() => throw UnimplementedError();
}

class _Picker extends FilePickerPlatform {
  File? next;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => next == null ? null : _PickedFile(next!);
}

class _MiscAPI extends MockMiscAPI {
  @override
  Future<VerifyTimestampResponse> verifyTimestamp(List<int> fileData, String filename) async {
    if (filename.startsWith('unknown')) {
      throw Exception('no timestamp found for this file');
    }
    return VerifyTimestampResponse(
      timestamp: FileTimestamp(filename: filename, status: 'confirmed'),
    );
  }
}

class _BitwindowRPC extends ChangeNotifier implements BitwindowRPC {
  @override
  final MiscAPI misc = _MiscAPI();

  @override
  bool connected = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SyncProvider extends ChangeNotifier implements SyncProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late _Picker picker;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<BitwindowRPC>(_BitwindowRPC());
    GetIt.I.registerSingleton<SyncProvider>(_SyncProvider());
    GetIt.I.registerSingleton<TimestampProvider>(TimestampProvider());
    picker = _Picker();
    FilePickerPlatform.instance = picker;
    dir = Directory.systemTemp.createTempSync('verify-timestamp-');
  });

  tearDown(() async {
    dir.deleteSync(recursive: true);
    await GetIt.I.reset();
  });

  test('a file that is too large replaces the result of the file before', () async {
    final model = VerifyTimestampViewModel();
    picker.next = File('${dir.path}/proof.txt')..writeAsStringSync('proof');
    await model.pickAndVerifyFile();
    expect(model.verificationResult, isNotNull);

    picker.next = File('${dir.path}/big.bin')..writeAsBytesSync(Uint8List(maxFileSizeBytes + 1));
    await model.pickAndVerifyFile();

    expect(model.selectedFilename, 'big.bin');
    expect(model.verificationResult, isNull);
    expect(model.modelError, 'File too large. Maximum size: 1MB');
  });

  test('a file with no timestamp shows the error on the verify page only', () async {
    final model = VerifyTimestampViewModel();
    picker.next = File('${dir.path}/unknown.txt')..writeAsStringSync('unknown');
    await model.pickAndVerifyFile();

    expect(model.modelError, 'Exception: no timestamp found for this file');
    expect(GetIt.I.get<TimestampProvider>().modelError, isNull);
  });
}
