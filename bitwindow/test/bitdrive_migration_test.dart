import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/gen/bitdrive/v1/bitdrive.pb.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';

import 'mocks/api_mock.dart';

void main() {
  group('BitDrive file-ops migration (frontend → backend RPC)', () {
    late MockBitDriveAPI mockApi;

    setUp(() {
      mockApi = MockBitDriveAPI();
    });

    test('listFiles returns BitDriveFile protobuf objects, not local file models', () async {
      final files = await mockApi.listFiles();
      // Default mock returns empty list; the important assertion is that
      // the return type is List<BitDriveFile> (protobuf), not a custom
      // frontend model. This would fail to compile if the old BitDriveFile
      // class were still used as return type.
      expect(files, isA<List<BitDriveFile>>());
    });

    test('wipeData takes no arguments (local dir deletion removed)', () async {
      // After migration, wipeData() is a simple RPC call with no local
      // filesystem cleanup. Calling without args must succeed.
      await mockApi.wipeData();
    });

    test('BitDriveFile protobuf has expected fields for table rendering', () {
      final file = BitDriveFile(
        id: Int64(1),
        filename: 'test.txt',
        fileType: 'text/plain',
        sizeBytes: Int64(1024),
        encrypted: true,
        txid: 'abc123',
        timestamp: 1700000000,
        createdAt: Timestamp.fromDateTime(DateTime(2024, 1, 15)),
      );

      expect(file.filename, 'test.txt');
      expect(file.txid, 'abc123');
      expect(file.sizeBytes.toInt(), 1024);
      expect(file.encrypted, true);
      expect(file.hasCreatedAt(), true);
      expect(file.createdAt.toDateTime().year, 2024);
    });

    test('BitDriveFile falls back to timestamp when createdAt is absent', () {
      final file = BitDriveFile(
        txid: 'def456',
        filename: 'no_created_at.bin',
        timestamp: 1700000000,
      );

      expect(file.hasCreatedAt(), false);
      // The page uses this fallback pattern:
      final date = file.hasCreatedAt()
          ? file.createdAt.toDateTime()
          : DateTime.fromMillisecondsSinceEpoch(file.timestamp * 1000);
      expect(date.year, 2023); // Nov 2023
    });

    test('file sorting by createdAt descending (newest first)', () {
      final files = [
        BitDriveFile(
          txid: 'old',
          createdAt: Timestamp.fromDateTime(DateTime(2024, 1, 1)),
        ),
        BitDriveFile(
          txid: 'new',
          createdAt: Timestamp.fromDateTime(DateTime(2024, 6, 1)),
        ),
        BitDriveFile(
          txid: 'mid',
          createdAt: Timestamp.fromDateTime(DateTime(2024, 3, 1)),
        ),
      ];

      files.sort((a, b) {
        final aTime = a.hasCreatedAt() ? a.createdAt.toDateTime() : DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.hasCreatedAt() ? b.createdAt.toDateTime() : DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      expect(files[0].txid, 'new');
      expect(files[1].txid, 'mid');
      expect(files[2].txid, 'old');
    });

    test('getRowId uses txid instead of file path', () {
      final files = [
        BitDriveFile(txid: 'tx_abc', filename: 'a.txt'),
        BitDriveFile(txid: 'tx_def', filename: 'b.txt'),
      ];

      // Mirrors the table's getRowId lambda
      String getRowId(int index) => files[index].txid;

      expect(getRowId(0), 'tx_abc');
      expect(getRowId(1), 'tx_def');
    });

    test('storeFile mock accepts expected RPC parameters', () async {
      final response = await mockApi.storeFile(
        content: [0x48, 0x65, 0x6C, 0x6C, 0x6F],
        filename: 'hello.txt',
        mimeType: 'text/plain',
        encrypt: true,
        feeSatPerVbyte: 5,
      );

      expect(response, isA<StoreFileResponse>());
    });

    test('scanForFiles and downloadPendingFiles RPCs work', () async {
      final scanResponse = await mockApi.scanForFiles();
      expect(scanResponse, isA<ScanForFilesResponse>());

      final downloadResponse = await mockApi.downloadPendingFiles();
      expect(downloadResponse, isA<DownloadPendingFilesResponse>());
    });
  });
}
