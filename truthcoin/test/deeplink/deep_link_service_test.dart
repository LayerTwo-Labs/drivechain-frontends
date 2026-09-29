import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:truthcoin/deeplink/deep_link_service.dart';
import 'package:truthcoin/routing/router.dart';

void main() {
  late StreamController<Uri> links;
  late List<String> steps;
  late List<PageRouteInfo> pushed;
  late DeepLinkService service;

  setUp(() {
    links = StreamController<Uri>.broadcast();
    steps = [];
    pushed = [];
    service = DeepLinkService(
      navigate: (route) async => steps.add('navigate ${route.routeName}'),
      push: (route) async {
        steps.add('push ${route.routeName}');
        pushed.add(route);
      },
      log: Logger(level: Level.off),
      links: links.stream,
    );
  });

  tearDown(() async {
    await service.stop();
    await links.close();
  });

  test('a market link opens the market page', () async {
    service.handle(Uri.parse('truthcoin://market/c8fa97101f0c'));
    await pumpEventQueue();

    expect(pushed, hasLength(1));
    expect(pushed.single.routeName, MarketDetailRoute.name);
    expect(pushed.single.rawPathParams['marketId'], 'c8fa97101f0c');
  });

  test('the app runs the home guards before the market page', () async {
    service.handle(Uri.parse('truthcoin://market/c8fa97101f0c'));
    await pumpEventQueue();

    expect(steps, ['navigate ${HomeRoute.name}', 'push ${MarketDetailRoute.name}']);
  });

  test('a markets link opens the market list', () async {
    service.handle(Uri.parse('truthcoin://markets'));
    await pumpEventQueue();

    expect(steps, ['navigate ${HomeRoute.name}', 'push ${MarketExplorerRoute.name}']);
  });

  test('a link the app does not own moves nothing', () async {
    service.handle(Uri.parse('https://example.com/market/c8fa97101f0c'));
    service.handle(Uri.parse('truthcoin://market/not-hex'));
    await pumpEventQueue();

    expect(steps, isEmpty);
  });

  test('the stream routes every link after start', () async {
    service.start();
    links.add(Uri.parse('truthcoin://market/494d3fd0489e'));
    await pumpEventQueue();
    links.add(Uri.parse('truthcoin://markets'));
    await pumpEventQueue();

    expect(pushed.map((r) => r.routeName), [MarketDetailRoute.name, MarketExplorerRoute.name]);
  });

  test('a second start keeps one subscription', () async {
    service.start();
    service.start();
    links.add(Uri.parse('truthcoin://markets'));
    await pumpEventQueue();

    expect(pushed, hasLength(1));
  });

  test('stop ends the routing', () async {
    service.start();
    await service.stop();
    links.add(Uri.parse('truthcoin://markets'));
    await pumpEventQueue();

    expect(pushed, isEmpty);
  });

  test('a stream error leaves the app alive', () async {
    service.start();
    links.addError(Exception('the platform channel failed'));
    links.add(Uri.parse('truthcoin://markets'));
    await pumpEventQueue();

    expect(pushed, hasLength(1));
  });
}
