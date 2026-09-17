import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const gap = Duration(seconds: 5);
  final start = DateTime(2026, 9, 17, 8);

  test('the first retry runs', () {
    expect(retryIsDue(last: null, now: start, gap: gap), isTrue);
  });

  test('a retry inside the gap waits', () {
    expect(retryIsDue(last: start, now: start.add(const Duration(seconds: 4)), gap: gap), isFalse);
  });

  test('a retry at the gap runs', () {
    expect(retryIsDue(last: start, now: start.add(gap), gap: gap), isTrue);
  });
}
