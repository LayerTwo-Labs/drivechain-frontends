import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  test('the send hint names the sidechain', () {
    expect(sendAddressHint(Thunder().name), 'Enter a Thunder address');
  });
}
