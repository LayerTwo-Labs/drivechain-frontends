import 'dart:async';
import 'dart:convert';

import 'package:bitwindow/models/chat_models.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thirds/blake3.dart';

class ChatProvider extends ChangeNotifier {
  BitnamesRPC get bitnamesRPC => GetIt.I.get<BitnamesRPC>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  final ClientSettings _clientSettings = GetIt.I.get<ClientSettings>();

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
  List<ChatContact> get contacts => _contacts;

  ChatContact? _selectedContact;
  ChatContact? get selectedContact => _selectedContact;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  List<ChatMessage> get currentConversation {
    if (_selectedContact == null || _selectedIdentity == null) return [];
    return _messages.where((m) {
      final isWithContact =
          m.senderPubkey == _selectedContact!.encryptionPubkey ||
          m.recipientPubkey == _selectedContact!.encryptionPubkey;
      final isFromMyIdentity =
          m.senderPubkey == _selectedIdentity!.details.encryptionPubkey ||
          m.recipientPubkey == _selectedIdentity!.details.encryptionPubkey;
      return isWithContact && isFromMyIdentity;
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSending = false;
  bool get isSending => _isSending;

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 30);

  ChatProvider() {
    bitnamesRPC.addListener(_onConnectionChanged);
    balanceProvider.addListener(_onBalanceChanged);
    _init();
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
    if (!bitnamesRPC.connected) return;
    await Future.wait([
      fetchIdentities(),
      _loadContacts(),
    ]);
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

      // Select first owned identity if none selected
      if (_selectedIdentity == null && _myIdentities.isNotEmpty) {
        _selectedIdentity = _myIdentities.first;
      }
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
            BitNameData(
              encryptionPubkey: encryptionPubkey,
              paymailFeeSats: 1000,
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
    try {
      final setting = ChatContactsSetting();
      final loaded = await _clientSettings.getValue(setting);
      _contacts = loaded.value;
      notifyListeners();
    } catch (e) {
      _contacts = [];
    }
  }

  Future<void> _saveContacts() async {
    final setting = ChatContactsSetting(newValue: _contacts);
    await _clientSettings.setValue(setting);
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

    // Get an address for sending to this contact
    final address = await bitnamesRPC.getNewAddress();

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
  }

  Future<void> fetchPaymail() async {
    if (!bitnamesRPC.connected || _selectedIdentity == null) return;

    try {
      final paymail = await bitnamesRPC.getPaymail();
      await _processPaymail(paymail);
    } catch (e) {
      _error = 'Failed to fetch paymail: $e';
      notifyListeners();
    }
  }

  Future<void> _processPaymail(Map<String, dynamic> paymail) async {
    // Process incoming paymail messages
    // Structure depends on actual API response - this is a placeholder
    // that will need to be updated based on actual paymail format
    if (paymail.isEmpty) return;

    // TODO: Parse paymail response and decrypt messages
    // For each message in paymail:
    // 1. Decrypt using our encryption key
    // 2. Add to messages list
    // 3. Auto-add sender to contacts if not already present

    notifyListeners();
  }

  Future<String?> sendMessage(String content) async {
    if (_selectedContact == null || _selectedIdentity == null) {
      _error = 'No contact or identity selected';
      notifyListeners();
      return null;
    }

    if (_selectedIdentity!.details.encryptionPubkey == null) {
      _error = 'Selected identity has no encryption key';
      notifyListeners();
      return null;
    }

    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Encrypt the message with recipient's pubkey
      final ciphertext = await bitnamesRPC.encryptMsg(
        msg: content,
        encryptionPubkey: _selectedContact!.encryptionPubkey,
      );

      // 2. Send as transfer with memo
      final txid = await bitnamesRPC.transfer(
        dest: _selectedContact!.address,
        value: _selectedContact!.paymailFeeSats ?? 1000,
        fee: 100,
        memo: ciphertext,
      );

      // 3. Add to local message list
      final message = ChatMessage(
        id: txid,
        content: content,
        senderPubkey: _selectedIdentity!.details.encryptionPubkey!,
        recipientPubkey: _selectedContact!.encryptionPubkey,
        timestamp: DateTime.now(),
        isOutgoing: true,
        txid: txid,
        valueSats: _selectedContact!.paymailFeeSats ?? 1000,
      );
      _messages.add(message);

      // 4. Update contact's last message
      final contactIndex = _contacts.indexWhere((c) => c.id == _selectedContact!.id);
      if (contactIndex >= 0) {
        _contacts[contactIndex] = _contacts[contactIndex].copyWith(
          lastMessage: content,
          lastMessageTime: DateTime.now(),
        );
        await _saveContacts();
      }

      notifyListeners();
      return txid;
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
      return null;
    } finally {
      _isSending = false;
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
    if (!bitnamesRPC.connected) return null;

    try {
      final data = await bitnamesRPC.getBitNameData(nameOrHash);
      if (data == null || data.encryptionPubkey == null) return null;

      // Get an address for this identity
      final address = await bitnamesRPC.getNewAddress();

      return ChatContact(
        id: nameOrHash,
        name: nameOrHash,
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
