import 'dart:async';
import 'dart:convert';

import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:bitwindow/services/bitnames_message.dart';
import 'package:bitwindow/services/chat_file_storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thirds/blake3.dart';

class ChatProvider extends ChangeNotifier {
  BitnamesRPC get bitnamesRPC => GetIt.I.get<BitnamesRPC>();
  Logger get log => GetIt.I.get<Logger>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  final ClientSettings _clientSettings = GetIt.I.get<ClientSettings>();
  final WalletReaderProvider? _walletReader = GetIt.I.isRegistered<WalletReaderProvider>()
      ? GetIt.I.get<WalletReaderProvider>()
      : null;
  late (String?, bool) _walletState;
  int _walletChange = 0;
  int get walletChange => _walletChange;

  List<BitnameEntry> _allBitNames = [];
  List<BitnameEntry> get allBitNames => _allBitNames;

  // BitNames owned by this wallet (from UTXOs)
  List<BitnameEntry> _myIdentities = [];
  List<BitnameEntry> get myIdentities => _myIdentities;

  // Cached owned hashes for quick startup
  Set<String> _ownedHashes = {};

  // BitNames sidechain balance from BalanceProvider
  double get balanceBTC => balanceProvider.balanceFor(bitnamesRPC).$1;
  int get balanceSats => (balanceBTC * 100000000).round();
  bool get hasSufficientBalance => balanceSats >= 10000;

  HashNameMappingSetting _hashNameMapping = HashNameMappingSetting();

  BitnameEntry? _selectedIdentity;
  BitnameEntry? get selectedIdentity => _selectedIdentity;

  List<ChatContact> _contacts = [];
  List<ChatContact> get contacts => _contacts.map(_withPreview).toList();

  ChatContact? _selectedContact;
  ChatContact? get selectedContact => _selectedContact == null ? null : _withPreview(_selectedContact!);

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  List<ChatMessage> get currentConversation {
    if (_selectedContact == null || _selectedIdentity == null) {
      return [];
    }
    return _messages.where((m) => _withContact(m, _selectedContact!) && _withIdentity(m)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  bool _withIdentity(ChatMessage message) {
    final identity = _selectedIdentity;
    if (identity == null) {
      return false;
    }
    return message.isOutgoing
        ? (message.senderBitname != null
              ? message.senderBitname == identity.hash
              : message.senderPubkey == identity.details.encryptionPubkey)
        : (message.recipientBitname != null
              ? message.recipientBitname == identity.hash
              : message.recipientPubkey == identity.details.encryptionPubkey);
  }

  ChatContact _withPreview(ChatContact contact) {
    ChatMessage? last;
    for (final message in _messages) {
      if (_withIdentity(message) &&
          _withContact(message, contact) &&
          (last == null || !message.timestamp.isBefore(last.timestamp))) {
        last = message;
      }
    }
    return contact.copyWith(
      lastMessage: last?.content,
      lastMessageTime: last?.timestamp,
      clearPreview: last == null,
    );
  }

  bool _withContact(ChatMessage message, ChatContact contact) {
    final hash = contact.encryptionPubkey.isEmpty ? null : BitnamesMessage.nameHash(contact.id);
    return message.isOutgoing
        ? (message.recipientBitname != null
              ? message.recipientBitname == hash
              : message.recipientPubkey == contact.encryptionPubkey)
        : (message.senderBitname != null
              ? message.senderBitname == hash
              : message.senderPubkey == contact.encryptionPubkey || message.senderPubkey == contact.address);
  }

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSending = false;
  bool get isSending => _isSending;

  /// The postage the selected reader accepts.
  int get postageSats => _selectedContact?.paymailFeeSats ?? defaultPostageSats;

  /// What one message takes out of the wallet. The reader keeps the postage,
  /// and the network takes the fee.
  int get messageCostSats => postageSats + networkFeeSats;

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 30);

  /// What a message costs the sender, beyond the postage the reader keeps.
  static const networkFeeSats = 100;

  /// The postage a reader accepts. A message that pays less stays hidden.
  static const defaultPostageSats = 1000;

  ChatProvider({BitnamesSecureStore? store}) : _secureStore = store {
    _walletState = (_walletReader?.activeWalletId, _walletReader?.isWalletUnlocked ?? true);
    _walletReader?.addListener(_onWalletChanged);
    bitnamesRPC.addListener(_onConnectionChanged);
    balanceProvider.addListener(_onBalanceChanged);
    if (bitnamesRPC.connected) {
      unawaited(_init());
    }
  }

  void _onWalletChanged() {
    final state = (_walletReader?.activeWalletId, _walletReader?.isWalletUnlocked ?? true);
    if (state == _walletState) {
      return;
    }
    _walletState = state;
    _walletChange++;
    _messages.clear();
    _contacts = [];
    _selectedContact = null;
    _selectedIdentity = null;
    _myIdentities = [];
    _ownedHashes = {};
    _statusMessages.clear();
    _error = null;
    _isSending = false;
    notifyListeners();
    unawaited(_init());
  }

  void _onConnectionChanged() {
    if (bitnamesRPC.connected) {
      _init();
    }
  }

  void _onBalanceChanged() {
    // Notify listeners when balance changes so UI updates
    notifyListeners();
  }

  Future<void> _init() async {
    final walletChange = _walletChange;
    if (!_walletState.$2) {
      return;
    }
    await Future.wait([if (bitnamesRPC.connected) fetchIdentities(), _loadContacts()]);
    if (walletChange != _walletChange) {
      return;
    }
    await _loadMessages();
  }

  Future<void> fetchIdentities() async {
    final walletChange = _walletChange;
    if (!_walletState.$2) {
      return;
    }
    // Load cached data first for quick startup
    await _loadCachedData();

    if (!bitnamesRPC.connected || walletChange != _walletChange) {
      return;
    }

    try {
      // Load hash-name mappings for friendly names
      final loadedMapping = await _clientSettings.getValue(HashNameMappingSetting());

      // Fetch all BitNames (for lookup and search)
      final allBitNames = await bitnamesRPC.listBitNames();

      // Get wallet UTXOs and find owned BitNames
      final utxos = await bitnamesRPC.listUTXOs();
      if (walletChange != _walletChange) {
        return;
      }
      _hashNameMapping = loadedMapping as HashNameMappingSetting;
      _allBitNames = allBitNames;
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
      if (walletChange != _walletChange) {
        return;
      }

      // Match owned hashes to full BitName entries
      _myIdentities = _allBitNames.where((entry) => _ownedHashes.contains(entry.hash)).toList();

      // Select first owned identity if none selected
      if (_selectedIdentity == null && _myIdentities.isNotEmpty) {
        _selectedIdentity = _myIdentities.first;
      }
      notifyListeners();
    } catch (e) {
      if (walletChange != _walletChange) {
        return;
      }
      _error = 'Failed to fetch identities: $e';
      notifyListeners();
    }
  }

  Future<void> _loadCachedData() async {
    final walletChange = _walletChange;
    try {
      // Load hash-name mappings
      final loadedMapping = await _clientSettings.getValue(HashNameMappingSetting());

      // Load cached owned hashes
      final ownedSetting = await _clientSettings.getValue(OwnedBitNamesSetting());
      if (walletChange != _walletChange) {
        return;
      }
      _hashNameMapping = loadedMapping as HashNameMappingSetting;
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

  /// Search for a BitName by plaintext name using Blake3 hash
  BitnameEntry? searchBitNameByPlaintext(String searchText) {
    if (searchText.isEmpty) {
      return null;
    }

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
    if (searchText.isEmpty) {
      return myIdentities;
    }

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
    final contact = _selectedContact;
    if (contact != null) {
      unawaited(markConversationRead(contact.id));
    }
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
  Future<String?> claimIdentity(String plaintextName) async {
    if (!bitnamesRPC.connected) {
      _error = 'BitNames not connected';
      notifyListeners();
      return null;
    }

    // Use a unique status ID per claim so back-to-back claims work
    final statusId = 'claiming_$plaintextName';
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
      _addStatus(statusId, 'Reserving "$plaintextName"...');
      await bitnamesRPC.reserveBitName(plaintextName);

      // Get encryption key for paymail
      final encryptionPubkey = await bitnamesRPC.getNewEncryptionKey();

      // Retry register until reservation is mined (stay in "Reserving" state)
      String? txid;
      const retryDelay = Duration(seconds: 10);

      while (txid == null) {
        try {
          txid = await bitnamesRPC.registerBitName(
            plaintextName,
            BitNameData(encryptionPubkey: encryptionPubkey, paymailFeeSats: 1000),
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
      _addStatus(statusId, 'Registering "$plaintextName"...');
      await _hashNameMapping.saveMapping(plaintextName, isMine: true);

      // Poll until BitName appears in identity list (register tx mined)
      while (true) {
        await fetchIdentities();
        if (_myIdentities.any((entry) => entry.plaintextName == plaintextName)) {
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

  Future<void> _loadContacts() async {
    final walletChange = _walletChange;
    try {
      final setting = ChatContactsSetting();
      final loaded = await _clientSettings.getValue(setting);
      if (walletChange != _walletChange) {
        return;
      }
      _contacts = loaded.value;
      await _saveContacts();
      notifyListeners();
    } catch (e) {
      if (walletChange != _walletChange) {
        return;
      }
      _error = 'Could not read contact settings: $e';
      notifyListeners();
    }
  }

  Future<void> _saveContacts() async {
    final setting = ChatContactsSetting(newValue: _contacts);
    await _clientSettings.setValue(setting);
  }

  /// The messages live encrypted at rest, under a key the wallet derives. A
  /// chat holds private text, and the chain never gives a sent message back.
  BitnamesSecureStore? _secureStore;

  Future<BitnamesSecureStore?> _store() async {
    if (_secureStore != null) {
      return _secureStore;
    }
    if (!GetIt.I.isRegistered<WalletReaderProvider>()) {
      return null;
    }
    final directory = await getApplicationSupportDirectory();
    _secureStore = BitnamesSecureStore(
      store: ChatFileStorage.fromDirectory(directory),
      keySource: WalletBitnamesStorageKeySource(GetIt.I.get<WalletReaderProvider>()),
    );
    return _secureStore;
  }

  Future<void> _loadMessages() async {
    final walletChange = _walletChange;
    try {
      final store = await _store();
      if (store == null) {
        return;
      }
      final state = await store.load();
      if (walletChange != _walletChange) {
        return;
      }
      final stored = state['messages'] as List<dynamic>? ?? const [];
      final oldMessages = stored
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .where((m) => !m.isOutgoing && m.senderBitname == null)
          .toList();
      final oldSenders = oldMessages.map((m) => m.senderPubkey).where((sender) => sender != 'unknown').toSet();
      _contacts.removeWhere((c) => !c.isManual && c.encryptionPubkey.isEmpty && oldSenders.contains(c.address));
      _messages
        ..clear()
        ..addAll(
          stored.map((e) {
            final message = ChatMessage.fromJson(e as Map<String, dynamic>);
            return !message.isOutgoing && message.senderBitname == null
                ? message.copyWith(senderPubkey: 'unknown')
                : message;
          }),
        );
      final unknown = _messages.lastWhereOrNull((m) => !m.isOutgoing && m.senderBitname == null);
      if (unknown != null) {
        await addContact(
          ChatContact(
            id: 'unknown',
            name: 'Unknown sender',
            encryptionPubkey: '',
            address: 'unknown',
          ),
        );
        if (walletChange != _walletChange) {
          return;
        }
      }
      notifyListeners();
    } catch (e) {
      if (walletChange != _walletChange) {
        return;
      }
      _error = 'Could not read stored messages: $e';
      notifyListeners();
    }
  }

  Future<void> _saveMessages() async {
    final walletChange = _walletChange;
    final store = await _store();
    if (store == null || walletChange != _walletChange) {
      return;
    }
    await store.save({'messages': _messages.map((m) => m.toJson()).toList()});
  }

  Future<void> addContact(ChatContact contact) async {
    final existingIndex = _contacts.indexWhere((c) => c.id == contact.id);
    if (existingIndex >= 0) {
      _contacts[existingIndex] = contact;
    } else {
      _contacts.add(contact);
    }
    await _saveContacts();
    notifyListeners();
  }

  Future<void> removeContact(String contactId) async {
    _contacts.removeWhere((c) => c.id == contactId);
    if (_selectedContact?.id == contactId) {
      _selectedContact = null;
    }
    await _saveContacts();
    notifyListeners();
  }

  /// Add contact directly from a BitnameEntry (no lookup needed)
  Future<void> addContactFromEntry(BitnameEntry entry) async {
    if (entry.details.encryptionPubkey == null) {
      _error = 'BitName has no encryption key';
      notifyListeners();
      return;
    }

    // A message pays the holder of the BitName. A fresh address of this
    // wallet pays nobody.
    final String address;
    try {
      address = await bitnamesRPC.getBitNameOwner(entry.hash);
    } catch (e) {
      _error = 'Could not find who holds ${entry.plaintextName ?? entry.hash}: $e';
      notifyListeners();
      return;
    }

    final contact = ChatContact(
      id: entry.hash,
      name: entry.hash,
      plaintextName: entry.plaintextName,
      encryptionPubkey: entry.details.encryptionPubkey!,
      address: address,
      paymailFeeSats: entry.details.paymailFeeSats,
      isManual: true,
    );

    await addContact(contact);
  }

  void selectContact(ChatContact contact) {
    _selectedContact = contact;
    notifyListeners();
    unawaited(markConversationRead(contact.id));
  }

  /// Counts the messages from one contact that the reader has not opened.
  int unreadCount(String contactId) {
    return _messages.where((m) => !m.isOutgoing && !m.read && _belongsTo(m, contactId)).length;
  }

  /// Marks every message of one conversation read, the way the bell history
  /// marks a notification read.
  Future<void> markConversationRead(String contactId) async {
    var changed = false;
    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (message.read || message.isOutgoing || !_belongsTo(message, contactId)) {
        continue;
      }
      _messages[i] = message.copyWith(read: true);
      changed = true;
    }
    if (!changed) {
      return;
    }
    await _saveMessages();
    notifyListeners();
  }

  bool _belongsTo(ChatMessage message, String contactId) {
    final contact = _contacts.firstWhereOrNull((c) => c.id == contactId);
    if (contact == null) {
      return false;
    }
    final identity = _selectedIdentity;
    if (identity == null ||
        (message.recipientBitname != null
            ? message.recipientBitname != identity.hash
            : message.recipientPubkey != identity.details.encryptionPubkey)) {
      return false;
    }
    return _withContact(message, contact);
  }

  Future<void> fetchPaymail() async {
    final walletChange = _walletChange;
    final identity = _selectedIdentity;
    if (!bitnamesRPC.connected || identity == null) {
      return;
    }

    PendingPaymail? pending;
    final errors = <String>[];
    try {
      pending = await bitnamesRPC.getPendingPaymail();
      if (walletChange != _walletChange) {
        return;
      }
      errors.addAll(await _processPaymail(pending.entries, identity, pending: true));
    } catch (e) {
      errors.add('Could not read pending paymail: $e');
    }
    if (walletChange != _walletChange) {
      return;
    }

    var confirmedRead = false;
    try {
      final paymail = await bitnamesRPC.getPaymail();
      if (walletChange != _walletChange) {
        return;
      }
      errors.addAll(await _processPaymail(paymail, identity));
      confirmedRead = true;
    } catch (e) {
      errors.add('Could not read confirmed paymail: $e');
    }
    if (walletChange != _walletChange) {
      return;
    }

    try {
      if (pending != null) {
        if (confirmedRead) {
          await _dropEvictedPending(pending.entries.keys.toSet(), identity);
        }
        if (walletChange != _walletChange) {
          return;
        }
        await _settleOutgoing(pending.mempoolTxids);
      }
    } catch (e) {
      errors.add('Could not save paymail: $e');
    }
    if (walletChange != _walletChange) {
      return;
    }
    _error = errors.isEmpty ? null : errors.join('; ');
    notifyListeners();
  }

  Future<List<String>> _processPaymail(
    Map<String, dynamic> paymail,
    BitnameEntry identity, {
    bool pending = false,
  }) async {
    final walletChange = _walletChange;
    final myEncryptionPubkey = identity.details.encryptionPubkey;
    if (myEncryptionPubkey == null) {
      return [];
    }
    final errors = <String>[];
    for (final entry in paymail.entries) {
      try {
        await _processPaymailEntry(entry, identity, myEncryptionPubkey, pending: pending);
      } on FormatException catch (e) {
        errors.add('Rejected paymail ${entry.key}: ${e.message}');
      }
      if (walletChange != _walletChange) {
        return [];
      }
    }
    notifyListeners();
    return errors;
  }

  Future<void> _processPaymailEntry(
    MapEntry<String, dynamic> entry,
    BitnameEntry identity,
    String myEncryptionPubkey, {
    required bool pending,
  }) async {
    final walletChange = _walletChange;
    final outpointKey = entry.key;
    final data = entry.value as Map<String, dynamic>;
    final seen = _messages.indexWhere((m) => m.txid == outpointKey || m.id == outpointKey);
    if (seen >= 0) {
      if (!pending && _messages[seen].isPending) {
        _messages[seen] = _messages[seen].copyWith(isPending: false);
        await _saveMessages();
      }
      return;
    }

    final memo = data['memo'];
    final String ciphertext;
    if (memo is String) {
      ciphertext = memo;
    } else if (memo is List) {
      ciphertext = memo.map((b) => (b as int).toRadixString(16).padLeft(2, '0')).join();
    } else {
      throw const FormatException('Invalid paymail memo');
    }
    if (ciphertext.isEmpty) {
      return;
    }

    final String plaintext;
    try {
      plaintext = await bitnamesRPC.decryptMsg(ciphertext: ciphertext, encryptionPubkey: myEncryptionPubkey);
    } catch (_) {
      return;
    }
    if (walletChange != _walletChange) {
      return;
    }

    final memoMessage = BitnamesMessage.decode(plaintext);
    if (memoMessage != null && memoMessage.recipient != identity.hash) {
      return;
    }
    final recipientAddress = await bitnamesRPC.getBitNameOwner(identity.hash);
    if (walletChange != _walletChange) {
      return;
    }
    if (data['address'] != recipientAddress) {
      if (memoMessage == null) {
        return;
      }
      throw const FormatException('The payment address does not match the recipient BitName owner');
    }
    final String messageId;
    final ChatContact contact;
    if (memoMessage == null) {
      messageId = outpointKey;
      contact = ChatContact(id: 'unknown', name: 'Unknown sender', encryptionPubkey: '', address: 'unknown');
    } else {
      final owner = await memoMessage.checkSender(bitnamesRPC, identity.hash);
      final sender = await bitnamesRPC.getBitNameData(memoMessage.sender);
      if (walletChange != _walletChange) {
        return;
      }
      if (sender?.encryptionPubkey == null) {
        throw const FormatException('The sender BitName has no encryption key');
      }
      messageId = memoMessage.storeId;
      final duplicate = _messages.indexWhere((m) => m.id == messageId);
      if (duplicate >= 0) {
        if (!pending && _messages[duplicate].isPending) {
          _messages[duplicate] = _messages[duplicate].copyWith(isPending: false, txid: outpointKey);
          await _saveMessages();
        }
        return;
      }
      final oldContact = _contacts.firstWhereOrNull((c) => c.id == memoMessage.sender);
      contact = ChatContact(
        id: memoMessage.sender,
        name: memoMessage.sender,
        plaintextName:
            oldContact?.plaintextName ??
            _allBitNames.firstWhereOrNull((b) => b.hash == memoMessage.sender)?.plaintextName,
        encryptionPubkey: sender!.encryptionPubkey!,
        address: owner,
        paymailFeeSats: sender.paymailFeeSats,
        isManual: oldContact?.isManual ?? false,
      );
    }

    final content = data['content'] as Map<String, dynamic>;
    final message = ChatMessage(
      id: messageId,
      content: memoMessage?.text ?? plaintext,
      senderPubkey: memoMessage == null ? contact.address : contact.encryptionPubkey,
      recipientPubkey: myEncryptionPubkey,
      senderBitname: memoMessage?.sender,
      recipientBitname: identity.hash,
      timestamp: DateTime.now(),
      isOutgoing: false,
      txid: outpointKey,
      valueSats: content['BitcoinSats'] as int?,
      isPending: pending,
      read: _selectedContact?.id == contact.id && _selectedIdentity?.hash == identity.hash,
    );
    _messages.add(message);
    await _saveMessages();
    if (walletChange != _walletChange) {
      return;
    }
    await addContact(contact);
    if (walletChange != _walletChange) {
      return;
    }
    if (_selectedContact?.id == contact.id) {
      _selectedContact = contact;
    }
  }

  Future<String?> sendMessage(String content) async {
    final walletChange = _walletChange;
    final identity = _selectedIdentity;
    final selectedContact = _selectedContact;
    if (selectedContact == null || identity == null) {
      _error = 'No contact or identity selected';
      notifyListeners();
      return null;
    }
    final quotedPostage = selectedContact.paymailFeeSats ?? defaultPostageSats;

    final senderKey = identity.details.encryptionPubkey;
    if (senderKey == null) {
      _error = 'The selected identity has no encryption key';
      notifyListeners();
      return null;
    }

    if (selectedContact.encryptionPubkey.isEmpty) {
      _error = 'This message has no known sender BitName. Add the sender by BitName before a reply.';
      notifyListeners();
      return null;
    }

    _isSending = true;
    _error = null;
    notifyListeners();

    String? txid;
    try {
      final recipientHash = BitnamesMessage.nameHash(selectedContact.id);
      final recipient = await bitnamesRPC.getBitNameData(recipientHash);
      if (walletChange != _walletChange) {
        return null;
      }
      if (recipient?.encryptionPubkey == null) {
        throw const FormatException('The recipient BitName has no encryption key');
      }
      final value = recipient!.paymailFeeSats;
      if (value == null) {
        throw const FormatException('The recipient BitName has no inbox');
      }
      if (value > quotedPostage) {
        final contact = selectedContact.copyWith(paymailFeeSats: value);
        if (_selectedContact?.id == contact.id) {
          _selectedContact = contact;
        }
        await addContact(contact);
        if (walletChange == _walletChange) {
          _error = 'The postage increased to $value sats. Select Send again to accept the new cost.';
        }
        return null;
      }
      final address = await bitnamesRPC.getBitNameOwner(recipientHash);
      final memoMessage = await BitnamesMessage.sign(
        rpc: bitnamesRPC,
        sender: identity.hash,
        recipient: recipientHash,
        text: content,
      );
      final ciphertext = await bitnamesRPC.encryptMsg(
        msg: memoMessage.encode(),
        encryptionPubkey: recipient.encryptionPubkey!,
      );
      if (walletChange != _walletChange) {
        return null;
      }
      txid = await bitnamesRPC.transfer(
        dest: address,
        value: value,
        fee: networkFeeSats,
        memo: ciphertext,
      );
      if (walletChange != _walletChange) {
        return _reportLateSend(txid);
      }

      final message = ChatMessage(
        id: memoMessage.storeId,
        content: content,
        senderPubkey: senderKey,
        recipientPubkey: recipient.encryptionPubkey!,
        senderBitname: identity.hash,
        recipientBitname: recipientHash,
        timestamp: DateTime.now(),
        isOutgoing: true,
        txid: txid,
        valueSats: value,
        isPending: true,
      );
      _messages.add(message);
      await _saveMessages();
      if (walletChange != _walletChange) {
        return _reportLateSend(txid);
      }

      final contactIndex = _contacts.indexWhere((c) => c.id == selectedContact.id);
      if (contactIndex >= 0) {
        final contact = _contacts[contactIndex].copyWith(
          encryptionPubkey: recipient.encryptionPubkey,
          address: address,
          paymailFeeSats: value,
        );
        _contacts[contactIndex] = contact;
        if (_selectedContact?.id == selectedContact.id) {
          _selectedContact = contact;
        }
        await _saveContacts();
      }
      if (walletChange != _walletChange) {
        return _reportLateSend(txid);
      }

      notifyListeners();
      return txid;
    } catch (e) {
      if (walletChange != _walletChange) {
        return txid == null ? null : _reportLateSend(txid);
      }
      _error = 'Could not send the message: $e';
      notifyListeners();
      return null;
    } finally {
      if (walletChange == _walletChange) {
        _isSending = false;
        notifyListeners();
      }
    }
  }

  String _reportLateSend(String txid) {
    _error = 'The node accepted the message. The wallet change stopped the local history save.';
    notifyListeners();
    return txid;
  }

  Future<void> _dropEvictedPending(Set<String> stillPending, BitnameEntry identity) async {
    final before = _messages.length;
    _messages.removeWhere(
      (m) =>
          m.isPending &&
          !m.isOutgoing &&
          (m.recipientBitname != null
              ? m.recipientBitname == identity.hash
              : m.recipientPubkey == identity.details.encryptionPubkey) &&
          !stillPending.contains(m.txid ?? m.id),
    );
    if (_messages.length != before) {
      await _saveMessages();
      notifyListeners();
    }
  }

  Future<void> _settleOutgoing(Set<String> mempoolTxids) async {
    var changed = false;
    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (!message.isOutgoing || !message.isPending) {
        continue;
      }
      if (message.txid != null && mempoolTxids.contains(message.txid)) {
        continue;
      }
      _messages[i] = message.copyWith(isPending: false);
      changed = true;
    }
    if (changed) {
      await _saveMessages();
      notifyListeners();
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      fetchPaymail();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<ChatContact?> lookupBitName(String nameOrHash) async {
    if (!bitnamesRPC.connected) {
      return null;
    }

    try {
      final hash = BitnamesMessage.nameHash(nameOrHash);
      final data = await bitnamesRPC.getBitNameData(hash);
      if (data == null || data.encryptionPubkey == null) {
        return null;
      }

      // A message pays the holder of the BitName, so the contact carries the
      // holder's address. A fresh address of this wallet pays nobody.
      final address = await bitnamesRPC.getBitNameOwner(hash);

      return ChatContact(
        id: hash,
        name: hash,
        plaintextName: nameOrHash,
        encryptionPubkey: data.encryptionPubkey!,
        address: address,
        paymailFeeSats: data.paymailFeeSats,
        isManual: true,
      );
    } catch (e) {
      _error = 'Failed to lookup BitName: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _walletReader?.removeListener(_onWalletChanged);
    bitnamesRPC.removeListener(_onConnectionChanged);
    balanceProvider.removeListener(_onBalanceChanged);
    _pollTimer?.cancel();
    super.dispose();
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
    return jsonEncode(
      value
          .map(
            (contact) => contact.toJson()
              ..remove('last_message')
              ..remove('last_message_time'),
          )
          .toList(),
    );
  }

  @override
  List<ChatContact>? fromJson(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map(
            (e) => ChatContact.fromJson(
              (e as Map<String, dynamic>)
                ..remove('last_message')
                ..remove('last_message_time'),
            ),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  SettingValue<List<ChatContact>> withValue([List<ChatContact>? value]) {
    return ChatContactsSetting(newValue: value);
  }
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
