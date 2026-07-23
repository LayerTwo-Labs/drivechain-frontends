import 'dart:convert';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/models/bitnames_commitment.dart';
import 'package:bitwindow/models/bitnames_recovery.dart';
import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/store_mock.dart';

void main() {
  late MockStore store;
  late ClientSettings settings;
  late FixedBitnamesStorageKeySource storageKeys;

  setUp(() async {
    await GetIt.I.reset();
    store = MockStore();
    settings = ClientSettings(store: store, log: Logger());
    storageKeys = FixedBitnamesStorageKeySource();
    GetIt.I.registerSingleton<ClientSettings>(settings);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('BitNames RPC restart is bounded and survives app restart', () async {
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'old-tip',
      sidechainHeight: 15,
      failChainSnapshot: true,
    )..setConnected(true);
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'new-tip')..setConnected(true);
    var restarts = 0;
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async => restarts++,
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await provider.initialize();
    expect(restarts, 1);
    expect(provider.chainHealth.state, BitnamesChainHealthState.recovering);
    await provider.refresh();
    expect(restarts, 1);
    expect(provider.chainHealth.state, BitnamesChainHealthState.error);
    provider.dispose();

    final restored = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async => restarts++,
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await restored.initialize();
    expect(restarts, 1);
    expect(restored.chainHealth.state, BitnamesChainHealthState.error);
    restored.dispose();
  });

  test('confirmed reservation resumes registration once after restart', () async {
    const hash = 'registered-hash';
    final now = DateTime.utc(2026, 7, 23, 13);
    final operation = BitnamesOperation(
      id: 'registration_$hash',
      type: BitnamesOperationType.registration,
      phase: BitnamesOperationPhase.reservationSubmitted,
      bitnameHash: hash,
      plaintextName: 'alice',
      reservationTxid: 'reservation-tx',
      introductionFeeSats: 500,
      createdAt: now,
      updatedAt: now,
    );
    await store.setString(
      'bitintroduction_state_v1',
      jsonEncode({
        'operations': [operation.toJson()],
      }),
    );
    final rpc =
        RecoveryBitnamesRPC(
            bitnamesMainchainHash: 'same-tip',
            sidechainHeight: 15,
          )
          ..setConnected(true)
          ..statuses['reservation-tx'] = BitnamesTransactionStatus.confirmed;
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'same-tip')..setConnected(true);

    final first = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await first.initialize();
    expect(rpc.registerCalls, 1);
    expect(
      first.operations.single.phase,
      BitnamesOperationPhase.registrationSubmitted,
    );
    first.dispose();

    rpc.statuses['registration-tx'] = BitnamesTransactionStatus.pending;
    final second = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await second.initialize();
    expect(rpc.registerCalls, 1);

    rpc
      ..registeredHash = hash
      ..statuses['registration-tx'] = BitnamesTransactionStatus.confirmed
      ..sidechainHeight = 16
      ..sidechainHash = 'side-16';
    await second.refresh();
    expect(
      second.operations.single.phase,
      BitnamesOperationPhase.confirmed,
    );
    expect(second.myIdentities.single.hash, hash);
    expect(rpc.registerCalls, 1);
    second.dispose();
  });

  test('uncertain reservation advances without a second reservation spend', () async {
    final now = DateTime.utc(2026, 7, 23, 13, 30);
    final operation = BitnamesOperation(
      id: 'registration_hash',
      type: BitnamesOperationType.registration,
      phase: BitnamesOperationPhase.reservationSubmitting,
      bitnameHash: 'hash',
      plaintextName: 'alice',
      introductionFeeSats: 500,
      createdAt: now,
      updatedAt: now,
      lastObservedSidechainHeight: 15,
      maySpend: false,
      lastError: 'reservation submission outcome is unknown',
    );
    await store.setString(
      'bitintroduction_state_v1',
      jsonEncode({
        'operations': [operation.toJson()],
      }),
    );
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'verified-mainchain-block',
      sidechainHeight: 16,
    )..setConnected(true);
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'newer-enforcer-tip')..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await provider.initialize();
    expect(rpc.reserveCalls, 0);
    expect(rpc.registerCalls, 1);
    expect(
      provider.operations.single.phase,
      BitnamesOperationPhase.registrationSubmitted,
    );
    provider.dispose();
  });

  test('interrupted unknown registration submission never resubmits', () async {
    final now = DateTime.utc(2026, 7, 23, 14);
    final operation = BitnamesOperation(
      id: 'registration_hash',
      type: BitnamesOperationType.registration,
      phase: BitnamesOperationPhase.registrationSubmitting,
      bitnameHash: 'hash',
      plaintextName: 'alice',
      reservationTxid: 'reservation-tx',
      introductionFeeSats: 500,
      encryptionPubkey: 'encryption',
      signingPubkey: 'signing',
      createdAt: now,
      updatedAt: now,
      maySpend: true,
    );
    await store.setString(
      'bitintroduction_state_v1',
      jsonEncode({
        'operations': [operation.toJson()],
      }),
    );
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'same-tip',
      sidechainHeight: 15,
    )..setConnected(true);
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'same-tip')..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await provider.initialize();
    await provider.refresh();
    expect(rpc.registerCalls, 0);
    expect(provider.operations.single.uncertain, isTrue);
    expect(provider.operations.single.maySpend, isFalse);
    expect(provider.operations.single.lastError, contains('without resubmitting'));
    provider.dispose();
  });

  test('reply-profile reorg locks messaging and does not republish', () async {
    const hash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final baseProfile = BitMessageProfile(
      bitNameHash: hash,
      signingPublicKey: 'signing',
      encryptionPublicKey: 'encryption',
      directEndpoints: [Uri.parse('http://127.0.0.1:37999/bitname/$hash/')],
      paymailFeeSats: 500,
    );
    final manifest = BitNamesCommitmentManifest.forReplyProfile(
      baseProfile,
      network: 'signet',
    );
    final profile = baseProfile.withCommitmentManifest(manifest.toJson());
    final now = DateTime.utc(2026, 7, 23, 15);
    final operation = BitnamesOperation(
      id: 'profile_$hash',
      type: BitnamesOperationType.profilePublication,
      phase: BitnamesOperationPhase.confirmed,
      bitnameHash: hash,
      plaintextName: 'alice',
      txid: 'profile-tx',
      introductionFeeSats: 500,
      encryptionPubkey: 'encryption',
      signingPubkey: 'signing',
      profile: profile.toJson(),
      createdAt: now,
      updatedAt: now,
    );
    await store.setString(
      'bitintroduction_state_v1',
      jsonEncode({
        'profiles': [profile.toJson()],
        'operations': [operation.toJson()],
      }),
    );
    final rpc =
        RecoveryBitnamesRPC(
            bitnamesMainchainHash: 'same-tip',
            sidechainHeight: 15,
            registeredHash: hash,
            commitment: manifest.commitment,
          )
          ..setConnected(true)
          ..statuses['profile-tx'] = BitnamesTransactionStatus.confirmed;
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'same-tip')..setConnected(true);
    final first = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await first.initialize();
    expect(first.selectedProfileReady, isTrue);
    expect(
      first.selectedCommitmentAssessment?.kind,
      BitNamesProfileCommitmentKind.namespaced,
    );
    first.dispose();

    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await provider.initialize();
    expect(provider.selectedProfileReady, isTrue);

    rpc
      ..commitment = 'd' * 64
      ..statuses['profile-tx'] = BitnamesTransactionStatus.absent
      ..sidechainHeight = 16
      ..sidechainHash = 'side-16';
    await provider.refresh();
    await provider.refresh();
    expect(provider.selectedProfilePending, isTrue);
    expect(provider.selectedProfileReady, isFalse);
    expect(provider.operations.single.phase, BitnamesOperationPhase.paused);
    expect(rpc.updateCalls, 0);
    provider.dispose();
  });

  test('unknown application commitment blocks publication before spending', () async {
    const hash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'same-tip',
      sidechainHeight: 15,
      registeredHash: hash,
      commitment: 'e' * 64,
    )..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      storageKeySource: storageKeys,
      autoStart: false,
      commitmentNetwork: 'signet',
      commitmentActivation: BitNamesCommitmentActivation.namespacedV1,
    );
    await provider.initialize();

    expect(provider.selectedCommitmentBlocked, isTrue);
    expect(
      await provider.publishProfile(
        direct: [Uri.parse('http://127.0.0.1:37999')],
        tor: const [],
        paymailFeeSats: 500,
      ),
      isNull,
    );
    expect(rpc.updateCalls, 0);
    expect(provider.error, contains('unknown application commitment'));
    provider.dispose();
  });

  test('commitment race aborts before journaling or spending', () async {
    const hash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'same-tip',
      sidechainHeight: 15,
      registeredHash: hash,
      commitmentFromSecondResolve: 'f' * 64,
    )..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      storageKeySource: storageKeys,
      autoStart: false,
      commitmentNetwork: 'signet',
      commitmentActivation: BitNamesCommitmentActivation.namespacedV1,
    );
    await provider.initialize();

    expect(
      await provider.publishProfile(
        direct: [Uri.parse('http://127.0.0.1:37999')],
        tor: const [],
        paymailFeeSats: 500,
      ),
      isNull,
    );
    expect(rpc.updateCalls, 0);
    expect(provider.operations, isEmpty);
    expect(provider.error, contains('changed while'));
    provider.dispose();
  });

  test('namespaced profile confirms, survives restart, and never downgrades', () async {
    const hash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'same-tip',
      sidechainHeight: 15,
      registeredHash: hash,
    )..setConnected(true);
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'same-tip')..setConnected(true);
    final active = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
      commitmentNetwork: 'signet',
      commitmentActivation: BitNamesCommitmentActivation.namespacedV1,
    );
    await active.initialize();
    final txid = await active.publishProfile(
      direct: [Uri.parse('http://127.0.0.1:37999')],
      tor: const [],
      paymailFeeSats: 500,
    );
    final submitted = rpc.lastUpdates!.commitment.value!;
    final profile = active.profiles[hash]!;

    expect(txid, 'profile-tx');
    expect(rpc.updateCalls, 1);
    expect(rpc.lastUpdateFee, ChatProvider.minerFeeSats);
    expect(profile.commitmentManifest, isNotNull);
    expect(bitNamesAuthoritativeProfileCommitment(profile), submitted);
    expect(active.selectedProfilePending, isTrue);

    rpc
      ..commitment = submitted
      ..statuses['profile-tx'] = BitnamesTransactionStatus.confirmed
      ..sidechainHeight = 16
      ..sidechainHash = 'side-16';
    await active.refresh();
    expect(active.selectedProfileReady, isTrue);
    expect(active.operations.single.phase, BitnamesOperationPhase.confirmed);
    active.dispose();

    final restarted = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
      commitmentNetwork: 'signet',
      commitmentActivation: BitNamesCommitmentActivation.legacyCompatible,
    );
    await restarted.initialize();
    expect(restarted.selectedProfileReady, isTrue);
    expect(
      restarted.selectedCommitmentAssessment?.kind,
      BitNamesProfileCommitmentKind.namespaced,
    );

    await restarted.publishProfile(
      direct: [Uri.parse('http://127.0.0.1:37999')],
      tor: const [],
      paymailFeeSats: 500,
    );
    expect(rpc.updateCalls, 2);
    expect(
      restarted.profiles[hash]!.commitmentManifest,
      isNotNull,
    );
    restarted.dispose();
  });

  test('introduction reorg relocks an accepted relationship', () async {
    const local = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    const remote = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
    final now = DateTime.utc(2026, 7, 23, 16);
    final contact = ChatContact(
      id: remote,
      localBitname: local,
      name: remote,
      plaintextName: 'bob',
      encryptionPubkey: 'remote-encryption',
      signingPubkey: 'remote-signing',
      relationshipState: ChatRelationshipState.accepted,
      introductionId: 'intro-id',
    );
    final introduction = ChatMessage(
      id: 'intro-id',
      content: 'hello',
      senderBitname: local,
      recipientBitname: remote,
      timestamp: now,
      isOutgoing: true,
      kind: ChatMessageKind.introduction,
      deliveryState: ChatDeliveryState.confirmed,
      transport: ChatTransport.bitnamesChain,
      txid: 'intro-tx',
      valueSats: 500,
    );
    final acceptance = ChatMessage(
      id: 'accept-id',
      content: 'accepted',
      senderBitname: remote,
      recipientBitname: local,
      timestamp: now.add(const Duration(seconds: 1)),
      isOutgoing: false,
      kind: ChatMessageKind.acceptance,
      deliveryState: ChatDeliveryState.confirmed,
      transport: ChatTransport.direct,
      introductionId: 'intro-id',
    );
    await store.setString(
      'bitintroduction_state_v1',
      jsonEncode({
        'contacts': [contact.toJson()],
        'messages': [introduction.toJson(), acceptance.toJson()],
      }),
    );
    final rpc =
        RecoveryBitnamesRPC(
            bitnamesMainchainHash: 'verified-mainchain-block',
            sidechainHeight: 15,
            registeredHash: local,
          )
          ..setConnected(true)
          ..statuses['intro-tx'] = BitnamesTransactionStatus.confirmed;
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'newer-enforcer-tip')..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await provider.initialize();
    expect(provider.contacts.single.relationshipState, ChatRelationshipState.accepted);

    rpc
      ..statuses['intro-tx'] = BitnamesTransactionStatus.absent
      ..sidechainHeight = 16
      ..sidechainHash = 'side-16';
    await provider.refresh();
    expect(
      provider.contacts.single.relationshipState,
      ChatRelationshipState.outgoingIntroduction,
    );
    expect(
      provider.messages.firstWhere((message) => message.id == 'intro-id').deliveryState,
      ChatDeliveryState.pending,
    );
    provider.dispose();
  });

  test('wallet lock clears private state and blocks every spend until unlock', () async {
    const local = 'alice';
    const remote = 'bob';
    final contact = ChatContact(
      id: remote,
      localBitname: local,
      name: remote,
      encryptionPubkey: 'remote-encryption',
    );
    final message = ChatMessage(
      id: 'private-message',
      content: 'private',
      senderBitname: local,
      recipientBitname: remote,
      timestamp: DateTime.utc(2026, 7, 23),
      isOutgoing: true,
    );
    await store.setString(
      BitnamesSecureStore.legacyStateKey,
      jsonEncode({
        'contacts': [contact.toJson()],
        'messages': [message.toJson()],
      }),
    );
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'tip',
      sidechainHeight: 15,
    )..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await provider.initialize();
    expect(provider.messages.single.content, 'private');

    storageKeys.lock();
    await _waitFor(() => provider.storageStatus.state == BitnamesStorageState.locked);
    expect(provider.messages, isEmpty);
    expect(provider.contacts, isEmpty);
    expect(await provider.claimIdentity('must-not-spend'), isNull);
    expect(rpc.reserveCalls, 0);

    storageKeys.unlock(
      scope: 'test-wallet',
      secret: 'test-only-bitnames-storage-secret',
    );
    await _waitFor(() => provider.messages.isNotEmpty);
    expect(provider.messages.single.content, 'private');
    provider.dispose();
  });

  test('wrong wallet key never falls back to a plaintext journal or spends', () async {
    final encrypted = BitnamesSecureStore(
      store: store,
      keySource: storageKeys,
    );
    await encrypted.load();
    await encrypted.save({
      'operations': [
        BitnamesOperation(
          id: 'registration_safe',
          type: BitnamesOperationType.registration,
          phase: BitnamesOperationPhase.reservationSubmitted,
          bitnameHash: 'safe',
          plaintextName: 'safe',
          reservationTxid: 'already-paid',
          createdAt: DateTime.utc(2026, 7, 23),
          updatedAt: DateTime.utc(2026, 7, 23),
        ).toJson(),
      ],
    });
    await store.setString(
      BitnamesSecureStore.legacyStateKey,
      jsonEncode({
        'operations': [
          BitnamesOperation(
            id: 'registration_attacker',
            type: BitnamesOperationType.registration,
            phase: BitnamesOperationPhase.prepared,
            bitnameHash: 'attacker',
            plaintextName: 'attacker',
            createdAt: DateTime.utc(2026, 7, 23),
            updatedAt: DateTime.utc(2026, 7, 23),
          ).toJson(),
        ],
      }),
    );
    storageKeys.unlock(
      scope: 'test-wallet',
      secret: 'wrong-secret-for-same-wallet',
    );
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'tip',
      sidechainHeight: 15,
    )..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      storageKeySource: storageKeys,
      autoStart: false,
    );
    await provider.initialize();

    expect(provider.storageStatus.state, BitnamesStorageState.corrupt);
    expect(provider.operations, isEmpty);
    expect(await provider.claimIdentity('attacker'), isNull);
    expect(rpc.reserveCalls, 0);
    expect(await store.getString(BitnamesSecureStore.legacyStateKey), isNotNull);
    provider.dispose();
  });

  test('interrupted direct delivery retries the same encrypted wire once', () async {
    final local = List.filled(64, 'a').join();
    final remote = List.filled(64, 'b').join();
    final profile = BitMessageProfile(
      bitNameHash: remote,
      signingPublicKey: 'signing',
      encryptionPublicKey: 'encryption',
      directEndpoints: [Uri.parse('http://peer.test/bitname/$remote/')],
      paymailFeeSats: 500,
    );
    final contact = ChatContact(
      id: remote,
      localBitname: local,
      name: remote,
      encryptionPubkey: 'encryption',
      signingPubkey: 'signing',
      paymailFeeSats: 500,
      relationshipState: ChatRelationshipState.accepted,
      introductionId: 'intro',
      replyProfile: profile.toJson(),
    );
    final message = ChatMessage(
      id: 'stable-message-id',
      content: 'resume exactly once',
      senderBitname: local,
      recipientBitname: remote,
      timestamp: DateTime.utc(2026, 7, 23),
      isOutgoing: true,
      deliveryState: ChatDeliveryState.pending,
      transport: ChatTransport.direct,
      introductionId: 'intro',
    );
    final wire = BitMessageWire(
      recipientBitNameHash: remote,
      ciphertext: 'same-ciphertext',
    );
    await store.setString(
      BitnamesSecureStore.legacyStateKey,
      jsonEncode({
        'contacts': [contact.toJson()],
        'messages': [message.toJson()],
        'pending_wires': {message.id: wire.toJson()},
      }),
    );
    final commitment = bitMessageProfileCommitment(profile);
    final rpc = RecoveryBitnamesRPC(
      bitnamesMainchainHash: 'tip',
      sidechainHeight: 15,
      registeredHash: remote,
      commitment: commitment,
    )..setConnected(true);
    final dialer = RecoveryDialer(profile);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      storageKeySource: storageKeys,
      transport: BitMessageTransport(directDialer: dialer),
      autoStart: false,
    );
    await provider.initialize();

    expect(dialer.submittedBodies, hasLength(1));
    expect(dialer.submittedBodies.single, contains('same-ciphertext'));
    expect(
      provider.messages.single.deliveryState,
      ChatDeliveryState.confirmed,
    );
    provider.dispose();

    final restartedDialer = RecoveryDialer(profile);
    final restarted = ChatProvider(
      rpc: rpc,
      settings: settings,
      storageKeySource: storageKeys,
      transport: BitMessageTransport(directDialer: restartedDialer),
      autoStart: false,
    );
    await restarted.initialize();
    expect(restartedDialer.submittedBodies, isEmpty);
    expect(restarted.messages.single.id, 'stable-message-id');
    expect(
      restarted.messages.single.deliveryState,
      ChatDeliveryState.confirmed,
    );
    restarted.dispose();
  });
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(condition(), isTrue);
}

class RecoveryEnforcerRPC extends MockEnforcerRPC {
  RecoveryEnforcerRPC({required this.height, required this.hash});

  int height;
  String hash;

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo(
      chain: 'signet',
      blocks: height,
      headers: height,
      bestBlockHash: hash,
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 1,
      initialBlockDownload: false,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: const [],
    );
  }
}

class RecoveryDialer implements BitMessageHttpDialer {
  RecoveryDialer(this.profile);

  final BitMessageProfile profile;
  final List<String> submittedBodies = [];

  @override
  Future<BitMessageHttpResponse> get(
    Uri uri, {
    required Duration timeout,
  }) async => BitMessageHttpResponse(
    statusCode: 200,
    body: jsonEncode(bitNamesCommitResponse(profile)),
  );

  @override
  Future<BitMessageHttpResponse> postJson(
    Uri uri, {
    required String body,
    required Duration timeout,
  }) async {
    submittedBodies.add(body);
    return const BitMessageHttpResponse(statusCode: 202, body: '{}');
  }

  @override
  void close() {}
}

class RecoveryBitnamesRPC extends MockBitnamesRPC {
  RecoveryBitnamesRPC({
    required this.bitnamesMainchainHash,
    required this.sidechainHeight,
    this.registeredHash,
    this.commitment,
    this.commitmentFromSecondResolve,
    this.failChainSnapshot = false,
  });

  String bitnamesMainchainHash;
  int sidechainHeight;
  String sidechainHash = 'side-15';
  String? registeredHash;
  String? commitment;
  String? commitmentFromSecondResolve;
  bool failChainSnapshot;
  int registerCalls = 0;
  int reserveCalls = 0;
  int updateCalls = 0;
  int resolveCalls = 0;
  BitNameDataUpdates? lastUpdates;
  int? lastUpdateFee;
  final Map<String, BitnamesTransactionStatus> statuses = {};

  @override
  Future<String?> getBestMainchainBlockHash() async {
    if (failChainSnapshot) throw StateError('transport closed');
    return bitnamesMainchainHash;
  }

  @override
  Future<String?> getBestSidechainBlockHash() async => sidechainHash;

  @override
  Future<int> getBlockCount() async => sidechainHeight;

  @override
  Future<List<BitnamesPeerInfo>> listPeers() async => [
    BitnamesPeerInfo(address: '127.0.0.1:6002', status: 'connected'),
  ];

  @override
  Future<BalanceResponse> getBalance() async => BalanceResponse(totalSats: 100000, availableSats: 100000);

  @override
  Future<BitnamesTransactionStatus> transactionStatus(String txid) async =>
      statuses[txid] ?? BitnamesTransactionStatus.absent;

  @override
  Future<bool> isTransactionConfirmed(String txid) async =>
      await transactionStatus(txid) == BitnamesTransactionStatus.confirmed;

  @override
  Future<String> registerBitName(String plainName, BitNameData? data) async {
    registerCalls++;
    return 'registration-tx';
  }

  @override
  Future<String> reserveBitName(String name) async {
    reserveCalls++;
    return 'reservation-tx';
  }

  @override
  Future<String> updateBitName({
    required String bitname,
    required BitNameDataUpdates updates,
    required int feeSats,
  }) async {
    updateCalls++;
    lastUpdates = updates;
    lastUpdateFee = feeSats;
    return 'profile-tx';
  }

  @override
  Future<BitNameResolution?> resolveBitName(String bitname) async {
    if (registeredHash != bitname) return null;
    resolveCalls++;
    return BitNameResolution(
      bitname: bitname,
      outpoint: const {'txid': 'registered', 'vout': 0},
      address: 'address',
      data: BitNameData(
        commitment: resolveCalls >= 2 ? commitmentFromSecondResolve ?? commitment : commitment,
        encryptionPubkey: 'encryption',
        signingPubkey: 'signing',
        paymailFeeSats: 500,
      ),
    );
  }

  @override
  Future<List<BitnameEntry>> listBitNames() async {
    final hash = registeredHash;
    if (hash == null) return [];
    return [
      BitnameEntry(
        hash: hash,
        plaintextName: 'alice',
        details: BitnameDetails(
          seqId: '1',
          commitment: commitment,
          encryptionPubkey: 'encryption',
          signingPubkey: 'signing',
          paymailFeeSats: 500,
        ),
      ),
    ];
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final hash = registeredHash;
    if (hash == null) return [];
    return [
      BitnamesUTXO(
        outpoint: 'registered:0',
        address: 'address',
        valueSats: 0,
        type: OutpointType.bitname,
        content: jsonEncode({'BitName': hash}),
      ),
    ];
  }

  @override
  Future<List<PaymailEntry>> getPaymailEntries() async => [];
}
