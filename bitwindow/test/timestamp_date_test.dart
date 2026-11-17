import 'package:bitwindow/pages/wallet/wallet_timestamps.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final blockTime = DateTime.utc(2026, 11, 17, 19, 46, 3);

  Widget table(FileTimestamp timestamp) {
    return SizedBox(width: 1000, height: 300, child: TimestampsTable(timestamps: [timestamp]));
  }

  group('timestamps table', () {
    testWidgets('shows the block time of a confirmed timestamp', (tester) async {
      await tester.pumpSailPage(
        table(
          FileTimestamp(
            id: Int64(1),
            filename: 'proof.txt',
            fileHash: 'd6c1e986146930dc1bab9a0c001b0425c859c025bf77fb5b814c8782a1834915',
            status: 'confirmed',
            blockHeight: Int64(640),
            confirmedAt: Timestamp.fromDateTime(blockTime),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(DateFormat('MMM d, yyyy HH:mm').format(blockTime.toLocal())), findsOneWidget);
    });

    testWidgets('shows a dash before the timestamp confirms', (tester) async {
      await tester.pumpSailPage(
        table(
          FileTimestamp(
            id: Int64(2),
            filename: 'proof.txt',
            fileHash: 'd6c1e986146930dc1bab9a0c001b0425c859c025bf77fb5b814c8782a1834915',
            status: 'confirming',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('-'), findsNWidgets(2));
    });
  });
}
