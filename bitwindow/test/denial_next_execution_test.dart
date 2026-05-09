import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

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
}
