import 'package:bitwindow/providers/ecash_migration_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

ECashMigrationStatus _status({
  String jobId = 'job-1',
  String toId = 'betanet',
  bool complete = false,
}) => ECashMigrationStatus(jobId: jobId, fromId: 'alphanet', toId: toId, complete: complete);

void main() {
  group('migrationNavLabel', () {
    test('a running swap names the target with a capital', () {
      expect(migrationNavLabel(_status()), 'Swapping to Betanet');
    });

    test('a stopped job still asks for the label, so the user can resume it', () {
      expect(migrationNavLabel(_status(complete: false)), 'Swapping to Betanet');
    });

    test('no saved job gives no label', () {
      expect(migrationNavLabel(null), '');
      expect(migrationNavLabel(_status(jobId: '')), '');
    });

    test('a complete job gives no label', () {
      expect(migrationNavLabel(_status(complete: true)), '');
    });

    test('a job without a target gives no label', () {
      expect(migrationNavLabel(_status(toId: '')), '');
    });
  });
}
