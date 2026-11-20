import 'package:bitwindow/pages/wallet/bitdrive_page.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bitdrive/v1/bitdrive.pb.dart' as bitdrivepb;
import 'package:sidechain_core/utils/share_file.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _FakeBitDrive extends ChangeNotifier implements BitDriveProvider {
  @override
  Future<void> init() async {}

  @override
  Future<List<bitdrivepb.BitDriveFile>> listFiles() async => [
    bitdrivepb.BitDriveFile(
      txid: 'a' * 64,
      filename: 'genesis-note.txt',
      sizeBytes: Int64(212),
      createdAt: Timestamp.fromDateTime(DateTime(2026, 10, 30)),
    ),
    bitdrivepb.BitDriveFile(
      txid: 'b' * 64,
      filename: 'proof-of-idea.pdf',
      sizeBytes: Int64(86221),
      createdAt: Timestamp.fromDateTime(DateTime(2026, 10, 28)),
    ),
  ];

  @override
  bool get isScanning => false;

  @override
  bool get isDownloading => false;

  @override
  int get pendingDownloadsCount => 0;

  @override
  int feeSatPerVbyte = 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => 'qa';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpMyFiles(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  addTearDown(() => tester.pumpWidget(const SizedBox()));
  await tester.pumpSailPage(const BitDriveTab());
  await tester.pump();
  await tester.tap(find.text('My Files'));
  await tester.pump();
  if (phone) {
    await tester.binding.setSurfaceSize(const Size(390, 844));
  }
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<BitwindowRPC>(MockAPI(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD));
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    await registerTestDependencies();
    GetIt.I.registerSingleton<BitDriveProvider>(_FakeBitDrive());
  });

  tearDown(() async {
    BitDriveViewModel.share = shareFile;
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone the title has its own line and the buttons sit under it', (tester) async {
    await _pumpMyFiles(tester, phone: true);

    expect(tester.takeException(), isNull);
    final title = tester.getRect(find.text('Your files stored on ${activeTicker.name}'));
    final scan = tester.getRect(find.widgetWithText(SailButton, 'Scan for new'));
    final download = tester.getRect(find.widgetWithText(SailButton, 'Download all'));
    expect(scan.top, greaterThan(title.bottom));
    expect(scan.left, title.left);
    expect(download.left, greaterThan(scan.right));
  });

  testWidgets('on a phone each file is a two-line row with the size at the right', (tester) async {
    await _pumpMyFiles(tester, phone: true);

    expect(find.byType(SailTable), findsNothing);
    final name = tester.getRect(find.text('genesis-note.txt'));
    final date = tester.getRect(find.text('Oct 30, 2026'));
    final size = tester.getRect(find.text('212 B'));
    expect(date.top, greaterThan(name.bottom - 1));
    expect(date.left, name.left);
    expect(size.left, greaterThan(name.right));
    expect(find.text('84.2 KB'), findsOneWidget);
  });

  testWidgets('the desktop keeps the files table', (tester) async {
    await _pumpMyFiles(tester, phone: false);

    expect(find.byType(SailTable), findsOneWidget);
  });

  testWidgets('on a phone a tap on a file shares it, and Open Folder is gone', (tester) async {
    final shared = <String>[];
    BitDriveViewModel.share = (path) async => shared.add(path);
    await _pumpMyFiles(tester, phone: true);

    expect(find.text('Open Folder'), findsNothing);
    await tester.tap(find.text('genesis-note.txt'));
    await tester.pump();

    expect(shared, ['/tmp/mock-bitdrive/genesis-note.txt']);
  });

  testWidgets('on a phone a failed share shows the error', (tester) async {
    BitDriveViewModel.share = (path) async => throw const ShareFileException('no app can take this file');
    await _pumpMyFiles(tester, phone: true);

    await tester.tap(find.text('genesis-note.txt'));
    await tester.pump();

    expect(find.text('no app can take this file'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the desktop keeps Open Folder', (tester) async {
    await _pumpMyFiles(tester, phone: false);

    expect(find.text('Open Folder'), findsOneWidget);
  });
}
