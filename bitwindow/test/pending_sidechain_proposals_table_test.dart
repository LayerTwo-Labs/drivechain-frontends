import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/drivechain/v1/drivechain.pb.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the proposal data as hex', (tester) async {
    await tester.pumpSailPage(
      SizedBox(
        height: 300,
        child: PendingSidechainProposalsTable(
          proposals: [
            SidechainProposal(slot: 5, data: [0xde, 0xad, 0xbe, 0xef], dataHash: 'abcd'),
          ],
        ),
      ),
    );

    expect(find.text('deadbeef'), findsOneWidget);
  });
}
