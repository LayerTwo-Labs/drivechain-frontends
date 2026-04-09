import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:bitwindow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app compiles and starts without crashing', (WidgetTester tester) async {
    // Just try to start the app and pump once
    // This is the most basic smoke test possible

    log('Starting minimal smoke test...');

    try {
      app.main([]);
      await tester.pump();
      log('App started without immediate crash');
    } catch (e) {
      log('App failed to start: $e');
      rethrow;
    }

    // Just verify we didn't crash - that's enough for a smoke test
    expect(true, isTrue, reason: 'App should start without crashing');

    log('Minimal smoke test passed!');
  });
}
