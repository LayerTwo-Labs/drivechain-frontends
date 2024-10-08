// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/receive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets('can build overview page', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;
    // Build our app and trigger a frame.
    await tester.pumpSailPage(
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 1200,
          maxWidth: 1000,
        ),
        child: ReceivePage(),
      ),
    );
  });
}
