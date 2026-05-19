import 'package:bitwindow/pages/liteverse_bridge_status_panel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LiteverseBridgeStatus parses slot mismatch and bridge evidence', () {
    final status = LiteverseBridgeStatus.fromOpsState({
      'ok': true,
      'generatedAt': '2026-05-19T00:00:00.000Z',
      'config': {
        'sidechainId': 73,
      },
      'issues': [],
      'litecoin': {
        'ok': true,
        'value': {
          'chain': 'signet',
          'blocks': 2015,
        },
      },
      'evm': {
        'ok': true,
        'value': {
          'blockNumber': 64387,
          'peerCount': 3,
          'bridgeAddress': '0xb90f5bb563d5d80f0af24c54713535908991e9a8',
        },
      },
      'enforcer': {
        'ok': true,
        'value': {
          'ping': 'Pong',
          'configuredSidechainId': 73,
          'activeSidechains': [
            {
              'proposal': {'sidechain_number': 73},
            },
          ],
          'ctipBySidechain': {
            '73': {
              'ok': true,
              'value': {
                'outpoint': '96fce684e7a800d90a6bff42846935d72d38a4cf60b80edaef9a8cdf76361c73:0',
                'value': 23400,
              },
            },
          },
          'recentEvents': {
            'ok': true,
            'value': {
              'deposits': [],
              'withdrawals': [],
              'bmm': [],
            },
          },
        },
      },
      'relayer': {
        'stateExists': false,
      },
    });

    expect(status.litecoinChain, 'signet');
    expect(status.litecoinHeight, 2015);
    expect(status.detectedSlot, 73);
    expect(status.slotMismatch, isTrue);
    expect(status.isCanonicalSlotActive, isFalse);
    expect(status.activeSlots, [73]);
    expect(status.enforcerHealthyLabel, 'Pong');
    expect(status.besuHealthyLabel, 'healthy');
    expect(status.opsHealthyLabel, 'healthy');
    expect(status.ctipSidechain, 73);
    expect(status.ctipValueSats, 23400);
    expect(status.bmmStatusLabel, 'no recent BMM events');
    expect(status.relayerStateLabel, 'state file not present');
  });
}
