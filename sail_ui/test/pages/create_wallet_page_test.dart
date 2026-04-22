import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/pages/create_wallet_page.dart';

void main() {
  test('awaitBackendReady returns immediately when already ready', () async {
    final ready = ValueNotifier<bool>(true);
    await awaitBackendReady(ready, timeout: const Duration(milliseconds: 50));
    ready.dispose();
  });

  test('awaitBackendReady completes when readiness flips true', () async {
    final ready = ValueNotifier<bool>(false);
    Timer(const Duration(milliseconds: 50), () => ready.value = true);

    await awaitBackendReady(ready, timeout: const Duration(seconds: 2));
    ready.dispose();
  });

  test('awaitBackendReady throws TimeoutException when never ready', () async {
    final ready = ValueNotifier<bool>(false);

    await expectLater(
      awaitBackendReady(ready, timeout: const Duration(milliseconds: 100)),
      throwsA(isA<TimeoutException>()),
    );
    ready.dispose();
  });
}
