import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/models/bitnames_commitment.dart';
import 'package:bitwindow/models/bitnames_recovery.dart';
import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/services/bitintroduction_codec.dart';
import 'package:bitwindow/services/bitmessage_server.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:bitwindow/services/bitnames_bitintroduction_backend.dart';
import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:bitwindow/services/bitnames_tor_controller.dart';
import 'package:bitwindow/services/tor_bitmessage_dialer.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:synchronized/synchronized.dart';
import 'package:thirds/blake3.dart';
import 'package:uuid/uuid.dart';

// dart format off
enum ChatSendDisposition { sent, needsChainConfirmation, failed }
class ChatSendResult {
  const ChatSendResult(this.disposition, {this.id, this.reference, this.error}); final ChatSendDisposition disposition; final String? id, reference, error;
  bool get sent => disposition == ChatSendDisposition.sent; bool get needsChainConfirmation => disposition == ChatSendDisposition.needsChainConfirmation;
}
typedef TorMutationGuard = Future<String?> Function();

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    BitnamesRPC? rpc, ClientSettings? settings, BalanceProvider? balances,
    EnforcerRPC? enforcer, Future<void> Function()? restartBitnames,
    BitMessageTransport? transport, BitnamesTorController? tor, TorMutationGuard? torMutationGuard,
    BitnamesSecureStore? secureStore, BitnamesStorageKeySource? storageKeySource,
    DateTime Function()? now, String Function()? id, this.autoStart = true,
    this.pollInterval = const Duration(seconds: 30), int serverPort = 37999,
    BitnamesChainRecovery chainRecovery = const BitnamesChainRecovery(),
    String? commitmentNetwork,
    BitNamesCommitmentActivation? commitmentActivation,
  }) : bitnamesRPC = rpc ?? GetIt.I.get<BitnamesRPC>(),
       _settings = settings ?? GetIt.I.get<ClientSettings>(),
       _balances = balances ?? _get<BalanceProvider>(),
       _enforcer = enforcer ?? _get<EnforcerRPC>(),
       _restartBitnames = restartBitnames ?? _defaultRestartBitnames,
       // ignore: prefer_initializing_formals
       _chainRecovery = chainRecovery,
       _tor = tor ?? _defaultTor(),
       // ignore: prefer_initializing_formals
       _torMutationGuard = torMutationGuard,
       _now = now ?? DateTime.now,
       _newId = id ?? const Uuid().v4,
       _commitmentNetwork = bitNamesCommitmentNetwork(
         commitmentNetwork ?? _defaultCommitmentNetwork(),
       ),
       _commitmentActivation = commitmentActivation ??
           (_namespacedCommitmentsActivated
               ? BitNamesCommitmentActivation.namespacedV1
               : BitNamesCommitmentActivation.legacyCompatible) {
    _storageKeys = secureStore?.keySource ?? storageKeySource ?? _defaultStorageKeys();
    _secureStore = secureStore ?? BitnamesSecureStore(store: _settings.store, keySource: _storageKeys);
    _verifier = BitnamesBitMessageProfileVerifier(
      bitnamesRPC,
      commitmentNetwork: _commitmentNetwork,
    );
    _codec = BitIntroductionEnvelopeCodec(signer: BitnamesBitIntroductionSigner(bitnamesRPC), signatureBackend: BitnamesBitIntroductionSignatureVerifier(bitnamesRPC), profileVerifier: _verifier, cipherBackend: BitnamesBitMessageCipher(bitnamesRPC));
    _ownsTransport = transport == null;
    _transport = transport ?? BitMessageTransport(directDialer: DirectBitMessageHttpDialer(), torDialer: createTorBitMessageDialer());
    _server = BitMessageServer(port: serverPort, bindAddress: InternetAddress.anyIPv4, allowRemoteClients: () => !_torOnly, profileProvider: (hash) => hash == null ? null : _profiles[hash], onIncomingWire: (wire) async {
      if (!await receiveWire(wire, ChatTransport.direct)) throw const FormatException('BitMessage was rejected');
    });
    bitnamesRPC.addListener(_onConnectionChanged);
    _balances?.addListener(_onBalanceChanged);
    _storageKeys.addListener(_onStorageKeyChanged);
    if (autoStart) unawaited(initialize());
  }

  static const minerFeeSats = 100, fallbackValueSats = 1, maxMessageBytes = 4096;
  static const _namespacedCommitmentsActivated =
      bool.fromEnvironment('BITNAMES_NAMESPACED_COMMITMENTS');
  final BitnamesRPC bitnamesRPC; final ClientSettings _settings; final BalanceProvider? _balances;
  final EnforcerRPC? _enforcer; final Future<void> Function()? _restartBitnames;
  final BitnamesChainRecovery _chainRecovery;
  final BitnamesTorController? _tor; final TorMutationGuard? _torMutationGuard;
  final DateTime Function() _now; final String Function() _newId;
  final String _commitmentNetwork;
  final BitNamesCommitmentActivation _commitmentActivation;
  final bool autoStart; final Duration pollInterval;
  late final BitnamesBitMessageProfileVerifier _verifier; late final BitIntroductionEnvelopeCodec _codec;
  late final BitMessageTransport _transport; late final BitMessageServer _server; late final bool _ownsTransport;
  late final BitnamesStorageKeySource _storageKeys;
  late final BitnamesSecureStore _secureStore;

  List<BitnameEntry> _allBitNames = [];
  List<BitnameEntry> _myIdentities = [];
  Set<String> _ownedHashes = {};
  BitnameEntry? _selectedIdentity;
  String? _preferredIdentityHash;
  ClientSettings get _clientSettings => _settings;
  HashNameMappingSetting _hashNameMapping = HashNameMappingSetting();
  List<ChatContact> _contacts = [];
  final List<ChatMessage> _messages = [];
  final Map<String, BitMessageProfile> _profiles = {}; final Set<String> _pendingProfiles = {}; final Map<String, BitMessageWire> _pendingWires = {};
  final Map<String, BitnamesOperation> _operations = {};
  ChatContact? _selectedContact;
  int _conversationPageSize = 50;
  Timer? _pollTimer;
  Future<void>? _ready; String? _torPeerOnion;
  bool _polling = false, _refreshing = false, _isSending = false, _torOnly = false, _disposed = false;
  String? _error;
  final Lock _saveLock = Lock();
  final Lock _operationLock = Lock();
  final Lock _storageReloadLock = Lock();
  BitnamesChainSnapshot _chainHealth = const BitnamesChainSnapshot();
  BitnamesTorStatus _torStatus = const BitnamesTorStatus(state: BitnamesTorState.unavailable);

  List<BitnameEntry> get allBitNames => _allBitNames;
  List<BitnameEntry> get myIdentities => _myIdentities;
  BitnameEntry? get selectedIdentity => _selectedIdentity;
  ChatContact? get selectedContact => _selectedContact;
  List<ChatContact> get contacts => _contacts.where((c) => c.localBitname == (_selectedIdentity?.hash ?? '')).toList();
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ChatMessage> get _allCurrentConversation => _messages.where((m) {
    final me = _selectedIdentity?.hash, them = _selectedContact?.id;
    return m.localBitname == me && ((m.senderBitname == me && m.recipientBitname == them) ||
        (m.senderBitname == them && m.recipientBitname == me));
  }).toList();
  List<ChatMessage> get currentConversation {
    final local = _selectedIdentity?.hash, remote = _selectedContact?.id;
    if (local == null || remote == null) return [];
    return conversationPage(
      localBitname: local,
      remoteBitname: remote,
      limit: _conversationPageSize,
    );
  }
  bool get hasOlderMessages =>
      _allCurrentConversation.length > currentConversation.length;
  bool get isSending => _isSending;
  bool get isLoading => _ready != null && _myIdentities.isEmpty; String? get error => _error;
  bool get torOnly => _torOnly; BitnamesTorStatus get torStatus => _torStatus;
  bool get hasConfiguredTorPeer => _torPeerOnion != null;
  BalanceProvider get balanceProvider => _balances ?? GetIt.I.get<BalanceProvider>();
  double get balanceBTC => balanceProvider.balanceFor(bitnamesRPC).$1;
  int get balanceSats => (balanceBTC * 100000000).round();
  bool get hasSufficientBalance => balanceSats >= 10000;
  Map<String, BitMessageProfile> get profiles => Map.unmodifiable(_profiles);
  bool profileReady(String hash) {
    final identity = _myIdentities.where((entry) => entry.hash == hash).firstOrNull;
    final profile = _profiles[hash];
    return identity != null &&
        profile != null &&
        !_pendingProfiles.contains(hash) &&
        _profileMatchesCommitment(identity, profile);
  }
  bool get selectedProfileReady => _selectedIdentity != null && profileReady(_selectedIdentity!.hash);
  bool get selectedProfilePending => _selectedIdentity != null && _pendingProfiles.contains(_selectedIdentity!.hash);
  String get commitmentNetwork => _commitmentNetwork;
  String get commitmentMode => _commitmentActivation == BitNamesCommitmentActivation.namespacedV1
      ? 'Namespaced v1 writes enabled'
      : 'Legacy-compatible writes; existing namespaced commitments remain namespaced';
  BitNamesCommitmentAssessment? get selectedCommitmentAssessment {
    final identity = _selectedIdentity;
    if (identity == null) return null;
    return assessBitMessageProfileCommitment(
      profile: _profiles[identity.hash],
      onChainCommitment: identity.details.commitment,
      network: _commitmentNetwork,
    );
  }
  bool get selectedCommitmentBlocked {
    final assessment = selectedCommitmentAssessment;
    return assessment != null && !assessment.writable;
  }
  BitnamesChainSnapshot get chainHealth => _chainHealth;
  List<BitnamesOperation> get operations => List.unmodifiable(_operations.values);
  BitnamesStorageStatus get storageStatus => _secureStore.status;
  bool get privateStorageReady => storageStatus.writable;

  Future<void> initialize() => _ready ??= _init();
  Future<void> _init() async {
    var opened = false;
    await _saveLock.synchronized(() async {
      try {
        final state = await _secureStore.load();
        _clearPrivateMemory();
        if (!storageStatus.writable) return;
        _hydrate(state);
        _restoreOperationStatuses();
        opened = true;
      } on BitnamesStorageException catch (e) {
        _clearPrivateMemory();
        _error = 'Private BitNames storage was not opened: $e';
      }
    });
    if (!opened) {
      _changed();
      return;
    }
    if (_tor != null) _torStatus = await _tor.refresh();
    if (autoStart) await _startRuntime();
    if (_torOnly && _torPeerOnion != null) {
      unawaited(_restoreTor());
    }
    if (bitnamesRPC.connected) await refresh();
    _changed();
  }

  void _hydrate(Map<String, dynamic> state) {
    _contacts = _list(state['contacts'], ChatContact.fromJson);
    _messages.addAll(_list(state['messages'], ChatMessage.fromJson));
    for (final json in _maps(state['profiles'])) { final profile = BitMessageProfile.fromJson(json); _profiles[profile.bitNameHash] = profile; }
    _pendingProfiles.addAll((state['pending_profiles'] as List? ?? []).whereType<String>());
    for (final entry in (state['pending_wires'] is Map ? state['pending_wires'] as Map : const {}).entries) {
      try {
        if (entry.key is String && entry.value is Map) {
          _pendingWires[entry.key as String] = BitMessageWire.fromJson(Map<String, dynamic>.from(entry.value as Map));
        }
      } catch (_) {}
    }
    for (final json in _maps(state['operations'])) {
      try {
        final operation = BitnamesOperation.fromJson(json);
        _operations[operation.id] = operation;
      } catch (_) {}
    }
    if (state['chain_health'] is Map) {
      try {
        _chainHealth = BitnamesChainSnapshot.fromJson(
          Map<String, dynamic>.from(state['chain_health'] as Map),
        );
      } catch (_) {}
    }
    _ownedHashes = (state['owned'] as List? ?? []).whereType<String>().toSet();
    _preferredIdentityHash = state['selected_identity'] is String ? state['selected_identity'] as String : null;
    _torOnly = state['tor_only'] == true;
    _torPeerOnion = state['tor_peer'] is String ? state['tor_peer'] as String : null;
  }

  void _clearPrivateMemory() {
    _contacts = [];
    _messages.clear();
    _profiles.clear();
    _pendingProfiles.clear();
    _pendingWires.clear();
    _operations.clear();
    _ownedHashes.clear();
    _myIdentities = [];
    _selectedIdentity = null;
    _selectedContact = null;
    _conversationPageSize = 50;
    _preferredIdentityHash = null;
    _torPeerOnion = null;
    _torOnly = false;
    _statusMessages.clear();
  }

  Future<void> _startRuntime() async {
    if (!_server.isRunning) {
      try { await _server.start(); }
      catch (e) { _error = 'BitMessage listener unavailable: $e'; }
    }
    startPolling();
  }

  void _onStorageKeyChanged() {
    unawaited(_storageReloadLock.synchronized(() async {
      if (_disposed) return;
      var ready = false;
      await _saveLock.synchronized(() async {
        stopPolling();
        if (_server.isRunning) await _server.stop();
        _clearPrivateMemory();
        try {
          final state = await _secureStore.load();
          if (!storageStatus.writable) {
            _error = null;
            return;
          }
          _hydrate(state);
          _restoreOperationStatuses();
          _error = null;
          ready = true;
        } on BitnamesStorageException catch (e) {
          _error = 'Private BitNames storage was not opened: $e';
        }
      });
      if (ready) {
        if (autoStart) await _startRuntime();
        if (_torOnly && _torPeerOnion != null) unawaited(_restoreTor());
        if (bitnamesRPC.connected) await refresh();
      }
      _changed();
    }));
  }

  Future<void> _restoreTor() async {
    try { await _tor?.enableChainTor(bitnamesRPC, _torPeerOnion!); }
    catch (e) { _error = 'Tor-only BitNames is not ready: $e'; }
    _changed();
  }

  Future<void> refresh() async {
    if (_refreshing || !privateStorageReady) return;
    _refreshing = true;
    try {
      if (_tor != null) _torStatus = await _tor.refresh();
      if (!await _refreshChainHealth()) return;
      await fetchIdentities();
      await _reconcileOperations();
      await fetchPaymail();
      _chainHealth = _chainHealth.copyWith(lastReconciledAt: _now());
      await _save();
    } finally {
      _refreshing = false;
      _changed();
    }
  }

  Future<bool> _refreshChainHealth() async {
    final enforcer = _enforcer;
    if (enforcer == null) return bitnamesRPC.connected;
    final now = _now();
    if (!bitnamesRPC.connected || !enforcer.connected) {
      _chainHealth = _chainRecovery.disconnected(_chainHealth, now).snapshot;
      await _save();
      return false;
    }
    try {
      final enforcerInfo = await enforcer.getBlockchainInfo();
      final bitnamesMainchainHash =
          await bitnamesRPC.getBestMainchainBlockHash();
      final sidechainHeight = await bitnamesRPC.getBlockCount();
      final sidechainHash = await bitnamesRPC.getBestSidechainBlockHash();
      final peers = await bitnamesRPC.listPeers();
      if (bitnamesMainchainHash == null || sidechainHash == null) {
        throw StateError('BitNames did not report complete chain tips');
      }
      final decision = _chainRecovery.observe(
        _chainHealth,
        BitnamesChainObservation(
          enforcerHeight: enforcerInfo.blocks,
          enforcerHash: enforcerInfo.bestBlockHash,
          bitnamesMainchainHash: bitnamesMainchainHash,
          sidechainHeight: sidechainHeight,
          sidechainHash: sidechainHash,
          peerCount: peers.length,
          waitingForBlock: _hasPendingChainWork,
        ),
        now,
      );
      _chainHealth = decision.snapshot;
      await _save();
      if (decision.restartBitnames) {
        final restart = _restartBitnames;
        if (restart == null) {
          _chainHealth = _chainHealth.copyWith(
            state: BitnamesChainHealthState.stalled,
            error: 'Automatic BitNames restart is unavailable',
          );
          await _save();
          return false;
        }
        try {
          await restart();
        } catch (e) {
          _chainHealth = _chainHealth.copyWith(
            state: BitnamesChainHealthState.error,
            error: 'Automatic BitNames restart failed: $e',
          );
          await _save();
        }
        return false;
      }
      return _chainHealth.mutationSafe;
    } catch (e) {
      final decision = _chainRecovery.failed(_chainHealth, now, e);
      _chainHealth = decision.snapshot;
      await _save();
      if (decision.restartBitnames && _restartBitnames != null) {
        try {
          await _restartBitnames();
        } catch (restartError) {
          _chainHealth = _chainHealth.copyWith(
            state: BitnamesChainHealthState.error,
            error: 'Automatic BitNames restart failed: $restartError',
          );
          await _save();
        }
      }
      return false;
    }
  }

  bool get _hasPendingChainWork =>
      _operations.values.any(
        (operation) =>
            !operation.terminal &&
            operation.phase != BitnamesOperationPhase.prepared &&
            operation.phase != BitnamesOperationPhase.paused,
      ) ||
      _messages.any(
        (message) =>
            message.transport == ChatTransport.bitnamesChain &&
            message.deliveryState == ChatDeliveryState.pending,
      );

  Future<void> retryChainRecovery() async {
    if (_chainHealth.state == BitnamesChainHealthState.stalled) {
      _chainHealth = _chainHealth.copyWith(
        state: BitnamesChainHealthState.waitingForBlock,
        observedAt: _now(),
        lastProgressAt: _now(),
        clearError: true,
      );
      await _save();
      await refresh();
      return;
    }
    final restart = _restartBitnames;
    if (restart == null) {
      _fail('BitNames restart is unavailable');
      return;
    }
    _chainHealth = _chainHealth.copyWith(
      state: BitnamesChainHealthState.recovering,
      observedAt: _now(),
      lastProgressAt: _now(),
      recoveryAttempts: _chainHealth.recoveryAttempts + 1,
      recoveryTip: _chainHealth.enforcerHash,
      clearError: true,
    );
    await _save();
    _changed();
    try {
      await restart();
    } catch (e) {
      _chainHealth = _chainHealth.copyWith(
        state: BitnamesChainHealthState.error,
        error: 'Could not restart BitNames: $e',
      );
      await _save();
      _changed();
    }
  }

  void _restoreOperationStatuses() {
    for (final operation in _operations.values.where((op) => !op.terminal)) {
      _addStatus(operation.id, _operationStatus(operation));
    }
  }

  String _operationStatus(BitnamesOperation operation) {
    final name =
        operation.plaintextName ??
        (operation.bitnameHash.length > 8
            ? '${operation.bitnameHash.substring(0, 8)}…'
            : operation.bitnameHash);
    return switch (operation.phase) {
      BitnamesOperationPhase.prepared =>
        'Preparing BitName operation for "$name"',
      BitnamesOperationPhase.reservationSubmitting =>
        'Reservation submission for "$name" was interrupted • checking chain state before any retry',
      BitnamesOperationPhase.reservationSubmitted =>
        'Reservation for "$name" submitted • waiting for a BitNames block'
            '${operation.reservationTxid == null ? '' : ' • transaction ${_short(operation.reservationTxid!)}'}',
      BitnamesOperationPhase.registrationSubmitting =>
        'Registration submission for "$name" was interrupted • checking chain state before any retry',
      BitnamesOperationPhase.registrationSubmitted =>
        '"$name" registration submitted • waiting for a BitNames block'
            '${operation.txid == null ? '' : ' • transaction ${_short(operation.txid!)}'}',
      BitnamesOperationPhase.profileSubmitting =>
        'Reply-profile submission for "$name" was interrupted • checking chain state before any retry',
      BitnamesOperationPhase.profileSubmitted =>
        'Reply profile for "$name" submitted • waiting for a BitNames block'
            '${operation.txid == null ? '' : ' • transaction ${_short(operation.txid!)}'}',
      BitnamesOperationPhase.paused =>
        '$name operation paused safely • ${operation.lastError ?? 'review required'}',
      BitnamesOperationPhase.failed =>
        '$name operation failed • ${operation.lastError ?? 'unknown error'}',
      BitnamesOperationPhase.cancelled => '$name operation cancelled',
      BitnamesOperationPhase.confirmed => '$name operation confirmed',
    };
  }

  Future<void> _putOperation(BitnamesOperation operation) async {
    _operations[operation.id] = operation;
    if (operation.phase == BitnamesOperationPhase.confirmed) {
      _addStatus(operation.id, _operationStatus(operation), completed: true);
    } else if (!operation.terminal) {
      _addStatus(operation.id, _operationStatus(operation));
    }
    await _save();
  }

  void _onConnectionChanged() {
    if (bitnamesRPC.connected && privateStorageReady) {
      unawaited(refresh());
    }
  }

  void _onBalanceChanged() {
    // Notify listeners when balance changes so UI updates
    notifyListeners();
  }

  Future<void> fetchIdentities() async {
    // Load cached data first for quick startup
    await _loadCachedData();

    if (!bitnamesRPC.connected) return;

    try {
      // Load hash-name mappings for friendly names
      final loadedMapping = await _clientSettings.getValue(HashNameMappingSetting());
      _hashNameMapping = loadedMapping as HashNameMappingSetting;

      // Fetch all BitNames (for lookup and search)
      _allBitNames = await bitnamesRPC.listBitNames();
      final namesByHash = {for (final entry in _allBitNames) entry.hash: entry.plaintextName};
      _contacts = _contacts
          .map((contact) => namesByHash[contact.id] == null
              ? contact
              : contact.copyWith(plaintextName: namesByHash[contact.id]))
          .toList();

      // Get wallet UTXOs and find owned BitNames
      final utxos = await bitnamesRPC.listUTXOs();
      final ownedHashes = <String>{};

      for (final utxo in utxos) {
        if (utxo.type == OutpointType.bitname && utxo is BitnamesUTXO) {
          // Extract BitName hash from UTXO content
          try {
            final content = jsonDecode(utxo.content) as Map<String, dynamic>;
            if (content.containsKey('BitName')) {
              final bitnameHash = content['BitName'] as String;
              ownedHashes.add(bitnameHash);
            }
          } catch (e) {
            // Skip malformed content
          }
        }
      }

      // Save owned hashes for quick startup next time
      _ownedHashes = ownedHashes;
      await _saveOwnedHashes();

      // Match owned hashes to full BitName entries
      _myIdentities = _allBitNames.where((entry) => _ownedHashes.contains(entry.hash)).toList();

      final preferredHash = _selectedIdentity?.hash ?? _preferredIdentityHash;
      final refreshed = _myIdentities.where((entry) => entry.hash == preferredHash).firstOrNull;
      if (refreshed == null) _selectedContact = null;
      _selectedIdentity = refreshed ?? _myIdentities.firstOrNull;
      _preferredIdentityHash = _selectedIdentity?.hash;
      for (final identity in _myIdentities) {
        final profile = _profiles[identity.hash];
        final statusId = 'profile_${identity.hash}';
        if (profile != null && _profileMatchesCommitment(identity, profile)) {
          if (_pendingProfiles.remove(identity.hash)) {
            _addStatus(
              statusId,
              'Reply profile confirmed in a BitNames block • "${_identityLabel(identity)}" is ready to message',
              completed: true,
            );
            Timer(const Duration(seconds: 15), () => _removeStatus(statusId));
          }
        } else if (_pendingProfiles.contains(identity.hash) &&
            !_statusMessages.any((status) => status.id == statusId)) {
          _addStatus(
            statusId,
            'Reply profile for "${_identityLabel(identity)}" submitted • waiting for a BitNames block',
          );
        }
      }
      await _save();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch identities: $e';
      notifyListeners();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load hash-name mappings
      final loadedMapping = await _clientSettings.getValue(HashNameMappingSetting());
      _hashNameMapping = loadedMapping as HashNameMappingSetting;
      notifyListeners();
    } catch (e) {
      // Ignore errors on cache load
    }
  }

  Future<void> _saveOwnedHashes() => _save();

  Future<String?> publishProfile({
    required Iterable<Uri> direct,
    required Iterable<Uri> tor,
    required int? paymailFeeSats,
  }) async {
    final me = _selectedIdentity;
    if (me == null) { _fail('Select a registered BitName first'); return null; }
    final statusId = 'profile_${me.hash}';
    final existing = _operations[statusId];
    if (existing?.phase == BitnamesOperationPhase.paused) {
      _fail(
        'The previous reply-profile transaction is paused safely: ${existing!.lastError ?? 'review required'}',
      );
      return null;
    }
    if (existing != null && !existing.terminal) {
      await _reconcileOperations();
      if (!(_operations[statusId]?.terminal ?? true)) {
        _fail('A reply-profile operation for this BitName is already being reconciled');
        return null;
      }
    }
    if (paymailFeeSats != null && paymailFeeSats < 0) { _fail('Introduction fee cannot be negative'); return null; }
    _addStatus(statusId, 'Creating signing and encryption keys for the reply profile...');
    if (!await _mutationAllowed()) { _removeStatus(statusId); return null; }
    BitnamesOperation? operation;
    try {
      final identity = me;
      if (!await _ownsBitNameNow(identity.hash)) {
        throw StateError('The selected BitName is no longer owned by this wallet');
      }
      final resolution = await _resolveOrNull(identity.hash);
      if (resolution == null) {
        throw StateError('The selected BitName is no longer registered');
      }
      final currentCommitment = resolution.data.commitment;
      final signing = resolution.data.signingPubkey ?? await bitnamesRPC.getNewVerifyingKey();
      final encryption = resolution.data.encryptionPubkey ?? await bitnamesRPC.getNewEncryptionKey();
      final proposedProfile = BitMessageProfile(bitNameHash: identity.hash, signingPublicKey: signing,
        encryptionPublicKey: encryption, directEndpoints: direct.map((u) => _path(u, identity.hash)),
        torEndpoints: tor.map((u) => _path(u, identity.hash)), paymailFeeSats: paymailFeeSats);
      if (proposedProfile.directEndpoints.isEmpty && proposedProfile.torEndpoints.isEmpty) {
        _removeStatus(statusId); _fail('Add a direct or Tor endpoint'); return null;
      }
      final planner = BitNamesCommitmentPlanner(
        network: _commitmentNetwork,
        activation: _commitmentActivation,
      );
      var knownProfile = _profiles[identity.hash];
      var assessment = planner.assess(
        onChainCommitment: currentCommitment,
        knownProfile: knownProfile,
      );
      if (!assessment.writable && knownProfile != null) {
        final discovered = await _transport.discoverProfile(knownProfile, torOnly: _torOnly);
        final discoveredAssessment = planner.assess(
          onChainCommitment: currentCommitment,
          knownProfile: discovered,
        );
        if (discoveredAssessment.writable) {
          knownProfile = discovered;
          assessment = discoveredAssessment;
        }
      }
      if (!assessment.writable) {
        throw BitNamesCommitmentConflict('${assessment.summary}. ${assessment.details}');
      }
      final plan = planner.plan(
        profile: proposedProfile,
        currentCommitment: currentCommitment,
        knownProfile: knownProfile,
      );
      final profile = plan.profile;
      _addStatus(
        statusId,
        '${plan.summary} • ${plan.commitment.substring(0, 12)}… on $_commitmentNetwork'
        '${plan.preservedApplications == 0 ? '' : ' • preserving ${plan.preservedApplications} other application namespace(s)'}',
      );
      final preflight = await _resolveOrNull(identity.hash);
      if (preflight == null || !await _ownsBitNameNow(identity.hash)) {
        throw StateError('BitName ownership changed while the reply profile was being prepared');
      }
      if (preflight.data.commitment != currentCommitment) {
        throw const BitNamesCommitmentConflict(
          'The application commitment changed while the reply profile was being prepared; nothing was submitted',
        );
      }
      if (preflight.data.seqId != resolution.data.seqId ||
          preflight.data.signingPubkey != resolution.data.signingPubkey ||
          preflight.data.encryptionPubkey != resolution.data.encryptionPubkey ||
          preflight.data.paymailFeeSats != resolution.data.paymailFeeSats) {
        throw const BitNamesCommitmentConflict(
          'BitName data changed while the reply profile was being prepared; nothing was submitted',
        );
      }
      final now = _now();
      operation = BitnamesOperation(
        id: statusId,
        type: BitnamesOperationType.profilePublication,
        phase: BitnamesOperationPhase.profileSubmitting,
        bitnameHash: identity.hash,
        plaintextName: identity.plaintextName,
        introductionFeeSats: paymailFeeSats,
        encryptionPubkey: encryption,
        signingPubkey: signing,
        profile: profile.toJson(),
        createdAt: now,
        updatedAt: now,
        lastObservedSidechainHeight: _chainHealth.sidechainHeight,
        attempts: 1,
        maySpend: true,
      );
      await _putOperation(operation);
      final txid = await bitnamesRPC.updateBitName(bitname: identity.hash,
        updates: BitNameDataUpdates(commitment: BitNameUpdate.set(plan.commitment),
          signingPubkey: BitNameUpdate.set(signing), encryptionPubkey: BitNameUpdate.set(encryption),
          paymailFeeSats: paymailFeeSats == null ? const BitNameUpdate<int>.delete() : BitNameUpdate.set(paymailFeeSats)),
        feeSats: minerFeeSats);
      _profiles[identity.hash] = profile; _pendingProfiles.add(identity.hash);
      operation = operation.copyWith(
        phase: BitnamesOperationPhase.profileSubmitted,
        txid: txid,
        updatedAt: _now(),
        maySpend: false,
        clearError: true,
      );
      await _putOperation(operation);
      _changed();
      return txid;
    } catch (e) {
      if (operation != null) {
        await _putOperation(
          operation.copyWith(
            updatedAt: _now(),
            maySpend: false,
            lastError: 'Submission outcome is unknown: $e',
          ),
        );
      } else {
        _removeStatus(statusId);
      }
      _fail('Could not publish reply profile: $e'); return null;
    }
  }

  Future<bool> setTorOnly(bool enabled, {String? peerOnion}) async {
    if (!privateStorageReady) {
      _fail('${storageStatus.summary}. Unlock the wallet before changing Tor routing');
      return false;
    }
    if (!enabled && !_torOnly) return true;
    if (enabled && _torOnly && _tor != null && await _tor.chainTorReady(bitnamesRPC)) return true;
    try {
      if (enabled) {
        final controller = _tor;
        final onion = peerOnion;
        if (controller == null || onion == null) {
          throw StateError('No BitNames Tor peer is configured. Use direct mode or connect a Tor-capable contact first');
        }
        await controller.enableChainTor(bitnamesRPC, onion);
        _torPeerOnion = onion;
      } else { await _tor?.disableChainTor(); }
      _torOnly = enabled; await _save(); _changed();
      return true;
    } catch (e) {
      _fail('Could not ${enabled ? 'enable' : 'disable'} Tor mode: $e'); return false;
    }
  }

  Future<BitnamesTorStatus> downloadAndStartTor() async {
    try { _torStatus = await _tor!.downloadAndStart(); }
    catch (e) { _torStatus = BitnamesTorStatus(state: BitnamesTorState.error, error: '$e'); }
    _changed(); return _torStatus;
  }

  Future<bool> addContactFromEntry(BitnameEntry entry) async {
    if (entry.hash == _selectedIdentity?.hash) {
      _fail('Choose a different BitName; you cannot add your current identity'); return false;
    }
    if (entry.details.encryptionPubkey == null) {
      _error = 'BitName has no encryption key';
      notifyListeners();
      return false;
    }

    final resolution = await bitnamesRPC.resolveBitName(entry.hash);
    if (resolution == null) { _fail('Could not resolve this BitName'); return false; }
    final address = resolution.address;

    final contact = ChatContact(
      id: entry.hash,
      localBitname: _selectedIdentity?.hash ?? '',
      name: entry.hash,
      plaintextName: entry.plaintextName,
      encryptionPubkey: entry.details.encryptionPubkey!,
      signingPubkey: entry.details.signingPubkey,
      address: address,
      paymailFeeSats: entry.details.paymailFeeSats,
      isManual: true,
    );

    await addContact(contact);
    return true;
  }

  Future<ChatContact?> lookupBitName(String nameOrHash) async {
    if (!bitnamesRPC.connected) return null;

    try {
      final hash = RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(nameOrHash)
          ? nameOrHash.toLowerCase()
          : blake3Hex(utf8.encode(nameOrHash.trim().toLowerCase()));
      final resolution = await bitnamesRPC.resolveBitName(hash);
      final data = resolution?.data;
      if (data == null || data.encryptionPubkey == null || _selectedIdentity == null) return null;

      return ChatContact(
        id: hash,
        localBitname: _selectedIdentity!.hash,
        name: hash,
        plaintextName: nameOrHash,
        encryptionPubkey: data.encryptionPubkey!,
        signingPubkey: data.signingPubkey,
        address: resolution!.address,
        paymailFeeSats: data.paymailFeeSats,
        isManual: true,
      );
    } catch (e) {
      _error = 'Failed to lookup BitName: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> addContact(ChatContact contact) async {
    final existingIndex = _contacts.indexWhere((c) => c.relationshipId == contact.relationshipId);
    if (existingIndex >= 0) {
      final old = _contacts[existingIndex];
      contact = ChatContact(id: contact.id, localBitname: contact.localBitname, name: contact.name,
        plaintextName: contact.plaintextName, encryptionPubkey: contact.encryptionPubkey,
        signingPubkey: contact.signingPubkey, address: contact.address,
        paymailFeeSats: contact.paymailFeeSats, relationshipState: old.relationshipState,
        introductionId: old.introductionId, replyProfile: old.replyProfile,
        lastMessage: old.lastMessage, lastMessageTime: old.lastMessageTime,
        unreadCount: old.unreadCount, isManual: contact.isManual);
    } else {
      _contacts.add(contact);
    }
    await _storeContact(contact);
  }

  Future<void> _putContact(ChatContact contact) => _storeContact(contact);

  Future<void> _storeContact(ChatContact contact) async {
    _storeContactInMemory(contact);
    await _save(); notifyListeners();
  }

  void _storeContactInMemory(ChatContact contact) {
    final index = _contacts.indexWhere((c) => c.relationshipId == contact.relationshipId);
    if (index >= 0) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    if (_selectedContact?.relationshipId == contact.relationshipId) _selectedContact = contact;
  }

  Future<void> removeContact(String contactId) async {
    _contacts.removeWhere(
      (c) => c.id == contactId && c.localBitname == _selectedIdentity?.hash,
    );
    if (_selectedContact?.id == contactId) {
      _selectedContact = null;
    }
    await _save();
    notifyListeners();
  }

  void selectContact(ChatContact contact) {
    _selectedContact = contact;
    _conversationPageSize = 50;
    notifyListeners();
  }

  void loadOlderMessages() {
    _conversationPageSize += 50;
    notifyListeners();
  }

  /// Search for a BitName by plaintext name using Blake3 hash
  BitnameEntry? searchBitNameByPlaintext(String searchText) {
    if (searchText.isEmpty) return null;

    try {
      final searchHash = blake3Hex(utf8.encode(searchText.toLowerCase()));
      return _allBitNames.firstWhere(
        (entry) => entry.hash.toLowerCase() == searchHash.toLowerCase(),
        orElse: () => throw StateError('Not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get filtered BitNames based on search text
  List<BitnameEntry> getFilteredBitNames(String searchText) {
    if (searchText.isEmpty) return myIdentities;

    final searchLower = searchText.toLowerCase();

    // First try to find by Blake3 hash match
    String? searchHash;
    try {
      searchHash = blake3Hex(utf8.encode(searchLower));
    } catch (e) {
      searchHash = null;
    }

    return myIdentities.where((entry) {
      // Check hash match
      if (searchHash != null && entry.hash.toLowerCase() == searchHash.toLowerCase()) {
        return true;
      }
      // Check plaintext name match
      if (entry.plaintextName?.toLowerCase().contains(searchLower) ?? false) {
        return true;
      }
      // Check hash prefix match
      if (entry.hash.toLowerCase().contains(searchLower)) {
        return true;
      }
      return false;
    }).toList();
  }

  void selectIdentity(BitnameEntry identity) {
    _selectedIdentity = identity;
    _preferredIdentityHash = identity.hash;
    _selectedContact = null;
    _conversationPageSize = 50;
    notifyListeners();
    unawaited(_save());
    fetchPaymail();
  }

  /// Save a plaintext name mapping so BitNames are "decrypted" forever
  Future<void> saveNameMapping(String plaintextName) async {
    await _hashNameMapping.saveMapping(plaintextName, isMine: false);
    // Refresh identities to update plaintext names
    await fetchIdentities();
  }

  // Track status messages for UI feedback (can have multiple concurrent operations)
  final List<StatusMessage> _statusMessages = [];
  List<StatusMessage> get statusMessages => List.unmodifiable(_statusMessages);

  void _addStatus(String id, String message, {bool completed = false}) {
    _statusMessages.removeWhere((s) => s.id == id);
    _statusMessages.add(StatusMessage(id: id, message: message, completed: completed));
    _changed();
  }

  void _removeStatus(String id) {
    _statusMessages.removeWhere((s) => s.id == id);
    _changed();
  }

  // Legacy getters for compatibility - check for any claiming_ status
  bool get isClaiming => _statusMessages.any((s) => s.id.startsWith('claiming_'));
  String? get claimingStatus => _statusMessages.where((s) => s.id.startsWith('claiming_')).firstOrNull?.message;

  /// Reserve and register a BitName automatically
  /// Handles the reserve-wait-register dance internally
  Future<String?> claimIdentity(String plaintextName, {int introductionFeeSats = 1000}) async {
    plaintextName = plaintextName.trim().toLowerCase();
    // Add progress before connection/privacy guards so Register never appears to do nothing.
    final statusId = 'claiming_$plaintextName';
    _addStatus(statusId, 'Preparing registration for "$plaintextName"...');
    if (plaintextName.isEmpty || introductionFeeSats < 0 || introductionFeeSats > 2100000000000000) {
      _fail('Enter a name and an introduction fee from 0 to 2,100,000,000,000,000 sats');
      _removeStatus(statusId); return null;
    }
    if (!bitnamesRPC.connected) {
      _error = 'BitNames not connected';
      _addStatus(statusId, 'Registration paused • BitNames is not connected');
      await Future.delayed(const Duration(seconds: 5));
      _removeStatus(statusId);
      return null;
    }
    if (!await _mutationAllowed()) {
      _addStatus(statusId, 'Registration paused • start BitNames Tor, then try again');
      await Future.delayed(const Duration(seconds: 5));
      _removeStatus(statusId);
      return null;
    }
    _addStatus(statusId, 'Checking balance and existing chain state...');
    try {
      final hash = blake3Hex(utf8.encode(plaintextName));
      final operationId = 'registration_$hash';
      var operation = _operations[operationId];
      if (operation?.phase == BitnamesOperationPhase.paused ||
          operation?.phase == BitnamesOperationPhase.failed ||
          operation?.phase == BitnamesOperationPhase.cancelled) {
        _fail(
          'The previous registration is ${operation!.phase.name}: '
          '${operation.lastError ?? 'review is required before another spend'}',
        );
        return null;
      }
      if (operation != null && !operation.terminal) {
        _addStatus(operation.id, _operationStatus(operation));
      }
      var alreadyRegistered = _allBitNames.any((entry) => entry.hash == hash);
      if (!alreadyRegistered) {
        try {
          alreadyRegistered = await bitnamesRPC.resolveBitName(hash) != null;
        } catch (e) {
          if (!e.toString().toLowerCase().contains('missing bitname')) rethrow;
        }
      }
      if (alreadyRegistered && operation == null) {
        _fail('That BitName is already registered'); return null;
      }
      if (operation == null) {
        final balance = await bitnamesRPC.getBalance();
        if (balance.availableSats < 10000) {
          _error = 'Insufficient BitNames balance. Deposit funds to BitNames sidechain first.';
          notifyListeners();
          return null;
        }
        final now = _now();
        operation = BitnamesOperation(
          id: operationId,
          type: BitnamesOperationType.registration,
          phase: BitnamesOperationPhase.prepared,
          bitnameHash: hash,
          plaintextName: plaintextName,
          introductionFeeSats: introductionFeeSats,
          createdAt: now,
          updatedAt: now,
          lastObservedSidechainHeight: _chainHealth.sidechainHeight,
        );
        await _putOperation(operation);
      }
      const retryDelay = Duration(seconds: 10);
      while (true) {
        await _reconcileOperations();
        operation = _operations[operationId]!;
        if (operation.phase == BitnamesOperationPhase.confirmed) {
          final registered = _myIdentities.where((entry) => entry.hash == hash).firstOrNull;
          if (registered != null) {
            _selectedIdentity = registered;
            _preferredIdentityHash = registered.hash;
            _selectedContact = null;
            await _save();
            _changed();
          }
          Timer(const Duration(seconds: 15), () => _removeStatus(operationId));
          _removeStatus(statusId);
          return operation.txid;
        }
        if (operation.uncertain && operation.lastError != null) {
          _fail(operation.lastError);
          return null;
        }
        if (!_chainHealth.mutationSafe) {
          _fail('${_chainHealth.summary}. Registration will resume automatically after reconciliation.');
          return null;
        }
        await Future.delayed(retryDelay);
        await refresh();
      }
    } catch (e) {
      _error = 'Failed to claim BitName: $e';
      notifyListeners();
      return null;
    } finally {
      _removeStatus(statusId);
    }
  }

  Future<void> _reconcileOperations() =>
      _operationLock.synchronized(_reconcileOperationsUnlocked);

  Future<void> _reconcileOperationsUnlocked() async {
    if (!bitnamesRPC.connected || !_chainHealth.mutationSafe) return;
    for (final operation in _operations.values.toList()) {
      if (operation.phase == BitnamesOperationPhase.failed ||
          operation.phase == BitnamesOperationPhase.cancelled) {
        continue;
      }
      if (operation.type == BitnamesOperationType.registration) {
        await _reconcileRegistration(operation);
      } else {
        await _reconcileProfile(operation);
      }
    }
  }

  Future<void> _reconcileRegistration(BitnamesOperation operation) async {
    final resolution = await _resolveOrNull(operation.bitnameHash);
    final owned = resolution != null && await _ownsBitNameNow(operation.bitnameHash);
    if (owned) {
      if (operation.plaintextName != null) {
        await _hashNameMapping.saveMapping(operation.plaintextName!, isMine: true);
      }
      if (operation.phase != BitnamesOperationPhase.confirmed) {
        await _putOperation(
          operation.copyWith(
            phase: BitnamesOperationPhase.confirmed,
            updatedAt: _now(),
            lastObservedSidechainHeight: _chainHealth.sidechainHeight,
            maySpend: false,
            clearError: true,
          ),
        );
        await fetchIdentities();
      }
      return;
    }

    if (operation.phase == BitnamesOperationPhase.confirmed) {
      await _putOperation(
        operation.copyWith(
          phase: BitnamesOperationPhase.registrationSubmitted,
          updatedAt: _now(),
          maySpend: false,
          lastError:
              'Registration was removed by a reorg or ownership changed; no transaction was resent',
        ),
      );
      return;
    }

    switch (operation.phase) {
      case BitnamesOperationPhase.prepared:
        final submitting = operation.copyWith(
          phase: BitnamesOperationPhase.reservationSubmitting,
          updatedAt: _now(),
          attempts: operation.attempts + 1,
          maySpend: true,
          clearError: true,
        );
        await _putOperation(submitting);
        try {
          final txid = await bitnamesRPC.reserveBitName(operation.plaintextName!);
          await _putOperation(
            submitting.copyWith(
              phase: BitnamesOperationPhase.reservationSubmitted,
              reservationTxid: txid,
              updatedAt: _now(),
              lastObservedSidechainHeight: _chainHealth.sidechainHeight,
              maySpend: false,
              clearError: true,
            ),
          );
        } catch (e) {
          await _putOperation(
            submitting.copyWith(
              updatedAt: _now(),
              maySpend: false,
              lastError:
                  'Reservation submission outcome is unknown; BitWindow will not spend again automatically: $e',
            ),
          );
        }
        return;
      case BitnamesOperationPhase.reservationSubmitting:
        if (operation.lastError == null) {
          await _putOperation(
            operation.copyWith(
              updatedAt: _now(),
              maySpend: false,
              lastError:
                  'BitWindow restarted during reservation submission; checking ownership without resubmitting',
            ),
          );
        } else if (operation.lastObservedSidechainHeight != null &&
            (_chainHealth.sidechainHeight ?? 0) >
                operation.lastObservedSidechainHeight!) {
          await _submitRegistration(
            operation,
            probingUncertainReservation: true,
          );
        }
        return;
      case BitnamesOperationPhase.reservationSubmitted:
        final txid = operation.reservationTxid;
        if (txid == null) {
          await _pauseOperation(operation, 'Reservation transaction ID is missing');
          return;
        }
        final status = await bitnamesRPC.transactionStatus(txid);
        if (status == BitnamesTransactionStatus.absent) {
          await _pauseOperation(
            operation,
            'Reservation is no longer in the canonical chain or mempool; retry requires fresh approval',
          );
          return;
        }
        if (status == BitnamesTransactionStatus.pending) return;
        await _submitRegistration(operation);
        return;
      case BitnamesOperationPhase.registrationSubmitting:
        if (operation.lastError == null) {
          await _putOperation(
            operation.copyWith(
              updatedAt: _now(),
              maySpend: false,
              lastError:
                  'BitWindow restarted during registration submission; checking ownership without resubmitting',
            ),
          );
        }
        return;
      case BitnamesOperationPhase.registrationSubmitted:
        final txid = operation.txid;
        if (txid == null) {
          await _pauseOperation(operation, 'Registration transaction ID is missing');
          return;
        }
        final status = await bitnamesRPC.transactionStatus(txid);
        if (status == BitnamesTransactionStatus.absent) {
          await _pauseOperation(
            operation,
            'Registration is no longer in the canonical chain or mempool; no transaction was resent',
          );
        } else if (status == BitnamesTransactionStatus.confirmed) {
          await _pauseOperation(
            operation,
            'Registration transaction is confirmed but ownership is not visible; wallet reconciliation is required',
          );
        }
        return;
      case BitnamesOperationPhase.profileSubmitting:
      case BitnamesOperationPhase.profileSubmitted:
      case BitnamesOperationPhase.paused:
      case BitnamesOperationPhase.failed:
      case BitnamesOperationPhase.cancelled:
      case BitnamesOperationPhase.confirmed:
        return;
    }
  }

  Future<void> _submitRegistration(
    BitnamesOperation operation, {
    bool probingUncertainReservation = false,
  }) async {
    var current = operation;
    if (current.encryptionPubkey == null || current.signingPubkey == null) {
      current = current.copyWith(
        encryptionPubkey:
            current.encryptionPubkey ??
            await bitnamesRPC.getNewEncryptionKey(),
        signingPubkey:
            current.signingPubkey ?? await bitnamesRPC.getNewVerifyingKey(),
        updatedAt: _now(),
      );
      await _putOperation(current);
    }
    final submitting = current.copyWith(
      phase: BitnamesOperationPhase.registrationSubmitting,
      updatedAt: _now(),
      attempts: current.attempts + 1,
      maySpend: true,
      clearError: true,
    );
    await _putOperation(submitting);
    try {
      final txid = await bitnamesRPC.registerBitName(
        current.plaintextName!,
        BitNameData(
          encryptionPubkey: current.encryptionPubkey,
          signingPubkey: current.signingPubkey,
          paymailFeeSats: current.introductionFeeSats,
        ),
      );
      await _putOperation(
        submitting.copyWith(
          phase: BitnamesOperationPhase.registrationSubmitted,
          txid: txid,
          updatedAt: _now(),
          lastObservedSidechainHeight: _chainHealth.sidechainHeight,
          maySpend: false,
          clearError: true,
        ),
      );
    } catch (e) {
      final missingReservation =
          probingUncertainReservation &&
          RegExp(
            'reservation|missing bitname|not found',
            caseSensitive: false,
          ).hasMatch('$e');
      await _putOperation(
        submitting.copyWith(
          phase: missingReservation
              ? BitnamesOperationPhase.reservationSubmitting
              : BitnamesOperationPhase.registrationSubmitting,
          updatedAt: _now(),
          lastObservedSidechainHeight: _chainHealth.sidechainHeight,
          maySpend: false,
          lastError: missingReservation
              ? 'No confirmed reservation was found at sidechain block '
                    '${_chainHealth.sidechainHeight ?? 'unknown'}; waiting without resubmitting'
              : 'Registration submission outcome is unknown; BitWindow will not spend again automatically: $e',
        ),
      );
    }
  }

  Future<void> _reconcileProfile(BitnamesOperation operation) async {
    BitMessageProfile? profile;
    try {
      profile =
          operation.profile == null
              ? _profiles[operation.bitnameHash]
              : BitMessageProfile.fromJson(operation.profile!);
    } catch (_) {}
    if (profile == null) {
      await _pauseOperation(operation, 'Saved reply profile is missing or invalid');
      return;
    }
    final identity =
        _allBitNames
            .where((entry) => entry.hash == operation.bitnameHash)
            .firstOrNull;
    final canonical =
        identity != null && _profileMatchesCommitment(identity, profile);
    if (canonical) {
      _profiles[operation.bitnameHash] = profile;
      _pendingProfiles.remove(operation.bitnameHash);
      if (operation.phase != BitnamesOperationPhase.confirmed) {
        await _putOperation(
          operation.copyWith(
            phase: BitnamesOperationPhase.confirmed,
            updatedAt: _now(),
            lastObservedSidechainHeight: _chainHealth.sidechainHeight,
            maySpend: false,
            clearError: true,
          ),
        );
      }
      return;
    }

    _pendingProfiles.add(operation.bitnameHash);
    if (operation.phase == BitnamesOperationPhase.confirmed) {
      await _putOperation(
        operation.copyWith(
          phase: BitnamesOperationPhase.profileSubmitted,
          updatedAt: _now(),
          maySpend: false,
          lastError:
              'Reply-profile confirmation was removed by a reorg or replaced; messaging remains locked',
        ),
      );
      return;
    }
    if (operation.phase == BitnamesOperationPhase.profileSubmitting) {
      if (operation.lastError == null) {
        await _putOperation(
          operation.copyWith(
            updatedAt: _now(),
            maySpend: false,
            lastError:
                'BitWindow restarted during reply-profile submission; checking the chain without resubmitting',
          ),
        );
      }
      return;
    }
    if (operation.phase != BitnamesOperationPhase.profileSubmitted) return;
    final txid = operation.txid;
    if (txid == null) {
      await _pauseOperation(operation, 'Reply-profile transaction ID is missing');
      return;
    }
    final status = await bitnamesRPC.transactionStatus(txid);
    if (status == BitnamesTransactionStatus.absent) {
      await _pauseOperation(
        operation,
        'Reply-profile transaction is no longer canonical; no transaction was resent',
      );
    } else if (status == BitnamesTransactionStatus.confirmed) {
      await _pauseOperation(
        operation,
        'Reply-profile transaction confirmed but its commitment is not current; another update may have replaced it',
      );
    }
  }

  Future<void> _pauseOperation(
    BitnamesOperation operation,
    String reason,
  ) =>
      _putOperation(
        operation.copyWith(
          phase: BitnamesOperationPhase.paused,
          updatedAt: _now(),
          maySpend: false,
          lastError: reason,
        ),
      );

  Future<BitNameResolution?> _resolveOrNull(String bitname) async {
    try {
      return await bitnamesRPC.resolveBitName(bitname);
    } catch (e) {
      if (e.toString().toLowerCase().contains('missing bitname')) return null;
      rethrow;
    }
  }

  Future<ChatSendResult> send(String body) async {
    if (_selectedContact?.relationshipState == ChatRelationshipState.accepted) {
      return _sendDirect(body, BitIntroductionKind.message, _selectedContact!.introductionId);
    }
    return sendIntroduction(body);
  }

  Future<String?> sendMessage(String body) async {
    final result = await send(body);
    return result.sent ? result.reference ?? result.id : null;
  }

  Future<ChatSendResult> sendIntroduction(String body) async {
    final contact = _selectedContact;
    if (_isSending) return _failed('A message is already being sent');
    if (contact == null || contact.relationshipState != ChatRelationshipState.none) {
      return _failed('A new introduction is not allowed for this contact'); }
    _isSending = true; _changed();
    try {
      final ctx = await _context();
      final fee = ctx?.remote.data.paymailFeeSats;
      if (ctx == null) {
        return _failed(_error ?? 'Publish the reply profile in Messaging setup and wait for its BitNames block');
      }
      if (fee != ctx.contact.paymailFeeSats) {
        await addContact(ChatContact(id: ctx.contact.id, localBitname: ctx.contact.localBitname,
          name: ctx.contact.name, plaintextName: ctx.contact.plaintextName,
          encryptionPubkey: ctx.remote.data.encryptionPubkey!, signingPubkey: ctx.remote.data.signingPubkey,
          address: ctx.remote.address, paymailFeeSats: fee, isManual: ctx.contact.isManual));
        if (fee == null) return _failed('Recipient is not accepting introductions');
        return _failed('The introduction fee changed to $fee sats; review and confirm it again');
      }
      if (fee == null) return _failed('Recipient is not accepting introductions');
      if (!await _mutationAllowed()) return _failed(_error!);
      final prepared = await _prepare(ctx, body, BitIntroductionKind.introduction, null, true);
      final id = prepared.$1.payload.id, pending = _message(prepared.$1, true, ChatTransport.bitnamesChain, null, fee)
        .copyWith(deliveryState: ChatDeliveryState.pending);
      _pendingWires[id] = prepared.$2;
      final contact = ctx.contact.copyWith(address: ctx.remote.address,
        relationshipState: ChatRelationshipState.outgoingIntroduction, introductionId: prepared.$1.payload.id);
      _storeContactInMemory(contact); _storeMessageInMemory(pending); await _save(); _changed();
      try { final txid = await bitnamesRPC.transferIdempotent(idempotencyKey: id, dest: ctx.remote.address,
        value: fee, fee: minerFeeSats, memo: prepared.$2.ciphertext);
        await _putMessage(pending.copyWith(txid: txid));
        return ChatSendResult(ChatSendDisposition.sent, id: id, reference: txid);
      } catch (e) { return ChatSendResult(ChatSendDisposition.failed, id: id,
        error: 'Introduction is queued and will retry when BitNames reconnects: $e'); }
    } catch (e) { return _failed('Could not send introduction: $e'); }
    finally { _isSending = false; _changed(); }
  }

  Future<ChatSendResult> _sendDirect(String body, BitIntroductionKind kind, String? reply) async {
    if (!privateStorageReady) {
      return _failed('${storageStatus.summary}. ${storageStatus.details ?? 'Unlock the wallet before messaging'}');
    }
    final ctx = await _context();
    final accepting = kind == BitIntroductionKind.acceptance &&
        ctx?.contact.relationshipState == ChatRelationshipState.incomingIntroduction;
    if (ctx == null) {
      return _failed(_error ?? 'Publish the reply profile in Messaging setup and wait for its BitNames block');
    }
    if (!ctx.contact.isAccepted && !accepting) return _failed('Chat is not accepted');
    final remoteProfile = _profile(ctx.contact);
    if (remoteProfile == null) return _failed('This contact has not published a verified reply profile');
    late (SignedBitIntroductionEnvelope, BitMessageWire) prepared;
    try { prepared = await _prepare(ctx, body, kind, reply, true); }
    catch (e) { return _failed('Could not prepare message: $e'); }
    final transport = _torOnly ? ChatTransport.tor : ChatTransport.direct;
    final pending = _message(prepared.$1, true, transport)
        .copyWith(deliveryState: ChatDeliveryState.pending);
    _pendingWires[prepared.$1.payload.id] = prepared.$2;
    _storeMessageInMemory(pending);
    await _save();
    try {
      VerifiedBitMessageProfile verified;
      try { verified = await _verifier.verify(remoteProfile); }
      catch (_) { final current = await _transport.discoverProfile(remoteProfile, torOnly: _torOnly);
        if (current == null) rethrow; verified = await _verifier.verify(current);
        await _putContact(ctx.contact.copyWith(encryptionPubkey: current.encryptionPublicKey,
          signingPubkey: current.signingPublicKey, replyProfile: current.toJson())); }
      await _transport.send(prepared.$2, verified, torOnly: _torOnly);
      _pendingWires.remove(prepared.$1.payload.id);
      _storeMessageInMemory(_message(prepared.$1, true, transport));
      if (accepting) {
        _storeContactInMemory(
          ctx.contact.copyWith(relationshipState: ChatRelationshipState.accepted),
        );
      }
      await _save(); _changed();
      return ChatSendResult(ChatSendDisposition.sent, id: prepared.$1.payload.id);
    } catch (e) {
      _storeMessageInMemory(_message(prepared.$1, true, transport, null, null, '$e'));
      await _save(); _changed();
      return ChatSendResult(ChatSendDisposition.needsChainConfirmation, id: prepared.$1.payload.id, error: '$e');
    }
  }

  Future<ChatSendResult> acceptIntroduction() async {
    if (_isSending) return _failed('A message is already being sent');
    final contact = _selectedContact;
    if (contact?.relationshipState != ChatRelationshipState.incomingIntroduction) return _failed('No introduction to accept');
    if (_messages.any((m) => m.kind == ChatMessageKind.acceptance && m.senderBitname == contact!.localBitname &&
        m.recipientBitname == contact.id && _pendingWires.containsKey(m.id))) {
      return _failed('Retry or reject the pending acceptance first'); }
    _isSending = true; _changed();
    try { return await _sendDirect('accepted', BitIntroductionKind.acceptance, contact!.introductionId);
    } finally { _isSending = false; _changed(); }
  }

  Future<void> rejectIntroduction() => _setRelationship(ChatRelationshipState.rejected);
  Future<void> cancelIntroduction() async {
    final contact = _selectedContact;
    if (_isSending || contact?.relationshipState != ChatRelationshipState.outgoingIntroduction) return;
    final id = contact!.introductionId;
    _pendingWires.remove(id);
    _messages.removeWhere((m) => m.id == id && m.localBitname == contact.localBitname);
    await _putContact(contact.copyWith(
      relationshipState: ChatRelationshipState.rejected, clearIntroductionId: true));
    await _save();
  }
  Future<void> blockContact() => _setRelationship(ChatRelationshipState.blocked);
  Future<void> _setRelationship(ChatRelationshipState state) async {
    if (!_isSending && _selectedContact != null) await _putContact(_selectedContact!.copyWith(relationshipState: state));
  }

  Future<ChatSendResult> sendViaChain(String id) async {
    if (_isSending) return _failed('A message is already being sent');
    final wire = _pendingWires[id];
    final message = _messages.where((m) => m.id == id && m.localBitname == _selectedIdentity?.hash).firstOrNull;
    final contact = message == null ? null : _find(message.senderBitname, message.recipientBitname);
    final accepting = message?.kind == ChatMessageKind.acceptance &&
        contact?.relationshipState == ChatRelationshipState.incomingIntroduction;
    final allowed = message?.kind == ChatMessageKind.acceptance ? accepting : contact?.isAccepted == true;
    if (wire == null || message == null || !allowed ||
        message.kind == ChatMessageKind.introduction) { return _failed('Chain fallback is only available after acceptance'); }
    _isSending = true; _changed();
    try {
      if (!await _mutationAllowed()) return _failed(_error!);
      if (!await _ownsBitNameNow(message.senderBitname)) throw StateError('The sending BitName is no longer owned');
      final remote = await bitnamesRPC.resolveBitName(message.recipientBitname);
      if (remote == null) throw StateError('Recipient is not registered');
      final pending = ChatMessage(id: message.id, content: message.content, senderBitname: message.senderBitname,
          recipientBitname: message.recipientBitname, timestamp: message.timestamp, isOutgoing: true,
          kind: message.kind, deliveryState: ChatDeliveryState.pending, transport: ChatTransport.bitnamesChain,
          introductionId: message.introductionId, valueSats: fallbackValueSats);
      _storeMessageInMemory(pending);
      if (accepting) {
        _storeContactInMemory(
          contact!.copyWith(relationshipState: ChatRelationshipState.acceptancePending),
        );
      }
      await _save(); _changed();
      final txid = await bitnamesRPC.transferIdempotent(idempotencyKey: id, dest: remote.address,
        value: fallbackValueSats, fee: minerFeeSats, memo: wire.ciphertext);
      await _putMessage(pending.copyWith(txid: txid));
      return ChatSendResult(ChatSendDisposition.sent, id: id, reference: txid);
    } catch (e) { return ChatSendResult(ChatSendDisposition.needsChainConfirmation, id: id, error: '$e'); }
    finally { _isSending = false; _changed(); }
  }

  Future<void> fetchPaymail() async {
    if (_polling || !bitnamesRPC.connected) return;
    _polling = true;
    try {
      await _recoverDirectSubmissions();
      await _recoverChainSubmissions();
      await _confirmAcceptances();
      final mailbox = await bitnamesRPC.getPaymailEntries(), validatedChainIds = <String>{};
      for (final mail in mailbox) {
        for (final recipient in mail.recipients.where((r) => _ownedHashes.contains(r.bitname))) {
          try { if (await receiveWire(
            BitMessageWire(recipientBitNameHash: recipient.bitname, ciphertext: mail.output.memoHex), ChatTransport.bitnamesChain,
            value: mail.valueSats, requiredFee: recipient.requiredFeeSats, recipientData: recipient.data,
            reference: canonicalJsonEncode(mail.outpoint), blockHash: mail.blockHash, txIndex: mail.txIndex, validatedChainIds: validatedChainIds,
          )) { break; } } catch (e) { _fail('Could not receive chain message: $e'); }
        }
      }
      await _reconcileChain(validatedChainIds);
    } catch (e) { _fail('Could not poll BitIntroduction messages: $e');
    } finally {
      _polling = false;
    }
  }

  Future<void> _recoverDirectSubmissions() async {
    final pending = _messages.where(
      (message) =>
          message.isOutgoing &&
          message.transport != ChatTransport.bitnamesChain &&
          message.deliveryState == ChatDeliveryState.pending &&
          _pendingWires.containsKey(message.id),
    ).toList();
    for (final message in pending) {
      final contact = _find(message.senderBitname, message.recipientBitname);
      final profile = _profile(contact);
      try {
        if (message.transport == ChatTransport.direct && _torOnly) {
          throw StateError('Direct retry blocked because Tor-only mode is enabled');
        }
        if (contact == null || profile == null) {
          throw StateError('The saved contact reply profile is unavailable');
        }
        final verified = await _verifier.verify(profile);
        await _transport.send(
          _pendingWires[message.id]!,
          verified,
          torOnly: message.transport == ChatTransport.tor,
        );
        _pendingWires.remove(message.id);
        _storeMessageInMemory(
          message.copyWith(deliveryState: ChatDeliveryState.confirmed),
        );
        if (message.kind == ChatMessageKind.acceptance &&
            contact.relationshipState ==
                ChatRelationshipState.incomingIntroduction) {
          _storeContactInMemory(
            contact.copyWith(relationshipState: ChatRelationshipState.accepted),
          );
        }
        await _save();
      } catch (e) {
        _storeMessageInMemory(
          message.copyWith(
            deliveryState: ChatDeliveryState.failed,
            error: 'Interrupted delivery was not retried successfully: $e',
          ),
        );
        await _save();
      }
    }
    if (pending.isNotEmpty) _changed();
  }

  Future<void> _confirmAcceptances() async {
    for (final message in _messages.where((m) => m.kind == ChatMessageKind.acceptance && m.txid != null)) {
      final contact = _find(message.senderBitname, message.recipientBitname);
      if (!{ChatRelationshipState.incomingIntroduction, ChatRelationshipState.acceptancePending}.contains(contact?.relationshipState)) continue;
      try { if (await bitnamesRPC.isTransactionConfirmed(message.txid!)) {
        await _putContact(contact!.copyWith(relationshipState: ChatRelationshipState.accepted)); } } catch (_) {}
    }
  }

  Future<void> _recoverChainSubmissions() async {
    for (final message in _messages.where((m) => m.isOutgoing && m.transport == ChatTransport.bitnamesChain && _pendingWires.containsKey(m.id)).toList()) {
      try {
        final status = message.txid == null ? BitnamesTransactionStatus.absent : await bitnamesRPC.transactionStatus(message.txid!);
        if (status == BitnamesTransactionStatus.confirmed) {
          await _putMessage(message.copyWith(deliveryState: ChatDeliveryState.confirmed)); continue; }
        if (status == BitnamesTransactionStatus.pending || !await _mutationAllowed() || !await _ownsBitNameNow(message.senderBitname)) continue;
        final remote = await bitnamesRPC.resolveBitName(message.recipientBitname); if (remote == null) continue;
        if (message.kind == ChatMessageKind.introduction && remote.data.paymailFeeSats != message.valueSats) continue;
        final txid = await bitnamesRPC.transferIdempotent(idempotencyKey: message.id, dest: remote.address,
          value: message.valueSats!, fee: minerFeeSats, memo: _pendingWires[message.id]!.ciphertext);
        await _putMessage(message.copyWith(txid: txid, deliveryState: ChatDeliveryState.pending));
      } catch (_) {}
    }
  }

  Future<void> _reconcileChain(Set<String> validatedChainIds) async {
    final valid = <String>{}, auth = _messages.where((m) => m.transport == ChatTransport.bitnamesChain).toList();
    for (final message in auth) { try { if (message.txid != null &&
      (message.isOutgoing ? await bitnamesRPC.isTransactionConfirmed(message.txid!) : validatedChainIds.contains(message.id))) { valid.add(message.id); } } catch (_) {} }
    for (final message in auth.where((message) => message.isOutgoing)) {
      final state = valid.contains(message.id)
          ? ChatDeliveryState.confirmed
          : ChatDeliveryState.pending;
      if (message.deliveryState != state) {
        await _putMessage(message.copyWith(deliveryState: state));
      }
    }
    for (final contact in _contacts) {
      if ({ChatRelationshipState.blocked, ChatRelationshipState.rejected}.contains(contact.relationshipState)) continue;
      final intro = _messages.where((m) => m.id == contact.introductionId && m.localBitname == contact.localBitname && m.kind == ChatMessageKind.introduction).firstOrNull;
      if (intro == null) continue;
      final canonical = valid.contains(intro.id), acceptances = _messages.where((m) => m.localBitname == contact.localBitname && m.kind == ChatMessageKind.acceptance && m.introductionId == intro.id);
      final accepted = canonical && acceptances.any((m) => m.deliveryState == ChatDeliveryState.confirmed && (m.transport != ChatTransport.bitnamesChain || valid.contains(m.id)));
      final pending = canonical && acceptances.any((m) => m.isOutgoing && m.transport == ChatTransport.bitnamesChain && !valid.contains(m.id));
      final state = accepted ? ChatRelationshipState.accepted : !canonical ? (intro.isOutgoing ? ChatRelationshipState.outgoingIntroduction : ChatRelationshipState.none) : intro.isOutgoing ? ChatRelationshipState.outgoingIntroduction : pending ? ChatRelationshipState.acceptancePending : ChatRelationshipState.incomingIntroduction;
      if (state != contact.relationshipState) await _putContact(contact.copyWith(relationshipState: state));
    }
    _messages.removeWhere((m) => auth.contains(m) && !m.isOutgoing && !valid.contains(m.id)); await _save();
  }

  Future<bool> receiveWire(
    BitMessageWire wire,
    ChatTransport transport, {
    int? value,
    int? requiredFee,
    BitNameData? recipientData,
    String? reference,
    String? blockHash,
    int? txIndex, Set<String>? validatedChainIds,
  }) async {
    bool reject(String reason) { if (transport == ChatTransport.bitnamesChain) throw FormatException(reason); return false; }
    if (!privateStorageReady) return reject('private chat storage is locked or unavailable');
    if (!_ownedHashes.contains(wire.recipientBitNameHash)) return reject('recipient BitName is not owned');
    final data = recipientData ?? (await bitnamesRPC.resolveBitName(wire.recipientBitNameHash))?.data;
    if (data?.encryptionPubkey == null || data?.signingPubkey == null) return reject('recipient profile has no messaging keys');
    final recipient = _synthetic(wire.recipientBitNameHash, data!);
    final envelope = await _codec.openWire(wire: wire, recipientProfile: recipient);
    final payload = envelope.payload;
    if (utf8.encode(payload.body).length > maxMessageBytes) return reject('message is oversized');
    final existing = _find(payload.recipientBitNameHash, payload.senderBitNameHash);
    if (existing?.relationshipState == ChatRelationshipState.blocked) return reject('sender is blocked');
    if (payload.kind == BitIntroductionKind.introduction &&
        (transport != ChatTransport.bitnamesChain || requiredFee == null || value != requiredFee)) { return reject('introduction payment does not match the advertised fee'); }
    if (payload.kind != BitIntroductionKind.introduction &&
        transport == ChatTransport.bitnamesChain && value != fallbackValueSats) { return reject('fallback payment is not 1 sat'); }
    final claimed = payload.replyProfile ?? _profile(existing);
    if (claimed == null) return reject('sender supplied no reply profile');
    final historical = blockHash == null || txIndex == null ? null :
        await bitnamesRPC.bitNameDataAtPosition(payload.senderBitNameHash, blockHash, txIndex);
    final sender = historical == null ? await _verifier.verify(claimed) :
        _verifier.verifyAt(claimed, historical, '$blockHash:$txIndex');
    await _codec.verify(envelope, senderProfile: sender, verifiedReplyProfile: historical == null ? null : sender);
    final duplicate = _messages.where((m) => m.id == payload.id && m.localBitname == wire.recipientBitNameHash).firstOrNull;
    if (duplicate != null) { final same = duplicate.senderBitname == payload.senderBitNameHash &&
        duplicate.recipientBitname == payload.recipientBitNameHash && duplicate.content == payload.body &&
        duplicate.kind.index == payload.kind.index && duplicate.timestamp.millisecondsSinceEpoch == payload.timestamp.millisecondsSinceEpoch;
      if (same) validatedChainIds?.add(payload.id); return same; }
    final state = switch (payload.kind) {
      BitIntroductionKind.introduction when existing == null || existing.relationshipState == ChatRelationshipState.none ||
              existing.relationshipState == ChatRelationshipState.rejected =>
        ChatRelationshipState.incomingIntroduction,
      BitIntroductionKind.acceptance when existing?.relationshipState == ChatRelationshipState.outgoingIntroduction &&
              existing?.introductionId == payload.inReplyTo =>
        ChatRelationshipState.accepted,
      BitIntroductionKind.message when existing?.isAccepted == true && existing?.introductionId == payload.inReplyTo =>
        ChatRelationshipState.accepted,
      _ => null,
    };
    if (state == null) return reject('message is invalid for the current relationship state');
    final senderResolution = await bitnamesRPC.resolveBitName(payload.senderBitNameHash);
    if (senderResolution == null) return reject('sender BitName is not registered');
    final base = existing ?? ChatContact(id: payload.senderBitNameHash, localBitname: payload.recipientBitNameHash,
      name: payload.senderBitNameHash,
      plaintextName: _allBitNames.where((entry) => entry.hash == payload.senderBitNameHash).firstOrNull?.plaintextName,
      encryptionPubkey: sender.encryptionPublicKey);
    _storeContactInMemory(base.copyWith(address: senderResolution.address, signingPubkey: sender.signingPublicKey,
      relationshipState: state, introductionId: payload.kind == BitIntroductionKind.introduction ? payload.id : existing?.introductionId,
      replyProfile: sender.profile.toJson(), lastMessage: payload.body, lastMessageTime: payload.timestamp));
    _storeMessageInMemory(_message(envelope, false, transport, reference, value));
    await _save(); _changed();
    validatedChainIds?.add(payload.id); return true;
  }

  Future<_Context?> _context() async {
    final me = _selectedIdentity, contact = _selectedContact;
    if (me == null || contact == null || !_ownedHashes.contains(me.hash) || contact.localBitname != me.hash) return null;
    final profile = _profiles[me.hash];
    if (profile == null || _pendingProfiles.contains(me.hash)) {
      _fail('Publish the reply profile in Messaging setup and wait for its BitNames block'); return null;
    }
    try {
      if (!await _ownsBitNameNow(me.hash)) throw StateError('The selected BitName is no longer owned');
      final self = await _verifier.verify(profile);
      final remote = await bitnamesRPC.resolveBitName(contact.id);
      if (remote?.data.encryptionPubkey == null || remote?.data.signingPubkey == null) return null;
      return _Context(contact, self, remote!, _synthetic(contact.id, remote.data));
    } catch (e) {
      _fail('Could not verify messaging profiles: $e'); return null;
    }
  }

  Future<(SignedBitIntroductionEnvelope, BitMessageWire)> _prepare(
    _Context ctx,
    String body,
    BitIntroductionKind kind,
    String? reply,
    bool includeProfile,
  ) async {
    if (utf8.encode(body).length > maxMessageBytes) throw ArgumentError('Messages are limited to $maxMessageBytes UTF-8 bytes');
    final envelope = await _codec.createSigned(id: _newId(), kind: kind, senderProfile: ctx.self,
      recipientBitNameHash: ctx.contact.id, timestamp: _now(), body: body, inReplyTo: reply,
      replyProfile: includeProfile ? ctx.self : null);
    return (envelope, await _codec.createWire(envelope: envelope, recipientProfile: ctx.remoteCipher));
  }

  VerifiedBitMessageProfile _synthetic(String hash, BitNameData data) {
    final profile = BitMessageProfile(bitNameHash: hash, signingPublicKey: data.signingPubkey!,
      encryptionPublicKey: data.encryptionPubkey!, paymailFeeSats: data.paymailFeeSats);
    return VerifiedBitMessageProfile.verified(profile: profile,
      onChainCommitment: bitMessageProfileCommitment(profile), verificationReference: 'encryption-only');
  }

  BitMessageProfile? _profile(ChatContact? contact) {
    try {
      return contact?.replyProfile == null ? null : BitMessageProfile.fromJson(contact!.replyProfile!);
    } catch (_) { return null; }
  }

  Future<bool> _ownsBitNameNow(String hash) async => (await bitnamesRPC.listUTXOs()).any((utxo) {
    if (utxo is! BitnamesUTXO || utxo.type != OutpointType.bitname) return false;
    try { return (jsonDecode(utxo.content) as Map<String, dynamic>)['BitName'] == hash; } catch (_) { return false; }
  });
  ChatContact? _find(String local, String remote) =>
      _contacts.where((c) => c.localBitname == local && c.id == remote).firstOrNull;
  String _identityLabel(BitnameEntry identity) => identity.plaintextName ?? '${identity.hash.substring(0, 8)}…';
  String _short(String value) => value.length <= 12 ? value : '${value.substring(0, 12)}…';
  bool _profileMatchesCommitment(BitnameEntry identity, BitMessageProfile profile) =>
      assessBitMessageProfileCommitment(
        profile: profile,
        onChainCommitment: identity.details.commitment,
        network: _commitmentNetwork,
      ).verified;

  ChatMessage _message(
    SignedBitIntroductionEnvelope envelope,
    bool outgoing,
    ChatTransport transport, [
    String? reference,
    int? value,
    String? error,
  ]) {
    final p = envelope.payload;
    return ChatMessage(id: p.id, content: p.body, senderBitname: p.senderBitNameHash,
      recipientBitname: p.recipientBitNameHash, timestamp: p.timestamp, isOutgoing: outgoing,
      kind: ChatMessageKind.values[BitIntroductionKind.values.indexOf(p.kind)],
      deliveryState: error == null ? ChatDeliveryState.confirmed : ChatDeliveryState.failed,
      transport: transport, introductionId: p.kind == BitIntroductionKind.introduction ? p.id : p.inReplyTo,
      txid: reference, valueSats: value, error: error);
  }

  Future<void> _putMessage(ChatMessage message) async {
    _storeMessageInMemory(message);
    await _save(); _changed();
  }

  void _storeMessageInMemory(ChatMessage message) {
    final index = _messages.indexWhere((m) => m.id == message.id && m.localBitname == message.localBitname);
    index < 0 ? _messages.add(message) : _messages[index] = message;
  }

  Future<bool> _mutationAllowed() async {
    if (!privateStorageReady) {
      _fail('${storageStatus.summary}. ${storageStatus.details ?? 'Unlock the wallet before continuing'}');
      return false;
    }
    if (_enforcer != null) {
      final observedAt = _chainHealth.observedAt;
      final stale =
          observedAt == null ||
          _now().difference(observedAt) > pollInterval;
      if ((stale || !_chainHealth.mutationSafe) &&
          !await _refreshChainHealth()) {
        _fail('${_chainHealth.summary}. ${_chainHealth.details}');
        return false;
      }
    }
    if (!_torOnly) return true;
    final guard = _torMutationGuard;
    if (guard != null) {
      final reason = await guard();
      if (reason == null) return true;
      _fail(reason); return false;
    }
    if (await _tor?.chainTorReady(bitnamesRPC) ?? false) return true;
    _fail('Tor-only BitNames writes require --tor-proxy-mode and a connected loopback UDP tunnel peer'); return false;
  }

  Map<String, dynamic> _snapshot() => {
      'contacts': _contacts.map((e) => e.toJson()).toList(),
      'messages': _messages.map((e) => e.toJson()).toList(),
      'profiles': _profiles.values.map((e) => e.toJson()).toList(),
      'pending_profiles': _pendingProfiles.toList(),
      'pending_wires': _pendingWires.map((k, v) => MapEntry(k, v.toJson())),
      'operations': _operations.values.map((e) => e.toJson()).toList(),
      'chain_health': _chainHealth.toJson(),
      'owned': _ownedHashes.toList(),
      'tor_only': _torOnly,
      if (_selectedIdentity != null) 'selected_identity': _selectedIdentity!.hash,
      if (_torPeerOnion != null) 'tor_peer': _torPeerOnion,
    };

  Future<void> _save() {
    if (!privateStorageReady) {
      throw BitnamesStorageException(
        '${storageStatus.summary}. ${storageStatus.details ?? 'Unlock the wallet before changing private BitNames data'}',
      );
    }
    return _saveLock.synchronized(
      () => _secureStore.save(_snapshot()),
    );
  }

  Future<String> exportPrivateData() => _secureStore.exportEncrypted();

  Future<void> restorePrivateData(String encoded) async {
    await _saveLock.synchronized(() async {
      await _secureStore.restoreEncrypted(encoded);
      final state = await _secureStore.load();
      _clearPrivateMemory();
      _hydrate(state);
      _restoreOperationStatuses();
    });
    _changed();
  }

  Future<void> clearChatHistory() async {
    if (!privateStorageReady) {
      throw BitnamesStorageException(storageStatus.summary);
    }
    await _saveLock.synchronized(() async {
      _contacts.clear();
      _messages.clear();
      _pendingWires.clear();
      _selectedContact = null;
      await _secureStore.clear();
      await _secureStore.save(_snapshot());
    });
    _changed();
  }

  List<ChatMessage> conversationPage({
    required String localBitname,
    required String remoteBitname,
    int limit = 50,
    DateTime? before,
  }) => _secureStore
      .pageMessages(
        _snapshot(),
        localBitname: localBitname,
        remoteBitname: remoteBitname,
        limit: limit,
        beforeTimestamp: before?.millisecondsSinceEpoch,
      )
      .map(ChatMessage.fromJson)
      .toList();

  void startPolling() {
    if (!privateStorageReady) return;
    _pollTimer ??= Timer.periodic(pollInterval, (_) => unawaited(refresh()));
  }
  void stopPolling() { _pollTimer?.cancel(); _pollTimer = null; }
  void clearError() {
    _error = null;
    notifyListeners();
  }

  ChatSendResult _failed(String message) { _fail(message); return ChatSendResult(ChatSendDisposition.failed, error: message); }
  void _fail(String? value) { _error = value; _changed(); }
  void _changed() { if (!_disposed) notifyListeners(); }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    bitnamesRPC.removeListener(_onConnectionChanged);
    _balances?.removeListener(_onBalanceChanged);
    _storageKeys.removeListener(_onStorageKeyChanged);
    unawaited(_server.stop());
    if (_ownsTransport) _transport.close();
    _tor?.close();
    super.dispose();
  }
}

class _Context {
  const _Context(this.contact, this.self, this.remote, this.remoteCipher);
  final ChatContact contact; final VerifiedBitMessageProfile self, remoteCipher; final BitNameResolution remote;
}

List<Map<String, dynamic>> _maps(Object? value) => (value as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) decode) => _maps(value).map(decode).toList();
Uri _path(Uri uri, String hash) {
  final base = uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  return base.path.endsWith('/bitname/$hash/') ? base : base.resolve('bitname/$hash/');
}
T? _get<T extends Object>() => GetIt.I.isRegistered<T>() ? GetIt.I.get<T>() : null;
String _defaultCommitmentNetwork() =>
    _get<BitcoinConfProvider>()?.network.toReadableNet() ?? 'signet';
Future<void> _defaultRestartBitnames() async {
  final binaries = _get<BinaryProvider>();
  final bitnames = binaries?.binaries.whereType<BitNames>().firstOrNull;
  if (binaries == null || bitnames == null) {
    throw StateError('BitNames is not managed by the local orchestrator');
  }
  await binaries.restart(bitnames);
}
BitnamesTorController? _defaultTor() {
  final orchestrator = _get<OrchestratorRPC>();
  return orchestrator == null ? null : BitnamesTorController(orchestrator: orchestrator);
}
BitnamesStorageKeySource _defaultStorageKeys() {
  final walletReader = _get<WalletReaderProvider>();
  if (walletReader == null) {
    throw StateError('WalletReaderProvider is required for encrypted BitNames storage');
  }
  return WalletBitnamesStorageKeySource(walletReader);
}
extension _First<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
// dart format on
