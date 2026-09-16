import 'package:bitwindow/widgets/ecash_migration_dialog.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

ECashMigrationStatus _records(int done, int total) =>
    ECashMigrationStatus(recordsDone: Int64(done), recordsTotal: Int64(total));

void main() {
  group('groupDigits', () {
    test('groups from the right', () {
      expect(groupDigits(1240118), '1 240 118');
      expect(groupDigits(963647), '963 647');
      expect(groupDigits(812), '812');
      expect(groupDigits(0), '0');
    });
  });

  group('migrationRecordFraction', () {
    test('no records reported reads as zero, never a divide by zero', () {
      expect(migrationRecordFraction(_records(0, 0)), 0);
    });

    test('a part way conversion reads as its share', () {
      expect(migrationRecordFraction(_records(412300, 1240118)), closeTo(0.3324, 0.0001));
    });

    test('more done than total still stops at one', () {
      expect(migrationRecordFraction(_records(12, 10)), 1);
    });
  });

  group('migrationStepShowsRecords', () {
    test('the conversion step carries the bar', () {
      expect(migrationStepShowsRecords('convert', _records(412300, 1240118)), isTrue);
    });

    test('a later step never carries it, although the counts stay set', () {
      expect(migrationStepShowsRecords('select', _records(1240118, 1240118)), isFalse);
      expect(migrationStepShowsRecords('check', _records(1240118, 1240118)), isFalse);
    });

    test('the conversion step without counts carries no bar', () {
      expect(migrationStepShowsRecords('convert', _records(0, 0)), isFalse);
    });
  });

  group('migrationRecordLabel', () {
    test('names both counts and the percent', () {
      expect(migrationRecordLabel(_records(412300, 1240118)), '412 300 of 1 240 118 records · 33%');
    });
  });

  group('migrationElapsedLabel', () {
    final started = DateTime.utc(2026, 9, 16, 12);

    test('under a minute reads as seconds', () {
      expect(
        migrationElapsedLabel(started.millisecondsSinceEpoch ~/ 1000, now: started.add(const Duration(seconds: 42))),
        '42 s',
      );
    });

    test('over a minute reads as minutes and padded seconds', () {
      expect(
        migrationElapsedLabel(
          started.millisecondsSinceEpoch ~/ 1000,
          now: started.add(const Duration(minutes: 14, seconds: 2)),
        ),
        '14 min 02 s',
      );
    });

    test('a clock behind the start never reads as negative', () {
      expect(
        migrationElapsedLabel(
          started.millisecondsSinceEpoch ~/ 1000,
          now: started.subtract(const Duration(seconds: 5)),
        ),
        '0 s',
      );
    });
  });
}
