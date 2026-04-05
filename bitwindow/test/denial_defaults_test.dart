import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('denial dialog default values are correct for signet compatibility', () {
    // Verify the normal defaults match expected values
    expect(DenialDialog.defaultHops, '3');
    expect(DenialDialog.defaultMinutes, '15'); // Fix for issue #1578
    expect(DenialDialog.defaultHours, '0');
    expect(DenialDialog.defaultDays, '0');
  });

  test('paranoid defaults are correct', () {
    expect(DenialDialog.paranoidHops, '6');
    expect(DenialDialog.paranoidMinutes, '0');
    expect(DenialDialog.paranoidHours, '0');
    expect(DenialDialog.paranoidDays, '2');
  });
}
