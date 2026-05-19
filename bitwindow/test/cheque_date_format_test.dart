import 'package:bitwindow/pages/wallet/wallet_checks.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';

void main() {
  group('formatChequeDate', () {
    test('returns "-" for null timestamp', () {
      expect(formatChequeDate(null), '-');
    });

    test('returns "-" for zero-valued Timestamp (proto3 default)', () {
      // Proto3 has no way to distinguish "unset" from "epoch 0" for value-
      // typed messages on the wire, so a freshly constructed Timestamp() is
      // indistinguishable from a row where created_at was never written. The
      // formatter must treat both as missing instead of leaking 1970-01-01.
      expect(formatChequeDate(Timestamp()), '-');
      expect(formatChequeDate(Timestamp(seconds: Int64(0), nanos: 0)), '-');
    });

    test('formats a real Timestamp with seconds (Int64)', () {
      // Regression: the previous implementation cast `seconds * 1000` (Int64)
      // to int implicitly, which threw at runtime and fell into a catch that
      // returned "-" — so even cheques with valid CreatedAt rendered as "-".
      // 2026-01-15 12:34:56 UTC = 1768523696
      final ts = Timestamp(seconds: Int64(1768523696));
      final formatted = formatChequeDate(ts);
      expect(formatted, isNot('-'));
      // Don't pin the exact string — locale time zone varies. Just assert
      // the date part is right and it's not an exception fallback.
      expect(formatted, contains('2026'));
      expect(formatted, contains('Jan'));
    });
  });
}
