import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:bitwindow/widgets/fee_coinnews.dart';
import 'package:bitwindow/widgets/homepage_widget_catalog.dart';
import 'package:bitwindow/widgets/mempool_widget.dart';
import 'package:bitwindow/widgets/peers_table_widget.dart';
import 'package:bitwindow/providers/mempool_provider.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart' show Peer;
import 'package:bitwindow/widgets/network_stats_widget.dart';
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
          width: 390,
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
      expect(fee.right, closeTo(390 - 8, 1));
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

  group('Dashboard Stats', () {
    Future<void> pump(WidgetTester tester, double width) async {
      await loadBundledFonts();
      await tester.pumpSailPage(
        SizedBox(
          width: width,
          child: FireplaceStatsView(
            priceLastUpdated: () => '1 minute ago',
            price: r'$0.000031',
            priceTitle: 'ECX Price',
            stats: GetFireplaceStatsResponse(
              transactionCount24h: Int64(18402),
              coinnewsCount7d: Int64(37),
              blockCount24h: Int64(144),
            ),
            loading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('on a phone the stats are rows in one panel', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      await pump(tester, 390);

      expect(find.byType(SailStatList), findsOneWidget);
      expect(find.byType(SailStatRow), findsNWidgets(4));
      expect(find.byType(SailCardStats), findsNothing);
      final title = tester.getRect(find.text('New transactions'));
      final value = tester.getRect(find.text('18402'));
      expect(tester.getRect(find.text('Last 24 hours').first).top, greaterThanOrEqualTo(title.bottom));
      expect(value.left, greaterThan(title.right));
      expect(tester.getRect(find.text('Number of blocks')).top, greaterThan(title.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('on the desktop the stats stay cards', (tester) async {
      SailStyleValues.phoneLayoutOverride = false;
      await pump(tester, 1200);

      expect(find.byType(SailCardStats), findsNWidgets(4));
      expect(find.byType(SailStatList), findsNothing);
    });
  });

  group('Network Stats', () {
    final stats = GetNetworkStatsResponse(
      peerCount: 10,
      connectionsIn: 8,
      connectionsOut: 2,
      blockHeight: Int64(1022811),
      totalBytesReceived: Int64(2048),
      totalBytesSent: Int64(1024),
      bitcoindBandwidth: ProcessBandwidth(pid: 4242, connectionCount: 10),
      enforcerBandwidth: ProcessBandwidth(pid: 4343, connectionCount: 3),
    );

    Future<void> pump(WidgetTester tester) async {
      await loadBundledFonts();
      await tester.pumpSailPage(
        SizedBox(
          width: 390,
          child: NetworkStatsContent(stats: stats, currentRxRate: 512, currentTxRate: 256),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('on a phone each stat is a row with its value at the right', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      await pump(tester);

      expect(find.byType(SailStatRow), findsNWidgets(6));
      final peers = tester.getRect(find.text('Peers'));
      final value = tester.getRect(find.text('10'));
      expect(tester.getRect(find.text('8 in / 2 out')).top, greaterThanOrEqualTo(peers.bottom));
      expect(value.right, closeTo(tester.getRect(find.byType(SailStatList)).right, 1));
      expect(peers.left, tester.getRect(find.byType(SailStatList)).left);
      expect(tester.getRect(find.text('enforcer')).top, greaterThan(tester.getRect(find.text('bitcoind')).bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('on the desktop the stats stay in two columns', (tester) async {
      SailStyleValues.phoneLayoutOverride = false;
      await pump(tester);

      expect(find.byType(SailStatRow), findsNothing);
      expect(find.byType(StatItem), findsNWidgets(6));
      expect(tester.getRect(find.text('Block Height')).left, greaterThan(tester.getRect(find.text('Peers')).right));
    });
  });

  group('Hacker Coin News', () {
    double cellWidth(WidgetTester tester, String value) =>
        tester.getSize(find.ancestor(of: find.text(value).first, matching: find.byType(SailTableCell))).width;

    Future<void> pump(WidgetTester tester, double width) async {
      await loadBundledFonts();
      await tester.pumpSailPage(
        SizedBox(
          width: width,
          child: CoinNewsTable(entries: news, onSort: (_) {}, loading: false),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('on a phone the title column takes the width the date and read time leave', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      await pump(tester, 390);

      expect(find.text('Topic'), findsNothing);
      const shortDate = 'Oct 31';
      expect(cellWidth(tester, shortDate), closeTo(72, 1));
      expect(cellWidth(tester, '1 min'), closeTo(88, 1));
      expect(cellWidth(tester, news.first.headline), closeTo(390 - 72 - 88, 2));
      expect(tester.getSize(find.text(shortDate).first).height, tester.getSize(find.text('1 min').first).height);
      expect(tester.takeException(), isNull);
    });

    testWidgets('on the desktop the table keeps the topic and the long date', (tester) async {
      SailStyleValues.phoneLayoutOverride = false;
      await pump(tester, 1200);

      expect(find.text('Topic'), findsOneWidget);
      expect(find.text(formatDate(time)), findsNWidgets(2));
    });
  });

  group('Mempool', () {
    final stats = MempoolStats(
      txCount: 4210,
      totalVsize: 1820000,
      totalFees: 4210000,
      medianFeeRate: 3.2,
      feeBuckets: const [],
      feeEstimates: const [],
    );

    testWidgets('on a phone each stat is a label at the left and its value at the right', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      await tester.pumpSailPage(SizedBox(width: 390, child: MempoolStatsRow(stats: stats)));

      final label = tester.getRect(find.text('Transactions'));
      final value = tester.getRect(find.text('4210'));
      expect(value.top, closeTo(label.top, 2));
      expect(value.right, closeTo(tester.getRect(find.byType(MempoolStatsRow)).right, 1));
      expect(tester.getRect(find.text('Size')).top, greaterThan(label.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('on the desktop each stat value stays under its label', (tester) async {
      SailStyleValues.phoneLayoutOverride = false;
      await tester.pumpSailPage(SizedBox(width: 800, child: MempoolStatsRow(stats: stats)));

      expect(tester.getRect(find.text('4210')).top, greaterThan(tester.getRect(find.text('Transactions')).bottom - 1));
    });
  });

  group('Connected Peers', () {
    final peers = [
      Peer(addr: '[2001:db8:85a3::8a2e:370:7334]:8333', inbound: false, bytesReceived: Int64(2048)),
      Peer(addr: '203.0.113.7:8333', inbound: true, bytesReceived: Int64(4096)),
    ];

    double cellWidth(WidgetTester tester, String value) =>
        tester.getSize(find.ancestor(of: find.text(value).first, matching: find.byType(SailTableCell))).width;

    Future<void> pump(WidgetTester tester, double width) async {
      await loadBundledFonts();
      await tester.pumpSailPage(
        SizedBox(
          width: width,
          height: 300,
          child: PeersTable(peers: peers, sortColumn: 'addr', sortAscending: true, onSort: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('on a phone the address takes the width that received and connected leave', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      await pump(tester, 390);

      expect(find.text('Direction'), findsNothing);
      expect(find.text('Received'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(cellWidth(tester, '2.0 KB'), closeTo(88, 1));
      expect(cellWidth(tester, '203.0.113.7:8333'), closeTo(390 - 88 - 96, 2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('on the desktop the peers table keeps every column', (tester) async {
      SailStyleValues.phoneLayoutOverride = false;
      await pump(tester, 1200);

      expect(find.text('Sent'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
    });
  });

  group('full-size coin news', () {
    for (final id in ['coin_news', 'hacker_coin_news']) {
      testWidgets('on a phone $id stacks its two cards', (tester) async {
        SailStyleValues.phoneLayoutOverride = true;
        await loadBundledFonts();
        final info = HomepageWidgetCatalog.getCatalogMap()[id]!;
        expect(info.fullOnPhones, isTrue);
        await tester.pumpSailPage(
          SizedBox(width: 390, child: SingleChildScrollView(child: info.builder(WidgetSize.full))),
        );
        await tester.pump();

        final cards = find.byType(SailCard);
        expect(cards, findsNWidgets(2));
        final first = tester.getRect(cards.first);
        final second = tester.getRect(cards.last);
        expect(second.top, greaterThan(first.bottom));
        expect(second.left, first.left);
        expect(first.width, closeTo(390, 1));
        expect(tester.takeException(), isNull);
      });

      testWidgets('on the desktop $id keeps its two cards side by side', (tester) async {
        SailStyleValues.phoneLayoutOverride = false;
        final info = HomepageWidgetCatalog.getCatalogMap()[id]!;
        await tester.pumpSailPage(SizedBox(width: 1100, child: info.builder(WidgetSize.full)));
        await tester.pump();

        final cards = find.byType(SailCard);
        expect(tester.getRect(cards.last).left, greaterThan(tester.getRect(cards.first).right));
      });
    }
  });
}
