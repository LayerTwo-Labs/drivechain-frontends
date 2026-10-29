import 'package:bitwindow/widgets/fork_countdown_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the fork strip counts the blocks that are left', () {
    expect(forkStripLabel('eCash', 10), 'ECASH HARDFORK · IN 10 BLOCKS');
    expect(forkStripLabel('eCash', 1), 'ECASH HARDFORK · IN 1 BLOCK');
    expect(forkStripLabel('', 0), 'HARDFORK · IN 0 BLOCKS');
  });
}
