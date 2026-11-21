import 'dart:io';

// ignore: drivechain_lints/avoid_material_import
import 'package:flutter/material.dart' show TextField;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sail_ui/sail_ui.dart';

/// Taps and waits for a phone app that never settles: the daemons poll for the whole test.
class PhoneUi {
  final WidgetTester tester;
  final IntegrationTestWidgetsFlutterBinding binding;
  final String platform = Platform.operatingSystem;
  var _shots = 0;
  var _surfaceReady = false;

  PhoneUi(this.tester, this.binding);

  /// Pumps frames until [finder] finds a widget, or fails after [timeout].
  Future<void> waitFor(Finder finder, {Duration timeout = const Duration(seconds: 60), String? reason}) async {
    final end = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        throw TestFailure('waited ${timeout.inSeconds}s for ${reason ?? finder.describeMatch(Plurality.one)}');
      }
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  /// Pumps frames until [check] is true, or fails after [timeout].
  Future<void> waitUntil(bool Function() check, String what, {Duration timeout = const Duration(seconds: 90)}) async {
    final end = DateTime.now().add(timeout);
    while (!check()) {
      if (DateTime.now().isAfter(end)) {
        throw TestFailure('waited ${timeout.inSeconds}s for $what');
      }
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// Pumps frames until [check] answers true, or fails after [timeout].
  Future<void> waitUntilAsync(
    Future<bool> Function() check,
    String what, {
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final end = DateTime.now().add(timeout);
    while (!await check()) {
      if (DateTime.now().isAfter(end)) {
        throw TestFailure('waited ${timeout.inSeconds}s for $what');
      }
      await settle(const Duration(milliseconds: 500));
    }
  }

  /// Pumps frames for [duration] of real time.
  Future<void> settle([Duration duration = const Duration(seconds: 1)]) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Scrolls [finder] into view and taps the match that a tap reaches.
  Future<void> tap(Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
    await waitFor(finder, timeout: timeout);
    var target = finder.hitTestable();
    for (var i = finder.evaluate().length - 1; i >= 0 && target.evaluate().isEmpty; i--) {
      await tester.ensureVisible(finder.at(i));
      await settle(const Duration(milliseconds: 400));
      target = finder.hitTestable();
    }
    if (target.evaluate().isEmpty) {
      throw TestFailure('no tap reaches ${finder.describeMatch(Plurality.one)}');
    }
    await tester.tap(target.last, warnIfMissed: false);
    await settle(const Duration(milliseconds: 600));
  }

  /// Long-presses [finder] until [opens] shows. A row the app rebuilds can drop one press.
  Future<void> longPressUntil(Finder finder, Finder opens, {int tries = 5}) async {
    for (var i = 0; i < tries; i++) {
      await waitFor(finder.hitTestable());
      await tester.longPress(finder.hitTestable().first, warnIfMissed: false);
      await settle();
      if (opens.evaluate().isNotEmpty) {
        return;
      }
      await settle(const Duration(seconds: 2));
    }
    throw TestFailure('a long press on ${finder.describeMatch(Plurality.one)} did not open the menu');
  }

  /// The match of [finder] that sits highest on the screen.
  Finder topmost(Finder finder) {
    final matches = finder.evaluate().toList();
    if (matches.isEmpty) {
      return finder;
    }
    var best = 0;
    for (var i = 1; i < matches.length; i++) {
      if (tester.getTopLeft(finder.at(i)).dy < tester.getTopLeft(finder.at(best)).dy) {
        best = i;
      }
    }
    return finder.at(best);
  }

  Future<void> tapText(String text, {Duration timeout = const Duration(seconds: 30)}) =>
      tap(find.text(text), timeout: timeout);

  /// Opens the side nav with the menu button of the top bar.
  Future<void> openSideNav() async {
    await tap(find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.menu));
  }

  /// Opens [label] in the side nav.
  Future<void> navigate(String label) async {
    await openSideNav();
    await tapText(label);
  }

  /// Writes a screenshot named `<nn>-<step>.png` through the test driver.
  Future<void> shot(String step) async {
    if (platform == 'android' && !_surfaceReady) {
      await binding.convertFlutterSurfaceToImage();
      _surfaceReady = true;
    }
    _shots++;
    final name = '${_shots.toString().padLeft(2, '0')}-$step';
    // Android's PixelCopy fails now and then while a frame is in flight.
    for (var attempt = 1; ; attempt++) {
      await tester.pump();
      try {
        await binding.takeScreenshot(name);
        return;
      } on PlatformException {
        if (attempt == 3) {
          rethrow;
        }
        await settle();
      }
    }
  }

  /// The first text field whose text matches [pattern].
  String fieldText(RegExp pattern) {
    for (final field in tester.widgetList<EditableText>(find.byType(EditableText))) {
      final text = field.controller.text;
      if (pattern.hasMatch(text)) {
        return text;
      }
    }
    return '';
  }

  /// Types [text] in the field whose hint [hint] finds.
  Future<void> enter(Finder hint, String text) async {
    final field = find.ancestor(of: hint, matching: find.byType(TextField));
    await waitFor(field);
    await tester.ensureVisible(field.first);
    await tester.enterText(field.first, text);
    // A user closes the keyboard before the next tap; the test text input keeps it up.
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(const Duration(milliseconds: 600));
  }

  final _layoutErrors = <String>[];
  String _step = 'boot';

  /// Records each layout overflow with the step that showed it. The app logs and drops them.
  void watchLayoutErrors() {
    final appHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) {
        _layoutErrors.add('$_step: ${text.split('\n').first}');
      }
      appHandler?.call(details);
    };
  }

  /// Names the step that the next layout errors belong to.
  void step(String name) => _step = name;

  /// The layout overflows seen so far.
  List<String> get layoutErrors => List.unmodifiable(_layoutErrors);
}
