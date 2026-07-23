import 'dart:convert';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/models/bitnames_recovery.dart';
import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/store_mock.dart';

void main() {
  late MockStore store;
  late ClientSettings settings;

  setUp(() async {
    await GetIt.I.reset();
    store = MockStore();
    settings = ClientSettings(store: store, log: Logger());
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
    final profile = BitMessageProfile(
      bitNameHash: hash,
      signingPublicKey: 'signing',
      encryptionPublicKey: 'encryption',
      directEndpoints: [Uri.parse('http://127.0.0.1:37999/bitname/$hash/')],
      paymailFeeSats: 500,
    );
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
            commitment: bitMessageProfileCommitment(profile),
          )
          ..setConnected(true)
          ..statuses['profile-tx'] = BitnamesTransactionStatus.confirmed;
    final enforcer = RecoveryEnforcerRPC(height: 749, hash: 'same-tip')..setConnected(true);
    final provider = ChatProvider(
      rpc: rpc,
      settings: settings,
      enforcer: enforcer,
      restartBitnames: () async {},
      autoStart: false,
    );
    await provider.initialize();
    expect(provider.selectedProfileReady, isTrue);

    rpc
      ..commitment = 'different-commitment'
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

class RecoveryBitnamesRPC extends MockBitnamesRPC {
  RecoveryBitnamesRPC({
    required this.bitnamesMainchainHash,
    required this.sidechainHeight,
    this.registeredHash,
    this.commitment,
    this.failChainSnapshot = false,
  });

  String bitnamesMainchainHash;
  int sidechainHeight;
  String sidechainHash = 'side-15';
  String? registeredHash;
  String? commitment;
  bool failChainSnapshot;
  int registerCalls = 0;
  int reserveCalls = 0;
  int updateCalls = 0;
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
    return 'profile-tx';
  }

  @override
  Future<BitNameResolution?> resolveBitName(String bitname) async {
    if (registeredHash != bitname) return null;
    return BitNameResolution(
      bitname: bitname,
      outpoint: const {'txid': 'registered', 'vout': 0},
      address: 'address',
      data: BitNameData(
        commitment: commitment,
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
