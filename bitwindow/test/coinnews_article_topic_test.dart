import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final time = DateTime.utc(2026, 11, 16, 16, 32);
  final topics = [
    Topic(id: Int64(1), topic: 'a1a1a1a1', name: 'US Weekly', confirmed: true),
    Topic(id: Int64(2), topic: 'b2b2b2b2', name: 'Japan Weekly'),
  ];

  CoinNews story(String topic) =>
      CoinNews(headline: 'Headline', topic: topic, createTime: Timestamp.fromDateTime(time));

  Future<void> pumpPanel(WidgetTester tester, String topic) async {
    await tester.pumpSailPage(
      SizedBox(
        width: 1000,
        height: 600,
        child: CoinNewsArticlePanel(news: story(topic), onClose: () {}),
      ),
    );
    await tester.pumpAndSettle();
    final provider = GetIt.I.get<NewsProvider>();
    provider.topics = topics;
    provider.notifyListeners();
    await tester.pumpAndSettle();
  }

  test('topicName returns the name of a known topic and null for an unknown topic', () async {
    await registerTestDependencies();
    final provider = GetIt.I.get<NewsProvider>();
    provider.topics = topics;

    expect(provider.topicName('a1a1a1a1'), 'US Weekly');
    expect(provider.topicName('b2b2b2b2'), 'Japan Weekly');
    expect(provider.topicName('ffffffff'), isNull);
  });

  testWidgets('article panel shows the topic name and the date', (tester) async {
    await pumpPanel(tester, 'a1a1a1a1');

    expect(find.text('US Weekly  ·  ${formatDate(time)}'), findsOneWidget);
    expect(find.textContaining('a1a1a1a1'), findsNothing);
  });

  testWidgets('article panel shows a pending topic name without a pending mark', (tester) async {
    await pumpPanel(tester, 'b2b2b2b2');

    expect(find.text('Japan Weekly  ·  ${formatDate(time)}'), findsOneWidget);
  });

  testWidgets('article panel shows only the date for an unknown topic', (tester) async {
    await pumpPanel(tester, 'ffffffff');

    expect(find.text(formatDate(time)), findsOneWidget);
    expect(find.textContaining('ffffffff'), findsNothing);
  });
}
