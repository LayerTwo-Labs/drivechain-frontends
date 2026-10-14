import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sidechain_core/extensions/formatting.dart';
import 'package:sidechain_core/providers/price_provider.dart';
import 'package:sidechain_core/ticker.dart';

String _dexScreener(String priceUsd) => jsonEncode({
  'pairs': [
    {'priceUsd': priceUsd},
  ],
});

void main() {
  test('each network reads the market of its own coin', () {
    expect(priceSourceFor(Ticker.bitcoin), PriceSource.blockchainInfo);
    expect(priceSourceFor(Ticker.betanet), PriceSource.wbECX);
    expect(priceSourceFor(Ticker.ecash), PriceSource.wECX);
    expect(priceSourceFor(Ticker.alphanet), isNull);
  });

  test('blockchain.info gives the BTC price', () {
    expect(
      PriceSource.blockchainInfo.parse(jsonDecode('{"USD": {"last": 64000.5, "symbol": "\$"}}')),
      64000.5,
    );
    expect(() => PriceSource.blockchainInfo.parse(jsonDecode('{"EUR": {"last": 1}}')), throwsFormatException);
  });

  test('dexscreener gives the pool price', () {
    expect(PriceSource.wbECX.parse(jsonDecode(_dexScreener('2.63'))), 2.63);
    expect(() => PriceSource.wECX.parse(jsonDecode('{"pairs": null}')), throwsFormatException);
    expect(() => PriceSource.wECX.parse(jsonDecode(_dexScreener('n/a'))), throwsFormatException);
  });

  test('the provider converts the balance at the betanet price', () async {
    final urls = <String>[];
    final provider = PriceProvider(
      client: MockClient((req) async {
        urls.add(req.url.toString());
        return http.Response(_dexScreener('2.5'), 200);
      }),
      source: () => PriceSource.wbECX,
    );
    addTearDown(provider.dispose);
    await pumpEventQueue();

    expect(urls, [PriceSource.wbECX.url]);
    expect(provider.usdPrice, 2.5);
    expect(provider.toUsd(4), 10);
    expect(provider.error, isNull);
  });

  test('a network change drops the price of the old coin', () async {
    PriceSource? source = PriceSource.blockchainInfo;
    final provider = PriceProvider(
      client: MockClient((req) async {
        if (req.url.toString() == PriceSource.blockchainInfo.url) {
          return http.Response('{"USD": {"last": 64000}}', 200);
        }
        return http.Response(_dexScreener('2.5'), 200);
      }),
      source: () => source,
    );
    addTearDown(provider.dispose);
    await pumpEventQueue();
    expect(provider.usdPrice, 64000);

    source = null;
    await provider.fetch();
    expect(provider.usdPrice, isNull);
    expect(provider.toUsd(1), isNull);

    source = PriceSource.wbECX;
    await provider.fetch();
    expect(provider.usdPrice, 2.5);
  });

  test('a failed fetch keeps no price and reports the error', () async {
    final provider = PriceProvider(
      client: MockClient((_) async => http.Response('rate limited', 429)),
      source: () => PriceSource.wECX,
    );
    addTearDown(provider.dispose);
    await pumpEventQueue();

    expect(provider.usdPrice, isNull);
    expect(provider.error, contains('429'));
  });

  test('a USD amount shows cents under 1000 dollars', () {
    expect(formatUsd(2.63), '\$2.63');
    expect(formatUsd(0.004), '\$0.00');
    expect(formatUsd(999.99), '\$999.99');
    expect(formatUsd(1000), '\$1 000');
    expect(formatUsd(83715.42), '\$83 715');
  });

  test('a network change clears the old price at once, also during a fetch', () async {
    final network = ValueNotifier(0);
    final slow = Completer<http.Response>();
    PriceSource? source = PriceSource.blockchainInfo;
    final provider = PriceProvider(
      client: MockClient(
        (req) => req.url.toString() == PriceSource.blockchainInfo.url
            ? slow.future
            : Future.value(http.Response(_dexScreener('2.5'), 200)),
      ),
      source: () => source,
      networkChanges: network,
    );
    addTearDown(provider.dispose);
    expect(provider.isFetching, isTrue);

    source = PriceSource.wbECX;
    network.value++;
    expect(provider.usdPrice, isNull);

    slow.complete(http.Response('{"USD": {"last": 64000}}', 200));
    await pumpEventQueue();
    expect(provider.usdPrice, isNull, reason: 'the BTC answer came after the switch');

    await provider.fetch();
    expect(provider.usdPrice, 2.5);
  });
}
