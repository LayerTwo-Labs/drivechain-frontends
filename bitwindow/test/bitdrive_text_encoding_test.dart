import 'dart:convert';

import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _RecordingBitDrive extends MockBitDriveAPI {
  final storedContents = <List<int>>[];

  @override
  Future<StoreFileResponse> storeFile({
    required List<int> content,
    String? filename,
    String? mimeType,
    bool encrypt = false,
    int? feeSatPerVbyte,
  }) async {
    storedContents.add(content);
    return StoreFileResponse();
  }
}

class _Api extends MockAPI {
  _Api() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final recorder = _RecordingBitDrive();

  @override
  BitDriveAPI get bitdrive => recorder;
}

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => 'qa';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Api api;
  late BitDriveProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    api = _Api();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BitwindowRPC>(api);
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    await registerTestDependencies();
    provider = BitDriveProvider();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('text goes to the server as UTF-8', () async {
    const text = 'café 5€ ✓';
    await provider.setTextContent(text);
    await provider.store();

    expect(api.recorder.storedContents.single, utf8.encode(text));
  });

  test('the 1 MB text limit counts UTF-8 bytes', () async {
    await provider.setTextContent('€' * 400000);

    expect(provider.error, 'Text size must be less than 1MB');
    expect(provider.textContent, isNull);
  });
}
