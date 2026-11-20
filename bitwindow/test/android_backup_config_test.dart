import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _domains = ['root', 'file', 'database', 'sharedpref', 'external'];

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml').readAsStringSync();

  test('the app opts out of Android backup', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="false"'));
    expect(manifest, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
  });

  for (final section in ['cloud-backup', 'device-transfer']) {
    test('$section excludes every data domain', () {
      final body = RegExp('<$section>(.*?)</$section>', dotAll: true).firstMatch(rules)?.group(1);
      expect(body, isNotNull);
      for (final domain in _domains) {
        expect(body, contains('<exclude domain="$domain" />'), reason: domain);
      }
    });
  }
}
