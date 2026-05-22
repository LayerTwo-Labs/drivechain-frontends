// Regression for #1739: re-running a sidechain's init() blew up with
// "Type Logger is already registered" because every registerSingleton call
// was unconditional. Commit 29a6ca4b wrapped 74 of those calls with
// `if (!GetIt.I.isRegistered<T>())`. This locks in the contract that the
// guard pattern is idempotent.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

void registerOnce<T extends Object>(T Function() factory) {
  if (!GetIt.I.isRegistered<T>()) {
    GetIt.I.registerSingleton<T>(factory());
  }
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  test('guarded registration is idempotent across repeated init() calls', () {
    final first = Logger();
    registerOnce<Logger>(() => first);
    registerOnce<Logger>(() => Logger()); // would throw without the guard
    registerOnce<Logger>(() => Logger());

    expect(GetIt.I.get<Logger>(), same(first));
  });
}
