import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/services/bitintroduction_codec.dart';
import 'package:bitwindow/services/bitmessage_server.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:bitwindow/services/bitnames_bitintroduction_backend.dart';
import 'package:bitwindow/services/bitnames_tor_controller.dart';
import 'package:bitwindow/services/tor_bitmessage_dialer.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
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
    BitMessageTransport? transport, BitnamesTorController? tor, TorMutationGuard? torMutationGuard,
    DateTime Function()? now, String Function()? id, this.autoStart = true,
    this.pollInterval = const Duration(seconds: 30), int serverPort = 37999,
  }) : bitnamesRPC = rpc ?? GetIt.I.get<BitnamesRPC>(),
       _settings = settings ?? GetIt.I.get<ClientSettings>(),
       _balances = balances ?? _get<BalanceProvider>(),
       _tor = tor ?? _defaultTor(),
       // ignore: prefer_initializing_formals
       _torMutationGuard = torMutationGuard,
       _now = now ?? DateTime.now,
       _newId = id ?? const Uuid().v4 {
    _verifier = BitnamesBitMessageProfileVerifier(bitnamesRPC);
    _codec = BitIntroductionEnvelopeCodec(signer: BitnamesBitIntroductionSigner(bitnamesRPC), signatureBackend: BitnamesBitIntroductionSignatureVerifier(bitnamesRPC), profileVerifier: _verifier, cipherBackend: BitnamesBitMessageCipher(bitnamesRPC));
    _ownsTransport = transport == null;
    _transport = transport ?? BitMessageTransport(directDialer: DirectBitMessageHttpDialer(), torDialer: createTorBitMessageDialer());
    _server = BitMessageServer(port: serverPort, bindAddress: InternetAddress.anyIPv4, allowRemoteClients: () => !_torOnly, profileProvider: (hash) => hash == null ? null : _profiles[hash], onIncomingWire: (wire) async {
      if (!await receiveWire(wire, ChatTransport.direct)) throw const FormatException('BitMessage was rejected');
    });
    bitnamesRPC.addListener(_onConnectionChanged);
    _balances?.addListener(_onBalanceChanged);
    if (autoStart) unawaited(initialize());
  }

  static const minerFeeSats = 100, fallbackValueSats = 1, maxMessageBytes = 4096;
  final BitnamesRPC bitnamesRPC; final ClientSettings _settings; final BalanceProvider? _balances;
  final BitnamesTorController? _tor; final TorMutationGuard? _torMutationGuard;
  final DateTime Function() _now; final String Function() _newId;
  final bool autoStart; final Duration pollInterval;
  late final BitnamesBitMessageProfileVerifier _verifier; late final BitIntroductionEnvelopeCodec _codec;
  late final BitMessageTransport _transport; late final BitMessageServer _server; late final bool _ownsTransport;

  List<BitnameEntry> _allBitNames = [];
  List<BitnameEntry> _myIdentities = [];
  Set<String> _ownedHashes = {};
  BitnameEntry? _selectedIdentity;
  ClientSettings get _clientSettings => _settings;
  HashNameMappingSetting _hashNameMapping = HashNameMappingSetting();
  List<ChatContact> _contacts = [];
  final List<ChatMessage> _messages = [];
  final Map<String, BitMessageProfile> _profiles = {}; final Set<String> _pendingProfiles = {}; final Map<String, BitMessageWire> _pendingWires = {};
  ChatContact? _selectedContact;
  Timer? _pollTimer;
  Future<void>? _ready; String? _torPeerOnion;
  bool _polling = false, _isSending = false, _torOnly = false, _disposed = false;
  String? _error;
  BitnamesTorStatus _torStatus = const BitnamesTorStatus(state: BitnamesTorState.unavailable);

  List<BitnameEntry> get allBitNames => _allBitNames;
  List<BitnameEntry> get myIdentities => _myIdentities;
  BitnameEntry? get selectedIdentity => _selectedIdentity;
  ChatContact? get selectedContact => _selectedContact;
  List<ChatContact> get contacts => _contacts.where((c) => c.localBitname == (_selectedIdentity?.hash ?? '')).toList();
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ChatMessage> get currentConversation => _messages.where((m) {
    final me = _selectedIdentity?.hash, them = _selectedContact?.id;
    return m.localBitname == me && ((m.senderBitname == me && m.recipientBitname == them) ||
        (m.senderBitname == them && m.recipientBitname == me));
  }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  bool get isSending => _isSending;
  bool get isLoading => _ready != null && _myIdentities.isEmpty; String? get error => _error;
  bool get torOnly => _torOnly; BitnamesTorStatus get torStatus => _torStatus;
  BalanceProvider get balanceProvider => _balances ?? GetIt.I.get<BalanceProvider>();
  double get balanceBTC => balanceProvider.balanceFor(bitnamesRPC).$1;
  int get balanceSats => (balanceBTC * 100000000).round();
  bool get hasSufficientBalance => balanceSats >= 10000;
  Map<String, BitMessageProfile> get profiles => Map.unmodifiable(_profiles);
  bool profileReady(String hash) => _profiles.containsKey(hash) && !_pendingProfiles.contains(hash);

  Future<void> initialize() => _ready ??= _init();
  Future<void> _init() async {
    final state = (await _settings.getValue(_ChatState())).value;
    await _loadContacts();
    final persistedContacts = _list(state['contacts'], ChatContact.fromJson);
    if (persistedContacts.isNotEmpty) _contacts = persistedContacts;
    _messages.addAll(_list(state['messages'], ChatMessage.fromJson));
    for (final json in _maps(state['profiles'])) { final profile = BitMessageProfile.fromJson(json); _profiles[profile.bitNameHash] = profile; }
    _pendingProfiles.addAll((state['pending_profiles'] as List? ?? []).cast<String>());
    for (final entry in (state['pending_wires'] as Map? ?? {}).entries) {
      _pendingWires[entry.key as String] = BitMessageWire.fromJson(Map<String, dynamic>.from(entry.value as Map));
    }
    _ownedHashes = (state['owned'] as List? ?? []).cast<String>().toSet();
    _torOnly = state['tor_only'] as bool? ?? false;
    _torPeerOnion = state['tor_peer'] as String?;
    if (_tor != null) _torStatus = await _tor.refresh();
    if (autoStart) {
      try { await _server.start(); } catch (e) { _error = 'BitMessage listener unavailable: $e'; }
      startPolling();
    }
    if (_torOnly && _torPeerOnion != null) {
      try { await _tor?.enableChainTor(bitnamesRPC, _torPeerOnion!); }
      catch (e) { _error = 'Tor-only BitNames is not ready: $e'; }
    }
    if (bitnamesRPC.connected) await refresh();
    _changed();
  }

  Future<void> refresh() async { if (_tor != null) _torStatus = await _tor.refresh();
    await fetchIdentities(); await fetchPaymail();
  }

  void _onConnectionChanged() {
    if (bitnamesRPC.connected) {
      refresh();
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

      final refreshed = _myIdentities.where((entry) => entry.hash == _selectedIdentity?.hash).firstOrNull;
      if (refreshed == null) _selectedContact = null;
      _selectedIdentity = refreshed ?? _myIdentities.firstOrNull;
      for (final identity in _myIdentities) {
        final profile = _profiles[identity.hash];
        if (profile != null && identity.details.commitment == bitMessageProfileCommitment(profile)) {
          _pendingProfiles.remove(identity.hash);
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

      // Load cached owned hashes
      final ownedSetting = await _clientSettings.getValue(OwnedBitNamesSetting());
      _ownedHashes = ownedSetting.value.toSet();

      notifyListeners();
    } catch (e) {
      // Ignore errors on cache load
    }
  }

  Future<void> _saveOwnedHashes() async {
    final setting = OwnedBitNamesSetting(newValue: _ownedHashes.toList());
    await _clientSettings.setValue(setting);
  }

  Future<void> _loadContacts() async {
    try {
      final setting = ChatContactsSetting();
      final loaded = await _clientSettings.getValue(setting);
      _contacts = loaded.value;
      notifyListeners();
    } catch (e) {
      _contacts = [];
    }
  }

  Future<String?> publishProfile({
    required Iterable<Uri> direct,
    required Iterable<Uri> tor,
    required int? paymailFeeSats,
  }) async {
    final me = _selectedIdentity;
    if (me?.details.signingPubkey == null || me?.details.encryptionPubkey == null) {
      _fail('Select a BitName with signing and encryption keys');
      return null;
    }
    if (paymailFeeSats != null && paymailFeeSats < 0) { _fail('Introduction fee cannot be negative'); return null; }
    if (!await _mutationAllowed()) return null;
    final identity = me!;
    final profile = BitMessageProfile(bitNameHash: identity.hash, signingPublicKey: identity.details.signingPubkey!,
      encryptionPublicKey: identity.details.encryptionPubkey!, directEndpoints: direct.map((u) => _path(u, identity.hash)),
      torEndpoints: tor.map((u) => _path(u, identity.hash)), paymailFeeSats: paymailFeeSats);
    if (profile.directEndpoints.isEmpty && profile.torEndpoints.isEmpty) {
      _fail('Add a direct or Tor endpoint');
      return null;
    }
    try {
      final txid = await bitnamesRPC.updateBitName(bitname: identity.hash,
        updates: BitNameDataUpdates(commitment: BitNameUpdate.set(bitMessageProfileCommitment(profile)),
          paymailFeeSats: paymailFeeSats == null ? const BitNameUpdate<int>.delete() : BitNameUpdate.set(paymailFeeSats)),
        feeSats: minerFeeSats);
      _profiles[identity.hash] = profile; _pendingProfiles.add(identity.hash); await _save(); _changed();
      return txid;
    } catch (e) {
      _fail('Could not publish reply profile: $e'); return null;
    }
  }

  Future<bool> setTorOnly(bool enabled, {String? peerOnion}) async {
    try {
      if (enabled) {
        final controller = _tor;
        final onion = peerOnion ?? _torPeerOnion;
        if (controller == null || onion == null) throw StateError('Start BitNames Tor and choose a P2P onion');
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

  Future<void> addContactFromEntry(BitnameEntry entry) async {
    if (entry.details.encryptionPubkey == null) {
      _error = 'BitName has no encryption key';
      notifyListeners();
      return;
    }

    final resolution = await bitnamesRPC.resolveBitName(entry.hash);
    if (resolution == null) return;
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

  Future<void> _saveContacts() async {
    final setting = ChatContactsSetting(newValue: _contacts);
    await _clientSettings.setValue(setting);
    await _save();
  }

  Future<void> addContact(ChatContact contact) async {
    final existingIndex = _contacts.indexWhere((c) => c.relationshipId == contact.relationshipId);
    if (existingIndex >= 0) {
      _contacts[existingIndex] = contact;
    } else {
      _contacts.add(contact);
    }
    if (_selectedContact?.relationshipId == contact.relationshipId) {
      _selectedContact = contact;
    }
    await _saveContacts();
    notifyListeners();
  }

  Future<void> _putContact(ChatContact contact) => addContact(contact);

  Future<void> removeContact(String contactId) async {
    _contacts.removeWhere(
      (c) => c.id == contactId && c.localBitname == _selectedIdentity?.hash,
    );
    if (_selectedContact?.id == contactId) {
      _selectedContact = null;
    }
    await _saveContacts();
    notifyListeners();
  }

  void selectContact(ChatContact contact) {
    _selectedContact = contact;
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
    _selectedContact = null;
    notifyListeners();
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

  void _addStatus(String id, String message) {
    _statusMessages.removeWhere((s) => s.id == id);
    _statusMessages.add(StatusMessage(id: id, message: message));
    notifyListeners();
  }

  void _removeStatus(String id) {
    _statusMessages.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Legacy getters for compatibility - check for any claiming_ status
  bool get isClaiming => _statusMessages.any((s) => s.id.startsWith('claiming_'));
  String? get claimingStatus => _statusMessages.where((s) => s.id.startsWith('claiming_')).firstOrNull?.message;

  /// Reserve and register a BitName automatically
  /// Handles the reserve-wait-register dance internally
  Future<String?> claimIdentity(String plaintextName, {int introductionFeeSats = 1000}) async {
    // Add progress before connection/privacy guards so Register never appears to do nothing.
    final statusId = 'claiming_$plaintextName';
    _addStatus(statusId, 'Preparing registration for "$plaintextName"...');
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
    _addStatus(statusId, 'Checking balance...');

    try {
      // Check balance first
      final balance = await bitnamesRPC.getBalance();
      if (balance.availableSats < 10000) {
        _error = 'Insufficient BitNames balance. Deposit funds to BitNames sidechain first.';
        notifyListeners();
        return null;
      }

      // Step 1: Reserve (wait for tx to be mined)
      _addStatus(statusId, 'Submitting reservation for "$plaintextName"...');
      await bitnamesRPC.reserveBitName(plaintextName);
      _addStatus(statusId, 'Reservation submitted • waiting for a BitNames block...');

      final encryptionPubkey = await bitnamesRPC.getNewEncryptionKey();
      final signingPubkey = await bitnamesRPC.getNewVerifyingKey();

      // Retry register until reservation is mined (stay in "Reserving" state)
      String? txid;
      const retryDelay = Duration(seconds: 10);

      while (txid == null) {
        try {
          txid = await bitnamesRPC.registerBitName(
            plaintextName,
            BitNameData(
              encryptionPubkey: encryptionPubkey,
              signingPubkey: signingPubkey,
              paymailFeeSats: introductionFeeSats,
            ),
          );
        } catch (e) {
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('reservation') || errorStr.contains('not found')) {
            // Reservation not mined yet, wait and retry
            await Future.delayed(retryDelay);
          } else {
            // Different error, rethrow
            rethrow;
          }
        }
      }

      // Step 2: Register tx submitted, wait for it to be mined
      _addStatus(statusId, 'Registration submitted • waiting for a BitNames block...');
      await _hashNameMapping.saveMapping(plaintextName, isMine: true);

      // Poll until BitName appears in identity list (register tx mined)
      while (true) {
        await fetchIdentities();
        final registered = _myIdentities.where((entry) => entry.plaintextName == plaintextName).firstOrNull;
        if (registered != null) {
          _selectedIdentity = registered;
          _selectedContact = null;
          _changed();
          break;
        }
        await Future.delayed(retryDelay);
      }

      // Step 3: Registered successfully
      _addStatus(statusId, 'Registered "$plaintextName" successfully!');
      await Future.delayed(const Duration(seconds: 5));

      return txid;
    } catch (e) {
      _error = 'Failed to claim BitName: $e';
      notifyListeners();
      return null;
    } finally {
      _removeStatus(statusId);
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
    if (contact == null || !{ChatRelationshipState.none, ChatRelationshipState.rejected}.contains(contact.relationshipState)) {
      return _failed('A new introduction is not allowed for this contact'); }
    _isSending = true; _changed();
    try {
      final ctx = await _context();
      final fee = ctx?.remote.data.paymailFeeSats;
      if (ctx == null || fee == null) return _failed('Recipient is not accepting introductions');
      if (fee != ctx.contact.paymailFeeSats) {
        await _putContact(ctx.contact.copyWith(address: ctx.remote.address, paymailFeeSats: fee));
        return _failed('The introduction fee changed to $fee sats; review and confirm it again');
      }
      if (!await _mutationAllowed()) return _failed(_error!);
      final prepared = await _prepare(ctx, body, BitIntroductionKind.introduction, null, true);
      final id = prepared.$1.payload.id, pending = _message(prepared.$1, true, ChatTransport.bitnamesChain, null, fee)
        .copyWith(deliveryState: ChatDeliveryState.pending);
      _pendingWires[id] = prepared.$2;
      final contact = ctx.contact.copyWith(address: ctx.remote.address,
        relationshipState: ChatRelationshipState.outgoingIntroduction, introductionId: prepared.$1.payload.id);
      await _putContact(contact); await _putMessage(pending);
      try { final txid = await bitnamesRPC.transferIdempotent(idempotencyKey: id, dest: ctx.remote.address,
        value: fee, fee: minerFeeSats, memo: prepared.$2.ciphertext);
        await _putMessage(pending.copyWith(txid: txid));
        return ChatSendResult(ChatSendDisposition.sent, id: id, reference: txid);
      } catch (e) { return ChatSendResult(ChatSendDisposition.needsChainConfirmation, id: id, error: '$e'); }
    } catch (e) { return _failed('Could not send introduction: $e'); }
    finally { _isSending = false; _changed(); }
  }

  Future<ChatSendResult> _sendDirect(String body, BitIntroductionKind kind, String? reply) async {
    final ctx = await _context();
    final accepting = kind == BitIntroductionKind.acceptance &&
        ctx?.contact.relationshipState == ChatRelationshipState.incomingIntroduction;
    if (ctx == null || (!ctx.contact.isAccepted && !accepting)) return _failed('Chat is not accepted');
    final remoteProfile = _profile(ctx.contact);
    if (remoteProfile == null) return _failed('Contact has no verified reply profile');
    late (SignedBitIntroductionEnvelope, BitMessageWire) prepared;
    try { prepared = await _prepare(ctx, body, kind, reply, true); }
    catch (e) { return _failed('Could not prepare message: $e'); }
    try {
      VerifiedBitMessageProfile verified;
      try { verified = await _verifier.verify(remoteProfile); }
      catch (_) { final current = await _transport.discoverProfile(remoteProfile, torOnly: _torOnly);
        if (current == null) rethrow; verified = await _verifier.verify(current);
        await _putContact(ctx.contact.copyWith(encryptionPubkey: current.encryptionPublicKey,
          signingPubkey: current.signingPublicKey, replyProfile: current.toJson())); }
      await _transport.send(prepared.$2, verified, torOnly: _torOnly);
      await _putMessage(_message(prepared.$1, true, _torOnly ? ChatTransport.tor : ChatTransport.direct));
      return ChatSendResult(ChatSendDisposition.sent, id: prepared.$1.payload.id);
    } catch (e) {
      _pendingWires[prepared.$1.payload.id] = prepared.$2;
      await _putMessage(_message(prepared.$1, true,
        _torOnly ? ChatTransport.tor : ChatTransport.direct, null, null, '$e'));
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
    try { final result = await _sendDirect('accepted', BitIntroductionKind.acceptance, contact!.introductionId);
      if (result.sent) await _putContact(contact.copyWith(relationshipState: ChatRelationshipState.accepted)); return result;
    } finally { _isSending = false; _changed(); }
  }

  Future<void> rejectIntroduction() => _setRelationship(ChatRelationshipState.rejected);
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
      await _putMessage(pending);
      if (accepting) await _putContact(contact!.copyWith(relationshipState: ChatRelationshipState.acceptancePending));
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
        if (status == BitnamesTransactionStatus.confirmed) { _pendingWires.remove(message.id);
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
    await _putContact(base.copyWith(address: senderResolution.address, signingPubkey: sender.signingPublicKey,
      relationshipState: state, introductionId: payload.kind == BitIntroductionKind.introduction ? payload.id : existing?.introductionId,
      replyProfile: sender.profile.toJson(), lastMessage: payload.body, lastMessageTime: payload.timestamp));
    await _putMessage(_message(envelope, false, transport, reference, value));
    validatedChainIds?.add(payload.id); return true;
  }

  Future<_Context?> _context() async {
    final me = _selectedIdentity, contact = _selectedContact;
    if (me == null || contact == null || !_ownedHashes.contains(me.hash) || contact.localBitname != me.hash) return null;
    final profile = _profiles[me.hash];
    if (profile == null || _pendingProfiles.contains(me.hash)) { _fail('Publish and confirm a reply profile first'); return null; }
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
    final index = _messages.indexWhere((m) => m.id == message.id && m.localBitname == message.localBitname);
    index < 0 ? _messages.add(message) : _messages[index] = message;
    await _save(); _changed();
  }

  Future<bool> _mutationAllowed() async {
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

  Future<void> _save() => _settings.setValue(_ChatState(newValue: {
        'contacts': _contacts.map((e) => e.toJson()).toList(),
        'messages': _messages.map((e) => e.toJson()).toList(),
        'profiles': _profiles.values.map((e) => e.toJson()).toList(),
        'pending_profiles': _pendingProfiles.toList(),
        'pending_wires': _pendingWires.map((k, v) => MapEntry(k, v.toJson())),
        'owned': _ownedHashes.toList(), 'tor_only': _torOnly,
        if (_torPeerOnion != null) 'tor_peer': _torPeerOnion,
      }));

  void startPolling() { _pollTimer ??= Timer.periodic(pollInterval, (_) => unawaited(refresh())); }
  void stopPolling() {}
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

class _ChatState extends SettingValue<Map<String, dynamic>> {
  _ChatState({super.newValue});
  @override String get key => 'bitintroduction_state_v1';
  @override Map<String, dynamic> defaultValue() => {};
  @override
  Map<String, dynamic>? fromJson(String value) {
    try { return Map<String, dynamic>.from(jsonDecode(value) as Map); }
    catch (_) { return null; }
  }
  @override String toJson() => jsonEncode(value);
  @override SettingValue<Map<String, dynamic>> withValue([Map<String, dynamic>? value]) => _ChatState(newValue: value);
}

class OwnedBitNamesSetting extends SettingValue<List<String>> {
  OwnedBitNamesSetting({super.newValue});

  @override
  String get key => 'owned_bitname_hashes';

  @override
  List<String> defaultValue() => [];

  @override
  String toJson() {
    return jsonEncode(value);
  }

  @override
  List<String>? fromJson(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return null;
    }
  }

  @override
  SettingValue<List<String>> withValue([List<String>? value]) {
    return OwnedBitNamesSetting(newValue: value);
  }
}

class ChatContactsSetting extends SettingValue<List<ChatContact>> {
  ChatContactsSetting({super.newValue});

  @override
  String get key => 'chat_contacts';

  @override
  List<ChatContact> defaultValue() => [];

  @override
  String toJson() {
    return jsonEncode(value.map((e) => e.toJson()).toList());
  }

  @override
  List<ChatContact>? fromJson(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => ChatContact.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  @override
  SettingValue<List<ChatContact>> withValue([List<ChatContact>? value]) {
    return ChatContactsSetting(newValue: value);
  }
}

List<Map<String, dynamic>> _maps(Object? value) => (value as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) decode) => _maps(value).map(decode).toList();
Uri _path(Uri uri, String hash) {
  final base = uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  return base.path.endsWith('/bitname/$hash/') ? base : base.resolve('bitname/$hash/');
}
T? _get<T extends Object>() => GetIt.I.isRegistered<T>() ? GetIt.I.get<T>() : null;
BitnamesTorController? _defaultTor() {
  final orchestrator = _get<OrchestratorRPC>();
  return orchestrator == null ? null : BitnamesTorController(orchestrator: orchestrator);
}
extension _First<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
// dart format on
