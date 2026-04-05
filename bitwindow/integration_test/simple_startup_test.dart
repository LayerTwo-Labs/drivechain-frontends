import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bitwindow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BitWindow launches and shows expected UI', (WidgetTester tester) async {
    // Launch the app
    app.main([]);

    // Wait for app to settle (BitWindow has a lot of initialization)
    // Use multiple pumps instead of timeout parameter
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 2));
    }

    print('🚀 App launched, looking for UI elements...');

    // Look for any of the main tab elements that should exist
    final possibleElements = [
      'Wallet',
      'Overview',
      'Sidechains',
      'Console',
      'Settings',
    ];

    bool foundElement = false;
    String foundElementText = '';

    for (final elementText in possibleElements) {
      final finder = find.text(elementText);
      if (tester.any(finder)) {
        foundElement = true;
        foundElementText = elementText;
        print('✅ Found expected element: $elementText');
        break;
      }
    }

    // If we didn't find tab text, try looking for other common UI elements
    if (!foundElement) {
      final fallbackFinders = [
        find.text('BitWindow'),
        find.textContaining('Bitcoin'),
        find.textContaining('Balance'),
        find.textContaining('Address'),
      ];

      for (final finder in fallbackFinders) {
        if (tester.any(finder)) {
          foundElement = true;
          foundElementText = finder.toString();
          print('✅ Found fallback element: $foundElementText');
          break;
        }
      }
    }

    expect(
      foundElement,
      isTrue,
      reason: 'Should find at least one expected UI element - app may have crashed or failed to load',
    );

    print('🎉 Smoke test passed! BitWindow launched successfully and UI is visible.');
    print('   Found element: $foundElementText');
  });
}
