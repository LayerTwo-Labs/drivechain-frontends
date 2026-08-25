import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

// bitwindowd owns orchestratord. A restart from the frontend would start a
// second one on the default paths, with no owner pid and no bitwindow dir.
void main() {
  final orchestratord = Orchestratord();
  final bitwindowd = BitWindow();

  test('bitwindow restarts the daemon that owns orchestratord', () {
    final target = restartTarget(orchestratord, [orchestratord, bitwindowd], isSidechainApp: false);
    expect(target, same(bitwindowd));
  });

  test('a sidechain app restarts orchestratord itself, because it spawns it', () {
    final target = restartTarget(orchestratord, [orchestratord], isSidechainApp: true);
    expect(target, same(orchestratord));
  });

  test('an app with no bitwindowd restarts orchestratord itself', () {
    final target = restartTarget(orchestratord, [orchestratord], isSidechainApp: false);
    expect(target, same(orchestratord));
  });

  test('every other binary restarts itself', () {
    expect(restartTarget(bitwindowd, [orchestratord, bitwindowd], isSidechainApp: false), same(bitwindowd));

    final core = BitcoinCore();
    expect(restartTarget(core, [core, bitwindowd], isSidechainApp: false), same(core));
  });
}
