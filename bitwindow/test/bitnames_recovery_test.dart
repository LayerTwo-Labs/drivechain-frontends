import 'package:bitwindow/models/bitnames_recovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const recovery = BitnamesChainRecovery(
    stallAfter: Duration(seconds: 90),
  );
  final start = DateTime.utc(2026, 7, 23, 12);

  BitnamesChainObservation observation({
    String enforcerHash = 'enforcer-1',
    String bitnamesHash = 'bitnames-0',
    int sidechainHeight = 15,
    bool waitingForBlock = false,
  }) {
    return BitnamesChainObservation(
      enforcerHeight: 749,
      enforcerHash: enforcerHash,
      bitnamesMainchainHash: bitnamesHash,
      sidechainHeight: sidechainHeight,
      sidechainHash: 'side-$sidechainHeight',
      peerCount: 1,
      waitingForBlock: waitingForBlock,
    );
  }

  test('normal enforcer advancement does not imply a BitNames stall', () {
    final first = recovery.observe(
      const BitnamesChainSnapshot(),
      observation(),
      start,
    );
    expect(first.snapshot.state, BitnamesChainHealthState.synced);
    expect(first.snapshot.mutationSafe, isTrue);
    expect(first.restartBitnames, isFalse);
  });

  test('pending transaction reports block wait then stalls without restarting', () {
    final first = recovery.observe(
      const BitnamesChainSnapshot(),
      observation(waitingForBlock: true),
      start,
    );
    expect(first.snapshot.state, BitnamesChainHealthState.waitingForBlock);

    final stalled = recovery.observe(
      first.snapshot,
      observation(waitingForBlock: true),
      start.add(const Duration(seconds: 91)),
    );
    expect(stalled.snapshot.state, BitnamesChainHealthState.stalled);
    expect(stalled.restartBitnames, isFalse);
  });

  test('real BitNames progress resets recovery budget', () {
    final recovering = BitnamesChainSnapshot(
      state: BitnamesChainHealthState.stalled,
      enforcerHeight: 749,
      enforcerHash: 'enforcer-1',
      bitnamesMainchainHash: 'bitnames-0',
      sidechainHeight: 15,
      sidechainHash: 'side-15',
      observedAt: start,
      lastProgressAt: start,
      recoveryAttempts: 1,
      recoveryTip: 'enforcer-1',
    );
    final progress = recovery.observe(
      recovering,
      observation(
        bitnamesHash: 'bitnames-1',
        sidechainHeight: 16,
        waitingForBlock: true,
      ),
      start.add(const Duration(seconds: 200)),
    );
    expect(progress.snapshot.state, BitnamesChainHealthState.waitingForBlock);
    expect(progress.snapshot.recoveryAttempts, 0);
    expect(progress.snapshot.lastProgressAt, start.add(const Duration(seconds: 200)));
    expect(progress.restartBitnames, isFalse);
  });

  test('complete operational snapshot unlocks writes and reconciliation', () {
    final decision = recovery.observe(
      const BitnamesChainSnapshot(
        state: BitnamesChainHealthState.waitingForBlock,
      ),
      observation(
        enforcerHash: 'same-tip',
        bitnamesHash: 'same-tip',
        sidechainHeight: 16,
      ),
      start,
    );
    expect(decision.snapshot.state, BitnamesChainHealthState.synced);
    expect(decision.snapshot.mutationSafe, isTrue);
    expect(decision.reconcile, isTrue);
  });

  test('RPC failure gets one bounded restart', () {
    final first = recovery.failed(
      const BitnamesChainSnapshot(),
      start,
      StateError('transport closed'),
    );
    expect(first.snapshot.state, BitnamesChainHealthState.recovering);
    expect(first.restartBitnames, isTrue);

    final persisted = BitnamesChainSnapshot.fromJson(first.snapshot.toJson());
    final second = recovery.failed(
      persisted,
      start.add(const Duration(seconds: 1)),
      StateError('transport still closed'),
    );
    expect(second.snapshot.state, BitnamesChainHealthState.error);
    expect(second.restartBitnames, isFalse);
  });

  test('operation journal round-trips uncertain submission state', () {
    final operation = BitnamesOperation(
      id: 'registration_hash',
      type: BitnamesOperationType.registration,
      phase: BitnamesOperationPhase.registrationSubmitting,
      bitnameHash: 'hash',
      plaintextName: 'alice',
      reservationTxid: 'reservation',
      introductionFeeSats: 500,
      encryptionPubkey: 'encryption',
      signingPubkey: 'signing',
      createdAt: start,
      updatedAt: start.add(const Duration(seconds: 3)),
      lastObservedSidechainHeight: 15,
      attempts: 2,
      maySpend: false,
      lastError: 'outcome unknown',
    );
    final restored = BitnamesOperation.fromJson(operation.toJson());
    expect(restored.phase, BitnamesOperationPhase.registrationSubmitting);
    expect(restored.uncertain, isTrue);
    expect(restored.reservationTxid, 'reservation');
    expect(restored.lastError, 'outcome unknown');
    expect(restored.maySpend, isFalse);
  });
}
