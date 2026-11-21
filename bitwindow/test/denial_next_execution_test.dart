import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

void main() {
  group('denialHasScheduledNextExecution', () {
    test('returns false when nextExecutionTime is unset', () {
      final info = DenialInfo();
      expect(denialHasScheduledNextExecution(info), false);
    });

    test('returns false when nextExecutionTime is the epoch-zero default', () {
      final info = DenialInfo(nextExecutionTime: Timestamp());
      expect(denialHasScheduledNextExecution(info), false);
    });

    test('returns true for a real future timestamp', () {
      final info = DenialInfo(
        nextExecutionTime: Timestamp.fromDateTime(DateTime(2030, 1, 1)),
      );
      expect(denialHasScheduledNextExecution(info), true);
    });
  });

  group('denialNextExecutionLabel', () {
    final now = DateTime.utc(2026, 11, 20, 12);
    DenialInfo at(Duration d) => DenialInfo(nextExecutionTime: Timestamp.fromDateTime(now.add(d)));

    test('shows a dash when no hop is scheduled', () {
      expect(denialNextExecutionLabel(DenialInfo(nextExecutionTime: Timestamp()), now), '-');
    });

    test('shows now when the hop is due', () {
      expect(denialNextExecutionLabel(at(const Duration(seconds: -5)), now), 'now');
    });

    test('rounds seconds up to minutes', () {
      expect(denialNextExecutionLabel(at(const Duration(seconds: 1)), now), 'in 1 min');
      expect(denialNextExecutionLabel(at(const Duration(minutes: 14, seconds: 30)), now), 'in 15 min');
    });

    test('shows hours from one hour', () {
      expect(denialNextExecutionLabel(at(const Duration(minutes: 59, seconds: 30)), now), 'in 1 hour');
      expect(denialNextExecutionLabel(at(const Duration(hours: 2, minutes: 10)), now), 'in 2 hours');
    });

    test('shows days from two days', () {
      expect(denialNextExecutionLabel(at(const Duration(days: 2, hours: 3)), now), 'in 2 days');
    });
  });

  group('denialHopsLabel', () {
    test('shows 0 for a UTXO with no denial', () {
      expect(denialHopsLabel(UnspentOutput()), '0');
    });

    test('keeps the total for a paused denial', () {
      final utxo = UnspentOutput(
        denialInfo: DenialInfo(hopsCompleted: 0, numHops: 2, pausedAt: Timestamp.fromDateTime(DateTime(2026))),
      );
      expect(denialHopsLabel(utxo), '0/2');
    });

    test('keeps the total for a completed denial', () {
      final utxo = UnspentOutput(denialInfo: DenialInfo(hopsCompleted: 3, numHops: 3, nextExecutionTime: Timestamp()));
      expect(denialHopsLabel(utxo), '3/3');
    });
  });
}
