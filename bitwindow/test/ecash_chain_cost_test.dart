import 'dart:io';

import 'package:bitwindow/widgets/ecash_upgrade_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/orchestrator/v1/bitcoin_conf.pb.dart';

void main() {
  // Both networks fork mainnet, so the chain rewinds to the block they share.
  // Chain data is never deleted, so no line may promise a resync.
  test('a switch names the block it rewinds to', () {
    final line = ecashChainCostLine(
      PlanECashSwitchResponse(fromId: 'drynet4', toId: 'alphanet', rewindHeight: 961631, needsRollback: true),
      'drynet4',
      'alphanet',
    );

    expect(line, contains('961631'));
    expect(line, contains('kept'));
    expect(line.toLowerCase(), isNot(contains('delete')));
  });

  // Without a published fork height there is no shared block to reach, so the
  // switch cannot run. It must say that, not offer to delete the chain.
  test('a blocked switch says it cannot run', () {
    final line = ecashChainCostLine(
      PlanECashSwitchResponse(fromId: 'drynet4', toId: 'alphanet', blocked: true),
      'drynet4',
      'alphanet',
    );

    expect(line, contains('cannot run'));
    expect(line.toLowerCase(), isNot(contains('delete')));
  });

  // A manual conf gets no backend rewind, and still must not promise a delete.
  test('a manual switch never names a delete', () {
    final line = ecashChainCostLine(null, 'drynet4', 'alphanet', manualConf: true);

    expect(line.toLowerCase(), isNot(contains('delete')));
  });

  // The manual steps must never tell the user to delete the chain the app now
  // keeps: every block below the rewind is shared with the target network.
  test('the manual steps keep the chain', () {
    final source = File('lib/widgets/ecash_upgrade_banner.dart').readAsStringSync();
    final steps = source.substring(source.indexOf('_manualSteps'));

    expect(steps, isNot(contains('Delete blocks/')));
    expect(steps, contains('Keep blocks/'));
  });
}
