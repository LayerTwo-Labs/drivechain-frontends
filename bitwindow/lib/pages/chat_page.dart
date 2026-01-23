import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thirds/blake3.dart';

@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<ChatViewModel>.reactive(
        viewModelBuilder: () => ChatViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) {
          if (!model.isConnected) {
            return _buildDisconnectedView(context);
          }

          return Column(
            children: [
              _buildIdentitySelector(context, model),
              const SizedBox(height: SailStyleValues.padding08),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: _buildContactList(context, model),
                    ),
                    const SizedBox(width: SailStyleValues.padding08),
                    Expanded(
                      child: _buildChatPanel(context, model),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDisconnectedView(BuildContext context) {
    final theme = SailTheme.of(context);
    return Center(
      child: SailCard(
        title: 'BitNames Required',
        subtitle: 'Chat requires BitNames sidechain to be running',
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SailSVG.fromAsset(
                SailSVGAsset.iconWarning,
                color: theme.colors.textSecondary,
                height: 48,
              ),
              const SizedBox(height: SailStyleValues.padding16),
              SailText.primary15(
                'BitNames sidechain is not connected',
                bold: true,
              ),
              const SizedBox(height: SailStyleValues.padding08),
              SailText.secondary13(
                'To use the Chat feature, you need to:\n'
                '1. Go to the Sidechains tab\n'
                '2. Download and start BitNames\n'
                '3. Register at least one BitName identity',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySelector(BuildContext context, ChatViewModel model) {
    return SailCard(
      padding: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding16,
          vertical: SailStyleValues.padding08,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status bars - stack all status messages
            ...model.statusMessages.map(
              (status) => _ClaimingStatusBar(status: status.message),
            ),
            // Main action bar
            Row(
              children: [
                SailText.secondary13('Chatting as:'),
                const SizedBox(width: SailStyleValues.padding12),
                if (model.myIdentities.isNotEmpty)
                  _SearchableIdentityDropdown(
                    identities: model.myIdentities,
                    allBitNames: model.allBitNames,
                    selectedIdentity: model.selectedIdentity,
                    onIdentitySelected: model.selectIdentity,
                  )
                else
                  SailText.secondary13('No BitNames owned'),
                const SizedBox(width: SailStyleValues.padding12),
                if (model.hasSufficientBalance)
                  Tooltip(
                    message: 'Registering a BitName costs sats on the BitNames sidechain',
                    child: SailButton(
                      label: 'Register BitName',
                      variant: ButtonVariant.secondary,
                      disabled: model.isClaiming,
                      onPressed: () async => _showRegisterBitNameDialog(context, model),
                      skipLoading: true,
                    ),
                  )
                else if (GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains)
                  Tooltip(
                    message: 'You need BitNames sidechain balance to register a BitName',
                    child: SailButton(
                      label: 'Deposit to BitNames',
                      variant: ButtonVariant.primary,
                      onPressed: () async => showDepositModal(context, BitNames().slot, 'BitNames'),
                    ),
                  ),
                const Spacer(),
                SailButton(
                  label: 'Add Contact',
                  variant: ButtonVariant.secondary,
                  onPressed: () async => _showAddContactDialog(context, model),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(BuildContext context, ChatViewModel model) {
    final theme = SailTheme.of(context);

    return SailCard(
      title: 'Contacts',
      bottomPadding: false,
      child: model.contacts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(SailStyleValues.padding20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailText.secondary13('No contacts yet'),
                    const SizedBox(height: SailStyleValues.padding08),
                    SailText.secondary12(
                      'Add a contact to start chatting',
                      color: theme.colors.textTertiary,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: model.contacts.length,
              itemBuilder: (context, index) {
                final contact = model.contacts[index];
                final isSelected = model.selectedContact?.id == contact.id;

                return InkWell(
                  onTap: () => model.selectContact(contact),
                  child: Container(
                    padding: const EdgeInsets.all(SailStyleValues.padding12),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colors.primary.withAlpha(30) : null,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colors.divider,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildAvatar(context, contact),
                        const SizedBox(width: SailStyleValues.padding12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.primary13(
                                contact.displayName,
                                bold: true,
                              ),
                              if (contact.lastMessage != null)
                                SailText.secondary12(
                                  contact.lastMessage!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (contact.lastMessageTime != null)
                          SailText.secondary12(
                            _formatTime(contact.lastMessageTime!),
                            color: theme.colors.textTertiary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChatPanel(BuildContext context, ChatViewModel model) {
    final theme = SailTheme.of(context);

    if (model.selectedContact == null) {
      return SailCard(
        bottomPadding: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SailSVG.fromAsset(
                SailSVGAsset.messageCircle,
                color: theme.colors.textTertiary,
                height: 64,
              ),
              const SizedBox(height: SailStyleValues.padding16),
              SailText.secondary13('Select a contact to start chatting'),
            ],
          ),
        ),
      );
    }

    return SailCard(
      title: model.selectedContact!.displayName,
      subtitle: 'Paymail fee: ${model.selectedContact!.paymailFeeSats ?? 1000} sats per message',
      bottomPadding: false,
      child: Column(
        children: [
          Expanded(
            child: _buildMessageList(context, model),
          ),
          const SizedBox(height: SailStyleValues.padding08),
          _buildMessageInput(context, model),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, ChatViewModel model) {
    final theme = SailTheme.of(context);
    final messages = model.currentConversation;

    if (messages.isEmpty) {
      return Center(
        child: SailText.secondary13(
          'No messages yet. Say hello!',
          color: theme.colors.textTertiary,
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(SailStyleValues.padding08),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final theme = SailTheme.of(context);
    final isOwn = message.isOutgoing;

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(vertical: SailStyleValues.padding04),
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        decoration: BoxDecoration(
          color: isOwn ? theme.colors.primary.withAlpha(30) : theme.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOwn ? theme.colors.primary.withAlpha(50) : theme.colors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary13(message.content),
            const SizedBox(height: SailStyleValues.padding04),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.secondary12(
                  _formatMessageTime(message.timestamp),
                  color: theme.colors.textTertiary,
                ),
                if (message.valueSats != null) ...[
                  const SizedBox(width: SailStyleValues.padding08),
                  SailText.secondary12(
                    '${message.valueSats} sats',
                    color: theme.colors.textTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatViewModel model) {
    return Row(
      children: [
        Expanded(
          child: SailTextField(
            controller: model.messageController,
            hintText: 'Type a message...',
            maxLines: 3,
            minLines: 1,
            onSubmitted: (_) => model.sendMessage(),
          ),
        ),
        const SizedBox(width: SailStyleValues.padding08),
        SailButton(
          label: 'Send',
          loading: model.isSending,
          disabled: model.messageController.text.isEmpty,
          onPressed: model.sendMessage,
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, ChatContact contact) {
    final theme = SailTheme.of(context);
    final initials = contact.displayName.isNotEmpty ? contact.displayName.substring(0, 1).toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colors.primary.withAlpha(50),
      ),
      child: Center(
        child: SailText.primary13(initials, bold: true),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'now';
  }

  String _formatMessageTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showAddContactDialog(BuildContext context, ChatViewModel model) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _AddContactDialog(model: model),
    );
  }

  Future<void> _showRegisterBitNameDialog(BuildContext context, ChatViewModel model) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RegisterBitNameDialog(model: model),
    );
  }
}

class _ClaimingStatusBar extends StatelessWidget {
  final String status;

  const _ClaimingStatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding08,
      ),
      margin: const EdgeInsets.only(bottom: SailStyleValues.padding08),
      decoration: BoxDecoration(
        color: theme.colors.primary.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colors.primary,
            ),
          ),
          const SizedBox(width: SailStyleValues.padding12),
          Expanded(
            child: SailText.primary13(status),
          ),
        ],
      ),
    );
  }
}

class _AddContactDialog extends StatefulWidget {
  final ChatViewModel model;

  const _AddContactDialog({required this.model});

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final searchController = TextEditingController();
  BitnameEntry? selectedBitName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final match = _findMatchingBitName();
    if (match != null && match.hash != selectedBitName?.hash) {
      // New match found - save the mapping forever!
      final query = searchController.text.trim();
      widget.model.saveNameMapping(query);
    }
    setState(() {
      selectedBitName = match;
    });
  }

  BitnameEntry? _findMatchingBitName() {
    final query = searchController.text.trim();
    if (query.isEmpty) return null;

    // Compute Blake3 hash of the search text
    final searchHash = blake3Hex(utf8.encode(query.toLowerCase()));

    // Find BitName with matching hash
    return widget.model.allBitNames.where((entry) {
      return entry.hash.toLowerCase() == searchHash.toLowerCase();
    }).firstOrNull;
  }

  List<BitnameEntry> get filteredBitNames {
    final query = searchController.text.toLowerCase().trim();
    if (query.isEmpty) return widget.model.allBitNames;

    // Compute Blake3 hash of the search text
    String? searchHash;
    try {
      searchHash = blake3Hex(utf8.encode(query));
    } catch (e) {
      searchHash = null;
    }

    return widget.model.allBitNames.where((entry) {
      // Exact hash match from plaintext search
      if (searchHash != null && entry.hash.toLowerCase() == searchHash.toLowerCase()) {
        return true;
      }
      // Plaintext name match (if already decrypted)
      if (entry.plaintextName?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      // Hash prefix match
      if (entry.hash.toLowerCase().contains(query)) {
        return true;
      }
      return false;
    }).toList();
  }

  Future<void> _addContact(BitnameEntry entry) async {
    // Check if BitName has encryption pubkey (required for chat)
    if (entry.details.encryptionPubkey == null) {
      showSnackBar(context, 'This BitName has no encryption key set - cannot chat');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create contact directly from entry data (no need to lookup again)
      await widget.model.addContactFromEntry(entry);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final filtered = filteredBitNames;

    return AlertDialog(
      backgroundColor: theme.colors.background,
      title: SailText.primary15('Add Contact', bold: true),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Search for a BitName by typing its plaintext name'),
            const SizedBox(height: SailStyleValues.padding12),
            SailTextField(
              controller: searchController,
              hintText: 'Type a name to find its hash...',
            ),
            const SizedBox(height: SailStyleValues.padding12),
            if (selectedBitName != null)
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  color: theme.colors.success.withValues(alpha: 0.1),
                  borderRadius: SailStyleValues.borderRadius,
                  border: Border.all(color: theme.colors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.check, color: theme.colors.success, height: 16),
                    const SizedBox(width: SailStyleValues.padding08),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.primary13('Match found: "${searchController.text.trim()}"', bold: true),
                          SailText.secondary12('${selectedBitName!.hash.substring(0, 24)}...'),
                        ],
                      ),
                    ),
                    SailButton(
                      label: 'Add',
                      loading: isLoading,
                      onPressed: () async => _addContact(selectedBitName!),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: SailStyleValues.padding12),
            SailText.secondary12('${filtered.length} BitNames'),
            const SizedBox(height: SailStyleValues.padding08),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colors.divider),
                  borderRadius: SailStyleValues.borderRadius,
                ),
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    final isMatch = selectedBitName?.hash == entry.hash;
                    return InkWell(
                      onTap: () => _addContact(entry),
                      child: Container(
                        padding: const EdgeInsets.all(SailStyleValues.padding12),
                        decoration: BoxDecoration(
                          color: isMatch ? theme.colors.success.withValues(alpha: 0.1) : null,
                          border: Border(
                            bottom: BorderSide(color: theme.colors.divider, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (entry.plaintextName != null)
                                    SailText.primary13(entry.plaintextName!, bold: true)
                                  else
                                    SailText.secondary13('(encrypted)'),
                                  SailText.secondary12(
                                    '${entry.hash.substring(0, 32)}...',
                                    color: theme.colors.textTertiary,
                                  ),
                                ],
                              ),
                            ),
                            if (isMatch) SailSVG.fromAsset(SailSVGAsset.check, color: theme.colors.success, height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _RegisterBitNameDialog extends StatefulWidget {
  final ChatViewModel model;

  const _RegisterBitNameDialog({required this.model});

  @override
  State<_RegisterBitNameDialog> createState() => _RegisterBitNameDialogState();
}

class _RegisterBitNameDialogState extends State<_RegisterBitNameDialog> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return AlertDialog(
      backgroundColor: theme.colors.background,
      title: SailText.primary15('Register BitName', bold: true),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.secondary13('Enter a name to register as your identity'),
            const SizedBox(height: SailStyleValues.padding12),
            SailTextField(
              controller: controller,
              hintText: 'e.g., alice',
              label: 'BitName',
            ),
            const SizedBox(height: SailStyleValues.padding08),
            SailText.secondary12(
              'This will reserve and register the name on the BitNames sidechain.',
              color: theme.colors.textTertiary,
            ),
          ],
        ),
      ),
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(),
        ),
        SailButton(
          label: 'Register',
          disabled: controller.text.isEmpty,
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              final name = controller.text;
              // Close dialog immediately - progress shows in main status bar
              Navigator.of(context).pop();
              // Start claiming in background (fire and forget)
              unawaited(widget.model.claimIdentity(name));
            }
          },
        ),
      ],
    );
  }
}

class ChatViewModel extends BaseViewModel {
  final ChatProvider _chatProvider = GetIt.I.get<ChatProvider>();
  final BitnamesRPC _bitnamesRPC = GetIt.I.get<BitnamesRPC>();
  final TextEditingController messageController = TextEditingController();

  bool get isConnected => _bitnamesRPC.connected;

  List<BitnameEntry> get myIdentities => _chatProvider.myIdentities;
  List<BitnameEntry> get allBitNames => _chatProvider.allBitNames;
  BitnameEntry? get selectedIdentity => _chatProvider.selectedIdentity;
  bool get hasSufficientBalance => _chatProvider.hasSufficientBalance;

  List<ChatContact> get contacts => _chatProvider.contacts;
  ChatContact? get selectedContact => _chatProvider.selectedContact;

  List<ChatMessage> get currentConversation => _chatProvider.currentConversation;

  bool get isSending => _chatProvider.isSending;
  String? get chatError => _chatProvider.error;

  bool get isClaiming => _chatProvider.isClaiming;
  String? get claimingStatus => _chatProvider.claimingStatus;
  List<StatusMessage> get statusMessages => _chatProvider.statusMessages;

  ChatViewModel() {
    _chatProvider.addListener(_onProviderChanged);
    _bitnamesRPC.addListener(_onConnectionChanged);
    messageController.addListener(notifyListeners);
  }

  void init() {
    if (isConnected) {
      _chatProvider.startPolling();
    }
  }

  void _onProviderChanged() {
    notifyListeners();
  }

  void _onConnectionChanged() {
    if (isConnected) {
      _chatProvider.startPolling();
    } else {
      _chatProvider.stopPolling();
    }
    notifyListeners();
  }

  void selectIdentity(BitnameEntry identity) {
    _chatProvider.selectIdentity(identity);
  }

  Future<String?> claimIdentity(String name) async {
    return await _chatProvider.claimIdentity(name);
  }

  Future<void> saveNameMapping(String plaintextName) async {
    await _chatProvider.saveNameMapping(plaintextName);
  }

  Future<void> addContactFromEntry(BitnameEntry entry) async {
    await _chatProvider.addContactFromEntry(entry);
  }

  void selectContact(ChatContact contact) {
    _chatProvider.selectContact(contact);
  }

  Future<ChatContact?> lookupAndAddContact(String nameOrHash) async {
    setBusy(true);
    try {
      final contact = await _chatProvider.lookupBitName(nameOrHash);
      if (contact != null) {
        await _chatProvider.addContact(contact);
      }
      return contact;
    } finally {
      setBusy(false);
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) return;

    final content = messageController.text;
    messageController.clear();

    final txid = await _chatProvider.sendMessage(content);
    if (txid == null && _chatProvider.error != null) {
      // Message failed, restore text
      messageController.text = content;
    }
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onProviderChanged);
    _bitnamesRPC.removeListener(_onConnectionChanged);
    _chatProvider.stopPolling();
    messageController.dispose();
    super.dispose();
  }
}

/// Searchable dropdown for selecting a BitName identity.
/// Supports searching by plaintext name (uses Blake3 hash matching)
/// or by hash prefix.
class _SearchableIdentityDropdown extends StatefulWidget {
  final List<BitnameEntry> identities;
  final List<BitnameEntry> allBitNames;
  final BitnameEntry? selectedIdentity;
  final ValueChanged<BitnameEntry> onIdentitySelected;

  const _SearchableIdentityDropdown({
    required this.identities,
    required this.allBitNames,
    required this.selectedIdentity,
    required this.onIdentitySelected,
  });

  @override
  State<_SearchableIdentityDropdown> createState() => _SearchableIdentityDropdownState();
}

class _SearchableIdentityDropdownState extends State<_SearchableIdentityDropdown> {
  late MenuController _menuController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _menuController = MenuController();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<BitnameEntry> get filteredIdentities {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return widget.identities;

    // Try to compute Blake3 hash of the search query
    String? searchHash;
    try {
      searchHash = blake3Hex(utf8.encode(query));
    } catch (e) {
      searchHash = null;
    }

    return widget.identities.where((entry) {
      // Check if search hash matches entry hash
      if (searchHash != null && entry.hash.toLowerCase() == searchHash.toLowerCase()) {
        return true;
      }
      // Check plaintext name match
      if (entry.plaintextName?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      // Check hash prefix match
      if (entry.hash.toLowerCase().contains(query)) {
        return true;
      }
      return false;
    }).toList();
  }

  String _getDisplayName(BitnameEntry entry) {
    return entry.plaintextName ?? '${entry.hash.substring(0, 8)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Display the currently selected identity
    final selectedDisplay = widget.selectedIdentity != null
        ? _getDisplayName(widget.selectedIdentity!)
        : 'Select identity';

    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          if (_menuController.isOpen) {
            _menuController.close();
          } else {
            _menuController.open();
            _searchController.clear();
            _focusNode.requestFocus();
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.border, width: 1),
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.primary13(selectedDisplay),
                SailSVG.fromAsset(
                  _menuController.isOpen ? SailSVGAsset.chevronUp : SailSVGAsset.chevronDown,
                  color: theme.colors.text,
                  width: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.colors.background),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      builder: (context, controller, child) => button,
      menuChildren: [
        // Search field at the top
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SailSVG.fromAsset(SailSVGAsset.search, height: 13, color: theme.colors.textSecondary),
              const SizedBox(width: 8),
              SizedBox(
                width: 200,
                child: TextField(
                  cursorColor: theme.colors.primary,
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search by name or hash...',
                    hintStyle: SailStyleValues.thirteen.copyWith(color: theme.colors.textSecondary, fontSize: 13),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  style: SailStyleValues.thirteen.copyWith(color: theme.colors.text, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Identity list
        if (filteredIdentities.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SailText.secondary13('No matching identities found'),
          )
        else
          SelectionContainer.disabled(
            child: SailMenu(
              items: filteredIdentities.map((entry) {
                final isSelected = widget.selectedIdentity?.hash == entry.hash;
                return SailMenuItem(
                  onSelected: () {
                    widget.onIdentitySelected(entry);
                    _menuController.close();
                  },
                  child: SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      if (isSelected)
                        SailSVG.fromAsset(SailSVGAsset.check, color: theme.colors.text, height: 8)
                      else
                        const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary13(_getDisplayName(entry)),
                            SailText.secondary12(
                              '${entry.hash.substring(0, 16)}...',
                              color: theme.colors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
