import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

// bitwindowd owns drivechaind. A restart from the frontend would start a
// second one on the default paths, with no owner pid and no bitwindow dir.
void main() {
  final drivechaind = Drivechaind();
  final bitwindowd = BitWindow();

  test('bitwindow restarts the daemon that owns drivechaind', () {
    final target = restartTarget(drivechaind, [drivechaind, bitwindowd], isSidechainApp: false);
    expect(target, same(bitwindowd));
  });

  test('a sidechain app restarts drivechaind itself, because it spawns it', () {
    final target = restartTarget(drivechaind, [drivechaind], isSidechainApp: true);
    expect(target, same(drivechaind));
  });

  test('an app with no bitwindowd restarts drivechaind itself', () {
    final target = restartTarget(drivechaind, [drivechaind], isSidechainApp: false);
    expect(target, same(drivechaind));
  });

  test('every other binary restarts itself', () {
    expect(restartTarget(bitwindowd, [drivechaind, bitwindowd], isSidechainApp: false), same(bitwindowd));

    final core = BitcoinCore();
    expect(restartTarget(core, [core, bitwindowd], isSidechainApp: false), same(core));
  });
}
