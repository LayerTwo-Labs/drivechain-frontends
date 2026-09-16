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

    test('the count stage says how many records it found, never a percent', () {
      final status = _records(0, 1512480)..recordStage = 'preflight';
      expect(migrationRecordLabel(status), '1 512 480 records found so far');
    });
  });

  group('migrationCountsRecords', () {
    test('the preflight stage counts', () {
      expect(migrationCountsRecords(_records(0, 900000)..recordStage = 'preflight'), isTrue);
    });

    test('the convert stage writes', () {
      expect(migrationCountsRecords(_records(10, 100)..recordStage = 'convert'), isFalse);
    });

    test('no stage reported reads as a write', () {
      expect(migrationCountsRecords(_records(10, 100)), isFalse);
    });
  });

  group('migrationStepShowsRecords', () {
    test('the conversion step shows the count stage although no record is done', () {
      final status = _records(0, 0)..recordStage = 'preflight';
      expect(migrationStepShowsRecords('convert', status), isTrue);
    });
  });

  group('migrationStepShowsDownload', () {
    test('the prepare step shows the download it runs', () {
      final status = ECashMigrationStatus(downloadMbDone: Int64(6), downloadMbTotal: Int64(24));
      expect(migrationStepShowsDownload('prepare', status), isTrue);
    });

    test('a later step never shows it', () {
      final status = ECashMigrationStatus(downloadMbDone: Int64(24), downloadMbTotal: Int64(24));
      expect(migrationStepShowsDownload('convert', status), isFalse);
    });

    test('no download reported shows nothing', () {
      expect(migrationStepShowsDownload('prepare', ECashMigrationStatus()), isFalse);
    });
  });

  group('migrationDownloadLabel', () {
    test('a known size names both figures and the percent', () {
      final status = ECashMigrationStatus(downloadMbDone: Int64(6), downloadMbTotal: Int64(24));
      expect(migrationDownloadLabel(status), '6 MB of 24 MB · 25%');
      expect(migrationDownloadFraction(status), 0.25);
    });

    test('an unknown size names what arrived, and the bar stays open', () {
      final status = ECashMigrationStatus(downloadMbDone: Int64(6), downloadMbTotal: Int64(-1));
      expect(migrationDownloadLabel(status), '6 MB so far');
      expect(migrationDownloadFraction(status), isNull);
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
