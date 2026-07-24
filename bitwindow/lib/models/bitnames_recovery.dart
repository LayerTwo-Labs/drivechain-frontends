enum BitnamesChainHealthState {
  unknown,
  disconnected,
  synced,
  waitingForBlock,
  recovering,
  stalled,
  error,
}

class BitnamesChainSnapshot {
  const BitnamesChainSnapshot({
    this.state = BitnamesChainHealthState.unknown,
    this.enforcerHeight,
    this.enforcerHash,
    this.bitnamesMainchainHash,
    this.sidechainHeight,
    this.sidechainHash,
    this.peerCount,
    this.observedAt,
    this.lastProgressAt,
    this.lastReconciledAt,
    this.recoveryAttempts = 0,
    this.recoveryTip,
    this.error,
  });

  final BitnamesChainHealthState state;
  final int? enforcerHeight;
  final String? enforcerHash;
  final String? bitnamesMainchainHash;
  final int? sidechainHeight;
  final String? sidechainHash;
  final int? peerCount;
  final DateTime? observedAt;
  final DateTime? lastProgressAt;
  final DateTime? lastReconciledAt;
  final int recoveryAttempts;
  final String? recoveryTip;
  final String? error;

  bool get mutationSafe =>
      state == BitnamesChainHealthState.synced || state == BitnamesChainHealthState.waitingForBlock;
  bool get needsAttention =>
      state == BitnamesChainHealthState.stalled ||
      state == BitnamesChainHealthState.error ||
      state == BitnamesChainHealthState.disconnected;

  String get summary => switch (state) {
    BitnamesChainHealthState.unknown => 'Checking BitNames chain progress…',
    BitnamesChainHealthState.disconnected => 'BitNames or its enforcer is disconnected',
    BitnamesChainHealthState.synced => 'BitNames is operational • sidechain block ${sidechainHeight ?? 'unknown'}',
    BitnamesChainHealthState.waitingForBlock => 'Transaction submitted • waiting for a BitNames miner and BMM block',
    BitnamesChainHealthState.recovering => 'BitNames RPC failed • restarting it once and reconciling',
    BitnamesChainHealthState.stalled =>
      'BitNames has not produced a sidechain block • submitted transactions remain pending',
    BitnamesChainHealthState.error => 'Could not verify BitNames chain progress',
  };

  String get details {
    final enforcer = '${enforcerHeight ?? '?'} • ${_short(enforcerHash)}';
    final observed = _short(bitnamesMainchainHash);
    final sidechain = '${sidechainHeight ?? '?'} • ${_short(sidechainHash)}';
    final parts = [
      'Enforcer tip $enforcer',
      'Sidechain tip BMM-verified in mainchain block $observed',
      'BitNames sidechain $sidechain',
      if (peerCount != null) '$peerCount peer${peerCount == 1 ? '' : 's'}',
      if (lastProgressAt != null) 'last progress ${lastProgressAt!.toIso8601String()}',
      if (error != null) error!,
    ];
    return parts.join(' • ');
  }

  BitnamesChainSnapshot copyWith({
    BitnamesChainHealthState? state,
    int? enforcerHeight,
    String? enforcerHash,
    String? bitnamesMainchainHash,
    int? sidechainHeight,
    String? sidechainHash,
    int? peerCount,
    DateTime? observedAt,
    DateTime? lastProgressAt,
    DateTime? lastReconciledAt,
    int? recoveryAttempts,
    String? recoveryTip,
    String? error,
    bool clearRecoveryTip = false,
    bool clearError = false,
  }) {
    return BitnamesChainSnapshot(
      state: state ?? this.state,
      enforcerHeight: enforcerHeight ?? this.enforcerHeight,
      enforcerHash: enforcerHash ?? this.enforcerHash,
      bitnamesMainchainHash: bitnamesMainchainHash ?? this.bitnamesMainchainHash,
      sidechainHeight: sidechainHeight ?? this.sidechainHeight,
      sidechainHash: sidechainHash ?? this.sidechainHash,
      peerCount: peerCount ?? this.peerCount,
      observedAt: observedAt ?? this.observedAt,
      lastProgressAt: lastProgressAt ?? this.lastProgressAt,
      lastReconciledAt: lastReconciledAt ?? this.lastReconciledAt,
      recoveryAttempts: recoveryAttempts ?? this.recoveryAttempts,
      recoveryTip: clearRecoveryTip ? null : recoveryTip ?? this.recoveryTip,
      error: clearError ? null : error ?? this.error,
    );
  }

  factory BitnamesChainSnapshot.fromJson(Map<String, dynamic> json) {
    return BitnamesChainSnapshot(
      state: BitnamesChainHealthState.values.firstWhere(
        (value) => value.name == json['state'],
        orElse: () => BitnamesChainHealthState.unknown,
      ),
      enforcerHeight: json['enforcer_height'] as int?,
      enforcerHash: json['enforcer_hash'] as String?,
      bitnamesMainchainHash: json['bitnames_mainchain_hash'] as String?,
      sidechainHeight: json['sidechain_height'] as int?,
      sidechainHash: json['sidechain_hash'] as String?,
      peerCount: json['peer_count'] as int?,
      observedAt: _date(json['observed_at']),
      lastProgressAt: _date(json['last_progress_at']),
      lastReconciledAt: _date(json['last_reconciled_at']),
      recoveryAttempts: json['recovery_attempts'] as int? ?? 0,
      recoveryTip: json['recovery_tip'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'state': state.name,
    if (enforcerHeight != null) 'enforcer_height': enforcerHeight,
    if (enforcerHash != null) 'enforcer_hash': enforcerHash,
    if (bitnamesMainchainHash != null) 'bitnames_mainchain_hash': bitnamesMainchainHash,
    if (sidechainHeight != null) 'sidechain_height': sidechainHeight,
    if (sidechainHash != null) 'sidechain_hash': sidechainHash,
    if (peerCount != null) 'peer_count': peerCount,
    if (observedAt != null) 'observed_at': observedAt!.millisecondsSinceEpoch,
    if (lastProgressAt != null) 'last_progress_at': lastProgressAt!.millisecondsSinceEpoch,
    if (lastReconciledAt != null) 'last_reconciled_at': lastReconciledAt!.millisecondsSinceEpoch,
    'recovery_attempts': recoveryAttempts,
    if (recoveryTip != null) 'recovery_tip': recoveryTip,
    if (error != null) 'error': error,
  };
}

class BitnamesChainObservation {
  const BitnamesChainObservation({
    required this.enforcerHeight,
    required this.enforcerHash,
    required this.bitnamesMainchainHash,
    required this.sidechainHeight,
    required this.sidechainHash,
    required this.peerCount,
    this.waitingForBlock = false,
  });

  final int enforcerHeight;
  final String enforcerHash;
  final String bitnamesMainchainHash;
  final int sidechainHeight;
  final String sidechainHash;
  final int peerCount;
  final bool waitingForBlock;
}

class BitnamesChainRecoveryDecision {
  const BitnamesChainRecoveryDecision({
    required this.snapshot,
    this.restartBitnames = false,
    this.reconcile = false,
  });

  final BitnamesChainSnapshot snapshot;
  final bool restartBitnames;
  final bool reconcile;
}

class BitnamesChainRecovery {
  const BitnamesChainRecovery({
    this.stallAfter = const Duration(seconds: 90),
    this.maxAutomaticRestarts = 1,
  });

  final Duration stallAfter;
  final int maxAutomaticRestarts;

  BitnamesChainRecoveryDecision disconnected(
    BitnamesChainSnapshot previous,
    DateTime now,
  ) {
    return BitnamesChainRecoveryDecision(
      snapshot: previous.copyWith(
        state: BitnamesChainHealthState.disconnected,
        observedAt: now,
      ),
    );
  }

  BitnamesChainRecoveryDecision failed(
    BitnamesChainSnapshot previous,
    DateTime now,
    Object error,
  ) {
    final canRestart = previous.recoveryAttempts < maxAutomaticRestarts;
    return BitnamesChainRecoveryDecision(
      snapshot: previous.copyWith(
        state: canRestart ? BitnamesChainHealthState.recovering : BitnamesChainHealthState.error,
        observedAt: now,
        recoveryAttempts: canRestart ? previous.recoveryAttempts + 1 : previous.recoveryAttempts,
        error: '$error',
      ),
      restartBitnames: canRestart,
    );
  }

  BitnamesChainRecoveryDecision observe(
    BitnamesChainSnapshot previous,
    BitnamesChainObservation observation,
    DateTime now,
  ) {
    final bitnamesProgressed =
        previous.bitnamesMainchainHash != observation.bitnamesMainchainHash ||
        previous.sidechainHeight != observation.sidechainHeight ||
        previous.sidechainHash != observation.sidechainHash;
    final firstObservation = previous.observedAt == null;
    final lastProgress = firstObservation || bitnamesProgressed
        ? now
        : previous.lastProgressAt ?? previous.observedAt ?? now;
    final state = !observation.waitingForBlock
        ? BitnamesChainHealthState.synced
        : now.difference(lastProgress) < stallAfter
        ? BitnamesChainHealthState.waitingForBlock
        : BitnamesChainHealthState.stalled;
    return BitnamesChainRecoveryDecision(
      snapshot: _snapshot(
        observation,
        now,
        lastProgress,
        state,
        recoveryAttempts: 0,
      ),
      reconcile: true,
    );
  }

  BitnamesChainSnapshot _snapshot(
    BitnamesChainObservation observation,
    DateTime now,
    DateTime lastProgress,
    BitnamesChainHealthState state, {
    required int recoveryAttempts,
    String? recoveryTip,
  }) {
    return BitnamesChainSnapshot(
      state: state,
      enforcerHeight: observation.enforcerHeight,
      enforcerHash: observation.enforcerHash,
      bitnamesMainchainHash: observation.bitnamesMainchainHash,
      sidechainHeight: observation.sidechainHeight,
      sidechainHash: observation.sidechainHash,
      peerCount: observation.peerCount,
      observedAt: now,
      lastProgressAt: lastProgress,
      recoveryAttempts: recoveryAttempts,
      recoveryTip: recoveryTip,
    );
  }
}

enum BitnamesOperationType {
  registration,
  profilePublication,
}

enum BitnamesOperationPhase {
  prepared,
  reservationSubmitting,
  reservationSubmitted,
  registrationSubmitting,
  registrationSubmitted,
  profileSubmitting,
  profileSubmitted,
  confirmed,
  paused,
  failed,
  cancelled,
}

class BitnamesOperation {
  const BitnamesOperation({
    required this.id,
    required this.type,
    required this.phase,
    required this.bitnameHash,
    required this.createdAt,
    required this.updatedAt,
    this.plaintextName,
    this.reservationTxid,
    this.txid,
    this.introductionFeeSats,
    this.encryptionPubkey,
    this.signingPubkey,
    this.profile,
    this.lastObservedSidechainHeight,
    this.attempts = 0,
    this.maySpend = false,
    this.lastError,
  });

  final String id;
  final BitnamesOperationType type;
  final BitnamesOperationPhase phase;
  final String bitnameHash;
  final String? plaintextName;
  final String? reservationTxid;
  final String? txid;
  final int? introductionFeeSats;
  final String? encryptionPubkey;
  final String? signingPubkey;
  final Map<String, dynamic>? profile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? lastObservedSidechainHeight;
  final int attempts;
  final bool maySpend;
  final String? lastError;

  bool get terminal =>
      phase == BitnamesOperationPhase.confirmed ||
      phase == BitnamesOperationPhase.failed ||
      phase == BitnamesOperationPhase.cancelled;
  bool get uncertain =>
      phase == BitnamesOperationPhase.reservationSubmitting ||
      phase == BitnamesOperationPhase.registrationSubmitting ||
      phase == BitnamesOperationPhase.profileSubmitting;

  BitnamesOperation copyWith({
    BitnamesOperationPhase? phase,
    String? reservationTxid,
    String? txid,
    int? introductionFeeSats,
    String? encryptionPubkey,
    String? signingPubkey,
    Map<String, dynamic>? profile,
    DateTime? updatedAt,
    int? lastObservedSidechainHeight,
    int? attempts,
    bool? maySpend,
    String? lastError,
    bool clearError = false,
  }) {
    return BitnamesOperation(
      id: id,
      type: type,
      phase: phase ?? this.phase,
      bitnameHash: bitnameHash,
      plaintextName: plaintextName,
      reservationTxid: reservationTxid ?? this.reservationTxid,
      txid: txid ?? this.txid,
      introductionFeeSats: introductionFeeSats ?? this.introductionFeeSats,
      encryptionPubkey: encryptionPubkey ?? this.encryptionPubkey,
      signingPubkey: signingPubkey ?? this.signingPubkey,
      profile: profile ?? this.profile,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastObservedSidechainHeight: lastObservedSidechainHeight ?? this.lastObservedSidechainHeight,
      attempts: attempts ?? this.attempts,
      maySpend: maySpend ?? this.maySpend,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }

  factory BitnamesOperation.fromJson(Map<String, dynamic> json) {
    return BitnamesOperation(
      id: json['id'] as String,
      type: BitnamesOperationType.values.firstWhere(
        (value) => value.name == json['type'],
      ),
      phase: BitnamesOperationPhase.values.firstWhere(
        (value) => value.name == json['phase'],
      ),
      bitnameHash: json['bitname_hash'] as String,
      plaintextName: json['plaintext_name'] as String?,
      reservationTxid: json['reservation_txid'] as String?,
      txid: json['txid'] as String?,
      introductionFeeSats: json['introduction_fee_sats'] as int?,
      encryptionPubkey: json['encryption_pubkey'] as String?,
      signingPubkey: json['signing_pubkey'] as String?,
      profile: json['profile'] is Map ? Map<String, dynamic>.from(json['profile'] as Map) : null,
      createdAt: _date(json['created_at'])!,
      updatedAt: _date(json['updated_at'])!,
      lastObservedSidechainHeight: json['last_observed_sidechain_height'] as int?,
      attempts: json['attempts'] as int? ?? 0,
      maySpend: json['may_spend'] == true,
      lastError: json['last_error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'phase': phase.name,
    'bitname_hash': bitnameHash,
    if (plaintextName != null) 'plaintext_name': plaintextName,
    if (reservationTxid != null) 'reservation_txid': reservationTxid,
    if (txid != null) 'txid': txid,
    if (introductionFeeSats != null) 'introduction_fee_sats': introductionFeeSats,
    if (encryptionPubkey != null) 'encryption_pubkey': encryptionPubkey,
    if (signingPubkey != null) 'signing_pubkey': signingPubkey,
    if (profile != null) 'profile': profile,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
    if (lastObservedSidechainHeight != null) 'last_observed_sidechain_height': lastObservedSidechainHeight,
    'attempts': attempts,
    'may_spend': maySpend,
    if (lastError != null) 'last_error': lastError,
  };
}

DateTime? _date(Object? value) => value is int ? DateTime.fromMillisecondsSinceEpoch(value) : null;

String _short(String? value) {
  if (value == null || value.isEmpty) return 'unknown';
  return value.length <= 12 ? value : '${value.substring(0, 12)}…';
}
