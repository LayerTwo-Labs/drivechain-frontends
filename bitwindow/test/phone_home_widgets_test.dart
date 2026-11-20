import 'package:bitwindow/widgets/fee_coinnews.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  final time = DateTime.utc(2026, 10, 31, 22, 47);
  final news = [
    CoinNews(
      topic: 'a1a1a1a1',
      headline: 'Drivechain upgrade successfully completed on the whole network',
      feeSats: Int64(412),
      createTime: Timestamp.fromDateTime(time),
    ),
    CoinNews(
      topic: 'a1a1a1a1',
      headline: 'Bitcoin price hits new all-time high',
      feeSats: Int64(96),
      createTime: Timestamp.fromDateTime(time),
    ),
  ];

  group('Fee Coin News', () {
    Future<void> pump(WidgetTester tester, void Function(CoinNews) onSelected) async {
      await loadBundledFonts();
      await tester.pumpSailPage(
        SizedBox(
          width: 335,
          child: FeeCoinNewsTable(entries: news, loading: false, onArticleSelected: onSelected),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('on a phone each story shows the headline over its time, with the fee at the right', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      CoinNews? opened;
      await pump(tester, (n) => opened = n);

      expect(find.byType(SailTable), findsNothing);
      final headline = tester.getRect(find.text(news.first.headline));
      final timeText = tester.getRect(find.text(formatDate(time, long: false)).first);
      final fee = tester.getRect(find.text('412 sat'));
      expect(timeText.top, greaterThanOrEqualTo(headline.bottom));
      expect(timeText.left, headline.left);
      expect(fee.left, greaterThan(headline.right));
      expect(fee.right, closeTo(335, 1));
      expect(tester.getSize(find.text(news.first.headline)).height, lessThan(20));

      await tester.tap(find.text('Bitcoin price hits new all-time high'));
      expect(opened, news[1]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('on the desktop the stories stay in the fee table', (tester) async {
      SailStyleValues.phoneLayoutOverride = false;
      await pump(tester, (_) {});

      expect(find.byType(SailTable), findsOneWidget);
      expect(find.text('Fees'), findsOneWidget);
      expect(find.text('412 sat'), findsNothing);
    });
  });
}
