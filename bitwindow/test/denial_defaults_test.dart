import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normal deniability defaults are CI-safe regression values', () {
    expect(DenialDefaults.normalHops, 3);
    expect(DenialDefaults.normalMinutes, 15);
    expect(DenialDefaults.normalHours, 0);
    expect(DenialDefaults.normalDays, 0);
  });

  test('paranoid deniability defaults remain unchanged', () {
    expect(DenialDefaults.paranoidHops, 6);
    expect(DenialDefaults.paranoidMinutes, 0);
    expect(DenialDefaults.paranoidHours, 0);
    expect(DenialDefaults.paranoidDays, 2);
  });
}
